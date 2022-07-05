-- CHESS MOD
-- ======================================
-- chess/init.lua
-- ======================================
-- Registers the basic chess stuff
--
-- Contents:
--
-- [regis] Spawn Block
-- [craft] Spawn Block
-- [regis] board_black
-- [regis] board_white
-- ======================================

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

dofile(minetest.get_modpath("chess").."/pieces.lua")

local letters = {"a", "b", "c", "d", "e", "f", "g", "h"}

local size = 9 --total width(10) including the border coordinate 0,0
local innerSize = 8 --inner width(8) including the coordinate 1,1

local function dig_chessboard(pos, node, digger)
	local size = 9
	local p = {x=pos.x+1, y=pos.y, z=pos.z+1}
	local n = minetest.get_node(p)

	if n.name == "chess:board_black" then
		for i = size, 0, -1 do
			for ii = size, 0, -1 do
				--remove board
				local p = {x=pos.x+i, y=pos.y, z=pos.z+ii}
				minetest.remove_node(p)

				--remove pieces ontop
				local p = {x=pos.x+i, y=pos.y+1, z=pos.z+ii}
				minetest.remove_node(p)
			end
		end
	end
end

local function place_chessboard(pos, placer)
	local player_name = placer:get_player_name()
	--place chess board
	for i = size, 0, -1 do
		for ii = size, 0, -1 do
			for iii = 1, 0, -1 do
				if (i+ii+iii~=0) then
					local p = {x=pos.x+i, y=pos.y+iii, z=pos.z+ii}
					local n = minetest.get_node(p)

					if(n.name ~= "air") then
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
        -- TODO: reset the pieces
		dig_chessboard(pos, node, puncher)
		minetest.add_node(pos, {name="chess:spawn"})
		place_chessboard(pos, puncher)
		return true
    end,
    after_place_node = place_chessboard,
})

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
    groups = {indestructable=1, not_in_creative_inventory=1},
})

--Register the Board Blocks: black
minetest.register_node("chess:board_black",{
    description = "Černé pole šachovnice",
    tiles = {"chess_board_black.png"},
    inventory_image = "chess_board_black.png",
    groups = {indestructable=1, not_in_creative_inventory=1},
})

minetest.register_node("chess:border",{
    description = "Okraj šachovnice",
    tiles = {"chess_board_black.png", "chess_board_black.png", "chess_board_black.png^chess_border_side.png"},
    inventory_image = "chess_board_black.png",
    groups = {indestructable=1, not_in_creative_inventory=1},
})

for iii = innerSize, 1, -1 do
    minetest.register_node("chess:border_" .. letters[iii],{
        description = "Bílé pole šachovnice",
        tiles = {"chess_board_black.png^chess_border_" .. letters[iii] .. ".png", "chess_board_black.png", "chess_board_black.png^chess_border_side.png"},
        inventory_image = "chess_board_white.png",
        paramtype2 = "facedir",
        groups = {indestructable=1, not_in_creative_inventory=1},
    })

    minetest.register_node("chess:border_" .. iii,{
        description = "Bílé pole šachovnice",
        tiles = {"chess_board_black.png^chess_border_" .. iii .. ".png", "chess_board_black.png", "chess_board_black.png^chess_border_side.png"},
        inventory_image = "chess_board_white.png",
        paramtype2 = "facedir",
        groups = {indestructable=1, not_in_creative_inventory=1},
    })
end

for _, n in ipairs({"pawn", "rook", "knight", "bishop", "queen", "king"}) do
	minetest.register_craft({
		output = "chess:" ..n.."_gray",
		type = "shapeless",
		recipe = {"chess:"..n.."_black", "chess:"..n.."_white"},
	})
end

for _, color in ipairs({"white", "gray", "black"}) do
	for _, n in ipairs({"rook", "knight", "bishop", "queen"}) do
		minetest.register_craft({
			output = "chess:" .. n .. "_" .. color .. " 2",
			type = "shapeless",
			recipe = {"chess:" .. n .. "_" .. color, "chess:pawn_" .. color},
		})
	end
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
