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

local signs_table = {
	-- dye_back, dye_front, itemstring_rect?, itemstring_right?, itemstring_large?
	{ "dye:white", "dye:black", "signs_road:white_sign", "signs_road:white_right_sign", "signs_road:large_street_sign" },
	{ "dye:blue", "dye:white", "signs_road:blue_sign", "signs_road:blue_right_sign", "signs_road:blue_large_street_sign" },
	{ "dye:green", "dye:white", "signs_road:green_sign", "signs_road:green_right_sign", "signs_road:green_large_street_sign" },
	{ "dye:yellow", "dye:black", "signs_road:yellow_sign", "signs_road:yellow_right_sign", "signs_road:yellow_large_street_sign" },
	{ "dye:red", "dye:white", "signs_road:red_sign", "signs_road:red_right_sign", "signs_road:red_large_street_sign" },
	{ "dye:brown", "dye:white", "signs_road:brown_sign", "signs_road:brown_right_sign", "signs_road:brown_large_street_sign" },
	{ "dye:red", "dye:white", "signs_road:red_sign", "signs_road:red_right_sign", "signs_road:red_large_street_sign" },
	{ "dye:black", "dye:white", "signs_road:black_sign", "signs_road:black_right_sign", "signs_road:black_large_street_sign"},
	{ "", "dye:black", "signs_road:inv_sign_black_text", "", "signs_road:invisible_large_street_sign_black_text"},
	{ "", "dye:white", "signs_road:inv_sign_white_text", "", "signs_road:invisible_large_street_sign_white_text"},
}

for i, v in ipairs(signs_table) do
	local dye_back, dye_front, itemstring_rect, itemstring_right, itemstring_large = unpack(v)
	if itemstring_right ~= "" then
		minetest.register_craft({
			output = itemstring_right .. " 2",
			recipe = {
				{dye_back, dye_front, "default:steel_ingot"},
				{"default:steel_ingot", "default:steel_ingot", ""},
				{"", "", ""},
			}
		})
	end
	if itemstring_rect ~= "" then
		minetest.register_craft({
			output = itemstring_rect .. " 2",
			recipe = {
				{dye_back, dye_front, ""},
				{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
				{"", "", ""},
			}
		})
		if itemstring_right ~= "" then
			minetest.register_craft({
				type = "shapeless",
				output = itemstring_right,
				recipe = {itemstring_rect},
			})
			minetest.register_craft({
				type = "shapeless",
				output = itemstring_rect,
				recipe = {itemstring_right},
			})
		end
		if itemstring_large ~= "" then
			minetest.register_craft({
				type = "shapeless",
				output = itemstring_large,
				recipe = {itemstring_rect, itemstring_rect, itemstring_rect, itemstring_rect},
			})
		end
	end
end

-- Various signs

minetest.register_craft({
	output = 'signs_road:blue_street_sign 4',
	recipe = {
		{'dye:blue', 'dye:white', 'dye:blue'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
	}
})

minetest.register_craft({
	output = 'signs_road:red_street_sign 2',
	recipe = {
		{'dye:white', 'dye:red', 'dye:black'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', '', ''},
	}
})
