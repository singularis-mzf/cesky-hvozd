--[[
    signs mod for Minetest - Various signs with text displayed on
    (c) Pierre-Yves Rollo

    This file is part of signs.

    signs is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    signs is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with signs.  If not, see <http://www.gnu.org/licenses/>.
--]]

local S = signs.S
local F = function(...) return minetest.formspec_escape(S(...)) end

-- Poster specific formspec
local function display_poster(pos, node, player)
	local meta = minetest.get_meta(pos)

	local ndef = core.registered_nodes[node.name]
	local def = ndef.display_entities["signs:display_text"]
	local font = font_api.get_font(meta:get_string("font") or def.font_name)

	local fs
	local fname = string.format("%s@%s:display",
		node.name, minetest.pos_to_string(pos))

	-- Title texture
	local titletexture = font:render(meta:get_string("display_text"),
		font:get_height()*8.4, font:get_height(), { lines = 1 })

	-- Background texture
	local bgtexture = core.formspec_escape("[combine:1x1:-"..math.floor((node.param2 or 0) / 32)..",0="..assert(ndef.palette).."^[opacity:63")

	fs = string.format(
		"formspec_version[6]"..
		"size[8,11]"..
		"bgcolor[#0000]"..
		"background[0,0;8,10;signs_poster_formspec.png^[multiply:#f0f0f0]"..
		"image[0,0;8,11;%s]".. -- background
		"image[0,-0.2;8.4,2;%s]"..
		"style_type[textarea;textcolor=#111;font_size=+4]"..
		"textarea[0.3,1.75;7.5,8.1;;%s;]",
		bgtexture,
		titletexture,
		minetest.formspec_escape(meta:get_string("text")))

	if minetest.is_protected(pos, player:get_player_name()) then
		fs = string.format("%sbutton_exit[2.5,10;2,1;ok;%s]", fs, F("Close"))
	else
		fs = string.format(
			"%sbutton[1.5,10;2,1;edit;%s]button_exit[4.5,10;2,1;ok;%s]",
			fs, F("Edit"), F("Close"))
	end
	minetest.show_formspec(player:get_player_name(), fname, fs)
end

local function edit_poster(pos, node, player)
	local meta = minetest.get_meta(pos)

	local fs
	local fname = string.format("%s@%s:edit",
		node.name, minetest.pos_to_string(pos))

	if not minetest.is_protected(pos, player:get_player_name()) then
		fs = string.format([=[
			size[6.5,7.5]%s%s%s
			field[0.5,0.7;6,1;display_text;%s;%s]
			textarea[0.5,1.7;6,6;text;%s;%s]
			button[1.25,7;2,1;font;%s]
			button_exit[3.25,7;2,1;write;%s]]=],
			default.gui_bg, default.gui_bg_img, default.gui_slots, F("Title"),
			minetest.formspec_escape(meta:get_string("display_text")),
			F("Text"), minetest.formspec_escape(meta:get_string("text")),
			F("Title font"), F("Write"))
		minetest.show_formspec(player:get_player_name(), fname, fs)
	end
end

-- Poster specific on_receive_fields callback
local function on_receive_fields_poster(pos, formname, fields, player)
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)

	if not minetest.is_protected(pos, player:get_player_name()) and fields then
		if formname == node.name.."@"..minetest.pos_to_string(pos)..":display"
		   and fields.edit then
			edit_poster(pos, node, player)
			return true
		end
		if formname == node.name.."@"..minetest.pos_to_string(pos)..":edit"
		then
			if (fields.write or fields.font or fields.key_enter) then
				meta:set_string("display_text", fields.display_text)
				meta:set_string("text", fields.text)
				local infotext_lines = ch_core.utf8_wrap(fields.text, 50, {allow_empty_lines = false, max_result_lines = 7, line_separator = "\n"})
				if #infotext_lines == 7 then
					infotext_lines[6] = S("(right-click to read more text)")
					infotext_lines[7] = nil
				end
				meta:set_string("infotext", table.concat(infotext_lines))
				display_api.update_entities(pos)
			end
			if (fields.write or fields.key_enter) then
				display_poster(pos, node, player)
			elseif (fields.font) then
				font_api.show_font_list(player, pos, function (playername, pos)
						local player = minetest.get_player_by_name(playername)
						local node = minetest.get_node(pos)
						if player and node then
							edit_poster(pos, node, player)
						end
					end)
			end
			return true
		end
	end
end

local function on_punch(pos, node, player, pointed_thing)
	display_api.update_entities(pos)
end

-- Text entity for all signs
display_api.register_display_entity("signs:display_text")

-- Sign models and registration
local models = {
	wooden_sign = {
		depth = 1/16, width = 14/16, height = 12/16,
		entity_fields = {
			size = { x = 12/16, y = 10/16 },
			maxlines = 3,
			color = "#000",
		},
		node_fields = {
			description = S("Wooden sign"),
			tiles = { "signs_wooden.png" },
			inventory_image = "signs_wooden_inventory.png",
			groups= { dig_immediate = 2 },
		},
	},
	wooden_long_sign = {
		depth = 1/16, width = 1, height = 7/16,
		entity_fields = {
			size = { x = 1, y = 6/16 },
			maxlines = 2,
			color = "#000",
		},
		node_fields = {
			description = S("Wooden long sign"),
			tiles = { "signs_wooden_long.png", "signs_wooden_long.png",
			"signs_wooden_long.png^[transformR90",
			"signs_wooden_long.png^[transformR90",
			"signs_wooden_long.png", "signs_wooden_long.png",
			},
			inventory_image = "signs_wooden_long_inventory.png",
			groups= { dig_immediate = 2 },
		},
	},
	wooden_right_sign = {
		depth = 1/16, width = 14/16, height = 7/16,
		entity_fields = {
			right = -3/32,
			size = { x = 12/16, y = 6/16 },
			maxlines = 2,
			color="#000",
		},
		node_fields = {
			description = S("Wooden direction sign"),
			tiles = { "signs_wooden_direction.png" },
			inventory_image = "signs_wooden_direction_inventory.png",
			signs_other_dir = 'signs:wooden_left_sign',
			on_place = signs_api.on_place_direction,
			drawtype = "mesh",
			mesh = "signs_dir_right.obj",
			selection_box = { type="fixed", fixed = {-0.5, -7/32, 0.5, 7/16, 7/32, 7/16}},
			collision_box = { type="fixed", fixed = {-0,5, -7/32, 0.5, 7/16, 7/32, 7/16}},
			groups= { dig_immediate = 2 },
		},
	},
	wooden_left_sign = {
		depth = 1/16, width = 14/16, height = 7/16,
		entity_fields = {
			right = 3/32,
			size = { x = 12/16, y = 6/16 },
			maxlines = 2,
			color = "#000",
		},
		node_fields = {
			description = S("Wooden direction sign"),
			tiles = { "signs_wooden_direction.png" },
			inventory_image = "signs_wooden_direction_inventory.png^[transformFX",
			signs_other_dir = 'signs:wooden_right_sign',
			drawtype = "mesh",
			mesh = "signs_dir_left.obj",
			selection_box = { type="fixed", fixed = {-7/16, -7/32, 0.5, 0.5, 7/32, 7/16}},
			collision_box = { type="fixed", fixed = {-7/16, -7/32, 0.5, 0.5, 7/32, 7/16}},
			groups = { not_in_creative_inventory = 1, dig_immediate = 2 },
			drop = "signs:wooden_right_sign",
		},
	},
	paper_poster = {
		depth = 1/32, width = 26/32, height = 30/32,
		entity_fields = {
			top = -11/32,
			size = { x = 26/32, y = 6/32 },
			maxlines = 1,
			color = "#000",
		},
		node_fields = {
			description = S("Poster"),
			tiles = { "signs_poster_sides.png", "signs_poster_sides.png",
			          "signs_poster_sides.png", "signs_poster_sides.png",
			          "signs_poster_sides.png", "signs_poster.png" },
			use_texture_alpha = "opaque",
			inventory_image = "signs_poster_inventory.png",
			groups= { dig_immediate = 2 },
			on_construct = display_api.on_construct,
			on_rightclick = display_poster,
			on_receive_fields = on_receive_fields_poster,
			on_punch = on_punch,
		},
	},
	label_small = {
		depth = 1/32, width = 4/16, height = 4/16,
		entity_fields = {
			size = { x = 4/16, y = 4/16 },
			maxlines = 1,
			color = "#000",
		},
		node_fields = {
			description = S("Small label"),
			tiles = { "signs_label.png" },
			inventory_image = "signs_label_small_inventory.png",
			groups= { dig_immediate = 3 },
		},
	},
	label_medium = {
		depth = 1/32, width = 8/16, height = 8/16,
		entity_fields = {
			size = { x = 8/16, y = 8/16 },
			maxlines = 2,
			color = "#000",
		},
		node_fields = {
			description = S("Label"),
			tiles = { "signs_label.png" },
			inventory_image = "signs_label_medium_inventory.png",
			groups= { dig_immediate = 3 },
		},
	},
}

models.paper_poster.node_fields.paramtype2 = "colorfacedir"
models.paper_poster.node_fields.palette = "signs_poster_palette1.png"

models.paper_poster2 = table.copy(models.paper_poster)
models.paper_poster2.node_fields = table.copy(models.paper_poster.node_fields)
models.paper_poster2.node_fields.groups = table.copy(models.paper_poster.node_fields.groups)

models.paper_poster2.node_fields.groups.not_in_creative_inventory = 1
models.paper_poster2.node_fields.palette = "signs_poster_palette2.png"
models.paper_poster2.node_fields.drop = "signs:paper_poster"
-- models.paper_poster2.node_fields.drop = {items = {{items = {"signs:paper_poster"}, inherit_color = false}}}

-- Node registration
for name, model in pairs(models)
do
	signs_api.register_sign("signs", name, model)
end

ch_core.register_shape_selector_group({
	nodes = {
		"signs:wooden_long_sign",
		"signs:wooden_left_sign",
		"signs:wooden_right_sign",
	},
	after_change = function(pos, old_node, new_node, player, nodespec)
		on_punch(pos)
	end,
})

ch_core.register_shape_selector_group({
    columns = 4, rows = 4, check_owner = true,
    nodes = {
        {name = "signs:paper_poster", param2 = 0x1F00,},
        {name = "signs:paper_poster", param2 = 0x1F20,},
        {name = "signs:paper_poster", param2 = 0x1F40,},
        {name = "signs:paper_poster", param2 = 0x1F60,},
        {name = "signs:paper_poster", param2 = 0x1F80,},
        {name = "signs:paper_poster", param2 = 0x1FA0,},
        {name = "signs:paper_poster", param2 = 0x1FC0,},
        {name = "signs:paper_poster", param2 = 0x1FE0,},
        {name = "signs:paper_poster2", param2 = 0x1F00, color = "#f6e7ae"},
        {name = "signs:paper_poster2", param2 = 0x1F20, color = "#efc9c8"},
        {name = "signs:paper_poster2", param2 = 0x1F40, color = "#73d9dc"},
        {name = "signs:paper_poster2", param2 = 0x1F60, color = "#adf2b1"},
        {name = "signs:paper_poster2", param2 = 0x1F80, color = "#e9e601"},
        {name = "signs:paper_poster2", param2 = 0x1FA0, color = "#fe8a08"},
        {name = "signs:paper_poster2", param2 = 0x1FC0, color = "#78db07"},
        {name = "signs:paper_poster2", param2 = 0x1FE0, color = "#c9b3ff"},
    },
})
