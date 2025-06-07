if core.get_modpath("display_api") and core.get_modpath("font_api") and core.get_modpath("signs_api") then
    local def = {
        width = 8/16, height = 8/16, depth = 1/16,
        node_fields = {
            description = "linková cedule",
            tiles = {{name = "ch_core_white_pixel.png", backface_culling = true}},
            paramtype = "light",
            paramtype2 = "color4dir",
            palette = "ch_extras_line_sign_palette.png",
            light_source = 12,
            is_ground_content = false,
            sunlight_propagates = true,
            groups = {choppy = 2, flammable = 2, oddly_breakable_by_hand = 3},
            sounds = default.node_sound_wood_defaults(),
            on_place = display_api.on_place,
            _ch_help = "Nabízí sortiment barev volitelný dlátem. Obvykle si budete muset přizpůsobit barvu písma.",
        },
        entity_fields = {
            depth = 0.5 - 1/16 - display_api.entity_spacing,
			top = 0, -- display_entity.depth = def.selection_box.fixed[1][3] - display_api.entity_spacing + (shape_def.text_depth_shift or 0)
			aspect_ratio = 0.5,
			size = {x = 8/16, y = 10/16},
            meta_lines_default = 1,
			maxlines = 2,
            font_name = "dvssans",
			on_display_update = assert(font_api.on_display_update),
			meta_color = "sign_text_color",
			meta_halign = "sign_halign",
            meta_lines = "sign_lines",
			-- meta_valign = "sign_valign",
        }
    }
    signs_api.register_sign("ch_extras", "line_sign", def)
    local name = "ch_extras:line_sign"
    local on_construct_old = core.registered_nodes[name].on_construct or function(...) end
    core.override_item(name, {
        on_construct = function(pos)
            on_construct_old(pos)
            core.get_meta(pos):set_string("font", "dvssans")
        end,
    })
    ch_core.register_shape_selector_group({
        columns = 5,
        nodes = {
            {name = name, param2 = 0x0304},
            {name = name, param2 = 0x0308},
            {name = name, param2 = 0x030C},
            {name = name, param2 = 0x0310},
            {name = name, param2 = 0x0314},
            {name = name, param2 = 0x0318},
            {name = name, param2 = 0x031C},
            {name = name, param2 = 0x0320},
            {name = name, param2 = 0x0324},
            {name = name, param2 = 0x0328},
            {name = name, param2 = 0x032C},
            {name = name, param2 = 0x0330},
            {name = name, param2 = 0x0334},
            {name = name, param2 = 0x0338},
            {name = name, param2 = 0x033C},
            {name = name, param2 = 0x0340},
            {name = name, param2 = 0x0344},
            {name = name, param2 = 0x0348},
            {name = name, param2 = 0x034C},
            {name = name, param2 = 0x0350},
            {name = name, param2 = 0x0300},
        },
    })
    core.register_craft({
        output = "ch_extras:line_sign",
        recipe = {{"ch_extras:line_sign"}},
    })
    core.register_craft({
        output = "ch_extras:line_sign 3",
        recipe = {
            {"group:letter", "group:letter", "group:letter"},
            {"", "group:dye", ""},
            {"", "technic:cast_iron_ingot", ""},
        }
    })
end
