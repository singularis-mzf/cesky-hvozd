ch_core.open_submod("entity_register", {lib = true})

local ifthenelse = ch_core.ifthenelse

local count = 0 -- aktuální počet zaregistrovaných entit
local next_gc_count = 16 -- počet, při jehož dosažení se spustí pročištění
local entities = {} -- mapa registrovaných entit: handle => entita
local handle_generator = PcgRandom(os.time())

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
            entities[handle] = nil
            count = count - 1
        end
        next_gc_count = 2 * count
        print("DEBUG: "..gc_count.." invalidated entities removed from the register. next_gc_count = "..next_gc_count)
    end
    return gc_count, result, count
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
        local result = lua_entity._ch_entity_handle
        if type(result) == "number" and entities[result] ~= nil then
            -- already has a handle
            if lua_entity.object:is_valid() then
                return result
            else
                -- object already expired!
                result._ch_entity_handle = nil
                entities[result] = nil
                count = count - 1
                return nil
            end
        end
        local message
        result, message = ch_core.register_entity(lua_entity)
        if message ~= nil then
            core.log(ifthenelse(result == nil, "error", "warning"), "ch_core.get_handle_of_entity(): "..message)
        end
        return result
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
        a) table (požadovaná entita)
        b) false (odkazovaná entita existuje, ale liší se hodnotou 'name')
        c) nil (parametr je nil nebo odkazovaná entita neexistuje nebo nemá platný objekt)
]]
function ch_core.get_entity_by_handle(handle, required_name)
    if type(handle) == "number" then
        local result = entities[handle]
        if result ~= nil then
            local o = result.object
            if o == nil or not o:is_valid() then
                print("DEBUG: Already invalid entity with handle "..handle.." removed from the register.")
                result._ch_entity_handle = nil
                entities[handle] = nil -- entity already invalidated!
                return nil
            end
            if required_name ~= nil and required_name ~= result.name then
                return false -- different name
            end
            return result
        end
        return result
    elseif handle == nil then
        return nil
    else
        minetest.log("warning", "ch_core.get_entity_by_handle() called with an invalid argument: "..dump2({type = type(handle), value = handle}))
        return nil
    end
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
    elseif result < -2147483648 or result > 2147483647 then
        return false, "out of range"
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
    local warning
    if handle_to_use ~= nil then
        local e = entities[handle_to_use]
        if e ~= nil then
            if e.object:is_valid() then
                handle = nil
                warning = "requested handle already used for a different entity"
            else
                -- object with requested handle already expired
                entities[handle_to_use] = nil
                count = count - 1
            end
        end
    end

    if handle == nil then
        -- generate a new handle
        repeat
            handle = handle_generator:next()
            assert(ch_core.is_valid_entity_handle(handle))
        until entities[handle] == nil
    end
    lua_entity._ch_entity_handle = handle
    entities[handle] = lua_entity
    count = count + 1
    print("DEBUG: a new entity registered under a new handle "..result)
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
            lua_entity._ch_entity_handle = nil
            if entities[handle] ~= nil then
                entities[handle] = nil
                return true
            end
        end
    end
end

ch_core.close_submod("entity_register")
