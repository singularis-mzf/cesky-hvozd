local ifthenelse = assert(ch_core.ifthenelse)

local filename = core.get_worldpath().."/ch_unkrep.dat"
local acc_dtime = 0
local next_clean_dtime = 0

local data = {
    [".mb_shapes"] = {
        -- {date, category, alternate}
        {20241223, "micro", ""},
        {20241223, "micro", "_1"},
        {20241223, "micro", "_12"},
        {20241223, "micro", "_15"},
        {20241223, "micro", "_2"},
        {20241223, "micro", "_4"},
        {20241223, "panel", ""},
        {20241223, "panel", "_1"},
        {20241223, "panel", "_12"},
        {20241223, "panel", "_15"},
        {20241223, "panel", "_2"},
        {20241223, "panel", "_4"},
        {20241223, "panel", "_banister"},
        {20241223, "panel", "_element"},
        {20241223, "panel", "_element_flat"},
        {20241223, "panel", "_l"},
        {20241223, "panel", "_l1"},
        {20241223, "panel", "_pole"},
        {20241223, "panel", "_pole_flat"},
        {20241223, "panel", "_special"},
        {20241223, "panel", "_wall"},
        {20241223, "panel", "_wall_flat"},
        {20241223, "panel", "_wide"},
        {20241223, "panel", "_wide_1"},
        {20241223, "slab", ""},
        {20241223, "slab", "_1"},
        {20241223, "slab", "_14"},
        {20241223, "slab", "_15"},
        {20241223, "slab", "_2"},
        {20241223, "slab", "_arcade"},
        {20241223, "slab", "_arcade_flat"},
        {20241223, "slab", "_bars"},
        {20241223, "slab", "_cube"},
        {20241223, "slab", "_quarter"},
        {20241223, "slab", "_rcover"},
        {20241223, "slab", "_table"},
        {20241223, "slab", "_three_quarter"},
        {20241223, "slab", "_three_sides"},
        {20241223, "slab", "_three_sides_half"},
        {20241223, "slab", "_three_sides_u"},
        {20241223, "slab", "_triplet"},
        {20241223, "slab", "_two_sides"},
        {20241223, "slab", "_two_sides_half"},
        {20241223, "slope", ""},
        {20241223, "slope", "_beveled"},
        {20241223, "slope", "_cut"},
        {20241223, "slope", "_cut2"},
        {20241223, "slope", "_diagfiller22a"},
        {20241223, "slope", "_diagfiller22b"},
        {20241223, "slope", "_diagfiller45"},
        {20241223, "slope", "_half"},
        {20241223, "slope", "_half_raised"},
        {20241223, "slope", "_inner"},
        {20241223, "slope", "_inner_cut"},
        {20241223, "slope", "_inner_cut_half"},
        {20241223, "slope", "_inner_cut_half_raised"},
        {20241223, "slope", "_inner_half"},
        {20241223, "slope", "_inner_half_raised"},
        {20241223, "slope", "_outer"},
        {20241223, "slope", "_outer_cut"},
        {20241223, "slope", "_outer_cut_half"},
        {20241223, "slope", "_outer_half"},
        {20241223, "slope", "_outer_half_raised"},
        {20241223, "slope", "_roof22"},
        {20241223, "slope", "_roof22_3"},
        {20241223, "slope", "_roof22_raised"},
        {20241223, "slope", "_roof22_raised_3"},
        {20241223, "slope", "_roof45"},
        {20241223, "slope", "_roof45_3"},
        {20241223, "slope", "_slab"},
        {20241223, "slope", "_tripleslope"},
        {20241223, "slope", "_valley"},
        {20241223, "stair", ""},
        {20241223, "stair", "_alt"},
        {20241223, "stair", "_alt_1"},
        {20241223, "stair", "_alt_2"},
        {20241223, "stair", "_alt_4"},
        {20241223, "stair", "_chimney"},
        {20241223, "stair", "_inner"},
        {20241223, "stair", "_outer"},
        {20241223, "stair", "_triple"},
        {20241223, "stair", "_wchimney"},
    },
}
local tools = {}

local function normalize_name(name)
    assert(type(name) == "string")
    if name:match("^:") then
        name = name:sub(2, -1)
    end
    if not name:match(":") then
        return nil
    end
    return name
end

local function reg_alias(old_name, new_name)
    assert(type(old_name) == "string")
    assert(type(new_name) == "string")
    if data[old_name] ~= nil then
        return
    end
    data[old_name] = {
        method = "alias",
        new_name = assert(new_name),
    }
end

local function reg_upgrade_tool(callback) -- => tool_handle
    assert(type(callback) == "function")
    table.insert(tools, callback)
    return {index = #tools}
end

local function reg_item(old_name, new_name, tool)
    assert(type(old_name) == "string")
    assert(type(new_name) == "string")
    if data[old_name] ~= nil then
        return
    end
    if new_name == old_name then
        error("[ch_unkrep] New name must be different then the old one ("..new_name..")!")
    end
    if core.registered_items[old_name] ~= nil then
        error("[ch_unkrep] Bad registration: "..old_name.." is a "..tostring(core.registered_items[old_name].type).."!")
    end
    if core.registered_items[new_name] == nil then
        error("[ch_unkrep] Bad registration: "..old_name.." would be repaired to an unknown item  "..new_name.."!")
    end
    local new_record = {
        method = "item",
        new_name = new_name,
    }
    if tool ~= nil then
        new_record.tool = tool.index
    end
    data[old_name] = new_record
end

local function reg_node(date, old_name, new_name, tool, no_lbm)
    assert(type(old_name) == "string")
    assert(type(new_name) == "string")
    if data[old_name] ~= nil then
        return
    end
    if new_name == old_name then
        error("[ch_unkrep] New name must be different then the old one ("..new_name..")!")
    end
    if core.registered_nodes[old_name] ~= nil then
        error("[ch_unkrep] Bad registration: "..old_name.." is a known node!")
    end
    if core.registered_nodes[new_name] == nil then
        error("[ch_unkrep] Bad registration: "..old_name.." would be repaired to an unknown node  "..new_name.."!")
    end
    local new_record = {
        method = "node",
        new_name = new_name,
    }
    if tool ~= nil then
        new_record.tool = tool.index
    end
    if not no_lbm then
        new_record.lbm_date = date
    end
    data[old_name] = new_record
end

local function reg_mb_alias(date, old_name, new_name)
    assert(type(date) == "number")
    assert(type(old_name) == "string")
    assert(type(new_name) == "string")
    old_name, new_name = normalize_name(old_name), normalize_name(new_name)
    if old_name == nil or new_name == nil then return end -- bad names
    local old_modname, old_varname = old_name:match("^([^:]+):(.*)$")
    local new_modname, new_varname = new_name:match("^([^:]+):(.*)$")
    if old_modname == nil or new_modname == nil or old_varname == nil or new_varname == nil then
        return
    end
    reg_alias(old_name, new_name)
    if old_modname == "default" then
        old_modname = "moreblocks"
    end
    if new_modname == "default" then
        new_modname = "moreblocks"
    end
    for _, shape in ipairs(assert(data)) do
        -- shape = {date, category, alternate}
        if shape[1] <= date then
            old_name = old_modname..":"..shape[2].."_"..old_varname..shape[3]
            new_name = new_modname..":"..shape[2].."_"..new_varname..shape[3]
            if core.registered_nodes[new_name] ~= nil then
                reg_alias(old_name, new_name)
            end
        end
    end
end

local function reg_mb_node(date, old_name, new_name, tool, no_lbm)
    assert(type(date) == "number")
    assert(type(old_name) == "string")
    assert(type(new_name) == "string")
    old_name, new_name = normalize_name(old_name), normalize_name(new_name)
    if old_name == nil or new_name == nil then return end -- bad names
    local old_modname, old_varname = old_name:match("^([^:]+):(.*)$")
    local new_modname, new_varname = new_name:match("^([^:]+):(.*)$")
    if old_modname == nil or new_modname == nil or old_varname == nil or new_varname == nil then
        return
    end
    reg_node(date, old_name, new_name, tool, no_lbm)
    if old_modname == "default" then
        old_modname = "moreblocks"
    end
    if new_modname == "default" then
        new_modname = "moreblocks"
    end
    for _, shape in ipairs(assert(data)) do
        -- shape = {date, category, alternate}
        if shape[1] <= date then
            old_name = old_modname..":"..shape[2].."_"..old_varname..shape[3]
            new_name = new_modname..":"..shape[2].."_"..new_varname..shape[3]
            if core.registered_nodes[new_name] ~= nil then
                reg_node(date, old_name, new_name, tool, no_lbm)
            end
        end
    end
end

local function get_data(old_name)
    if data == nil then
        -- load data from the file
        local f = io.open(filename)
        if f then
            local text = f:read("*a")
            f:close()
            data = core.deserialize(text, true)
            if type(data) ~= "table" then
                error("Deserialization of "..filename.." failed!")
            end
            next_clean_dtime = acc_dtime + 30
            if old_name == nil then
                print("DEBUG: unkrep data loaded")
            else
                print("DEBUG: unkrep data loaded because of '"..old_name.."'")
            end
        else
            error("Cannot open "..filename.."!")
        end
    end
    return data
end

function ch_unkrep.repair_itemstack(itemstack)
    if itemstack:is_empty() then
        return false
    end
    local name = itemstack:get_name()
    local my_data = get_data(name)
    local record = my_data[name]
    if record == nil then
        return false
    end
    local tool
    if record.tool ~= nil then
        tool = tools[record.tool]
    end
    if tool == nil then
        itemstack:set_name(record.new_name)
        return true
    else
        return tool("itemstack", itemstack, name, record.new_name)
    end
end

function ch_unkrep.repair_node(pos, node)
    local name = node.name
    local param2 = node.param2
    local my_data = get_data(name)
    local record = my_data[name]
    if record == nil or record.method == "item" then
        return false
    end
    local tool
    if record.tool ~= nil then
        tool = tools[record.tool]
    end
    if tool == nil then
        node.name = record.new_name
        core.swap_node(pos, node)
        core.log("action", "Unknown node "..name.."/"..param2.." at "..core.pos_to_string(pos).." repaired to "..node.name)
        return true
    elseif tool("node", pos, node, {name = assert(record.new_name), param = node.param, param2 = node.param2}) then
        core.log("action", "Unknown node "..name.."/"..param2.." at "..core.pos_to_string(pos).." repaired using a tool")
        return true
    else
        core.log("warning", "Unknown node "..name.."/"..param2.." at "..core.pos_to_string(pos).." not repaired, because the tool failed")
        return false
    end
end

local function lbm_action(pos, node, dtime_s)
    ch_unkrep.repair_node(pos, node)
end

local function commit_aliases_and_lbms()
    assert(data)
    local count, lbm_count, lbm_nn_count, alias_count = 0, 0, 0, 0
    local keys = {}
    local key = next(data)
    while key ~= nil do
        if key:sub(1, 1) ~= "." then
            table.insert(keys, key)
        end
        key = next(data, key)
    end
    -- Remove known items and commit aliases:
    for i = 1, #keys do
        local old_name = keys[i]
        local record = data[old_name]
        if core.registered_items[old_name] ~= nil then
            core.log("warning", old_name.." was registered for repair as unknown, but it is "..tostring(core.registered_items[old_name].type).."!")
            data[old_name] = nil
        elseif record.method == "alias" then
            if core.registered_aliases[old_name] ~= nil then
                core.log("warning", "[ch_unkrep] Alias '"..old_name.."' is already defined!")
            end
            core.register_alias(old_name, record.new_name)
            data[old_name] = nil
            alias_count = alias_count + 1
        elseif record.method == "node" and core.registered_nodes[record.new_name] == nil then
            core.log("warning", "[ch_unkrep] Bad registration: "..old_name.." will be repaired to an unknown node '"..record.new_name.."'!")
            count = count + 1
        elseif record.method == "item" and core.registered_items[record.new_name] == nil then
            core.log("warning", "[ch_unkrep] Bad registration: "..old_name.." will be repaired to an unknown item '"..record.new_name.."'!")
            count = count + 1
        else
            count = count + 1
        end
    end
    -- LBMs:
    local lbm_nodenames = {}
    for old_name, record in pairs(data) do
        local date = record.lbm_date
        if date ~= nil then
            local list = lbm_nodenames[date]
            if list == nil then
                list = {}
                lbm_nodenames[date] = list
            end
            table.insert(list, old_name)
            lbm_nn_count = lbm_nn_count + 1
        end
    end
    for date, nodenames in pairs(lbm_nodenames) do
        core.register_lbm({
            label = "Upgrade unknown nodes: "..date,
            name = "ch_unkrep:u_"..date,
            nodenames = nodenames,
            action = lbm_action,
        })
        lbm_count = lbm_count + 1
    end
    print("[ch_unkrep] Data generated: "..count.." old items, "..lbm_count.." LBMs with "..lbm_nn_count..
        " nodenames, "..alias_count.." new aliases.")
end

-- REGISTRATIONS
local tool_param2_to_0 = reg_upgrade_tool(function(type, ...)
    if type == "item" then
        local itemstack, old_name, new_name = ...
        itemstack:set_name(new_name)
        return true
    elseif type == "node" then
        local pos, old_node, new_node = ...
        new_node = 0
        core.swap_node(pos, new_node)
        return true
    else
        return false
    end
end)

local tool_param2_to_194 = reg_upgrade_tool(function(type, ...)
    if type == "item" then
        local itemstack, old_name, new_name = ...
        itemstack:set_name(new_name)
        return true
    elseif type == "node" then
        local pos, old_node, new_node = ...
        new_node = 194
        core.swap_node(pos, new_node)
        return true
    else
        return false
    end
end)

reg_item("aloz:aluminum_ingot", "default:steel_ingot")
reg_item("aloz:bauxite_lump", "default:iron_lump")

reg_node(20240823, "aloz:stone_with_bauxite", "default:stone_with_iron")
reg_node(20240823, "aloz:trapdoor_aluminum", "xpanes:trapdoor_steel_bar")
reg_node(20240823, "aloz:aluminum_block", "default:steelblock")
reg_node(20240823, "aloz:aluminum_beam", "default:steelblock")
reg_node(20240823, "bamboo:leaves", "air")
reg_node(20240823, "bamboo:sprout", "air")
reg_node(20240823, "bamboo:trunk", "air")
reg_node(20240823, "xpanes:aluminum_railing", "streets:fence_chainlink")
reg_node(20240823, "xpanes:aluminum_railing_flat", "streets:fence_chainlink")
reg_node(20240823, "xpanes:aluminum_barbed_wire", "streets:fence_chainlink")
reg_node(20240823, "xpanes:aluminum_barbed_wire_flat", "streets:fence_chainlink")
reg_mb_alias(20240823, "moretrees:beech_planks", "default:wood")
reg_mb_alias(20240823, "moretrees:beech_trunk_noface", "moreblocks:tree_noface")
reg_alias("moretrees:beech_trunk", "default:tree")
reg_alias("moretrees:beech_leaves", "default:leaves")
reg_alias("moretrees:beech_fence", "default:fence_wood")
reg_alias("moretrees:beech_fence_rail", "default:fence_rail_wood")
reg_alias("moretrees:beech_gate_closed", "default:gate_wood_closed")
reg_alias("moretrees:beech_gate_open", "default:gate_wood_open")
reg_alias("moretrees:beech_mese_post_light", "default:mese_post_light")
reg_alias("moretrees:beech_trunk_allfaces", "moreblocks:tree_allfaces")

reg_mb_alias(20240823, "chestnuttree:wood", "moretrees:chestnut_tree_planks")
reg_mb_alias(20240823, "chestnuttree:trunk_noface", "moretrees:chestnut_tree_trunk_noface")
reg_alias("chestnuttree:trunk", "moretrees:chestnut_tree_trunk")
reg_alias("chestnuttree:trunk_allfaces", "moretrees:chestnut_tree_trunk_allfaces")
reg_alias("chestnuttree:mese_post_light", "moretrees:chestnut_tree_mese_post_light")
reg_alias("chestnuttree:leaves", "moretrees:chestnut_tree_leaves")
reg_alias("chestnuttree:sapling", "moretrees:chestnut_tree_sapling")
reg_alias("chestnuttree:sapling_ongen", "moretrees:chestnut_tree_sapling_ongen")
reg_alias("chestnuttree:gate_open", "moretrees:chestnut_tree_gate_open")
reg_alias("chestnuttree:gate_closed", "moretrees:chestnut_tree_gate_closed")
reg_alias("chestnuttree:fence", "moretrees:chestnut_tree_fence")
reg_alias("chestnuttree:fence_rail", "moretrees:chestnut_tree_fence_rail")
reg_alias("chestnuttree:bur", "moretrees:bur")
reg_alias("chestnuttree:fruit", "moretrees:chestnut")
reg_alias("doors:door_chestnut_wood", "doors:door_luxury_wood")
reg_alias("doors:door_chestnut_wood_a", "doors:door_luxury_wood_a")
reg_alias("doors:door_chestnut_wood_b", "doors:door_luxury_wood_b")
reg_alias("doors:door_chestnut_wood_c", "doors:door_luxury_wood_c")
reg_alias("doors:door_chestnut_wood_cd", "doors:door_luxury_wood_cd")
reg_alias("doors:door_chestnut_wood_cd_a", "doors:door_luxury_wood_cd_a")
reg_alias("doors:door_chestnut_wood_cd_b", "doors:door_luxury_wood_cd_b")
reg_alias("doors:door_chestnut_wood_cd_c", "doors:door_luxury_wood_cd_c")
reg_alias("doors:door_chestnut_wood_cd_d", "doors:door_luxury_wood_cd_d")
reg_alias("doors:door_chestnut_wood_d", "doors:door_luxury_wood_d")

reg_mb_alias(20240823, "cherrytree:wood", "moretrees:cherry_tree_planks")
reg_mb_alias(20240823, "cherrytree:trunk_noface", "moretrees:cherry_tree_trunk_noface")
reg_alias("cherrytree:trunk", "moretrees:cherry_tree_trunk")
reg_alias("cherrytree:trunk_allfaces", "moretrees:cherry_tree_trunk_allfaces")
reg_alias("cherrytree:mese_post_light", "moretrees:cherry_tree_mese_post_light")
reg_alias("cherrytree:blossom_leaves", "moretrees:cherry_tree_leaves")
reg_alias("cherrytree:leaves", "moretrees:cherry_tree_leaves")
reg_alias("cherrytree:sapling", "moretrees:cherry_tree_sapling")
reg_alias("cherrytree:sapling_ongen", "moretrees:cherry_tree_sapling_ongen")
reg_alias("cherrytree:gate_open", "moretrees:cherry_tree_gate_open")
reg_alias("cherrytree:gate_closed", "moretrees:cherry_tree_gate_closed")
reg_alias("cherrytree:fence", "moretrees:cherry_tree_fence")
reg_alias("cherrytree:fence_rail", "moretrees:cherry_tree_fence_rail")
reg_alias("cherrytree:cherries", "moretrees:cherry")

reg_mb_alias(20240823, "ebony:wood", "moretrees:ebony_planks")
reg_mb_alias(20240823, "ebony:trunk_allfaces", "moretrees:ebony_trunk_allfaces")
reg_mb_alias(20240823, "ebony:ebony_trunk_noface", "moretrees:ebony_trunk_noface")
reg_mb_alias(20240823, "ebony:trunk", "moretrees:ebony_trunk")
reg_alias("ebony:mese_post_light", "moretrees:ebony_mese_post_light")
reg_alias("ebony:leaves", "moretrees:ebony_leaves")
reg_alias("ebony:sapling", "moretrees:ebony_sapling")
reg_alias("ebony:sapling_ongen", "moretrees:ebony_sapling_ongen")
reg_alias("ebony:gate_open", "moretrees:ebony_gate_open")
reg_alias("ebony:gate_closed", "moretrees:ebony_gate_closed")
reg_alias("ebony:fence", "moretrees:ebony_fence")
reg_alias("ebony:fence_rail", "moretrees:ebony_fence_rail")
reg_node(20240823, "ebony:persimmon", "air")
reg_node(20240823, "ebony:creeper", "air")
reg_node(20240823, "ebony:creeper_leaves", "air")
reg_node(20240823, "ebony:liana", "air")

reg_node(20240823, "jonez:blossom_pavement", "ch_extras:colorable_stone_block")
reg_node(20240823, "jonez:carthaginian_pavement", "moreblocks:iron_stone_bricks", tool_param2_to_0)
reg_node(20240823, "jonez:climbing_rose", "air")
reg_node(20240823, "jonez:diamond_pavement", "ch_decor:wood_tile")
reg_node(20240823, "jonez:industrial_base", "darkage:ors_brick", tool_param2_to_0)
reg_node(20240823, "jonez:industrial_shaft", "darkage:ors_brick", tool_param2_to_0)
reg_node(20240823, "jonez:minoan_shaft", "ch_extras:shaft")
reg_node(20240823, "jonez:mosaic_pavement", "moreblocks:iron_stone_bricks", tool_param2_to_0)
reg_node(20240823, "jonez:pompeiian_capital", "ch_extras:colorable_stone_block", tool_param2_to_194)
reg_node(20240823, "jonez:pompeiian_pavement", "ch_decor:wood_tile")
reg_node(20240823, "jonez:romantic_shaft", "ch_extras:shaft")
reg_node(20240823, "jonez:ruin_creeper", "air")
reg_node(20240823, "jonez:ruin_vine", "air")
reg_node(20240823, "jonez:swedish_ivy", "air")
reg_node(20240823, "jonez:tuscan_architrave", "ch_extras:colorable_stone_block")
reg_node(20240823, "jonez:versailles_architrave", "default:obsidian_block")
reg_node(20240823, "jonez:versailles_base", "ch_extras:shaft")
reg_node(20240823, "jonez:versailles_capital", "ch_extras:shaft")
reg_node(20240823, "jonez:versailles_shaft", "ch_extras:shaft")
--[[
for i = 1, 14 do
    for j = 0, 1 do
        lbm_replacements["tombs:jonez_marble_"..i.."_"..j] = {name = "tombs:ch_extras_marble_"..i.."_"..j}
    end
end
]]

reg_mb_alias(20240823, "plumtree:wood", "moretrees:plumtree_planks")
reg_mb_alias(20240823, "plumtree:trunk_noface", "moretrees:plumtree_trunk_noface")
reg_alias("plumtree:trunk", "moretrees:plumtree_trunk")
reg_alias("plumtree:trunk_allfaces", "moretrees:plumtree_trunk_allfaces")
reg_alias("plumtree:mese_post_light", "moretrees:plumtree_mese_post_light")
reg_alias("plumtree:leaves", "moretrees:plumtree_leaves")
reg_alias("plumtree:sapling", "moretrees:plumtree_sapling")
reg_alias("plumtree:sapling_ongen", "moretrees:plumtree_sapling_ongen")
reg_alias("plumtree:gate_open", "moretrees:plumtree_gate_open")
reg_alias("plumtree:gate_closed", "moretrees:plumtree_gate_closed")
reg_alias("plumtree:fence", "moretrees:plumtree_fence")
reg_alias("plumtree:fence_rail", "moretrees:plumtree_fence_rail")
reg_alias("plumtree:plum", "moretrees:plum")

reg_mb_alias(20240823, "willow:wood", "moretrees:willow_planks")
reg_mb_alias(20240823, "willow:trunk_noface", "moretrees:willow_trunk_noface")
reg_alias("willow:trunk", "moretrees:willow_trunk")
reg_alias("willow:trunk_allfaces", "moretrees:willow_trunk_allfaces")
reg_alias("willow:mese_post_light", "moretrees:willow_mese_post_light")
reg_alias("willow:leaves", "moretrees:willow_leaves")
reg_alias("willow:sapling", "moretrees:willow_sapling")
reg_alias("willow:sapling_ongen", "moretrees:willow_sapling_ongen")
reg_alias("willow:gate_open", "moretrees:willow_gate_open")
reg_alias("willow:gate_closed", "moretrees:willow_gate_closed")
reg_alias("willow:fence", "moretrees:willow_fence")
reg_alias("willow:fence_rail", "moretrees:willow_fence_rail")

reg_node(20241223, "moretrees:panel_palm_planks_l", "moretrees:panel_oak_planks_l")
reg_node(20241223, "moretrees:panel_palm_planks_special", "moretrees:panel_oak_planks_special")
reg_node(20241223, "default:tree_technic_cnc_stick", "moreblocks:panel_tree_noface_pole_flat")
reg_node(20241223, "ch_overrides:concrete_arcade", "technic:slab_concrete_arcade")
reg_node(20241223, "walls:cobble", "moreblocks:panel_cobble_wall")
reg_node(20241223, "walls:mossycobble", "moreblocks:panel_cobble_wall")
reg_node(20241223, "walls:desertcobble", "moreblocks:panel_desert_cobble_wall")
reg_node(20241223, "default:dirt_technic_cnc_valley", "moreblocks:slope_dirt_valley")
reg_node(20241223, "default:wood_technic_cnc_valley", "moreblocks:slope_wood_valley")

-- Plaster upgrade:
reg_node(20241223, "solidcolor:micro_plaster_red_4", "ch_core:micro_plaster_red_4")
reg_node(20241223, "solidcolor:micro_plaster_white_1", "ch_core:micro_plaster_white_1")
reg_node(20241223, "solidcolor:panel_plaster_medium_amber_s50", "ch_core:panel_plaster_medium_amber_s50")
reg_node(20241223, "solidcolor:panel_plaster_red_4", "ch_core:panel_plaster_red_4")
reg_node(20241223, "solidcolor:panel_plaster_white", "ch_core:panel_plaster_white")
reg_node(20241223, "solidcolor:panel_plaster_white_1", "ch_core:panel_plaster_white_1")
reg_node(20241223, "solidcolor:panel_plaster_white_l", "ch_core:panel_plaster_white_l")
reg_node(20241223, "solidcolor:panel_plaster_white_special", "ch_core:panel_plaster_white_special")
reg_node(20241223, "solidcolor:panel_plaster_yellow", "ch_core:panel_plaster_yellow")
reg_node(20241223, "solidcolor:plaster_blue", "ch_core:plaster_blue")
reg_node(20241223, "solidcolor:plaster_cyan", "ch_core:plaster_cyan")
reg_node(20241223, "solidcolor:plaster_dark_green", "ch_core:plaster_dark_green")
reg_node(20241223, "solidcolor:plaster_dark_grey", "ch_core:plaster_dark_grey")
reg_node(20241223, "solidcolor:plaster_green", "ch_core:plaster_green")
reg_node(20241223, "solidcolor:plaster_grey", "ch_core:plaster_grey")
reg_node(20241223, "solidcolor:plaster_medium_amber_s50", "ch_core:plaster_medium_amber_s50")
reg_node(20241223, "solidcolor:plaster_orange", "ch_core:plaster_orange")
reg_node(20241223, "solidcolor:plaster_pink", "ch_core:plaster_pink")
reg_node(20241223, "solidcolor:plaster_red", "ch_core:plaster_red")
reg_node(20241223, "solidcolor:plaster_white", "ch_core:plaster_white")
reg_node(20241223, "solidcolor:plaster_yellow", "ch_core:plaster_yellow")
reg_node(20241223, "solidcolor:slab_plaster_blue", "ch_core:slab_plaster_blue")
reg_node(20241223, "solidcolor:slab_plaster_blue_1", "ch_core:slab_plaster_blue_1")
reg_node(20241223, "solidcolor:slab_plaster_blue_2", "ch_core:slab_plaster_blue_2")
reg_node(20241223, "solidcolor:slab_plaster_blue_quarter", "ch_core:slab_plaster_blue_quarter")
reg_node(20241223, "solidcolor:slab_plaster_blue_triplet", "ch_core:slab_plaster_blue_triplet")
reg_node(20241223, "solidcolor:slab_plaster_blue_two_sides", "ch_core:slab_plaster_blue_two_sides")
reg_node(20241223, "solidcolor:slab_plaster_cyan", "ch_core:slab_plaster_cyan")
reg_node(20241223, "solidcolor:slab_plaster_cyan_1", "ch_core:slab_plaster_cyan_1")
reg_node(20241223, "solidcolor:slab_plaster_cyan_2", "ch_core:slab_plaster_cyan_2")
reg_node(20241223, "solidcolor:slab_plaster_cyan_quarter", "ch_core:slab_plaster_cyan_quarter")
reg_node(20241223, "solidcolor:slab_plaster_cyan_triplet", "ch_core:slab_plaster_cyan_triplet")
reg_node(20241223, "solidcolor:slab_plaster_cyan_two_sides", "ch_core:slab_plaster_cyan_two_sides")
reg_node(20241223, "solidcolor:slab_plaster_dark_green", "ch_core:slab_plaster_dark_green")
reg_node(20241223, "solidcolor:slab_plaster_dark_green_1", "ch_core:slab_plaster_dark_green_1")
reg_node(20241223, "solidcolor:slab_plaster_dark_green_2", "ch_core:slab_plaster_dark_green_2")
reg_node(20241223, "solidcolor:slab_plaster_dark_green_quarter", "ch_core:slab_plaster_dark_green_quarter")
reg_node(20241223, "solidcolor:slab_plaster_dark_green_triplet", "ch_core:slab_plaster_dark_green_triplet")
reg_node(20241223, "solidcolor:slab_plaster_dark_green_two_sides", "ch_core:slab_plaster_dark_green_two_sides")
reg_node(20241223, "solidcolor:slab_plaster_dark_grey", "ch_core:slab_plaster_dark_grey")
reg_node(20241223, "solidcolor:slab_plaster_dark_grey_1", "ch_core:slab_plaster_dark_grey_1")
reg_node(20241223, "solidcolor:slab_plaster_dark_grey_2", "ch_core:slab_plaster_dark_grey_2")
reg_node(20241223, "solidcolor:slab_plaster_dark_grey_quarter", "ch_core:slab_plaster_dark_grey_quarter")
reg_node(20241223, "solidcolor:slab_plaster_dark_grey_triplet", "ch_core:slab_plaster_dark_grey_triplet")
reg_node(20241223, "solidcolor:slab_plaster_dark_grey_two_sides", "ch_core:slab_plaster_dark_grey_two_sides")
reg_node(20241223, "solidcolor:slab_plaster_green", "ch_core:slab_plaster_green")
reg_node(20241223, "solidcolor:slab_plaster_green_1", "ch_core:slab_plaster_green_1")
reg_node(20241223, "solidcolor:slab_plaster_green_2", "ch_core:slab_plaster_green_2")
reg_node(20241223, "solidcolor:slab_plaster_green_quarter", "ch_core:slab_plaster_green_quarter")
reg_node(20241223, "solidcolor:slab_plaster_green_triplet", "ch_core:slab_plaster_green_triplet")
reg_node(20241223, "solidcolor:slab_plaster_green_two_sides", "ch_core:slab_plaster_green_two_sides")
reg_node(20241223, "solidcolor:slab_plaster_grey", "ch_core:slab_plaster_grey")
reg_node(20241223, "solidcolor:slab_plaster_grey_1", "ch_core:slab_plaster_grey_1")
reg_node(20241223, "solidcolor:slab_plaster_grey_2", "ch_core:slab_plaster_grey_2")
reg_node(20241223, "solidcolor:slab_plaster_grey_quarter", "ch_core:slab_plaster_grey_quarter")
reg_node(20241223, "solidcolor:slab_plaster_grey_triplet", "ch_core:slab_plaster_grey_triplet")
reg_node(20241223, "solidcolor:slab_plaster_grey_two_sides", "ch_core:slab_plaster_grey_two_sides")
reg_node(20241223, "solidcolor:slab_plaster_medium_amber_s50", "ch_core:slab_plaster_medium_amber_s50")
reg_node(20241223, "solidcolor:slab_plaster_medium_amber_s50_1", "ch_core:slab_plaster_medium_amber_s50_1")
reg_node(20241223, "solidcolor:slab_plaster_medium_amber_s50_15", "ch_core:slab_plaster_medium_amber_s50_15")
reg_node(20241223, "solidcolor:slab_plaster_medium_amber_s50_2", "ch_core:slab_plaster_medium_amber_s50_2")
reg_node(20241223, "solidcolor:slab_plaster_medium_amber_s50_quarter", "ch_core:slab_plaster_medium_amber_s50_quarter")
reg_node(20241223, "solidcolor:slab_plaster_medium_amber_s50_triplet", "ch_core:slab_plaster_medium_amber_s50_triplet")
reg_node(20241223, "solidcolor:slab_plaster_medium_amber_s50_two_sides", "ch_core:slab_plaster_medium_amber_s50_two_sides")
reg_node(20241223, "solidcolor:slab_plaster_orange", "ch_core:slab_plaster_orange")
reg_node(20241223, "solidcolor:slab_plaster_orange_1", "ch_core:slab_plaster_orange_1")
reg_node(20241223, "solidcolor:slab_plaster_orange_2", "ch_core:slab_plaster_orange_2")
reg_node(20241223, "solidcolor:slab_plaster_orange_quarter", "ch_core:slab_plaster_orange_quarter")
reg_node(20241223, "solidcolor:slab_plaster_orange_triplet", "ch_core:slab_plaster_orange_triplet")
reg_node(20241223, "solidcolor:slab_plaster_orange_two_sides", "ch_core:slab_plaster_orange_two_sides")
reg_node(20241223, "solidcolor:slab_plaster_pink", "ch_core:slab_plaster_pink")
reg_node(20241223, "solidcolor:slab_plaster_pink_1", "ch_core:slab_plaster_pink_1")
reg_node(20241223, "solidcolor:slab_plaster_pink_2", "ch_core:slab_plaster_pink_2")
reg_node(20241223, "solidcolor:slab_plaster_pink_quarter", "ch_core:slab_plaster_pink_quarter")
reg_node(20241223, "solidcolor:slab_plaster_pink_triplet", "ch_core:slab_plaster_pink_triplet")
reg_node(20241223, "solidcolor:slab_plaster_pink_two_sides", "ch_core:slab_plaster_pink_two_sides")
reg_node(20241223, "solidcolor:slab_plaster_red", "ch_core:slab_plaster_red")
reg_node(20241223, "solidcolor:slab_plaster_red_1", "ch_core:slab_plaster_red_1")
reg_node(20241223, "solidcolor:slab_plaster_red_2", "ch_core:slab_plaster_red_2")
reg_node(20241223, "solidcolor:slab_plaster_red_quarter", "ch_core:slab_plaster_red_quarter")
reg_node(20241223, "solidcolor:slab_plaster_red_triplet", "ch_core:slab_plaster_red_triplet")
reg_node(20241223, "solidcolor:slab_plaster_red_two_sides", "ch_core:slab_plaster_red_two_sides")
reg_node(20241223, "solidcolor:slab_plaster_white", "ch_core:slab_plaster_white")
reg_node(20241223, "solidcolor:slab_plaster_white_1", "ch_core:slab_plaster_white_1")
reg_node(20241223, "solidcolor:slab_plaster_white_2", "ch_core:slab_plaster_white_2")
reg_node(20241223, "solidcolor:slab_plaster_white_quarter", "ch_core:slab_plaster_white_quarter")
reg_node(20241223, "solidcolor:slab_plaster_white_triplet", "ch_core:slab_plaster_white_triplet")
reg_node(20241223, "solidcolor:slab_plaster_white_two_sides", "ch_core:slab_plaster_white_two_sides")
reg_node(20241223, "solidcolor:slab_plaster_yellow", "ch_core:slab_plaster_yellow")
reg_node(20241223, "solidcolor:slab_plaster_yellow_1", "ch_core:slab_plaster_yellow_1")
reg_node(20241223, "solidcolor:slab_plaster_yellow_2", "ch_core:slab_plaster_yellow_2")
reg_node(20241223, "solidcolor:slab_plaster_yellow_quarter", "ch_core:slab_plaster_yellow_quarter")
reg_node(20241223, "solidcolor:slab_plaster_yellow_triplet", "ch_core:slab_plaster_yellow_triplet")
reg_node(20241223, "solidcolor:slab_plaster_yellow_two_sides", "ch_core:slab_plaster_yellow_two_sides")
reg_node(20241223, "solidcolor:slope_plaster_blue", "ch_core:slope_plaster_blue")
reg_node(20241223, "solidcolor:slope_plaster_blue_half", "ch_core:slope_plaster_blue_half")
reg_node(20241223, "solidcolor:slope_plaster_blue_half_raised", "ch_core:slope_plaster_blue_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_blue_slab", "ch_core:slope_plaster_blue_slab")
reg_node(20241223, "solidcolor:slope_plaster_cyan", "ch_core:slope_plaster_cyan")
reg_node(20241223, "solidcolor:slope_plaster_cyan_half", "ch_core:slope_plaster_cyan_half")
reg_node(20241223, "solidcolor:slope_plaster_cyan_half_raised", "ch_core:slope_plaster_cyan_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_cyan_slab", "ch_core:slope_plaster_cyan_slab")
reg_node(20241223, "solidcolor:slope_plaster_dark_green", "ch_core:slope_plaster_dark_green")
reg_node(20241223, "solidcolor:slope_plaster_dark_green_half", "ch_core:slope_plaster_dark_green_half")
reg_node(20241223, "solidcolor:slope_plaster_dark_green_half_raised", "ch_core:slope_plaster_dark_green_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_dark_green_slab", "ch_core:slope_plaster_dark_green_slab")
reg_node(20241223, "solidcolor:slope_plaster_dark_green_tripleslope", "ch_core:slope_plaster_dark_green_tripleslope")
reg_node(20241223, "solidcolor:slope_plaster_dark_grey", "ch_core:slope_plaster_dark_grey")
reg_node(20241223, "solidcolor:slope_plaster_dark_grey_half", "ch_core:slope_plaster_dark_grey_half")
reg_node(20241223, "solidcolor:slope_plaster_dark_grey_half_raised", "ch_core:slope_plaster_dark_grey_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_dark_grey_slab", "ch_core:slope_plaster_dark_grey_slab")
reg_node(20241223, "solidcolor:slope_plaster_dark_grey_tripleslope", "ch_core:slope_plaster_dark_grey_tripleslope")
reg_node(20241223, "solidcolor:slope_plaster_green", "ch_core:slope_plaster_green")
reg_node(20241223, "solidcolor:slope_plaster_green_half", "ch_core:slope_plaster_green_half")
reg_node(20241223, "solidcolor:slope_plaster_green_half_raised", "ch_core:slope_plaster_green_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_green_slab", "ch_core:slope_plaster_green_slab")
reg_node(20241223, "solidcolor:slope_plaster_grey", "ch_core:slope_plaster_grey")
reg_node(20241223, "solidcolor:slope_plaster_grey_half", "ch_core:slope_plaster_grey_half")
reg_node(20241223, "solidcolor:slope_plaster_grey_half_raised", "ch_core:slope_plaster_grey_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_grey_slab", "ch_core:slope_plaster_grey_slab")
reg_node(20241223, "solidcolor:slope_plaster_medium_amber_s50", "ch_core:slope_plaster_medium_amber_s50")
reg_node(20241223, "solidcolor:slope_plaster_medium_amber_s50_half", "ch_core:slope_plaster_medium_amber_s50_half")
reg_node(20241223, "solidcolor:slope_plaster_medium_amber_s50_half_raised", "ch_core:slope_plaster_medium_amber_s50_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_medium_amber_s50_slab", "ch_core:slope_plaster_medium_amber_s50_slab")
reg_node(20241223, "solidcolor:slope_plaster_orange", "ch_core:slope_plaster_orange")
reg_node(20241223, "solidcolor:slope_plaster_orange_half", "ch_core:slope_plaster_orange_half")
reg_node(20241223, "solidcolor:slope_plaster_orange_half_raised", "ch_core:slope_plaster_orange_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_orange_slab", "ch_core:slope_plaster_orange_slab")
reg_node(20241223, "solidcolor:slope_plaster_pink", "ch_core:slope_plaster_pink")
reg_node(20241223, "solidcolor:slope_plaster_pink_half", "ch_core:slope_plaster_pink_half")
reg_node(20241223, "solidcolor:slope_plaster_pink_half_raised", "ch_core:slope_plaster_pink_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_pink_slab", "ch_core:slope_plaster_pink_slab")
reg_node(20241223, "solidcolor:slope_plaster_red", "ch_core:slope_plaster_red")
reg_node(20241223, "solidcolor:slope_plaster_red_half", "ch_core:slope_plaster_red_half")
reg_node(20241223, "solidcolor:slope_plaster_red_half_raised", "ch_core:slope_plaster_red_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_red_slab", "ch_core:slope_plaster_red_slab")
reg_node(20241223, "solidcolor:slope_plaster_white", "ch_core:slope_plaster_white")
reg_node(20241223, "solidcolor:slope_plaster_white_half", "ch_core:slope_plaster_white_half")
reg_node(20241223, "solidcolor:slope_plaster_white_half_raised", "ch_core:slope_plaster_white_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_white_inner_half", "ch_core:slope_plaster_white_inner_half")
reg_node(20241223, "solidcolor:slope_plaster_white_inner_half_raised", "ch_core:slope_plaster_white_inner_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_white_outer_half", "ch_core:slope_plaster_white_outer_half")
reg_node(20241223, "solidcolor:slope_plaster_white_outer_half_raised", "ch_core:slope_plaster_white_outer_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_white_slab", "ch_core:slope_plaster_white_slab")
reg_node(20241223, "solidcolor:slope_plaster_yellow", "ch_core:slope_plaster_yellow")
reg_node(20241223, "solidcolor:slope_plaster_yellow_half", "ch_core:slope_plaster_yellow_half")
reg_node(20241223, "solidcolor:slope_plaster_yellow_half_raised", "ch_core:slope_plaster_yellow_half_raised")
reg_node(20241223, "solidcolor:slope_plaster_yellow_slab", "ch_core:slope_plaster_yellow_slab")
reg_node(20241223, "solidcolor:stair_plaster_medium_amber_s50", "ch_core:stair_plaster_medium_amber_s50")
reg_node(20241223, "solidcolor:stair_plaster_white_chimney", "ch_core:stair_plaster_white_chimney")

-- CNC stick upgrade:
reg_node(20241223, "bakedclay:black_technic_cnc_stick", "bakedclay:panel_black_pole_flat")
reg_node(20241223, "bakedclay:blue_technic_cnc_stick", "bakedclay:panel_blue_pole_flat")
reg_node(20241223, "bakedclay:brown_technic_cnc_stick", "bakedclay:panel_brown_pole_flat")
reg_node(20241223, "bakedclay:cyan_technic_cnc_stick", "bakedclay:panel_cyan_pole_flat")
reg_node(20241223, "bakedclay:dark_green_technic_cnc_stick", "bakedclay:panel_dark_green_pole_flat")
reg_node(20241223, "bakedclay:dark_grey_technic_cnc_stick", "bakedclay:panel_dark_grey_pole_flat")
reg_node(20241223, "bakedclay:green_technic_cnc_stick", "bakedclay:panel_green_pole_flat")
reg_node(20241223, "bakedclay:grey_technic_cnc_stick", "bakedclay:panel_grey_pole_flat")
reg_node(20241223, "bakedclay:magenta_technic_cnc_stick", "bakedclay:panel_magenta_pole_flat")
reg_node(20241223, "bakedclay:natural_technic_cnc_stick", "bakedclay:panel_natural_pole_flat")
reg_node(20241223, "bakedclay:orange_technic_cnc_stick", "bakedclay:panel_orange_pole_flat")
reg_node(20241223, "bakedclay:pink_technic_cnc_stick", "bakedclay:panel_pink_pole_flat")
reg_node(20241223, "bakedclay:red_technic_cnc_stick", "bakedclay:panel_red_pole_flat")
reg_node(20241223, "bakedclay:violet_technic_cnc_stick", "bakedclay:panel_violet_pole_flat")
reg_node(20241223, "bakedclay:white_technic_cnc_stick", "bakedclay:panel_white_pole_flat")
reg_node(20241223, "bakedclay:yellow_technic_cnc_stick", "bakedclay:panel_yellow_pole_flat")
reg_node(20241223, "building_blocks:fakegrass_technic_cnc_stick", "building_blocks:panel_fakegrass_pole_flat")
reg_node(20241223, "cottages:black_technic_cnc_stick", "cottages:panel_black_pole_flat")
reg_node(20241223, "cottages:brown_technic_cnc_stick", "cottages:panel_brown_pole_flat")
reg_node(20241223, "cottages:red_technic_cnc_stick", "cottages:panel_red_pole_flat")
reg_node(20241223, "cottages:reet_technic_cnc_stick", "cottages:panel_reet_pole_flat")
reg_node(20241223, "darkage:slate_tile_technic_cnc_stick", "darkage:panel_slate_tile_pole_flat")
reg_node(20241223, "default:acacia_wood_technic_cnc_stick", "moreblocks:panel_acacia_wood_pole_flat")
reg_node(20241223, "default:aspen_wood_technic_cnc_stick", "moreblocks:panel_aspen_wood_pole_flat")
reg_node(20241223, "default:brick_technic_cnc_stick", "moreblocks:panel_brick_pole_flat")
reg_node(20241223, "default:bronzeblock_technic_cnc_stick", "moreblocks:panel_bronzeblock_pole_flat")
reg_node(20241223, "default:cobble_technic_cnc_stick", "moreblocks:panel_cobble_pole_flat")
reg_node(20241223, "default:copperblock_technic_cnc_stick", "moreblocks:panel_copperblock_pole_flat")
reg_node(20241223, "default:desert_cobble_technic_cnc_stick", "moreblocks:panel_desert_cobble_pole_flat")
reg_node(20241223, "default:desert_sandstone_block_technic_cnc_stick", "moreblocks:panel_desert_sandstone_block_pole_flat")
reg_node(20241223, "default:desert_sandstone_brick_technic_cnc_stick", "moreblocks:panel_desert_sandstone_brick_pole_flat")
reg_node(20241223, "default:desert_sandstone_technic_cnc_stick", "moreblocks:panel_desert_sandstone_pole_flat")
reg_node(20241223, "default:desert_stone_block_technic_cnc_stick", "moreblocks:panel_desert_stone_block_pole_flat")
reg_node(20241223, "default:desert_stone_technic_cnc_stick", "moreblocks:panel_desert_stone_pole_flat")
reg_node(20241223, "default:desert_stonebrick_technic_cnc_stick", "moreblocks:panel_desert_stonebrick_pole_flat")
reg_node(20241223, "default:dirt_technic_cnc_stick", "moreblocks:panel_dirt_pole_flat")
reg_node(20241223, "default:goldblock_technic_cnc_stick", "moreblocks:panel_goldblock_pole_flat")
reg_node(20241223, "default:ice_technic_cnc_stick", "moreblocks:panel_ice_pole_flat")
reg_node(20241223, "default:junglewood_technic_cnc_stick", "moreblocks:panel_junglewood_pole_flat")
reg_node(20241223, "default:meselamp_technic_cnc_stick", "moreblocks:panel_meselamp_pole_flat")
reg_node(20241223, "default:obsidian_block_technic_cnc_stick", "moreblocks:panel_obsidian_block_pole_flat")
reg_node(20241223, "default:pine_wood_technic_cnc_stick", "moreblocks:panel_pine_wood_pole_flat")
reg_node(20241223, "default:silver_sandstone_block_technic_cnc_stick", "moreblocks:panel_silver_sandstone_block_pole_flat")
reg_node(20241223, "default:silver_sandstone_brick_technic_cnc_stick", "moreblocks:panel_silver_sandstone_brick_pole_flat")
reg_node(20241223, "default:silver_sandstone_technic_cnc_stick", "moreblocks:panel_silver_sandstone_pole_flat")
reg_node(20241223, "default:steelblock_technic_cnc_stick", "moreblocks:panel_steelblock_pole_flat")
reg_node(20241223, "default:stone_block_technic_cnc_stick", "moreblocks:panel_stone_block_pole_flat")
reg_node(20241223, "default:stone_technic_cnc_stick", "moreblocks:panel_stone_pole_flat")
reg_node(20241223, "default:stonebrick_technic_cnc_stick", "moreblocks:panel_stonebrick_pole_flat")
reg_node(20241223, "default:wood_technic_cnc_stick", "moreblocks:panel_wood_pole_flat")
reg_node(20241223, "moreblocks:cactus_brick_technic_cnc_stick", "moreblocks:panel_cactus_brick_pole_flat")
reg_node(20241223, "moreblocks:cactus_checker_technic_cnc_stick", "moreblocks:panel_cactus_checker_pole_flat")
reg_node(20241223, "moreblocks:copperpatina_technic_cnc_stick", "moreblocks:panel_copperpatina_pole_flat")
reg_node(20241223, "moreblocks:grey_bricks_technic_cnc_stick", "moreblocks:panel_grey_bricks_pole_flat")
reg_node(20241223, "technic:blast_resistant_concrete_technic_cnc_stick", "technic:panel_blast_resistant_concrete_pole_flat")
reg_node(20241223, "technic:cast_iron_block_technic_cnc_stick", "technic:panel_cast_iron_block_pole_flat")
reg_node(20241223, "technic:granite_technic_cnc_stick", "technic:panel_granite_pole_flat")
reg_node(20241223, "technic:marble_technic_cnc_stick", "technic:panel_marble_pole_flat")
reg_node(20241223, "technic:warning_block_technic_cnc_stick", "technic:panel_warning_block_pole_flat")
reg_node(20241223, "technic:zinc_block_technic_cnc_stick", "technic:panel_zinc_block_pole_flat")

-- Roof upgrade:
reg_node(20241223, "bakedclay:black_technic_cnc_d45_slope_216", "bakedclay:slope_black_roof45")
reg_node(20241223, "bakedclay:black_technic_cnc_d45_slope_216_3", "bakedclay:slope_black_roof45_3")
reg_node(20241223, "bakedclay:blue_technic_cnc_d45_slope_216", "bakedclay:slope_blue_roof45")
reg_node(20241223, "bakedclay:blue_technic_cnc_d45_slope_216_3", "bakedclay:slope_blue_roof45_3")
reg_node(20241223, "cottages:black_technic_cnc_d45_slope_216", "cottages:slope_black_roof45")
reg_node(20241223, "cottages:black_technic_cnc_d45_slope_216_3", "cottages:slope_black_roof45_3")
reg_node(20241223, "cottages:brown_technic_cnc_d45_slope_216", "cottages:slope_brown_roof45")
reg_node(20241223, "cottages:brown_technic_cnc_d45_slope_216_3", "cottages:slope_brown_roof45_3")
reg_node(20241223, "cottages:red_technic_cnc_d45_slope_216", "cottages:slope_red_roof45")
reg_node(20241223, "cottages:red_technic_cnc_d45_slope_216_3", "cottages:slope_red_roof45_3")
reg_node(20241223, "cottages:reet_technic_cnc_d45_slope_216", "cottages:slope_reet_roof45")
reg_node(20241223, "cottages:reet_technic_cnc_d45_slope_216_3", "cottages:slope_reet_roof45_3")
reg_node(20241223, "darkage:slate_tile_technic_cnc_d45_slope_216", "darkage:slope_slate_tile_roof45")
reg_node(20241223, "darkage:slate_tile_technic_cnc_d45_slope_216_3", "darkage:slope_slate_tile_roof45_3")
reg_node(20241223, "default:acacia_wood_technic_cnc_d45_slope_216", "moreblocks:slope_acacia_wood_roof45")
reg_node(20241223, "default:acacia_wood_technic_cnc_d45_slope_216_3", "moreblocks:slope_acacia_wood_roof45_3")
reg_node(20241223, "default:aspen_wood_technic_cnc_d45_slope_216", "moreblocks:slope_aspen_wood_roof45")
reg_node(20241223, "default:aspen_wood_technic_cnc_d45_slope_216_3", "moreblocks:slope_aspen_wood_roof45_3")
reg_node(20241223, "default:copperblock_technic_cnc_d45_slope_216", "moreblocks:slope_copperblock_roof45")
reg_node(20241223, "default:copperblock_technic_cnc_d45_slope_216_3", "moreblocks:slope_copperblock_roof45_3")
reg_node(20241223, "default:junglewood_technic_cnc_d45_slope_216", "moreblocks:slope_junglewood_roof45")
reg_node(20241223, "default:junglewood_technic_cnc_d45_slope_216_3", "moreblocks:slope_junglewood_roof45_3")
reg_node(20241223, "default:obsidian_glass_technic_cnc_d45_slope_216", "moreblocks:slope_obsidian_glass_roof45")
reg_node(20241223, "default:obsidian_glass_technic_cnc_d45_slope_216_3", "moreblocks:slope_obsidian_glass_roof45_3")
reg_node(20241223, "default:pine_wood_technic_cnc_d45_slope_216", "moreblocks:slope_pine_wood_roof45")
reg_node(20241223, "default:pine_wood_technic_cnc_d45_slope_216_3", "moreblocks:slope_pine_wood_roof45_3")
reg_node(20241223, "default:steelblock_technic_cnc_d45_slope_216", "moreblocks:slope_steelblock_roof45")
reg_node(20241223, "default:steelblock_technic_cnc_d45_slope_216_3", "moreblocks:slope_steelblock_roof45_3")
reg_node(20241223, "default:wood_technic_cnc_d45_slope_216", "moreblocks:slope_wood_roof45")
reg_node(20241223, "default:wood_technic_cnc_d45_slope_216_3", "moreblocks:slope_wood_roof45_3")
reg_node(20241223, "farming:straw_technic_cnc_d45_slope_216", "moreblocks:slope_straw_roof45")
reg_node(20241223, "farming:straw_technic_cnc_d45_slope_216_3", "moreblocks:slope_straw_roof45_3")
reg_node(20241223, "moreblocks:cactus_checker_technic_cnc_d45_slope_216", "moreblocks:slope_cactus_checker_roof45")
reg_node(20241223, "moreblocks:cactus_checker_technic_cnc_d45_slope_216_3", "moreblocks:slope_cactus_checker_roof45_3")
reg_node(20241223, "moreblocks:copperpatina_technic_cnc_d45_slope_216", "moreblocks:slope_copperpatina_roof45")
reg_node(20241223, "moreblocks:copperpatina_technic_cnc_d45_slope_216_3", "moreblocks:slope_copperpatina_roof45_3")
reg_node(20241223, "technic:cast_iron_block_technic_cnc_d45_slope_216", "technic:slope_cast_iron_block_roof45")
reg_node(20241223, "technic:cast_iron_block_technic_cnc_d45_slope_216_3", "technic:slope_cast_iron_block_roof45_3")
reg_node(20241223, "technic:zinc_block_technic_cnc_d45_slope_216", "technic:slope_zinc_block_roof45")
reg_node(20241223, "technic:zinc_block_technic_cnc_d45_slope_216_3", "technic:slope_zinc_block_roof45_3")
reg_item("building_blocks:grate", "ch_extras:grate_1")
reg_item("building_blocks:slope_grate_half", "ch_extras:grate_1")
reg_item("building_blocks:slope_grate_half_raised", "ch_extras:grate_1")

reg_node(20241230, "solidcolor:solid_block", "ch_extras:colorable_plastic")

-- END OF REGISTRATIONS
commit_aliases_and_lbms()

local function globalstep(dtime)
    acc_dtime = acc_dtime + dtime
    if acc_dtime < next_clean_dtime then
        return
    end
    if next_clean_dtime == 0 then
        -- first call => save the data
        local text = core.serialize(data)
        if text == nil then
            core.log("error", "[ch_unkrep] Data serialization failed!")
            return
        end
        core.safe_file_write(filename, text)
    end
    if data ~= nil then
        data = nil
        print("DEBUG: unkrep data cleared")
    end
    next_clean_dtime = acc_dtime + 30
end
core.register_globalstep(globalstep)
