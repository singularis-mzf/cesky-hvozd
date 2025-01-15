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
        description = "blok plastu (lakovaný)",
        tiles = {"ch_core_white_pixel.png"},
        groups = {dig_immediate = 2, ud_param2_colorable = 1}
    },
    ["ch_extras:colorable_plaster"] = {
        description = "blok omítky (lakovaný)",
        tiles = {"ch_core_clay.png"},
        groups = {cracky = 1, plaster = 1, ud_param2_colorable = 1},
    },
    ["ch_extras:colorable_cobble"] = {
        description = "lakovaný dlažební kámen",
        tiles = {"default_cobble.png"},
        groups = {cracky = 3, stone = 2, ud_param2_colorable = 1},
    },
    ["ch_extras:colorable_stone_block"] = {
        description = "lakovaný kamenný blok",
        tiles = {"ch_extras_stone_block.png"},
        groups = {cracky = 2, stone = 1, ud_param2_colorable = 1},
    },
    ["ch_extras:colorable_stone_brick"] = {
        description = "lakované kamenné cihly",
        tiles = {"default_stone_brick.png^[brighten"},
        groups = {cracky = 2, stone = 1, ud_param2_colorable = 1},
    },
    ["ch_extras:colorable_stone_brick_2"] = {
        description = "lakované kamenné cihly (textury otočené o 90°)",
        tiles = {"default_stone_brick.png^[brighten^[transformR90"},
        groups = {cracky = 2, stone = 1, ud_param2_colorable = 1},
        drop = {items = {{items = {"ch_extras:colorable_stone_brick"}, inherit_color = true}}},
        on_dig = core.node_dig,
    },
    ["ch_extras:colorable_texture"] = {
        description = "lakovaný texturovaný blok",
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

ch_core.register_shape_selector_group({
    nodes = {"ch_extras:colorable_stone_brick", "ch_extras:colorable_stone_brick_2"},
})
