ch_core.open_submod("shape_selector", {chat = true, formspecs = true, lib = true})

local item_to_shape_selector_group = {}
local F = minetest.formspec_escape

--[[
    Shape selector group definition:
    {
        columns = int, -- number of columns in the formspec (>= 1),
        rows = int, -- number of rows in the formspec (>= 1),
        nodes = {nodespec, ...}, -- the list of nodes in the group (nils are allowed)
    }

    Each nodespec can be:
    - string (node name)
    - a table:
    {
        name = string, -- node name (required)
        param2 = 0..255, -- a particular param2 value (optional)
        price = ItemStack(...), -- an item required as a price for change (optional) <not supported yet>
    }
    - nil (to render a free space)

    TODO:
    [ ] add support for 'oneway'
    [ ] add support for colored nodes (like ch_extras:dice)
    [ ] add support for custom tooltips (if possible)
    [ ] add support for 'price'
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
    if def.rows < 1 then
        error("Invalid number of rows: "..def.rows)
    end
    if def.columns < 1 then
        error("Invalid number of columns: "..def.columns)
    end
    local count = def.rows * def.columns
    local new_group = {columns = def.columns, rows = def.rows, count = count, nodes = def.nodes}
    local new_nodes = {}
    for i = 1, count do
        local nodespec = def.nodes[i]
        if nodespec ~= nil then
            local name
            if type(nodespec) == "table" then
                name = nodespec.name
            else
                name = nodespec
            end
            if new_nodes[name] == nil then
                new_nodes[name] = true
                if item_to_shape_selector_group[name] ~= nil then
                    error(name.." already has registered the shape selector!")
                end
            end
        end
    end
    for name, _ in pairs(new_nodes) do
        item_to_shape_selector_group[name] = new_group
        if core.registered_nodes[name] == nil then
            core.log("warning", name.." is used in a shape selector group, but it is an unknown node!")
        end
    end
end

local function formspec_callback(custom_state, player, formname, fields)
	local player_name = player:get_player_name()
	local pos = custom_state.pos
    local old_node = custom_state.old_node
	local current_node = core.get_node(pos)
    for k, _ in pairs(fields) do
        if k:match("^chg_%d+$") then
            local i = tonumber(k:sub(5, -1))
            local new_node_spec = custom_state.nodes[i]
            if new_node_spec ~= nil then
                if core.is_protected(pos, player_name) then
                    core.record_protection_violation(pos, player_name)
                    return
                end
                if old_node.name ~= current_node.name or old_node.param2 ~= current_node.param2 then
                    ch_core.systemovy_kanal(player_name, "Blok se změnil během výběru! Zkuste to znovu.")
                    return
                end
                local new_node
                if type(new_node_spec) == "table" then
                    new_node = {name = new_node_spec.name, new_node_spec.param2 or current_node.param2}
                else
                    new_node = {name = new_node_spec, param2 = current_node.param2}
                end
                if new_node.name == current_node.name and new_node.param2 == current_node.param2 then
                    return -- nic se nezměnilo
                end
                core.swap_node(pos, new_node)
                fields.quit = "true"
                core.close_formspec(player_name, formname)
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
                local nodespec = nodes[i]
                local node_name
                if type(nodespec) == "table" then
                    local node_name = nodespec.name
                    if minetest.registered_nodes[node_name] ~= nil then
                        -- TODO: support for param2 and price
                        -- table.insert(formspec, ("box[%f,%f;1.2,1.2;#ff0000]"):format(1.25 * col - 0.75 - 0.1, 1.25 * row - 0.25 - 0.1))
                        table.insert(formspec, ("item_image_button[%f,%f;1,1;%s;%s;]"):format(1.25 * col - 0.75, 1.25 * row - 0.25, F(node_name), "chg_"..i))
                    end
                else
                    local node_name = nodespec
                    if minetest.registered_nodes[node_name] ~= nil then
                        table.insert(formspec, ("item_image_button[%f,%f;1,1;%s;%s;]"):format(1.25 * col - 0.75, 1.25 * row - 0.25, F(node_name), "chg_"..i))
                    end
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

local function chisel_on_use(itemstack, user, pointed_thing)
    if user == nil or pointed_thing.type ~= "node" then
        return -- player and node are required
    end
    local player_name = user:get_player_name()
    local pos = pointed_thing.under
    local node = core.get_node(pos)
    local group = item_to_shape_selector_group[node.name]
    if group == nil then
        return
    end
    if core.is_protected(pos, player_name) then
        core.record_protection_violation(pos, player_name)
        return
    end
    if not core.is_creative_enabled(player_name) then
        itemstack:add_wear_by_uses(200)
    end
    ch_core.show_shape_selector(user, pos, node)
    return itemstack
end

local def = {
    description = "dláto",
    inventory_image = "ch_core_chisel.png",
    wield_image = "ch_core_chisel.png",
    groups = {tool = 1},
    on_use = chisel_on_use,
    _ch_help = "Levým klikem na podporované bloky můžete změnit jejich tvar nebo variantu,\nněkdy i barvu.",
}

core.register_tool("ch_core:chisel", def)
core.register_craft({
    output = "ch_core:chisel",
    recipe = {
        {"default:steel_ingot", "", ""},
        {"default:steel_ingot", "", ""},
        {"default:stick", "", ""},
    },
})

ch_core.close_submod("shape_selector")
