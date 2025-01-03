--[[
    signs_road mod for Minetest - Various road signs with text displayed
    on.
    (c) Pierre-Yves Rollo

    This file is part of signs_road.

    signs_road is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    signs_road is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with signs_road.  If not, see <http://www.gnu.org/licenses/>.
--]]

local ifthenelse = assert(ch_core.ifthenelse)
local S = signs_road.intllib

local prefix5 = "[combine:32x32:-16,-16=ch_core_5.png^"

local colored_sign_entity_size = { x = 1, y = 6/16 }
local invisible_sign_entity_size = { x = 3, y = 12/16 }
local large_sign_size = { x = 4, y = 12/16 }
local dir_sign_entity_size = { x = 12/16, y = 6/16 }

local cbox_left = { type = "fixed", fixed = { -7/16, -7/32, 0.5, 0.5, 7/32, 7/16 } }
local cbox_right = { type = "fixed", fixed = { -0.5, -7/32, 0.5, 7/16, 7/32, 7/16 } }

local blank_tiles = { "blank.png", "blank.png", "blank.png", "blank.png", "blank.png", "blank.png" }

local function colored_sign_def(defs)
	-- a) description, text_color, sign_color, [other_tile]
	-- b) description, text_color, inventory_image, front_tile, [other_tile]
	local sign_color = defs.sign_color
	local other_tile = defs.other_tile or "signs_road_sides.png"
	local front_tile, inventory_image
	if sign_color ~= nil then
		front_tile = "signs_road_white.png^[multiply:"..sign_color
		inventory_image = front_tile
	else
		front_tile = assert(defs.front_tile)
		inventory_image = assert(defs.inventory_image)
	end
	return {
		depth = 1/16,
		width = 1,
		height = 7/16,
		entity_fields = {
			size = colored_sign_entity_size,
			maxlines = 2,
			color = assert(defs.text_color),
			meta_color = "sign_text_color",
			aspect_ratio = 1/2,
		},
		node_fields = {
			description = assert(defs.description),
			tiles = { other_tile, other_tile, other_tile, other_tile, other_tile, front_tile },
			use_texture_alpha = "opaque",
			inventory_image = inventory_image,
		},
		allow_on_pole = true,
	}
end

local function inv_sign_def(defs)
	return {
		depth = 1/128,
		width = 4/16,
		height = 4/16,
		entity_fields = {
			size = invisible_sign_entity_size,
			maxlines = 4,
			color = assert(defs.text_color),
			aspect_ratio = 1/2,
		},
		node_fields = {
			description = assert(defs.description),
			tiles = blank_tiles,
			use_texture_alpha = "clip",
			inventory_image = "signs_road_white.png^[multiply:#999999^(signs_road_letter.png^[multiply:"..defs.text_color..
				")^default_invisible_node_overlay.png",
		},
		allow_on_pole = true,
	}
end

local function large_sign_def(defs)
	local sign_color = assert(defs.sign_color)
	local other_tile = defs.other_tile or "signs_road_sides.png"
	return {
		depth = 1/16,
		width = 64/16,
		height = 12/16,
		entity_fields = {
			maxlines = 1,
			color = assert(defs.text_color),
			aspect_ratio = 1/2,
		},
		node_fields = {
			description = assert(defs.description),
			visual_scale = 1,
			tiles = { other_tile, other_tile, other_tile, other_tile, other_tile, "signs_road_large_white.png^[multiply:"..sign_color },
			use_texture_alpha = "opaque",
			inventory_image = prefix5.."(signs_road_white.png^[multiply:"..sign_color..")"
		},
	}
end

local function large_inv_sign_def(defs)
	return {
		depth = 1/16,
		width = 64/16,
		height = 12/16,
		entity_fields = {
			maxlines = 1,
			color = assert(defs.text_color),
			aspect_ratio = 1/2,
		},
		node_fields = {
			description = assert(defs.description),
			visual_scale = 1,
			tiles = blank_tiles,
			use_texture_alpha = "clip",
			inventory_image = prefix5.."(signs_road_white.png^[multiply:#999999)^(signs_road_letter.png^[multiply:"..defs.text_color..
				")^default_invisible_node_overlay.png",
		},
	}
end

local function dir_sign_def(prefix, dir, defs)
	-- prefix, dir, {description, text_color, [sign_color]}
	local sign_color = defs.sign_color
	local tile, inventory_image
	if sign_color ~= nil then
		tile = "signs_road_white_direction.png^[multiply:"..sign_color
		inventory_image = "signs_road_white_dir_inventory.png^[multiply:"..sign_color
	else
		tile = "signs_road_"..prefix.."_direction.png"
		inventory_image = "signs_road_"..prefix.."_dir_inventory.png"
	end
	local node_fields = {
		description = assert(defs.description),
		tiles = { tile },
		use_texture_alpha = "opaque",
		inventory_image = inventory_image,
		on_place = signs_api.on_place_direction,
		on_rightclick = signs_api.on_right_click_direction,
		drawtype = "mesh",
	}
	local entity_pos_right
	if dir ~= "right" then
		-- left:
		node_fields.mesh = "signs_dir_left.obj"
		node_fields.inventory_image = node_fields.inventory_image.."^[transformFX"
		node_fields.selection_box = cbox_left
		node_fields.collision_box = cbox_left
		node_fields.signs_other_dir = "signs_road:"..prefix.."_right_sign"
		node_fields.groups = {not_in_creative_inventory = 1}
		node_fields.drop = node_fields.signs_other_dir
		entity_pos_right = 3/32
	else
		-- right:
		node_fields.mesh = "signs_dir_right.obj"
		node_fields.selection_box = cbox_right
		node_fields.collision_box = cbox_right
		node_fields.signs_other_dir = "signs_road:"..prefix.."_left_sign"
		entity_pos_right = -3/32
	end
	return {
		depth = 1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
			right = entity_pos_right,
			size = dir_sign_entity_size,
			maxlines = 2,
			aspect_ratio = 1/2,
			color = assert(defs.text_color),
		},
		node_fields = node_fields,
		allow_on_pole = true,
	}
end

local function black_dir_sign_def(dir)
	local node_fields = {
		description = S("Black direction sign"),
		tiles = { "signs_road_sides.png", "signs_road_sides.png",
				  "signs_road_sides.png", "signs_road_sides.png",
				  "signs_road_sides.png", "signs_road_black_dir_"..dir..".png" },
		use_texture_alpha = "opaque",
		inventory_image = "signs_road_black_dir_inventory.png",
		on_place = signs_api.on_place_direction,
		on_rightclick = signs_api.on_right_click_direction,
	}
	if dir ~= "right" then
		-- left:
		node_fields.inventory_image = node_fields.inventory_image.."^[transformFX"
		node_fields.signs_other_dir = "signs_road:black_right_sign"
		node_fields.groups = { not_in_creative_inventory = 1 }
		node_fields.drop = "signs_road:black_right_sign"

	else
		-- right:
		node_fields.signs_other_dir = "signs_road:black_left_sign"
	end
	return {
		depth = 1/32,
		width = 1,
		height = 0.5,
		entity_fields = {
			aspect_ratio = 3/4,
			size = { x = 1, y = 3/16 },
			maxlines = 1,
			color = "#000",
		},
		node_fields = node_fields,
		allow_on_pole = true,
	}
end

local models = {
	large_street_sign = large_sign_def({description = S("Large banner"), sign_color = "#ffffff", text_color = "#000"}),
	blue_large_street_sign = large_sign_def({description = S("Large blue banner"), sign_color = "#0040C0", text_color = "#fff"}),
	green_large_street_sign = large_sign_def({description = S("Large green banner"), sign_color = "#008040", text_color = "#fff"}),
	red_large_street_sign = large_sign_def({description = S("Large red banner"), sign_color = "#ff0000", text_color = "#fff"}),
	black_large_street_sign = large_sign_def({description = S("Large black banner"), sign_color = "#000000", text_color = "#fff"}),
	yellow_large_street_sign = large_sign_def({description = S("Large yellow banner"), sign_color = "#fbdf00", text_color = "#000"}),
	brown_large_street_sign = large_sign_def({description = S("Large brown banner"), sign_color = "#754222", text_color = "#fff"}),
	invisible_large_street_sign_black_text = large_inv_sign_def({description = S("Large invisible banner with black text"), text_color = "#000000"}),
	invisible_large_street_sign_white_text = large_inv_sign_def({description = S("Large invisible banner with white text"), text_color = "#ffffff"}),
	invisible_large_street_sign_green_text = large_inv_sign_def({description = S("Large invisible banner with green text"), text_color = "#00ff00"}),
	invisible_large_street_sign_orange_text = large_inv_sign_def({description = S("Large invisible banner with orange text"), text_color = "#ffbb00"}),
	white_sign = colored_sign_def({description = S("White road sign"), text_color = "#000",
		front_tile = "signs_road_white.png", inventory_image = "signs_road_white.png"}),
	white_end_sign = colored_sign_def({description = S("White road end sign"), text_color = "#000",
		front_tile = "signs_road_white_end.png", inventory_image = "signs_road_white_end.png^[resize:32x32"}),
	black_sign = colored_sign_def({description = S("Black road sign"), text_color = "#fff", sign_color = "#000000"}),
	brown_sign = colored_sign_def({description = S("Brown road sign"), text_color = "#fff", sign_color = "#754222"}),
	blue_sign = colored_sign_def({description = S("Blue road sign"), text_color = "#fff",
		front_tile = "signs_road_blue.png", inventory_image = "signs_road_blue.png"}),
	green_sign = colored_sign_def({description = S("Green road sign"), text_color = "#fff",
		front_tile = "signs_road_green.png", inventory_image = "signs_road_green.png"}),
	yellow_sign = colored_sign_def({description = S("Yellow road sign"), text_color = "#000",
		front_tile = "signs_road_yellow.png", inventory_image = "signs_road_yellow.png"}),
	red_sign = colored_sign_def({description = S("Red road sign"), text_color = "#fff",
		front_tile = "signs_road_red.png", inventory_image = "signs_road_red.png"}),
	orange_sign = colored_sign_def({description = S("Orange road sign"), text_color = "#000",
		front_tile = "signs_road_white.png^[multiply:#9d2d0a", other_tile = "signs_road_sides.png^[multiply:#9d2d0a",
		inventory_image = "signs_road_white.png^[multiply:#9d2d0a"}),
	inv_sign_black_text = inv_sign_def({description = S("Invisible sign with black text"), text_color = "#000000"}),
	inv_sign_white_text = inv_sign_def({description = S("Invisible sign with white text"), text_color = "#ffffff"}),
	inv_sign_orange_text = inv_sign_def({description = S("Invisible sign with orange text"), text_color = "#ffbb00"}),
	inv_sign_green_text = inv_sign_def({description = S("Invisible sign with green text"), text_color = "#00ff00"}),

	-- Direction signs:
	white_right_sign = dir_sign_def("white", "right", {description = S("White direction sign"), text_color = "#000000"}),
	white_left_sign = dir_sign_def("white", "left", {description = S("White direction sign"), text_color = "#000000"}),
	brown_right_sign = dir_sign_def("brown", "right", {description = S("Brown direction sign"), sign_color = "#754222", text_color = "#ffffff"}),
	brown_left_sign = dir_sign_def("brown", "left", {description = S("Brown direction sign"), sign_color = "#754222", text_color = "#ffffff"}),
	blue_right_sign = dir_sign_def("blue", "right", {description = S("Blue direction sign"), text_color = "#ffffff"}),
	blue_left_sign = dir_sign_def("blue", "left", {description = S("Blue direction sign"), text_color = "#ffffff"}),
	green_right_sign = dir_sign_def("green", "right", {description = S("Green direction sign"), text_color = "#ffffff"}),
	green_left_sign = dir_sign_def("green", "left", {description = S("Green direction sign"), text_color = "#ffffff"}),
	yellow_right_sign = dir_sign_def("yellow", "right", {description = S("Yellow direction sign"), text_color = "#000000"}),
	yellow_left_sign = dir_sign_def("yellow", "left", {description = S("Yellow direction sign"), text_color = "#000000"}),
	red_right_sign = dir_sign_def("red", "right", {description = S("Red direction sign"), text_color = "#ffffff"}),
	red_left_sign = dir_sign_def("red", "left", {description = S("Red direction sign"), text_color = "#ffffff"}),
	orange_right_sign = dir_sign_def("orange", "right", {description = S("Orange direction sign"), sign_color = "#9d2d0a", text_color = "#000000"}),
	orange_left_sign = dir_sign_def("orange", "left", {description = S("Orange direction sign"), sign_color = "#9d2d0a", text_color = "#000000"}),

	black_right_sign = black_dir_sign_def("right"),
	black_left_sign = black_dir_sign_def("left"),

	-- Special signs:
	blue_street_sign = {
		depth = 1/16,
		width = 14/16,
		height = 12/16,
		entity_fields = {
			-- size = { x = 14/16, y = 10/16 },
			size = { x = 14/16, y = 9/16 },
			maxlines = 3,
			color = "#fff",
			aspect_ratio = 14/10/3,
		},
		node_fields = {
			description = S("Blue street sign"),
			tiles = { "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_blue_street.png" },
			use_texture_alpha = "opaque",
			inventory_image = "signs_road_blue_street.png",
		},
		allow_on_pole = true,
	},
	red_street_sign = {
		depth = 1/16,
		width = 1,
		height = 7/16,
		entity_fields = {
			size = { x = 1, y = 3.5/16 },
			maxlines = 1,
			color = "#000",
			aspect_ratio = 14/30,
		},
		node_fields = {
			description = S("Red and white town sign"),
			tiles = { "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_red_white.png" },
			use_texture_alpha = "opaque",
			inventory_image="signs_road_red_white.png",
		},
		allow_on_pole = true,
	},
}

-- Node registration
signs_api.shape_selector_mode = "suppress"
for name, model in pairs(models)
do
	if name:match("^inv") or name:match("_left_") or name:match("_right_") then
		signs_api.register_sign("signs_road", name, model)
	end
end
signs_api.shape_selector_mode = "with_dirsigns"
for name, model in pairs(models)
do
	if not (name:match("^inv") or name:match("_left_") or name:match("_right_")) then
		signs_api.register_sign("signs_road", name, model)
	end
end
signs_api.shape_selector_mode = nil
