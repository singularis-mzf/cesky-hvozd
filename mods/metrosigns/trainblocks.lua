---------------------------------------------------------------------------------------------------
-- metrosigns mod for minetest by A S Lewis
--      https://github.com/axcore/metrosigns
--      Licence: GNU Affero GPL
---------------------------------------------------------------------------------------------------
-- Code/textures from trainblocks by Maxx
--      https://github.com/maxhipp/trainblocks_bc
--      https://forum.minetest.net/viewtopic.php?t=19743
--      Licence: GNU Affero GPL
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Original material from trainblocks by Maxx
---------------------------------------------------------------------------------------------------

if not HAVE_TRAINBLOCKS_FLAG and
        (metrosigns.create_all_flag or metrosigns.create_trainblocks_flag) then

	local display_entity_name = "tombs:text"
	display_api.register_display_entity(display_entity_name)

    local category = "tramvajové cedule"
    metrosigns.register_category(category)

	local _ch_help = "Tyto směrovky jsou barvitelné barvicí pistolí.\nPro výběr barvy je nutno Shift+pravý klik, protože jen pravý klik otevře okno s textem."
	local _ch_help_group = "mtsgns"

	local box_groups = {cracky = 3}
	local box_light_source = 10

    minetest.register_node("metrosigns:tb_sign_station", {
        description = "značka stanice",
        tiles = {
            "trainblocks_sign_station_blank.png",
            "trainblocks_sign_station_blank.png",
            "trainblocks_sign_station_blank.png",
            "trainblocks_sign_station_blank.png",
            "trainblocks_sign_station_text.png",
            "trainblocks_sign_station_text.png",
        },
        groups = {cracky = 3},

        drawtype = "nodebox",
        inventory_image = "trainblocks_sign_station_text.png",
        is_ground_content = false,
        light_source = 6,
        node_box = {
            type = "fixed",
            fixed = {
                {-8/16, -5/16, 6/16,  8/16,  5/16, 8/16},
            },
        },
        paramtype = "light",
        paramtype2 = "facedir",
    })
    metrosigns.register_sign(category, "metrosigns:tb_sign_station", metrosigns.writer.sign_units)

    minetest.register_node("metrosigns:tb_sign_station_exit_left", {
        description = "směrovka vlevo: stanice",
        tiles = {
            "trainblocks_sign_station_blank.png",
            "trainblocks_sign_station_blank.png",
            "trainblocks_sign_station_blank.png",
            "trainblocks_sign_station_blank.png",
            "trainblocks_sign_station_exit_text.png",
            "trainblocks_sign_station_exit_text.png^[transformFX",
        },
        groups = {cracky = 3},

        drawtype = "nodebox",
        inventory_image = "trainblocks_sign_station_exit_text.png^[transformFX",
        is_ground_content = false,
        light_source = 6,
        node_box = {
            type = "fixed",
            fixed = {
                {-8/16, -5/16, 6/16,  8/16,  5/16, 8/16},
            },
        },
        paramtype = "light",
        paramtype2 = "facedir",
    })
    metrosigns.register_sign(
        category, "metrosigns:tb_sign_station_exit_left", metrosigns.writer.sign_units
    )

    minetest.register_node("metrosigns:tb_sign_station_exit_right", {
        description = "směrovka vpravo: stanice",
        tiles = {
            "trainblocks_sign_station_blank.png",
            "trainblocks_sign_station_blank.png",
            "trainblocks_sign_station_blank.png",
            "trainblocks_sign_station_blank.png",
            "trainblocks_sign_station_exit_text.png",
            "trainblocks_sign_station_exit_text.png",
        },
        groups = {cracky = 3},

        drawtype = "nodebox",
        inventory_image = "trainblocks_sign_station_exit_text.png",
        is_ground_content = false,
        light_source = 6,
        node_box = {
            type = "fixed",
            fixed = {
                {-8/16, -5/16, 6/16,  8/16,  5/16, 8/16},
            },
        },
        paramtype = "light",
        paramtype2 = "facedir",
    })
    metrosigns.register_sign(
        category, "metrosigns:tb_sign_station_exit_right", metrosigns.writer.sign_units
    )

	local function on_construct(pos)
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]
		if not ndef then
			minetest.log("error", "[metrosigns] on_construct called on unknown node "..node.name.."!")
			return
		end
		local meta = minetest.get_meta(pos)
		local formspec = {
			"formspec_version[4]", -- [1]
			"size[6,4]", -- [2]
			default.gui_bg, -- [3]
			default.gui_bg_img, -- [4]
			default.gui_slots, -- [5]
			"textarea[0.5,0.7;5,2;display_text;", -- [6]
			"Text", -- [7]
			";${display_text}]",
			"button[0.5,3;2.25,0.75;font;Písmo]",
			"button_exit[3.25,3;2.25,0.75;ok;Napsat]",
		}
		local maxlines
		if ndef.display_entities ~= nil then
			maxlines = ndef.display_entities[display_entity_name].maxlines or 1
		end
		if maxlines == nil then
			formspec[7] = "Text (jen infotext):"
		elseif maxlines == 1 then
			formspec[7] = "Text (jen 1 řádek):"
		elseif 2 <= maxlines and maxlines <= 4 then
			formspec[7] = "Text (max. "..maxlines.." řádky):"
		else
			formspec[7] = "Text (max. "..maxlines.." řádek):"
		end
		meta:set_string("formspec", table.concat(formspec))
	end
	local function after_place_node(pos, placer, itemstack, pointed_thing)
		local result = unifieddyes.fix_rotation_nsew(pos, placer, itemstack, pointed_thing)
		minetest.get_meta(pos):set_string("owner",placer:get_player_name())
		return result
	end
	local function on_receive_fields(pos, formname, fields, sender)
		local player_name = sender and sender:get_player_name()
		if not player_name then
			return
		end
		if minetest.is_protected(pos, player_name) then
			minetest.record_protection_violation(pos, player_name)
			return
		end
		local node = minetest.get_node(pos)
		local meta = minetest.get_meta(pos)
		if fields.ok or fields.font then
			meta:set_string("display_text", fields.display_text)
			meta:set_string("infotext", fields.display_text)
			minetest.log("action", "Player "..player_name.." wrote this on "..node.name.." at "..minetest.pos_to_string(pos).." owned by '"..meta:get_string("owner").."': >>>"..fields.display_text.."<<<")
			display_api.update_entities(pos)
		end
		if fields.font then
			font_api.show_font_list(sender, pos)
		end
	end
	local def = {
		description = "svítící barvitelná směrovka vlevo",
		tiles = {
			"ch_core_white_pixel.png^[resize:32x32",
			"ch_core_white_pixel.png^[resize:32x32",
			"ch_core_white_pixel.png^[resize:32x32",
			"ch_core_white_pixel.png^[resize:32x32",
			"ch_core_white_pixel.png^[resize:32x32",
			"ch_core_white_pixel.png^[resize:32x32",
		},
		overlay_tiles = {
			{name = "metrosigns_ch_sign_overlay.png", color = "white", backface_culling = false},
			{name = "metrosigns_ch_sign_overlay.png", color = "white", backface_culling = false},
			{name = "metrosigns_ch_exit_sign_overlay_black.png^[transformR90", color = "white", backface_culling = false},
			{name = "metrosigns_ch_exit_sign_overlay_black.png^[transformR270", color = "white", backface_culling = false},
			{name = "metrosigns_ch_sign_overlay.png^[transformR90", color = "white", backface_culling = false},
			{name = "metrosigns_ch_sign_overlay.png^[transformR270", color = "white", backface_culling = false},
		},
		drawtype = "nodebox",
		inventory_image = "ch_core_white_pixel.png^[resize:32x32^metrosigns_ch_exit_sign_overlay_black.png^[transformFX",
		is_ground_content = false,
		light_source = 5,
		node_box = {
			type = "fixed",
			fixed = {
				-- {-8/16, -5/16, 6/16,  8/16,  5/16, 8/16},
				{ 6/16, -8/16, -5/16, 8/16, 8/16, 5/16 },
			},
		},
		paramtype = "light",
		paramtype2 = "colorwallmounted",
		groups = {cracky = 3, ud_param2_colorable = 1},
		palette = "unifieddyes_palette_colorwallmounted.png",
		after_place_node = after_place_node,
		on_dig = unifieddyes.on_dig,
		on_construct = on_construct,
		on_destruct = display_api.on_destruct,
		on_rotate = display_api.on_rotate,
		on_place = display_api.on_place,
		on_punch = display_api.update_entities,
		on_receive_fields = on_receive_fields,
		display_entities = {
			[display_entity_name] = {
				depth = -2/16, -- right
				top = 0/32, -- top?
				right = 5.75/16, -- depth
				aspect_ratio = 0.3, -- font width
				yaw = math.pi / 2,
				size = {x = 9/16, y = 8/16},
				maxlines = 2,
				on_display_update = font_api.on_display_update,
			},
		},
		_ch_help = _ch_help,
		_ch_help_group = _ch_help_group,
	}
	minetest.register_node("metrosigns:sign_exit_left", table.copy(def))
	metrosigns.register_sign(category, "metrosigns:sign_exit_left", metrosigns.writer.sign_units)


	def.description = "svítící barvitelná směrovka vpravo"
	def.overlay_tiles = {
		def.overlay_tiles[1],
		def.overlay_tiles[2],
		def.overlay_tiles[4],
		def.overlay_tiles[3],
		def.overlay_tiles[6],
		def.overlay_tiles[5],
	}
	def.inventory_image = "ch_core_white_pixel.png^[resize:32x32^metrosigns_ch_exit_sign_overlay_black.png"
	local x = table.copy(def.display_entities[display_entity_name])
	x.depth = -x.depth
	def.display_entities = {[display_entity_name] = x}
	minetest.register_node("metrosigns:sign_exit_right", table.copy(def))
	metrosigns.register_sign(category, "metrosigns:sign_exit_right", metrosigns.writer.sign_units)

--[[
    minetest.register_node("metrosigns:tb_box_berlin_sbahn", {
        description = "Berlin S-Bahn lightbox (trainblocks)",
        tiles = {
            "trainblocks_box_berlin_sbahn_top.png",
            "trainblocks_box_berlin_sbahn_top.png",
            "trainblocks_box_berlin_sbahn_side.png",
            "trainblocks_box_berlin_sbahn_side.png",
            "trainblocks_box_berlin_sbahn_side.png",
            "trainblocks_box_berlin_sbahn_side.png",
        },
        groups = box_groups,

        light_source = box_light_source,
    })
    metrosigns.register_sign(
        category, "metrosigns:tb_box_berlin_sbahn", metrosigns.writer.box_units
    )
]]

	local linky = {
		[1] = {bgcolor = "#1e00ff"},
		[2] = {bgcolor = "#ff001e"},
		[3] = {bgcolor = "#7f007f"},
		[4] = {bgcolor = "#007f00"},
		[5] = {bgcolor = "#ffa400"},
		[6] = {bgcolor = "#ffff00", color = "#000000"},
		[7] = {bgcolor = "#797979"},
		[8] = {bgcolor = "#ff1ed0"},
		[9] = {bgcolor = "#00c0b1"},
		[10] = {bgcolor = "#000000"},
		[11] = {bgcolor = "#499ca5"},
		[12] = {bgcolor = "#8cfdee", color = "#000000"},
		[13] = {bgcolor = "#cf5f38"},
		[14] = {bgcolor = "#13c081"},
		[15] = {bgcolor = "#5622ca"},
		[16] = {bgcolor = "#998314"},
		[17] = {bgcolor = "#dce45d", color = "#000000"},
		[18] = {bgcolor = "#2046a6"},
		[19] = {bgcolor = "#63a7ef"},
		[20] = {bgcolor = "#a60939"},
	}

	for l, ldef in ipairs(linky) do
		local num = ("0"..l):sub(-2,-1)
		local hdigit, ldigit = num:sub(1,1), num:sub(2,2)
		local tiles_texture, inv_texture
		local bgcolor = ldef.bgcolor or "#000000"
		local color = ldef.color or "#ffffff"

		if hdigit == "0" then
			-- single-digit line
			tiles_texture = "[combine:128x128"..
				":0,0=ch_core_white_pixel.png\\^[multiply\\:"..bgcolor.."\\^[resize\\:128x128"..
				":32,32=ch_core_white_pixel.png\\^[multiply\\:"..color.."\\^[resize\\:64x64\\^(letters_"..ldigit.."_overlay.png\\^[resize\\:64x64)\\^[makealpha\\:255,126,126"..
				"^[resize:64x64"
			inv_texture = "[combine:64x64"..
				":0,0=ch_core_white_pixel.png\\^[multiply\\:"..bgcolor.."\\^[resize\\:64x64"..
				":0,0=ch_core_white_pixel.png\\^[multiply\\:"..color.."\\^[resize\\:64x64\\^(letters_"..ldigit.."_overlay.png\\^[resize\\:64x64)\\^[makealpha\\:255,126,126"
		else
			-- two-digit line
			tiles_texture = "[combine:240x128"..
				":0,0=ch_core_white_pixel.png\\^[multiply\\:"..bgcolor.."\\^[resize\\:240x128"..
				":64,32=ch_core_white_pixel.png\\^[multiply\\:"..color.."\\^[resize\\:64x64\\^(letters_"..hdigit.."_overlay.png\\^[resize\\:64x64)\\^[makealpha\\:255,126,126"..
				":112,32=ch_core_white_pixel.png\\^[multiply\\:"..color.."\\^[resize\\:64x64\\^(letters_"..ldigit.."_overlay.png\\^[resize\\:64x64)\\^[makealpha\\:255,126,126"..
				"^[resize:64x64"
			inv_texture = "[combine:128x64"..
				":0,0=ch_core_white_pixel.png\\^[multiply\\:"..bgcolor.."\\^[resize\\:176x64"..
				":8,0=ch_core_white_pixel.png\\^[multiply\\:"..color.."\\^[resize\\:64x64\\^(letters_"..hdigit.."_overlay.png\\^[resize\\:64x64)\\^[makealpha\\:255,126,126"..
				":56,0=ch_core_white_pixel.png\\^[multiply\\:"..color.."\\^[resize\\:64x64\\^(letters_"..ldigit.."_overlay.png\\^[resize\\:64x64)\\^[makealpha\\:255,126,126"..
				"^[resize:64x64"
		end

		minetest.register_node("metrosigns:tb_sign_line_"..num, {
			description = "("..num..") značka: linka "..l,
			tiles = {
				{ name = tiles_texture, backface_culling = true },
				{ name = "ch_core_white_pixel.png", color = bgcolor, backface_culling = true },
			},
            groups = {attached_node = 1, choppy = 2, flammable = 2, oddly_breakable_by_hand = 3},

            drawtype = "nodebox",
            inventory_image = inv_texture,
            is_ground_content = false,
            legacy_wallmounted = true,
            light_source = 12,
            node_box = {
                type = "wallmounted",
                wall_top = {-8/16, -4/16, -4/16, -7/16, 4/16, 4/16},
                wall_bottom = {-8/16, -4/16, -4/16, -7/16, 4/16, 4/16},
                wall_side = {-8/16, -4/16, -4/16, -7/16, 4/16, 4/16},
            },
            paramtype = "light",
            paramtype2 = "wallmounted",
            sunlight_propagates = true,
            walkable = false
        })
        metrosigns.register_sign(category, "metrosigns:tb_sign_line_"..num, metrosigns.writer.sign_units)
    end
end
