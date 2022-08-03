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
local STATUS_SIGNATURE_SET = "[giftbox2] %s sets message '%s' to %s at %s"

-- Load configutation
giftbox2 = {}
giftbox2.config = {}
dofile(minetest.get_modpath("giftbox2") .. "/config.lua")
local config = giftbox2.config

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
	minetest.register_node( "giftbox2:giftbox_" .. color, {
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

	        selection_box = {
			type = "fixed",
			fixed = {
				{ -0.45, -0.5, -0.45,  0.45,  0.45, 0.45 },
			}
		},

		drop = { max_items = 1,	items = config.drops },

		on_dig = function ( pos, node, player )
			local digger = player:get_player_name( )
			local receiver = minetest.get_meta( pos ):get_string( "receiver" )

			if is_owner(pos, digger) then
				-- always allow owner to dig node but still obey protection
				if not minetest.is_protected( pos, digger ) then
					-- give gift box back to owner (not its contents)
					minetest.handle_node_drops( pos, { node.name }, player )
					minetest.remove_node( pos )
					minetest.check_for_falling( pos )
				end
			elseif receiver == digger or receiver == OWNER_NOBODY then
				-- otherwise drop random items directly for receiver (if any)
				local drops = minetest.get_node_drops( node.name, player:get_wielded_item( ):get_name( ) )
				minetest.handle_node_drops( pos, drops, player )
				minetest.remove_node( pos )
				minetest.check_for_falling( pos )
			end
		end,
		after_place_node = function ( pos, player )
			local placer = player:get_player_name( ) or "singleplayer"
			local meta = minetest.get_meta( pos )

			set_owner( pos, placer )
			meta:set_string( "receiver", OWNER_NOBODY )
			meta:set_string( "is_anonymous", "false" )

			-- initial item string: Gift Box (from <placer>)
			meta:set_string( "infotext", S("@1 (from @2)", S(config.public_infotext1), placer))
		end,
		on_open = function ( pos, player, fields )
			local meta = minetest.get_meta( pos )
			local formspec =
				"size[8,3]" ..
				"button_exit[6,2.5;2,0.3;save;"..F(S("Save")).."]" ..
				"checkbox[4.5,1.3;is_anonymous;"..F(S("Anonymous Sender"))..";" .. meta:get_string( "is_anonymous" ) .. "]" ..
				"label[0.1,0;"..F(S("Personalize your greeting (or leave blank for the default):")).."]" ..
				"field[0.4,1;7.8,0.25;message;;" .. F( meta:get_string( "message" ) ) .. "]" ..
				"label[0.1,1.5;"..F(S("Recipient:")).."]" ..
				"field[1.8,1.9;2.5,0.25;receiver;;" .. meta:get_string( "receiver" ) .. "]"

			-- only placer of gift box should edit properties, not the receiver
			if is_owner( pos, player:get_player_name( ) ) then
				return formspec
        		end        
		end,
	        on_close = function ( pos, player, fields )
			local owner = player:get_player_name( )
			local meta = minetest.get_meta( pos )

			-- only placer of gift box should edit properties, not the receiver
			if not is_owner( pos, owner ) then return end

			if fields.is_anonymous then
				-- in next version of active formspecs, we should save checkbox state
				-- in form meta first rather than directly to node meta
				meta:set_string( "is_anonymous", fields.is_anonymous )

			elseif fields.save and fields.message and fields.receiver then
				local infotext = ""

				if fields.message ~= "" and string.len( fields.message ) < 1 then
					minetest.chat_send_player( owner, S("The specified message is too short.") )
					return
				elseif string.len( fields.message ) > 250 then
					minetest.chat_send_player( owner, S("The specified message is too long.") )
					return
				elseif fields.receiver == owner then
					minetest.chat_send_player( owner, S("You cannot give a gift to yourself.") )
					return
				elseif fields.receiver ~= OWNER_NOBODY and not string.find( fields.receiver, "^[-_A-Za-z0-9]+$" ) then
					minetest.chat_send_player( owner, S("The specified recipient is invalid.") )
					return
				end

				-- item string with message: Dear sorcerykid: "Happy holidays!" (placed by sorcerykid)
				-- item string without message: Gift Box for maikerumine (placed by sorcerykid)
				
				if fields.receiver == OWNER_NOBODY then
					-- public gift box
					if fields.message == "" then
						infotext = S(config.public_infotext1)
					else
						infotext = S(config.public_infotext2, fields.message)
					end
				else
					-- private gift box
					if fields.message == "" then
						infotext = S(config.private_infotext1, fields.receiver)
					else
						infotext = S(config.private_infotext2, fields.receiver, fields.message)
					end
				end

				if meta:get_string( "is_anonymous" ) == "false" then
					infotext = S("@1 (from @2)", infotext, owner)
				end

				minetest.log( "action", string.format( STATUS_SIGNATURE_SET, player:get_player_name( ), fields.message, "gift box", minetest.pos_to_string( pos ) ) )

				meta:set_string( "receiver", fields.receiver )
				meta:set_string( "message", fields.message )
				meta:set_string( "infotext", infotext )
			end
		end,
	} )

	minetest.register_craft( {
		output = "giftbox2:giftbox_" .. color,
		recipe = {
			{ "wool:" .. color, "farming:cotton", "wool:" .. color },
			{ "default:paper", "default:mese_crystal", "default:paper" },
			{ "wool:" .. color, "default:paper", "wool:" .. color },
		}
	} )

	if colortab[3] then
		-- Alias for original giftbox mod
		minetest.register_alias("giftbox:giftbox_"..color, "giftbox2:giftbox_"..color)
	end
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



