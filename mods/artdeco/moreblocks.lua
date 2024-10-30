if not minetest.global_exists("stairsplus") then return end

local function register(recipe_item)
	local def = minetest.registered_nodes[recipe_item]
	local modname, subname = recipe_item:match("^([^:]+):([^:]+)$")
	stairsplus:register_all(modname, subname, recipe_item, def)
end


register("artdeco:1a")
register("artdeco:1b")
register("artdeco:1c")
register("artdeco:1d")
-- register("artdeco:1e")
register("artdeco:1f")
register("artdeco:1g")
register("artdeco:1h")
register("artdeco:1i")
register("artdeco:1j")
register("artdeco:1k")
register("artdeco:1l")

register("artdeco:2a")
register("artdeco:2b")
register("artdeco:2c")
register("artdeco:2d")

-- register("artdeco:italianmarble")

register("artdeco:tile1")
register("artdeco:tile2")
register("artdeco:tile3")
register("artdeco:tile4")
register("artdeco:tile5")
register("artdeco:brownwalltile")
register("artdeco:greenwalltile")
register("artdeco:ceilingtile")

register("artdeco:decoblock1")
-- register("artdeco:decoblock2")
register("artdeco:decoblock3")
register("artdeco:decoblock4")
register("artdeco:decoblock5")
-- register("artdeco:decoblock6")

register("artdeco:whitegardenstone")
-- register("artdeco:stonewall")

