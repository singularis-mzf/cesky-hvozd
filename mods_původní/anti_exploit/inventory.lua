-- TODO ensure that formspecs are closed if you move
-- formspec -> accessible
inv_fs_accessible_inventories = {}
-- playername -> accessible
shown_formspecs = {}
-- playername -> pos
node_context_pos = {}

function get_accessible_inventories(formspec)
    local accessible_inventories = {}
    for location, list_name, width, height, offset in string.gmatch(formspec, "list%[(.-);(.-);.-,.-;(.-),(.-);(.-)%]") do
        if list_name == "craftpreview" then
            -- HACK as minetest uses craftpreview to show the result, but craftresult for the actual inventory action
            list_name = "craftresult"
        end
        local index = location .. ";" .. list_name
        local min = offset:len() > 0 and tonumber(offset) or 1
        local max = min - 1 + tonumber(width) * tonumber(height)
        accessible_inventories[index] = accessible_inventories[index] or {}
        table.insert(accessible_inventories[index], {min = min, max = max})
    end
    return accessible_inventories
end

modlib.minetest.override("show_formspec", function(original)
    return function(playername, formname, formspec, ...)
        shown_formspecs[playername] = {accessible_inventories = get_accessible_inventories(formspec), formname = formname}
        return original(playername, formname, formspec, ...)
    end
end)

function on_formspec_closed(playername, formname)
    if not (shown_formspecs[playername] and shown_formspecs[playername].formname == formname) then
        return
    end
    shown_formspecs[playername] = nil
    node_context_pos[playername] = nil
end

modlib.minetest.override("close_formspec", function(original)
    return function(playername, formname)
        on_formspec_closed(playername, formname)
        return original(playername, formname)
    end
end)

minetest.register_on_player_receive_fields(function(player, _, fields)
    -- TODO ensure that this is sufficient
    if fields.quit then
        on_formspec_closed(player:get_player_name())
    end
end)

function is_accessible(player, inventory, list_name, index)
    local function index_is_accessible(ranges)
        if not ranges then
            return
        end
        for _, range in pairs(ranges) do
            if index >= range.min and index <= range.max then
                return true
            end
        end
    end
    if not(player and inventory and list_name and index) then
        return
    end
    local name = player:get_player_name()
    local inv_fs = player:get_inventory_formspec()
    local accessible_inventories = inv_fs_accessible_inventories[inv_fs] or get_accessible_inventories(inv_fs)
    inv_fs_accessible_inventories[inv_fs] = accessible_inventories
    local inventory_location = inventory:get_location()
    local inventory_locations = {}
    local type = inventory_location.type
    if type == "undefined" then
        return
    elseif type == "detached" then
        table.insert(inventory_locations, "detached:" .. inventory_location.name)
    elseif type == "node" then
        local pos = inventory_location.pos
        table.insert(inventory_locations, "nodemeta:" .. table.concat({pos.x, pos.y, pos.z}, ","))
        if node_context_pos[name] and vector.equals(node_context_pos[name], pos) then
            table.insert(inventory_locations, "context")
            table.insert(inventory_locations, "current_name")
        end
    else
        assert(type == "player")
        if inventory_location.name == name then
            table.insert(inventory_locations, "current_player")
        end
        table.insert(inventory_locations, "player:" .. inventory_location.name)
    end
    local fs_accessible_invs = (shown_formspecs[name] or {}).accessible_inventories or {}
    for _, inventory_location in pairs(inventory_locations) do
        local inv_index = inventory_location .. ";" .. list_name
        if index_is_accessible(accessible_inventories[inv_index]) or index_is_accessible(fs_accessible_invs[inv_index]) then
            return true
        end
    end
end

local function disallow_move(player, inv, from_list, from_index, to_list, to_index)
    return not(is_accessible(player, inv, from_list, from_index) and is_accessible(player, inv, to_list, to_index))
end

local function disallow_put(player, inv, listname, index)
    return not is_accessible(player, inv, listname, index)
end

local disallow_take = disallow_put

modlib.minetest.override("create_detached_inventory", function(original)
    return function(name, callbacks, ...)
        local allow_move, allow_put, allow_take = callbacks.allow_move, callbacks.allow_put, callbacks.allow_take
        function callbacks.allow_move(inv, from_list, from_index, to_list, to_index, count, player)
            if disallow_move(player, inv, from_list, from_index, to_list, to_index) then
                return 0
            end
            return allow_move and allow_move(inv, from_list, from_index, to_list, to_index, count, player) or count
        end
        function callbacks.allow_put(inv, listname, index, stack, player)
            if disallow_put(player, inv, listname, index) then
                return 0
            end
            return allow_put and allow_put(inv, listname, index, stack, player) or stack:get_count()
        end
        function callbacks.allow_take(inv, listname, index, stack, player)
            if disallow_take(player, inv, listname, index) then
                return 0
            end
            return allow_take and allow_take(inv, listname, index, stack, player) or stack:get_count()
        end
        return original(name, callbacks, ...)
    end
end)

for name, callbacks in pairs(core.detached_inventories) do
    minetest.remove_detached_inventory(name)
    -- TODO find a way to preserve player name
    minetest.create_detached_inventory(name, callbacks)
end

-- HACK might need to be be updated as minetest.item_place changes
local item_place
modlib.minetest.override("item_place", function(original)
    item_place = original
    return function(itemstack, placer, pointed_thing, param2)
        if pointed_thing.type == "node" and placer and not placer:get_player_control().sneak then
            local node = minetest.get_node(pointed_thing.under)
            local def = minetest.registered_nodes[node.name]
            if def and def.on_rightclick then
                local stack = def.on_rightclick(pointed_thing.under, node, placer, itemstack, pointed_thing)
                if not def._anti_exploit_on_rightclick then
                    return stack or itemstack, nil
                end
            end
        end
        if itemstack:get_definition().type == "node" then
            return minetest.item_place_node(itemstack, placer, pointed_thing, param2)
        end
        return itemstack, nil
    end
end)

local function hook_node_def(def, new_def)
    new_def = new_def or def
    local allow_metadata_inventory_move, allow_metadata_inventory_put, allow_metadata_inventory_take = def.allow_metadata_inventory_move, def.allow_metadata_inventory_put, def.allow_metadata_inventory_take
    function new_def.allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
        if disallow_move(player, minetest.get_meta(pos):get_inventory(), from_list, from_index, to_list, to_index) then
            return 0
        end
        return allow_metadata_inventory_move and allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player) or count
    end
    function new_def.allow_metadata_inventory_put(pos, listname, index, stack, player)
        if disallow_put(player, minetest.get_meta(pos):get_inventory(), listname, index) then
            return 0
        end
        return allow_metadata_inventory_put and allow_metadata_inventory_put(pos, listname, index, stack, player) or stack:get_count()
    end
    function new_def.allow_metadata_inventory_take(pos, listname, index, stack, player)
        if disallow_take(player, minetest.get_meta(pos):get_inventory(), listname, index) then
            return 0
        end
        return allow_metadata_inventory_take and allow_metadata_inventory_take(pos, listname, index, stack, player) or stack:get_count()
    end
    local on_rightclick = def.on_rightclick
    if not on_rightclick then
        new_def._anti_exploit_on_rightclick = true
    end
    function new_def.on_rightclick(pos, node, clicker, ...)
        local formspec = minetest.get_meta(pos):get("formspec")
        if formspec then
            local name = clicker:get_player_name()
            node_context_pos[name] = pos
            -- TODO determine actual formname
            shown_formspecs[name] = {accessible_inventories = get_accessible_inventories(formspec), formname = nil}
        end
        if not on_rightclick then
            return
        end
        return on_rightclick(pos, node, clicker, ...)
    end
    -- TODO consider new_def.on_receive_fields
    return new_def
end

modlib.minetest.override("register_node", function(original)
    return function(name, def)
        hook_node_def(def)
        original(name, def)
    end
end)

local override_item = minetest.override_item
local registered_nodes = minetest.registered_nodes
for name, def in pairs(registered_nodes) do
    override_item(name, hook_node_def(def, {}))
end
for name, def in pairs(minetest.registered_items) do
    override_item(name, {on_place = (def.on_place ~= item_place and def.on_place) or minetest.item_place})
end

modlib.minetest.override("override_item", function(original)
    return function(name, def)
        original(name, def)
        def = minetest.registered_nodes[name]
        if def then
            original(name, hook_node_def(def, {}))
        end
    end
end)

minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
    if action == "put" or action == "take" then
        -- TODO responsibility of the other inv to ensure that the player has access to his inv
        if disallow_put(player, inventory, inventory_info.listname, inventory_info.index) then
            return 0
        end
    else
        assert(action == "move")
        if disallow_move(player, inventory, inventory_info.from_list, inventory_info.from_index, inventory_info.to_list, inventory_info.to_index) then
            return 0
        end
    end
end)