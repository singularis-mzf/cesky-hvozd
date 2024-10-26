ch_core.open_submod("active_objects", {})

local objects = {}
-- [name] = {{/*current:*/ [key] = ObjRef, ...}, {/*prev*/ [key] = ObjRef, ...}}

local function push_active_object(name, obj)
    local key = tostring(obj)
    local t = objects[name]
    if t == nil then
        objects[name] = {{[key] = obj}, {}}
    else
        t[1][key] = obj
    end
end

local function on_step_default(self)
    push_active_object(assert(self.name), assert(self.object))
end

local function try_append(dst, src)
    for k, v in pairs(src) do
        if dst[k] == nil then
            dst[k] = v
        end
    end
end

local function try_append_if_in_radius(dst, src, pos, radius)
    for k, v in pairs(src) do
        if dst[k] == nil and vector.distance(pos, v:get_pos()) <= radius then
            dst[k] = v
        end
    end
end

--[[
    Vrátí všechny aktivní objekty typu "name" v tabulce {[key] = ObjectRef}.
    Platí pouze pro objekty používající ch_core.object_on_step() v poli on_step a hráčské postavy (name == "player").
]]
function ch_core.get_active_objects(names)
    local result = {}
    local t = type(names)
    if t == "nil" then
        -- return all objects
        for _, lists in pairs(objects) do
            try_append(result, lists[1])
            try_append(result, lists[2])
        end
    elseif t == "string" then
        -- single type of objects
        local lists = objects[names]
        if lists ~= nil then
            try_append(result, lists[1])
            try_append(result, lists[2])
        end
    elseif t == "table" then
        for _, name in ipairs(names) do
            local lists = objects[name]
            if lists ~= nil then
                try_append(result, lists[1])
                try_append(result, lists[2])
            end
        end
    else
        error("Invalid type of argument: "..t)
    end
    return result
end

local function append_if_inside_radius(dst, lists, pos, radius)
    local new = {}
    for i = 2, 1, -1 do
        for key, obj in pairs(lists[i]) do
            if new[key] == nil and vector.distance(obj:get_pos(), pos) <= radius then
                new[key] = obj
                dst[key] = obj
            end
        end
    end
end

--[[
    Vrátí aktivní objekty typu "name", pokud se nacházejí v zadané oblasti,
    v tabulce {[key] = ObjectRef}.
    Platí pouze pro objekty používající ch_core.object_on_step() v poli on_step a hráčské postavy (name == "player").
]]
function ch_core.get_active_objects_inside_radius(names, pos, radius)
    local result = {}
    local t = type(names)
    if t == "nil" then
        -- return all objects
        for _, lists in pairs(objects) do
            try_append_if_in_radius(result, lists[1], pos, radius)
            try_append_if_in_radius(result, lists[2], pos, radius)
        end
    elseif t == "string" then
        -- single type of objects
        local lists = objects[names]
        if lists ~= nil then
            try_append_if_in_radius(result, lists[1], pos, radius)
            try_append_if_in_radius(result, lists[2], pos, radius)
        end
    elseif t == "table" then
        for _, name in ipairs(names) do
            local lists = objects[name]
            if lists ~= nil then
                try_append_if_in_radius(result, lists[1], pos, radius)
                try_append_if_in_radius(result, lists[2], pos, radius)
            end
        end
    else
        error("Invalid type of argument: "..t)
    end
    return result
end

--[[
    Musí být zadána do pole on_step u objektů, které mají být hledány pomocí
    funkcí z tohoto modulu.
    orig_func - původní funkce on_step (bude volána), nebo nil
]]
function ch_core.object_on_step(orig_func)
    if orig_func ~= nil then
        return function(self, ...)
            push_active_object(assert(self.name), assert(self.object))
            return orig_func(self, ...)
        end
    else
        return on_step_default
    end
end

-- Globalstep
local skip = true
local function on_globalstep(dtime)
    if skip then
        skip = false
        return
    end
    for _, name in pairs(objects) do
        name[2] = name[1]
        name[1] = {}
    end
    -- add players:
    local players = {}
    for _, player in ipairs(minetest.get_connected_players()) do
        local key = tostring(player)
        if players[key] ~= nil then
            minetest.log("error", "Key duplicity in players table: "..player:get_player_name().." x "..players[key]:get_player_name().."!")
        end
        players[key] = player
    end
    objects.player = {players, {}}
end
minetest.register_globalstep(on_globalstep)

ch_core.close_submod("active_objects")
