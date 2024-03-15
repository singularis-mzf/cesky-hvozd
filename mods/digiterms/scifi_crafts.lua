--[[
	digiterms mod for Minetest - Digilines monitors using Display API / Font API
	(c) Pierre-Yves Rollo

	This file is part of digiterms.

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

-- local wire = 'mesecons:wire_00000000_off'

minetest.register_craft({
	output = "digiterms:scifi_glassscreen",
	recipe = {
		{"ch_extras:colorable_glass", "ch_extras:colorable_glass"},
		{'technic:control_logic_unit', 'technic:control_logic_unit'},
	},
})

minetest.register_craft({
	output = "digiterms:scifi_widescreen 2",
	recipe = {
		{"digiterms:lcd_monitor", "digiterms:lcd_monitor"},
		{"", ""}
	},
})

minetest.register_craft({
	output = "digiterms:scifi_tallscreen 2",
	recipe = {
		{"digiterms:lcd_monitor", ""},
		{"digiterms:lcd_monitor", ""},
	},
})

minetest.register_craft({
	output = "digiterms:scifi_widescreen",
	recipe = {{"digiterms:scifi_tallscreen"}},
})

minetest.register_craft({
	output = "digiterms:scifi_tallscreen",
	recipe = {{"digiterms:scifi_widescreen"}},
})

minetest.register_craft({
	output = "digiterms:scifi_keysmonitor",
	recipe = {
		{"digiterms:cathodic_black_monitor",""},
		{"digiterms:black_keyboard",""},
	},
})
