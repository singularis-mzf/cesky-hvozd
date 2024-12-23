local dye_row = {"dye:red", "dye:green", "dye:blue"}

local function generate_recipe(input_material, output)
    local material_row = {input_material, input_material, input_material}
    return {output = output, recipe = {dye_row, material_row, material_row}}
end

ch_core.register_nodes({
    -- common defs:
    paramtype2 = "color",
    palette = "unifieddyes_palette_extended.png",
    is_ground_content = false,
    sounds = default.node_sound_stone_defaults(),
    on_construct = unifieddyes.on_construct,
    on_dig = unifieddyes.on_dig,
}, {
    ["ch_extras:colorable_plastic"] = {
        description = "blok plastu (barvitelný)",
        tiles = {"ch_core_white_pixel.png"},
        groups = {dig_immediate = 2, ud_param2_colorable = 1}
    },
    ["ch_extras:colorable_plaster"] = {
        description = "blok omítky (barvitelný)",
        tiles = {"ch_core_clay.png"},
        groups = {cracky = 1, plaster = 1, ud_param2_colorable = 1},
    },
    ["ch_extras:colorable_cobble"] = {
        description = "barvitelný dlažební kámen",
        tiles = {"default_cobble.png"},
        groups = {cracky = 3, stone = 2, ud_param2_colorable = 1},
    },
    ["ch_extras:colorable_stone_block"] = {
        description = "barvitelný kamenný blok",
        tiles = {"ch_extras_stone_block.png"},
        groups = {cracky = 2, stone = 1, ud_param2_colorable = 1},
    },
    ["ch_extras:colorable_stone_brick"] = {
        description = "barvitelné kamenné cihly",
        tiles = {"default_stone_brick.png^[brighten"},
        groups = {cracky = 2, stone = 1, ud_param2_colorable = 1},
    },
    ["ch_extras:colorable_stone_brick_2"] = {
        description = "barvitelné kamenné cihly (textury otočené o 90°)",
        tiles = {"default_stone_brick.png^[brighten^[transformR90"},
        groups = {cracky = 2, stone = 1, ud_param2_colorable = 1},
        drop = {items = {{items = {"ch_extras:colorable_stone_brick"}, inherit_color = true}}},
        on_dig = core.node_dig,
    },
    ["ch_extras:colorable_texture"] = {
        description = "barvitelný texturovaný blok",
        tiles = {"ch_extras_small_noise.png"},
        groups = {cracky = 2, oddly_breakable_by_hand = 2, ud_param2_colorable = 1},
    }
}, {
    {output = "ch_extras:colorable_plastic",
    recipe = {
        {"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"},
        {"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"},
        {"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"},
    }},
    generate_recipe("group:plaster", "ch_extras:colorable_plaster 6"),
    generate_recipe("default:cobble", "ch_extras:colorable_cobble 6"),
    generate_recipe("default:desert_cobble", "ch_extras:colorable_cobble 6"),
    generate_recipe("default:stone_block", "ch_extras:colorable_stone_block 6"),
    generate_recipe("default:desert_stone_block", "ch_extras:colorable_stone_block 6"),
    generate_recipe("default:stonebrick", "ch_extras:colorable_stone_brick 6"),
    generate_recipe("default:desert_stonebrick", "ch_extras:colorable_stone_brick 6"),
    {output = "ch_extras:colorable_texture",
    recipe = {
        {"dye:red", "dye:green", "dye:blue"},
        {"group:sand", "default:dirt", "group:sand"},
        {"default:clay_lump", "default:clay_lump", "default:clay_lump"},
    }},
})

local map = {
    ["solidcolor:solid_block"] = "ch_extras:colorable_plastic",
    ["solidcolor:clay_block"] = "ch_extras:colorable_plaster",
    ["solidcolor:cobble_block"] = "ch_extras:colorable_cobble",
    ["solidcolor:stoneblock_block"] = "ch_extras:colorable_stone_block",
    ["solidcolor:stonebrick_block"] = "ch_extras:colorable_stone_brick",
    ["solidcolor:noise_block"] = "ch_extras:colorable_texture",
}
local legacy_nodes = {}
for n, _ in pairs(map) do
    table.insert(legacy_nodes, n)
end
core.register_lbm({
    label = "Upgrade legacy solidcolor nodes",
    name = "ch_extras:upgrade_solidcolor_nodes_v2",
    nodenames = legacy_nodes,
    action = function(pos, node, dtime_s)
        local old_name = node.name
        node.name = map[old_name]
        if node.name ~= nil and core.registered_nodes[node.name] then
            core.swap_node(pos, node)
            core.log("action", old_name.."/"..node.param2.." upgraded to "..node.name.." at "..core.pos_to_string(pos).." (dtime_s="..tostring(dtime_s)..")")
        else
            core.log("error", map[old_name].." not registered for upgrade!")
        end
    end,
})

ch_core.register_shape_selector_group({
    nodes = {"ch_extras:colorable_stone_brick", "ch_extras:colorable_stone_brick_2"},
})
