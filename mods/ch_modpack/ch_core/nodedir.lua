ch_core.open_submod("nodedir", {lib = true})

ch_core.registered_nodedir_groups = {}

local node_to_info = {}

function ch_core.register_nodedir_group(def)
    local to_add = {}
    local new_group = {}
    for i = 0, 23 do
        local nodename = def[i]
        if type(nodename) == "string" then
            if node_to_info[nodename] ~= nil then
                error(nodename.." is already registered in a different nodedir group!")
            elseif to_add[nodename] == nil then
                to_add[nodename] = {facedir = i, group = new_group}
            end
            new_group[i] = nodename
        elseif nodename ~= nil then
            error("Invalid nodename type: "..type(nodename))
        elseif i == 0 then
            error("Nodedir name [0] is required!")
        end
    end
    assert(type(new_group[0]) == "string")
    for k, v in pairs(to_add) do
        node_to_info[k] = v
    end
    table.insert(ch_core.registered_nodedir_groups, new_group)
    return true
end

local facedir_table = {}
for i = 0, 23 do
    facedir_table[i] = true
end

local function assert_is_facedir(facedir)
    if type(facedir) == "number" and facedir_table[facedir] then
        return facedir
    else
        error("Invalid facedir value: "..dump2({type = type(facedir), value = facedir}))
    end
end

--[[
    Pokud je zadaný blok registrován, vrátí jeho otočení typu facedir, jinak vrací nil.
]]
function ch_core.get_nodedir(nodename)
    local info = node_to_info[assert(nodename)]
    if info ~= nil then
        return info.facedir
    else
        return nil
    end
end

--[[
    Pokud je zadaný blok registrován a podporuje cílové otočení, vrátí název odpovídajícího cílového bloku.
    Jinak vrací nil.
]]
function ch_core.get_nodedir_nodename(current_nodename, new_facedir)
    local info = node_to_info[assert(current_nodename)]
    if info ~= nil then
        return info ~= nil and info.group[assert_is_facedir(new_facedir)]
    else
        return nil
    end
end

--[[
    Pokud je zadaný blok registrován, nastaví v množině 'set' klíče odpovídající
    zadanému bloku a jeho ostatním otočením na true.
    'set' může být nil, v takovém případě jen vrátí návratovou hodnotu, zda je blok registrován.
    Vrací true, pokud je zadaný blok registrován, jinak false.
]]
function ch_core.fill_nodedir_equals_set(set, nodename)
    local info = node_to_info[assert(nodename)]
    if info == nil then return false end
    if set ~= nil then
        local group, n = info.group
        for i = 0, 23 do
            n = group[i]
            if n ~= nil then
                set[n] = true
            end
        end
    end
    return true
end

-- override screwdriver handler:
local old_screwdriver_handler = assert(screwdriver.handler)
function screwdriver.handler(itemstack, user, pointed_thing, mode, uses)
    if pointed_thing.type ~= "node" then return end
    local node = minetest.get_node(pointed_thing.under)
    local nodedir_facedir = ch_core.get_nodedir(node.name)
    if nodedir_facedir == nil then
        -- call a normal handler
        return old_screwdriver_handler(itemstack, user, pointed_thing, mode, uses)
    end
    local pos = pointed_thing.under
    local player_name = (user and user:get_player_name()) or ""
    if minetest.is_protected(pos, player_name) then
        minetest.record_protection_violation(pos, player_name)
        return
    end
    local new_facedir
    if mode == screwdriver.ROTATE_FACE then
        new_facedir = bit.band(nodedir_facedir, 0x1C) + bit.band(nodedir_facedir + 1, 0x03)
    elseif mode == screwdriver.ROTATE_AXIS then
        new_facedir = (nodedir_facedir + 4) % 24
    else
        return -- unknown mode
    end
    local new_node_name = ch_core.get_nodedir_nodename(node.name, new_facedir)
    if new_node_name == nil then
        return -- orientation not supported by the node
    end

    if new_node_name ~= node.name then
        node.name = new_node_name
        minetest.swap_node(pos, node)
        minetest.check_for_falling(pos)
    end
    if not minetest.is_creative_enabled(player_name) then
        itemstack:add_wear_by_uses(uses or 200)
    end
    return itemstack
end

ch_core.close_submod("nodedir")
