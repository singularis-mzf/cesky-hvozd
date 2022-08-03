--------------------------------------------------------
-- Minetest :: Giftbox2 Mod (giftbox2)
--
-- See README.txt for licensing and other information.
-- Copyright (c) 2016-2021, Leslie E. Krause and Wuzzy
--------------------------------------------------------

local S = minetest.get_translator("giftbox2")
local F = minetest.formspec_escape

local OWNER_NOBODY = ""
local set_owner = function( pos, player_name )
	local meta = minetest.get_meta(pos)
	meta:set_string("owner", player_name)
end
local is_owner = function( pos, player_name )
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	return owner == player_name
end
-- local STATUS_SIGNATURE_SET = "[giftbox2] %s sets message '%s' to %s at %s"

-- Load configuration
giftbox2 = {}

local box_colors = {
	-- color, decription, uses alias
	{ "black", S("Black Gift Box"), true},
	{ "blue", S("Blue Gift Box"), true},
	{ "cyan", S("Cyan Gift Box"), true},
	{ "green", S("Green Gift Box"), true},
	{ "magenta", S("Magenta Gift Box"), true},
	{ "red", S("Red Gift Box"), true},
	{ "white", S("White Gift Box"), true},
	{ "yellow", S("Yellow Gift Box"), true},
	{ "orange", S("Orange Gift Box"), false},
	{ "violet", S("Violet Gift Box"), false},
}

for i, colortab in ipairs( box_colors ) do
	local color = colortab[1]

	local def = {
		description = colortab[2],
		drawtype = "mesh",
		mesh = "giftbox.obj",
		tiles = { "giftbox_" .. color .. ".png" },
		use_texture_alpha = "clip",
		paramtype = "light",
		visual_scale = 0.45,
		wield_scale = { x = 0.45, y = 0.45, z = 0.45 },
		sunlight_propagates = true,
		is_ground_content = false,
		groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 1 },
		sounds = {
			footstep = {name="giftbox_step", gain=0.2},
			place = {name="giftbox_step", gain=0.6},
			dig = {name="giftbox_dig", gain=0.2},
			dug = {name="giftbox_dug", gain=0.4},
		},
		locked = true,

		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.45, -0.5, -0.45,  0.45,  0.45, 0.45 },
			}
		},

		width = 4,
		height = 4,
		sort = true,
		infotext = true,
		autosort = false,
		tube = false,
	}
	technic.chests.register_chest("giftbox2:giftbox_"..color, def)

	minetest.register_craft( {
		output = "giftbox2:giftbox_" .. color,
		recipe = {
			{ "wool:" .. color, "farming:cotton", "wool:" .. color },
			{ "default:paper", "default:mese_crystal", "default:paper" },
			{ "wool:" .. color, "default:paper", "wool:" .. color },
		}
	} )
end

minetest.register_alias( "mt_seasons:gift_box_brown", "giftbox2:giftbox_orange" )
minetest.register_alias( "mt_seasons:gift_box_dark_green", "giftbox2:giftbox_green" )
minetest.register_alias( "mt_seasons:gift_box_dark_grey", "giftbox2:giftbox_black" )
minetest.register_alias( "mt_seasons:gift_box_grey", "giftbox2:giftbox_white" )
minetest.register_alias( "mt_seasons:gift_box_orange", "giftbox2:giftbox_orange" )
minetest.register_alias( "mt_seasons:gift_box_pink", "giftbox2:giftbox_red" )
minetest.register_alias( "mt_seasons:gift_box_violet", "giftbox2:giftbox_violet" )

minetest.register_alias( "mt_seasons:gift_box_red", "giftbox2:giftbox_red" )
minetest.register_alias( "mt_seasons:gift_box_green", "giftbox2:giftbox_green" )
minetest.register_alias( "mt_seasons:gift_box_blue", "giftbox2:giftbox_blue" )
minetest.register_alias( "mt_seasons:gift_box_cyan", "giftbox2:giftbox_cyan" )
minetest.register_alias( "mt_seasons:gift_box_magenta", "giftbox2:giftbox_magenta" )
minetest.register_alias( "mt_seasons:gift_box_yellow", "giftbox2:giftbox_yellow" )
minetest.register_alias( "mt_seasons:gift_box_white", "giftbox2:giftbox_white" )
minetest.register_alias( "mt_seasons:gift_box_black", "giftbox2:giftbox_black" )
