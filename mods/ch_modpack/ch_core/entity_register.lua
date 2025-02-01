ch_core.open_submod("entity_register", {lib = true})

local ifthenelse = ch_core.ifthenelse

local count = 0 -- aktuální počet zaregistrovaných entit
local next_gc_count = 16 -- počet, při jehož dosažení se spustí pročištění
local entities = {} -- mapa registrovaných entit: handle => entita
local name_index = {
    ["__builtin:item"] = {},
} -- mapa entity_name => {handle => object} (indexování __builtin:item je zapnuto předem)
local handle_generator = PcgRandom(os.time())

local function remove_registered_entity(handle)
    local entity = entities[handle]
    if entity == nil then
        return false
    end
    local name = assert(entity.name)
    local index = name_index[name]
    if index ~= nil then
        index[handle] = nil
    end
    entities[handle] = nil
    entity._ch_entity_handle = nil
    count = count - 1
    return true
end

local function add_entity_to_register(handle, entity)
    local object = entity.object
    if not object:is_valid() or entities[handle] ~= nil then
        return false
    end
    entities[handle] = entity
    local index = name_index[entity.name]
    if index ~= nil then
        index[handle] = object
    end
    count = count + 1
    entity._ch_entity_handle = handle
end

--[[
    Projde zaregistrované entity a odstraní ty, jejichž objekty již vypršely.
    Vrací:
        gc_count (int) [počet odstraněných entit],
        result (table) [tabulka odstraněných entit (mapa handle => entita), velikost odpovídá gc_count],
        remains_count (int) [počet zbylých (platných) registrovaných entit]
]]
function ch_core.collect_invalid_entities()
    local result = {}
    local gc_count = 0
    for handle, entity in pairs(entities) do
        local o = entity.object
        if o == nil or not o:is_valid() then
            gc_count = gc_count + 1
            result[handle] = entity
        end
    end
    if gc_count > 0 then
        for handle, _ in pairs(result) do
            remove_registered_entity(handle)
        end
        next_gc_count = 2 * count
    end
    return gc_count, result, count
end

--[[
    Vypne indexování entit zadaného jména
]]
function ch_core.disable_entity_name_index(name)
    name_index[name] = nil
end

--[[
    Zapne indexování entit zadaného jména
]]
function ch_core.enable_entity_name_index(name)
    if name_index[name] == nil then
        local new_index = {}
        for handle, entity in pairs(entities) do
            if entity.name == name and entity.object:is_valid() then
                new_index[handle] = entity.object
            end
        end
        name_index[name] = new_index
    end
end

--[[
    Vrátí seznam handles pro entity daného typu v zadané oblasti.
    Aby fungovala, musí být zapnutý entity_name_index pro daný typ entit.
    Parametry:
    * pos (vector),
    * radius (float),
    * name (string),
    * return_type (enum: handle|entity|object or nil) [co vrátit v seznamu; nil znamená handle]
    * handle_to_ignore (int32 or nil) [je-li nastaveno, entita se zadaným handle se do výstupního seznamu nezahrne]
    Vrací:
    a) seznam nalezených entit (typ prvků je určený parametrem return_type)
    b) nil (pokud není zapnuto indexování entit daného typu)
]]
function ch_core.find_handles_in_radius(pos, radius, name, return_type, handle_to_ignore)
    local result = {}
    local index = name_index[name]
    if index == nil then
        return nil
    end
    if handle_to_ignore == nil then
        handle_to_ignore = 0
    end
    for handle, object in pairs(index) do
        if handle ~= handle_to_ignore then
            local opos = object:get_pos() -- get_pos() může vrátit nil pro vypršené objekty
            if opos ~= nil and vector.distance(pos, opos) <= radius then
                if return_type == nil or return_type == "handle" then
                    table.insert(result, handle)
                elseif return_type == "entity" then
                    table.insert(result, entities[handle])
                else
                    table.insert(result, object)
                end
            end
        end
    end
    return result
end

--[[
    Vrátí počet zaregistrovaných entit bez ohledu na to, zda mají platné objekty.
    Vrací:
        count (int)
]]
function ch_core.get_count_of_registered_entities()
    return count
end

--[[
    Vrací handle pro danou (platnou) entitu.
    Pokud je parametr nil, nebo jde o entitu, jejíž objekt již vypršel, vrací nil.
    Jde-li o entitu s platným objektem, ale dosud neregistrovanou, zaregistruje ji a vrátí nové handle.
    Vrací:
        handle (int32 or nil)
]]
function ch_core.get_handle_of_entity(lua_entity)
    if lua_entity == nil then
        return nil
    elseif type(lua_entity) == "table" then
        local handle = lua_entity._ch_entity_handle
        local is_valid = lua_entity.object:is_valid()
        if type(handle) == "number" and entities[handle] ~= nil then
            -- already has a handle
            if is_valid then
                return handle
            else
                -- object already expired!
                remove_registered_entity(handle)
                return nil
            end
        elseif not is_valid then
            -- invalid object
            return nil
        end
        local message
        handle, message = ch_core.register_entity(lua_entity)
        if message ~= nil then
            core.log(ifthenelse(handle == nil, "error", "warning"), "ch_core.get_handle_of_entity(): "..message)
        end
        return handle
    else
        error("ch_core.get_handle_of_entity() called with an invalid argument: "..dump2({type = type(lua_entity), value = lua_entity}))
    end
end

--[[
    Existuje-li entita s platným objektem zaregistrovaná pod zadaným handle, vrátí ji.
    Vyhledávání je možno omezit také na specifickou hodnotu 'name'.
    Parametry:
        * handle (int32 or nil)
        * required_name (string or nil)
    Vrací:
        a) entity (table) [požadovaná entita], object (ObjRef) [její objekt]
        b) nil, other_name (string) [odkazovaná entita existuje, ale liší se hodnotou 'name']
        c) nil, nil [parametr je nil nebo odkazovaná entita neexistuje nebo nemá platný objekt]
]]
function ch_core.get_entity_by_handle(handle, required_name)
    if type(handle) == "number" then
        local result = entities[handle]
        if result ~= nil then
            local o = result.object
            if o == nil or not o:is_valid() then
                remove_registered_entity(handle)
                return nil
            end
            if required_name ~= nil and required_name ~= result.name then
                return nil, result.name -- different name
            end
            return result, o
        end
    elseif handle ~= nil then
        minetest.log("warning", "ch_core.get_entity_by_handle() called with an invalid argument: "..dump2({type = type(handle), value = handle}))
    end
    return nil, nil
end

--[[
    Otestuje předaný argument, zda jde o použitelné handle pro registraci entit.
    Vrací: success (bool or nil), reason (string)
    Pro nil vrací nil, "nil".
]]
function ch_core.is_valid_entity_handle(h)
    if h == nil then
        return nil, "nil"
    elseif type(h) ~= "number" then
        return false, "not a number (invalid type)"
    elseif math.floor(h) ~= h then
        return false, "not an integer"
    elseif h < -2147483648 or h > 2147483647 then
        return false, "out of range"
    elseif h == 0 then
        return false, "zero is an invalid handle"
    else
        return true, "OK"
    end
end

local function normalize_lua_entity(lua_entity)
    if type(lua_entity) == "table" and type(lua_entity.name) == "string" and lua_entity.object ~= nil and lua_entity.object:is_valid() then
        return lua_entity
    end
end

--[[
    Zaregistruje dosud neregistrovanou entitu a vrátí handle.
    Parametry:
    * lua_entity (table or nil)
    * handle_to_use (int32 or nil)
    Vrací:
    a) new_handle (int32), warning_message (string or nil)
    b) nil, error_message (string)
]]
function ch_core.register_entity(lua_entity, handle_to_use)
    if lua_entity == nil then
        return nil, "nothing to register"
    end
    local success, reason = ch_core.is_valid_entity_handle(handle_to_use)
    if success == false then
        return nil, "handle_to_use is invalid: "..reason
    end
    lua_entity = normalize_lua_entity(lua_entity)
    if lua_entity == nil then
        return nil, "invalid or expired entity!"
    end
    local handle = lua_entity._ch_entity_handle
    if type(handle) == "number" and entities[handle] ~= nil then
        -- the entity already has a handle
        return handle, ifthenelse(handle_to_use == nil or handle_to_use == handle, "already registered", "already registered under a different handle!")
    end
    handle = handle_to_use
    local handle_type = "old"
    local warning
    if handle_to_use ~= nil then
        local e = entities[handle_to_use]
        if e ~= nil then
            if e.object:is_valid() then
                handle = nil
                handle_type = "???"
                warning = "requested handle already used for a different entity"
            else
                -- object with requested handle already expired
                remove_registered_entity(handle_to_use)
            end
        end
    end

    if handle == nil then
        -- generate a new handle
        repeat
            repeat
                handle = handle_generator:next()
            until handle ~= 0
            assert(ch_core.is_valid_entity_handle(handle))
        until entities[handle] == nil
        handle_type = "new"
    end
    add_entity_to_register(handle, lua_entity)
    if count >= next_gc_count then
        ch_core.collect_invalid_entities()
        if entities[handle] == nil then
            core.log("error", "Freshly added entity collected as garbage! This means internal error.")
            return nil, "internal error"
        end
    end
    return handle, nil
end

--[[
    Je-li daná entita v registru, odstraní ji. Používá se zpravidla uvnitř obsluhy on_deactivate.
    Lze ji přiřadit i přímo:
    on_deactivate = ch_core.unregister_entity
]]
function ch_core.unregister_entity(lua_entity)
    if lua_entity ~= nil then
        local handle = lua_entity._ch_entity_handle
        if type(handle) == "number" then
            if entities[handle] ~= nil then
                remove_registered_entity(handle)
                return true
            end
            lua_entity._ch_entity_handle = nil -- for sure
        end
    end
end

-- __builtin:item by se měla registrovat:
local builtin_item = core.registered_entities["__builtin:item"]
local function empty_function() end
local orig_on_activate = builtin_item.on_activate or empty_function
local orig_on_deactivate = builtin_item.on_deactivate or empty_function
local new_item = {
    on_activate = function(self, ...)
        orig_on_activate(self, ...)
        ch_core.register_entity(self)
    end,
    on_deactivate = function(self, ...)
        orig_on_deactivate(self, ...)
        ch_core.unregister_entity(self)
    end,
}
setmetatable(new_item, {__index = builtin_item})
core.register_entity(":__builtin:item", new_item)

ch_core.close_submod("entity_register")
