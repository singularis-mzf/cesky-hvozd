local colours = {{name="black", caption="Black"}, {name="white", caption="White"}}

local function register_piece(name, caption, crafts)
	for _, colour in ipairs(colours) do
		local node = "chess:"..colour.name.."_"..name
		minetest.register_node(node, {
			description = colour.caption.." "..caption,
			drawtype = "mesh",
			mesh = "chess_"..name..".obj",
			tiles = {"chess_"..colour.name..".png"},
			paramtype = "light",
			sunlight_propagates = true,
			walkable = true,
			groups = {cracky = 3, oddly_breakable_by_hand = 3},
			sounds = default.node_sound_glass_defaults(),
			visual_scale = 1,
		})
		for _, craft in ipairs(crafts) do
			minetest.register_craft({
			output = node,
				recipe = {
					{craft},
					{"bakedclay:"..colour.name},
				}
			})
		end
	end
end

register_piece("pawn", "Pawn", {"default:stick"})
register_piece("knight", "Knight", {"group:grass"})
register_piece("bishop", "Bishop", {"group:leaves"})
register_piece("rook", "Rook", {"default:cobble", "default:desert_cobble", "group:cobble"})
register_piece("queen", "Queen", {"default:stonebrick", "default:desert_stonebrick", "group:stonebrick"})
register_piece("king", "King", {"default:stone_block", "default:desert_stone_block", "group:stoneblock"})

