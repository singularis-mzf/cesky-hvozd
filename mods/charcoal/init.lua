--[[
		Minetest-mod "Charcoal", A mod with charcoal lumps and blocks
		Copyright (C) 2021 J. A. Anders

		This program is free software; you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation; version 3 of the License.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program; if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
		MA 02110-1301, USA.
]]

--
-- Mod Version 0.1
--

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

charcoal = {}

-- Get Translator
local S = minetest.get_translator("charcoal")
charcoal.get_translator = S
local S = charcoal.get_translator
local expect_compactor = minetest.settings:get_bool("ch_expect_compactor", false)

-- Basic Charcoal
minetest.register_craftitem("charcoal:charcoal", {
  description = S("Charcoal Lump"),
  inventory_image = "charcoal_charcoal.png",
})

-- Charcoal Block
minetest.register_node("charcoal:charcoal_block", {
  description = S("Charcoal Block"),
  -- inventory_image = minetest.inventorycube("charcoal_charcoal_block.png"),
  tiles = {{name = "default_gravel.png^[multiply:#443333", backface_culling = true}},
  -- tiles = {"charcoal_charcoal_block.png"},
  groups = {cracky = 2, crumbly = 2, oddly_breakable_by_hand = 1, falling_node = 1},
  sounds = default.node_sound_gravel_defaults(),
  drop = "charcoal:charcoal 10",
})

stairsplus:register_all("charcoal", "charcoal_block", "charcoal:charcoal_block", minetest.registered_nodes["charcoal:charcoal_block"])

-- Override and register default Coal Block as well

minetest.override_item("default:coalblock", {
  description = "uhlí",
	tiles = {{name = "default_gravel.png^[multiply:#333333"}},
	groups = {cracky = 2, crumbly = 2, falling_node = 1},
	sounds = default.node_sound_gravel_defaults(),
  drop = "default:coal_lump 10",
})

stairsplus:register_all("moreblocks", "coalblock", "default:coalblock", minetest.registered_nodes["default:coalblock"])

-- Use Charcoal as fuel
minetest.register_craft({
  type = "fuel",
  recipe = "charcoal:charcoal",
  burntime = 30,
})

minetest.register_craft({
  type = "fuel",
  recipe = "charcoal:charcoal_block",
  burntime = 270,
})



-- Craft Charcoal
minetest.register_craft({
  type = "cooking",
  output = "charcoal:charcoal 2",
  recipe = "group:tree",
  cooktime = 8,
})

if not expect_compactor then
minetest.register_craft({
  type = "shaped",
  output = "charcoal:charcoal_block",
  recipe = {
    {"charcoal:charcoal","charcoal:charcoal","charcoal:charcoal"},
    {"charcoal:charcoal","charcoal:charcoal","charcoal:charcoal"},
    {"charcoal:charcoal","charcoal:charcoal","charcoal:charcoal"},
  },
})

minetest.register_craft({
  type = "shapeless",
  output = "charcoal:charcoal 9",
  recipe = {"charcoal:charcoal_block"}
})
end

-- Make torch from charcoal
minetest.register_craft({
  type = "shaped",
  output = "default:torch 2",
  recipe = {
    {"charcoal:charcoal"},
    {"default:stick"},
  },  
})

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
