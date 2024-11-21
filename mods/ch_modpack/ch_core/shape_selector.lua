ch_core.open_submod("shape_selector", {chat = true, formspecs = true, lib = true})

local item_to_shape_selector_group = {}
local F = minetest.formspec_escape

--[[
    Shape selector group definition:
    {
        columns = int, -- number of columns in the formspec,
        rows = int, -- number of rows in the formspec,
        nodes = {nodename, ...}, -- the list of nodes in the group (nils are allowed)
    }
]]

function ch_core.register_shape_selector_group(def)
    if type(def.columns) ~= "number" then
        error("Invalid type(def.columns): "..type(def.columns))
    end
    if type(def.rows) ~= "number" then
        error("Invalid type(def.rows): "..type(def.rows))
    end
    if type(def.nodes) ~= "table" then
        error("Invalid type(def.nodes): "..type(def.nodes))
    end
    local new_group = {columns = def.columns, rows = def.rows, count = def.rows * def.columns, nodes = def.nodes}
    for _, name in ipairs(def.nodes) do
        if item_to_shape_selector_group[name] ~= nil then
            error(name.." already has registered the shape selector!")
        end
    end
    for _, name in ipairs(def.nodes) do
        item_to_shape_selector_group[name] = new_group
        if minetest.registered_nodes[name] == nil then
            minetest.log("warning", name.." is used in a shape selector group, but it is an unknown node!")
        end
    end
    table.insert(item_to_shape_selector_group, new_group)
    if def.override_rightclick ~= false then
        for _, name in ipairs(def.nodes) do
            local ndef = minetest.registered_nodes[name]
            if ndef ~= nil then
                local old_on_rightclick = ndef.on_rightclick
                minetest.override_item(name, {on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
                    if item_to_shape_selector_group[node.name] ~= nil and minetest.is_player(clicker) and clicker:get_player_control().aux1 then
                        ch_core.show_shape_selector(clicker, pos, node)
                        return
                    elseif old_on_rightclick ~= nil then
                        return old_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
                    end
                end})
            end
        end
    end
end

local function formspec_callback(custom_state, player, formname, fields)
	local player_name = player:get_player_name()
	local pos = custom_state.pos
    local old_node = custom_state.old_node
	local current_node = minetest.get_node(pos)
    for k, _ in pairs(fields) do
        if k:match("^chg_%d+$") then
            local i = tonumber(k:sub(5, -1))
            local new_node_name = custom_state.nodes[i]
            if new_node_name ~= nil then
                if minetest.is_protected(pos, player_name) then
                    minetest.record_protection_violation(pos, player_name)
                    return
                end
                if old_node.name ~= current_node.name or old_node.param2 ~= current_node.param2 then
                    ch_core.systemovy_kanal(player_name, "Blok se změnil během výběru! Zkuste to znovu.")
                    return
                end
                if new_node_name == current_node.name then
                    return -- nic se nezměnilo
                end
                current_node.name = new_node_name
                minetest.swap_node(pos, current_node)
                fields.quit = "true"
                minetest.close_formspec(player_name, formname)
                return
            end
        end
    end
end

function ch_core.show_shape_selector(player, pos, node)
    local group = item_to_shape_selector_group[assert(node.name)]
    if group == nil then
        return false -- no selector group
    end
    local width = 0.75 + 1.25 * math.max(4, group.columns)
    local height = 1.5 + 1.25 * math.max(2, group.rows)
    local formspec = {
        ch_core.formspec_header({formspec_version = 6, size = {width, height}, auto_background = true}),
        "label[0.5,0.5;Změnit tvar]",
		"button_exit["..(width - 0.975)..",0.25;0.5,0.5;close;X]",
    }
    local nodes = assert(group.nodes)
    for row = 1, group.rows do
        for col = 1, group.columns do
            local i = group.columns * (row - 1) + col
            if nodes[i] ~= nil then
                local node_name = nodes[i]
                if minetest.registered_nodes[node_name] ~= nil then
                    table.insert(formspec, ("item_image_button[%f,%f;1,1;%s;%s;]"):format(1.25 * col - 0.75, 1.25 * row - 0.25, F(node_name), "chg_"..i))
                end
            end
        end
    end
    local custom_state = {
        pos = assert(pos),
        old_node = node,
        nodes = nodes,
    }
    ch_core.show_formspec(player, "ch_core:shape_selector", table.concat(formspec), formspec_callback, custom_state, {})
    return true
end

ch_core.close_submod("shape_selector")
