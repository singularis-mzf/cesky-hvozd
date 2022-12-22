print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

chess = {
	letters = {"a", "b", "c", "d", "e", "f", "g", "h"},
	colors = {
		black = {
			description = "čern",
			texture = "chess_black.png",
			place_param2 = 0,
		},
		white = {
			description = "bíl",
			texture = "chess_white.png",
			place_param2 = 2,
		},
		gray = {
			description = "šed",
			texture = "chess_gray.png",
			place_param2 = 3,
		},
	},
}

dofile(minetest.get_modpath("chess").."/pieces.lua")

local register_stopper = minetest.get_modpath("mesecons_mvps") and mesecon.register_mvps_stopper or function(n)
	return true
end

local letters = chess.letters

local size = 9 --total width(10) including the border coordinate 0,0
local innerSize = 8 --inner width(8) including the coordinate 1,1

local function get_nil()
	return nil
end

local function dig_chessboard(pos, node, digger)
	local p = vector.new(pos.x + 1, pos.y, pos.z + 1)
	local n = minetest.get_node(p).name

	if n ~= "chess:board_black" then
		return false
	end
	local registered_nodes = minetest.registered_nodes
	local positions_to_remove = {}
	for i = size, 0, -1 do
		for ii = size, 0, -1 do
			--remove board
			p = vector.new(pos.x + i, pos.y, pos.z + ii)
			positions_to_remove[1 + #positions_to_remove] = p

			--remove pieces ontop
			p = vector.new(pos.x + i, pos.y + 1, pos.z + ii)
			n = minetest.get_node(p)
			n = n and n.name
			if n and n ~= "air" and n ~= "chess:spawn" then
				n = registered_nodes[n]
				if not n or n.diggable == false or (n.can_dig and n.can_dig(vector.copy(p), digger) == false) then
					minetest.log("warning", "Na šachovnici byl nalezen neodstranitelný blok ("..(pos.x + i)..","..(pos.y + 1)..","..(pos.z + ii)..")")
				else
					positions_to_remove[1 + #positions_to_remove] = p
				end
			end
		end
	end
	for _, p in ipairs(positions_to_remove) do
		minetest.remove_node(p)
	end
	return true
end

local function place_chessboard(pos, placer)
	local player_name = placer:get_player_name()
	local registered_nodes = minetest.registered_nodes
	--place chess board
	for i = size, 0, -1 do
		for ii = size, 0, -1 do
			for iii = 1, 0, -1 do
				if (i+ii+iii~=0) then
					local p = {x=pos.x+i, y=pos.y+iii, z=pos.z+ii}
					local n = minetest.get_node(p)
					local is_free = n.name == "air"

					if not is_free then
						local def = registered_nodes[n.name]
						is_free = def and def.buildable_to
					end

					if not is_free then
						minetest.chat_send_player(player_name, "Nemohu umístit šachovnici! Ujistěte se, že na severovýchod je volný prostor 10x10.")
						return
					end
				end
			end
		end
	end

	for i = size, 0, -1 do
		for ii = size, 0, -1 do
			--place chessboard
			local p = {x=pos.x+i, y=pos.y, z=pos.z+ii}
			local p_top = {x=pos.x+i, y=pos.y+1, z=pos.z+ii}

			if (ii == 0) or (ii == size) or (i ==0) or (i == size) then --if border
				if (ii == 0) and (i < size) and (i > 0) then --black letters
					minetest.add_node(p, {name="chess:border_" .. letters[i]})
				end

				if (ii == size) and (i < size) and (i > 0) then --white letters
					minetest.add_node(p, {name="chess:border_" .. letters[i], param2=2})
				end

				if (i == 0) and (ii < size) and (ii > 0) then --black numbers
					minetest.add_node(p, {name="chess:border_" .. ii})
				end

				if (i == size) and (ii < size) and (ii > 0) then --white numbers
					minetest.add_node(p, {name="chess:border_" .. ii, param2=2})
				end

				if (i == 0 or i == size) and (ii == 0 or ii == size) and i+ii ~= 0 then --corners
					minetest.add_node(p, {name="chess:border"})
				end

			else--if inside border
				if (((ii+i)/2) == math.floor((ii+i)/2)) then
					minetest.add_node(p, {name="chess:board_black"})
				else
					minetest.add_node(p, {name="chess:board_white"})
				end
				local meta = minetest.get_meta(p)
				meta:set_int("chess_offset_x", i)
				meta:set_int("chess_offset_z", ii)
				meta:set_string("infotext", letters[i]..ii)
			end
			--place pieces
			local face = 2
			if (ii == 2) and (i>0) and (i<size) then --pawns
				minetest.add_node(p_top, {name="chess:pawn_white", param2 = face})
			end

			if (ii == 1) then --behind pawns
				if (i == 1 or i == 8) then minetest.add_node(p_top, {name="chess:rook_white", param2 = face}) end
				if (i == 2 or i == 7) then minetest.add_node(p_top, {name="chess:knight_white", param2 = face}) end
				if (i == 3 or i == 6) then minetest.add_node(p_top, {name="chess:bishop_white", param2 = face}) end
				if (i == 4) then minetest.add_node(p_top, {name="chess:queen_white", param2 = face}) end
				if (i == 5) then minetest.add_node(p_top, {name="chess:king_white", param2 = face}) end
			end

			--black pieces
			face = 0
			if (ii == 7) and (i>0) and (i<size) then --pawns
				minetest.add_node(p_top, {name="chess:pawn_black", param2 = face})
			end

			if (ii == 8) then --behind pawns
				if (i == 1 or i == 8) then minetest.add_node(p_top, {name="chess:rook_black", param2 = face}) end
				if (i == 2 or i == 7) then minetest.add_node(p_top, {name="chess:knight_black", param2 = face}) end
				if (i == 3 or i == 6) then minetest.add_node(p_top, {name="chess:bishop_black", param2 = face}) end
				if (i == 4) then minetest.add_node(p_top, {name="chess:queen_black", param2 = face}) end
				if (i == 5) then minetest.add_node(p_top, {name="chess:king_black", param2 = face}) end
			end
		end
	end
end

-- Register the spawn block
minetest.register_node("chess:spawn",{
    description = "Šachovnice",
    tiles = {"chess_border_spawn.png", "chess_board_black.png", "chess_board_black.png^chess_border_side.png"},
    groups = {snappy=1,choppy=2,oddly_breakable_by_hand=1},
    after_dig_node = dig_chessboard,
    on_punch = function(pos, node, puncher)
		if puncher and puncher:is_player() then
			local controls = puncher:get_player_control()
			if not controls.sneak then
				minetest.chat_send_player(puncher:get_player_name(), "** pro uvedení šachovnice do výchozího stavu musíte při kliknutí držet Shift **")
				return false, "** pro uvedení šachovnice do výchozího stavu musíte při kliknutí držet Shift **"
			end
		end
		dig_chessboard(pos, node, puncher)
		minetest.add_node(pos, {name="chess:spawn"})
		place_chessboard(pos, puncher)
		return true
    end,
    after_place_node = place_chessboard,
	on_blast = function(pos, intensity)
		dig_chessboard(pos, nil, nil)
		return nil
	end,
	_ch_help = "Šachovnice se rozloží do prostoru 10x10 metrů na severovýchod od místa umístění.\nOdstranit ji lze jen vytěžením výchozího bloku.\nShift+levý klik na výchozí blok pro reset hry.",
})
register_stopper("chess:spawn")

-- Add crafting for the spawn block
minetest.register_craft({
    output="chess:spawn",
    recipe = {
        {'default:wood','default:tree','default:wood'},
        {'default:tree','default:wood','default:tree'},
        {'default:wood','default:tree','default:wood'},
    }
})

--Register the Board Blocks: white
minetest.register_node("chess:board_white",{
    description = "Bílé pole šachovnice",
    tiles = {"chess_board_white.png"},
    inventory_image = "chess_board_white.png",
	paramtype = "light",
	light_source = 6,
    groups = {indestructable=1, not_in_creative_inventory=1},
	diggable = false,
	on_blast = get_nil,
})
register_stopper("chess:board_white")

--Register the Board Blocks: black
minetest.register_node("chess:board_black",{
    description = "Černé pole šachovnice",
    tiles = {"chess_board_black.png"},
    inventory_image = "chess_board_black.png",
	paramtype = "light",
	light_source = 6,
    groups = {indestructable=1, not_in_creative_inventory=1},
	diggable = false,
	on_blast = get_nil,
})
register_stopper("chess:board_black")

minetest.register_node("chess:border",{
    description = "Okraj šachovnice",
    tiles = {"chess_board_black.png", "chess_board_black.png", "chess_board_black.png^chess_border_side.png"},
    inventory_image = "chess_board_black.png",
    groups = {indestructable=1, not_in_creative_inventory=1},
	diggable = false,
	on_blast = get_nil,
})
register_stopper("chess:border")

for iii = innerSize, 1, -1 do
    minetest.register_node("chess:border_" .. letters[iii],{
        description = "Bílé pole šachovnice",
        tiles = {"chess_board_black.png^chess_border_" .. letters[iii] .. ".png", "chess_board_black.png", "chess_board_black.png^chess_border_side.png"},
        inventory_image = "chess_board_white.png",
        paramtype2 = "facedir",
        groups = {indestructable=1, not_in_creative_inventory=1},
		diggable = false,
		on_blast = get_nil,
	})
	register_stopper("chess:border_" .. letters[iii])

    minetest.register_node("chess:border_" .. iii,{
        description = "Bílé pole šachovnice",
        tiles = {"chess_board_black.png^chess_border_" .. iii .. ".png", "chess_board_black.png", "chess_board_black.png^chess_border_side.png"},
        inventory_image = "chess_board_white.png",
        paramtype2 = "facedir",
        groups = {indestructable=1, not_in_creative_inventory=1},
		diggable = false,
		on_blast = get_nil,
    })
	register_stopper("chess:border_" .. iii)
end

for _, n in ipairs({"pawn", "rook", "knight", "bishop", "queen", "king"}) do
	minetest.register_craft({
		output = "chess:" ..n.."_gray",
		type = "shapeless",
		recipe = {"chess:"..n.."_black", "chess:"..n.."_white"},
	})
end

for color, _ in pairs(chess.colors) do
	for _, n in ipairs({"rook", "knight", "bishop", "queen"}) do
		minetest.register_craft({
			output = "chess:" .. n .. "_" .. color .. " 2",
			type = "shapeless",
			recipe = {"chess:" .. n .. "_" .. color, "chess:pawn_" .. color},
		})
	end
end

--[[
if register_stopper then
	for _, n in ipairs({""}) do
		register_stopper("chess:" .. n)
	end
end
]]

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
