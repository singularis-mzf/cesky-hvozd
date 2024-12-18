ch_core.open_submod("shape_selector", {chat = true, formspecs = true, lib = true})

local ifthenelse = ch_core.ifthenelse
local F = minetest.formspec_escape

local item_to_shape_selector_group = {}

local function get_group_size(group)
    if group.rows ~= nil and group.columns ~= nil then
        return group.columns, group.rows
    end
    local count = #group.nodes
    if group.rows ~= nil then
        return math.ceil(count / group.rows), group.rows
    elseif group.columns ~= nil then
        return group.columns, math.ceil(count / group.columns)
    else
        if count <= 8 then
            return count, 1
        else
            return 8, math.ceil(count / 8)
        end
    end
end

--[[
    Shape selector group definition:
    {
        -- povinné položky:
        nodes = {nodespec, ...}, -- seznam bloků ve skupině; musí být sekvence, s výjimkou případu, že jsou
                                 -- uvedeny obě vlastnosti columns a rows
        -- volitelné položky:
        columns = int, -- počet sloupců ve formspecu (>= 1),
        rows = int, -- počet řádek ve formspecu (>= 1),
        check_owner = bool, -- je-li true a má-li blok meta:get_string("owner"), povolí změnu jen
                            -- vlastníkovi/ici a postavám s právem protection_bypass
        on_change = function(pos, old_node, new_node, player, nodespec),
            -- callback volaný pro provedení změny (je-li nastaven); vrátí-li false, změna selhala
        after_change = function(pos, old_node, new_node, player, nodespec), -- callback, který bude zavolaný *po* provedení změny
    }

    Každý nodespec může být:
    - string (název bloku; není-li registrován, pozice bude vynechána)
    - table:
    {
        -- povinné položky:
        name = string, -- název bloku
        -- volitelné položky:
        param2 = 0..255 + 256 * (bitová maska 0..255),
            -- základní hodnota udává hodnotu pro nastavení do param2;
            -- maska udává, které bity se přímo nastaví podle spodního bajtu (bity 0)
            -- a které se sloučí ze spodního bajtu a původní hodnoty param2 operací xor (bity 1);
            -- není-li zadána, ponechá se původní hodnota param2 (odpovídá zadání 0xFF00)
        oneway = bool, -- je-li true, zadaný blok se nebude registrovat do skupiny a konverze bude
                       -- prezentováno jako jednosměrná; rovněž se nepoužije při rozpoznávání
        tooltip = string, -- vlastní text pro tooltip[]
        label = string, -- vlastní text na tlačítko (musí být krátký, jinak nevypadá dobře)
    }
    - nil (jen pokud má skupina uvedeny obě vlastnosti 'columns' a 'rows')

    TODO:
    [x] plná podpora pro param2 s maskou
    [x] podpora pro 'tooltip' (je-li možná)
    [x] podpora pro 'oneway'
    [x] podpora pro barvené bloky (jako ch_extras:dice)
    [x] rozpoznání současné varianty
]]

function ch_core.register_shape_selector_group(def)
    local has_columns = type(def.columns) == "number"
    local has_rows = type(def.rows) == "number"
    if type(def.nodes) ~= "table" then
        error("Invalid type(def.nodes): "..type(def.nodes))
    end
    if has_columns and def.columns < 1 then
        error("Invalid number of columns: "..def.columns)
    end
    if has_rows and def.rows < 1 then
        error("Invalid number of rows: "..def.rows)
    end

    local new_group = {nodes = def.nodes}
    if has_columns then new_group.columns = def.columns end
    if has_rows then new_group.rows = def.rows end
    local columns, rows = get_group_size(new_group)
    local count = columns * rows
    if def.check_owner then
        new_group.check_owner = true
    end
    if def.after_change ~= nil then
        new_group.after_change = def.after_change
    end
    if def.on_change ~= nil then
        new_group.on_change = def.on_change
    end
    local new_nodes = {}
    for i = 1, count do
        local nodespec = def.nodes[i]
        if nodespec ~= nil then
            local name
            if type(nodespec) ~= "table" then
                name = nodespec
            elseif not nodespec.oneway then
                name = nodespec.name
            end
            if name ~= nil and new_nodes[name] == nil then
                new_nodes[name] = true
                if item_to_shape_selector_group[name] ~= nil then
                    error(name.." already has registered the shape selector!")
                end
            end
        end
    end
    -- local new_nodes_count = 0
    for name, _ in pairs(new_nodes) do
        item_to_shape_selector_group[name] = new_group
        -- new_nodes_count = new_nodes_count + 1
        if core.registered_nodes[name] == nil then
            core.log("warning", name.." is used in a shape selector group, but it is an unknown node!")
        end
    end
end

local function process_param2(current_param2, param2_spec)
    if param2_spec == nil then
        return current_param2
    end
    local old_mask = bit.rshift(param2_spec, 8)
    local new_mask = bit.bxor(old_mask, 0xFF)
    return bit.bxor(bit.band(old_mask, current_param2), bit.band(new_mask, param2_spec))
end

local function get_group_count(group)
    local columns, rows = get_group_size(group)
    return columns * rows
end

local function formspec_callback(custom_state, player, formname, fields)
	local player_name = player:get_player_name()
    local inv = player:get_inventory()
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
                    new_node = {name = new_node_spec.name, param2 = process_param2(current_node.param2, new_node_spec.param2)}
                else
                    new_node = {name = new_node_spec, param2 = current_node.param2}
                end
                local change_node = new_node.name ~= current_node.name or new_node.param2 ~= current_node.param2
                if change_node then
                    local change_result, error_message
                    if custom_state.on_change ~= nil then
                        change_result, error_message = custom_state.on_change(pos, old_node,
                            {name = new_node.name, param = old_node.param, param2 = new_node.param2}, player, new_node_spec)
                    end
                    if change_result == nil then
                        core.swap_node(pos, new_node)
                    elseif change_result == false then
                        change_node = false
                    end
                end
                fields.quit = "true"
                core.close_formspec(player_name, formname)
                inv:set_size("ch_shape_selector", 1)
                inv:set_stack("ch_shape_selector", 1, ItemStack())
                if change_node and custom_state.after_change ~= nil then
                    custom_state.after_change(pos, old_node, core.get_node(pos), player, new_node_spec)
                end
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
    local inv = player:get_inventory()
    local columns, rows = get_group_size(group)
    local count = columns * rows
    local nodes = assert(group.nodes)
    inv:set_list("ch_shape_selector", {})
    inv:set_size("ch_shape_selector", count)
    local current_index
    for i = 1, count do
        local nodespec = nodes[i]
        if nodespec ~= nil then
            local node_name
            if type(nodespec) ~= "table" then
                node_name = nodespec
                nodespec = {name = node_name, param2 = 0xFF00}
            else
                node_name = nodespec.name
            end
            local node_def = core.registered_nodes[node_name]
            if node_def ~= nil then
                local stack = ItemStack(node_name)
                local meta = stack:get_meta()
                local new_param2 = process_param2(node.param2, nodespec.param2)
                if node_def.palette ~= nil and type(node_def.paramtype2) == "string" then
                    local palette_idx = core.strip_param2_color(new_param2, node_def.paramtype2)
                    if palette_idx ~= nil then
                        meta:set_int("palette_index", palette_idx)
                    end
                end
                if nodespec.label ~= nil then
                    meta:set_int("count_alignment", 14) -- middle bottom
                    meta:set_string("count_meta", nodespec.label)
                end
                inv:set_stack("ch_shape_selector", i, stack)
                if current_index == nil and node_name == node.name and new_param2 == node.param2 then
                    current_index = i
                end
            end
        end
    end

    local width = 0.75 + 1.25 * math.max(4, columns)
    local height = 1.5 + 1.25 * math.max(2, rows)
    local formspec = {
        ch_core.formspec_header({
            formspec_version = 6,
            size = {width, height},
            listcolors = {"#00000000", "#00000000", "#00000000"},
            auto_background = true}),
        "label[0.5,0.5;Změnit tvar či variantu]",
		"button_exit["..(width - 0.975)..",0.25;0.5,0.5;close;X]",
        "style_type[item_image_button;border=false;content_offset=(1024,1024)]",
    }
    local formspec2 = {
        "list[current_player;ch_shape_selector;0.5,1;"..columns..","..rows..";]",
    }
    for row = 1, rows do
        for col = 1, columns do
            local i = columns * (row - 1) + col
            local x, y = 1.25 * col - 0.75, 1.25 * row - 0.25
            local nodespec = nodes[i]
            local nodespec_type = type(nodespec)
            local node_name
            if nodespec_type == "table" then
                node_name = nodespec.name
            else
                node_name = nodespec
            end
            if node_name ~= nil and core.registered_nodes[node_name] ~= nil then
                assert(nodespec ~= nil)
                if current_index ~= nil and current_index == i then
                    table.insert(formspec, ("box[%f,%f;1.2,1.2;#00ff00]"):format(x - 0.1, y - 0.1))
                end
                table.insert(formspec, ("image_button[%f,%f;1,1;blank.png;%s;]"):format(x, y, "chg_"..i.."_bg"))
                table.insert(formspec2, ("item_image_button[%f,%f;1,1;%s;%s;]"):format(x, y, F(node_name), "chg_"..i))
                if nodespec_type == "table" then
                    if nodespec.tooltip ~= nil then
                        table.insert(formspec2, "tooltip[chg_"..i..";"..F(nodespec.tooltip).."]")
                    end
                    if nodespec.oneway then
                        table.insert(formspec2, ("vertlabel[%f,%f;↮]"):format(x + 0.2, y - 0.05))
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
    if group.after_change ~= nil then
        custom_state.after_change = group.after_change
    end
    if group.on_change ~= nil then
        custom_state.on_change = group.on_change
    end
    if group.check_owner then
        custom_state.check_owner = true
    end
    formspec = table.concat(formspec)..table.concat(formspec2)
    ch_core.show_formspec(player, "ch_core:shape_selector", formspec, formspec_callback, custom_state, {})
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
    if group.check_owner and not core.check_player_privs(player_name, "protection_bypass") then
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        if owner ~= "" and owner ~= player_name then
            ch_core.systemovy_kanal(player_name, "Tento blok patří postavě '"..ch_core.prihlasovaci_na_zobrazovaci(owner).."'!")
            return
        end
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

local function allow_player_inventory_action(player, action, inventory, inventory_info)
    if action == "move" then
        return ifthenelse(
            inventory_info.from_list ~= "ch_shape_selector" and inventory_info.to_list ~= "ch_shape_selector",
            inventory_info.count,
            0)
    elseif action == "put" or action == "take" then
        return ifthenelse(inventory_info.listname ~= "ch_shape_selector", inventory_info.stack:get_count(), 0)
    end
end
local function on_joinplayer(player, last_login)
    local inv = player:get_inventory()
    if inv:get_size("ch_shape_selector") == 0 then
        inv:set_size("ch_shape_selector", 1)
    end
end

core.register_allow_player_inventory_action(allow_player_inventory_action)
core.register_on_joinplayer(on_joinplayer)

ch_core.close_submod("shape_selector")
