-- from Bushes classic mod (originally by unknown, maintained by VanessaE),
-- reduced by Singularis

-- support for i18n
local S = minetest.get_translator("bushes_classic")

local bushes = {
	["strawberry"] = S("Strawberry Bush"),
	["blackberry"] = S("Blackberry Bush"),
	["blueberry"] = S("Blueberry Bush"),
	["raspberry"] = S("Raspberry Bush"),
	["gooseberry"] = S("Gooseberry Bush"),
	["fruitless"] = S("Currently fruitless Bush"),
}
local def = {
	drawtype = "mesh",
	mesh = "bushes_bush.obj",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	groups = {snappy = 3, bush = 1, flammable = 2, attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	-- drop = "",
}

for id, description in pairs(bushes) do
	def.description = description
	def.tiles = {"bushes_bush_"..id..".png"}
	minetest.register_node("bushes_classic:"..id.."_bush", table.copy(def))
end
