-- CHESS MOD
-- ======================================
-- chess/pieces.lua
-- ======================================
-- Registers the chess pieces
--
-- Contents:
--
-- [loop] registers pieces
-- ======================================

local colors = { "black", "white", "gray" }
local colornames_y = {"Černý", "Bílý", "Šedý"}
local colornames_a = {"Černá", "Bílá", "Šedá"}

local def = {
    drawtype = "nodebox",
    use_texture_alpha = "opaque",
    sunlight_propagates = true,
    paramtype = 'light',
    paramtype2 = "facedir",
    light_source = 8,
    selection_box = {
      type = "fixed",
      fixed = {-0.3, -0.5, -0.3, 0.3, 0.2, 0.3},
    },
    groups = {snappy=3},
}

local pawn_nodebox = {
	type = "fixed",
	fixed = {
		{-0.2, -0.5, -0.3, 0.2, -0.4, 0.3},
		{-0.3, -0.5, -0.2, 0.3, -0.4, 0.2},
		{-0.1, -0.4, -0.2, 0.1, -0.3, 0.2},
		{-0.2, -0.4, -0.1, 0.2, -0.3, 0.1},
		{-0.1, -0.3, -0.1, 0.1, 0.2, 0.1},
		{-0.2, -0.1, -0.1, 0.2, 0.1, 0.1},
		{-0.1, -0.1, -0.2, 0.1, 0.1, 0.2},
	},
}

local rook_nodebox = {
	type = "fixed",
	fixed = {
		{-0.2, -0.5, -0.3, 0.2, -0.4, 0.3},
		{-0.3, -0.5, -0.2, 0.3, -0.4, 0.2},
		{-0.1, -0.4, -0.2, 0.1, -0.3, 0.2},
		{-0.2, -0.4, -0.1, 0.2, -0.3, 0.1},
		{-0.1, -0.3, -0.1, 0.1, 0.2, 0.1},
		{-0.1, 0.2, -0.2, 0.1, 0.3, 0.2 },
		{-0.2, 0.2, -0.1, 0.2, 0.3, 0.1},
		{-0.2, 0.3, -0.2, 0.2, 0.4, 0.2},
		{-0.2, 0.4, -0.2, -0.1, 0.5, -0.1},
		{-0.05, 0.4, -0.2, 0.05, 0.5, -0.1},
		{0.1, 0.4, -0.2, 0.2, 0.5, -0.1},
		{-0.2, 0.4, -0.05, -0.1, 0.5, 0.05},
		{0.1, 0.4, -0.05, 0.2, 0.5, 0.05},
		{-0.2, 0.4, 0.1, -0.1, 0.5, 0.2},
		{-0.05, 0.4, 0.1, 0.05, 0.5, 0.2},
		{0.1, 0.4, 0.1, 0.2, 0.5, 0.2},
	},
}

local knight_node_box = {
	type = "fixed",
	fixed = {
		{-0.2, -0.5, -0.3, 0.2, -0.4, 0.3},
		{-0.3, -0.5, -0.2, 0.3, -0.4, 0.2},
		{-0.1, -0.4, -0.2, 0.1, -0.3, 0.2},
		{-0.2, -0.4, -0.1, 0.2, -0.3, 0.1},
		{-0.1, -0.3, -0.1, 0.1, 0.45, 0.1},
		{-0.1, -0.2, -0.2, 0.1, 0.1, 0.15},
		{-0.15, -0.2, -0.1, 0.15, 0.1, 0.1},
		{-0.1, 0.2, -0.25, 0.1, 0.35, 0.15},
		{-0.1, 0.45, 0.01, -0.07, 0.5, 0.06},
		{0.07, 0.45, 0.01, 0.1, 0.5, 0.06},
	},
}

local bishop_node_box = {
	type = "fixed",
	fixed = {
		{-0.2, -0.5, -0.3, 0.2, -0.4, 0.3},
		{-0.3, -0.5, -0.2, 0.3, -0.4, 0.2},
		{-0.1, -0.4, -0.2, 0.1, -0.3, 0.2},
		{-0.2, -0.4, -0.1, 0.2, -0.3, 0.1},
		{-0.1, -0.3, -0.1, 0.1, 0.4, 0.1},
		{-0.1, 0, -0.2, 0.1, 0.1, 0.2},
		{-0.2, 0, -0.1, 0.2, 0.1, 0.1},
		{-0.1, 0.15, -0.2, 0.1, 0.35, 0.2},
		{-0.2, 0.15, -0.1, 0.2, 0.35, 0.1 },
		{-0.05, 0.4, -0.05, 0.05, 0.5, 0.05},
	},
}

local queen_node_box = {
	type = "fixed",
	fixed = {
		{-0.2, -0.5, -0.3, 0.2, -0.4, 0.3},
		{-0.3, -0.5, -0.2, 0.3, -0.4, 0.2},
		{-0.1, -0.4, -0.2, 0.1, -0.3, 0.2},
		{-0.2, -0.4, -0.1, 0.2, -0.3, 0.1},
		{-0.1, -0.3, -0.1, 0.1, 0.2, 0.1},
		{-0.1, 0, -0.2, 0.1, 0.1, 0.2},
		{-0.2, 0, -0.1, 0.2, 0.1, 0.1},
		{-0.1, 0.2, -0.2, 0.1, 0.4, 0.2},
		{-0.2, 0.2, -0.1, 0.2, 0.4, 0.1},
		{-0.07, 0.4, -0.19, 0.07, 0.44, -0.11},
		{-0.07, 0.4, 0.11, 0.07, 0.44, 0.19},
		{-0.19, 0.4, -0.07, -0.11, 0.44, 0.07},
		{0.11, 0.4, -0.07, 0.19, 0.44, 0.07},
		{-0.04, 0.4, -0.07, 0.04, 0.46, 0.07},
		{-0.07, 0.4, -0.04, 0.07, 0.46, 0.04},
		{-0.04, 0.46, -0.04, 0.04, 0.49, 0.04},
	},
}

local king_node_box = {
	type = "fixed",
	fixed = {
		{-0.2, -0.5, -0.3, 0.2, -0.4, 0.3},
		{-0.3, -0.5, -0.2, 0.3, -0.4, 0.2},
		{-0.1, -0.4, -0.2, 0.1, -0.3, 0.2},
		{-0.2, -0.4, -0.1, 0.2, -0.3, 0.1},
		{-0.1, -0.3, -0.1, 0.1, 0.2, 0.1},
		{-0.1, 0, -0.2, 0.1, 0.1, 0.2},
		{-0.2, 0, -0.1, 0.2, 0.1, 0.1},
		{-0.1, 0.2, -0.2, 0.1, 0.4, 0.2},
		{-0.2, 0.2, -0.1, 0.2, 0.4, 0.1},
		{-0.02, 0.4, -0.02, 0.02, 0.5, 0.02},
		{-0.02, 0.43, -0.05, 0.02, 0.47, 0.05},
		{-0.05, 0.43, -0.02, 0.05, 0.47, 0.02},
	},
}

--make a loop which makes the black and white nodes and crafting recipes
for color = 1, 3 do
	def.tiles = {
		"chess_piece_"..colors[color].."_top.png",
		"chess_piece_"..colors[color].."_top.png",
		"chess_piece_"..colors[color]..".png",
		"chess_piece_"..colors[color]..".png",
		"chess_piece_"..colors[color].."_side.png",
		"chess_piece_"..colors[color].."_side.png"
	}

	--Pawn
	def.description = colornames_y[color] .. " pěšec"
	def.node_box = pawn_nodebox
	minetest.register_node("chess:pawn_"..colors[color], table.copy(def))

	--Rook
	def.description = colornames_a[color] .. " věž"
	def.node_box = rook_nodebox
	minetest.register_node("chess:rook_"..colors[color], table.copy(def))

	--Knight
	def.description = colornames_y[color] .. " jezdec"
	def.node_box = knight_node_box
	minetest.register_node("chess:knight_"..colors[color], table.copy(def))

	--Bishop
	def.description = colornames_y[color] .. " střelec"
	def.node_box = bishop_node_box
	minetest.register_node("chess:bishop_"..colors[color], table.copy(def))

	--Queen
	def.description = colornames_a[color] .. " dáma"
	def.node_box = queen_node_box
	minetest.register_node("chess:queen_"..colors[color], table.copy(def))

	--King
	def.description = colornames_y[color] .. " král"
	def.node_box = king_node_box
	minetest.register_node("chess:king_"..colors[color], table.copy(def))
end
