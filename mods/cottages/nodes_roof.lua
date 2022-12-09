-- Boilerplate to support localized strings if intllib mod is installed.
local S = cottages.S

-- Materials:

local cottage_materials = {
	reet = {
            description = S("špinavá sláma"),
            tiles = {"cottages_reet.png"},
            sounds = cottages.sounds.stone,
            groups = {hay = 3, snappy=3,choppy=3,oddly_breakable_by_hand=3,flammable=3,roof=1},
	},
	black = {
			description = S("asfaltová střešní krytina"),
			tiles = {"cottages_homedecor_shingles_asphalt.png"},
			sounds = cottages.sounds.stone,
			groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2,roof=1},
	},
	red = {
			description = S("světlé křidlice (střešní krytina)"),
			tiles = {"cottages_homedecor_shingles_terracotta.png"},
			sounds = cottages.sounds.stone,
			groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2,roof=1},
	},
	brown = {
			description = S("tmavé křidlice (střešní krytina)"),
			tiles = {"cottages_homedecor_shingles_wood.png"},
			sounds = cottages.sounds.wood,
			groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2,roof=1},
	},
}

for name, def in pairs(cottage_materials) do
	minetest.register_node("cottages:" .. name, {
		description = def.description,
		tiles = def.tiles,
		use_texture_alpha = "oblique",
		paramtype2 = "facedir",
		groups = def.groups,
		sounds = def.sounds,
		is_ground_content = false,
		})
end

if minetest.get_modpath("moreblocks") then
	for name, def in pairs(cottage_materials) do
		stairsplus:register_all("cottages", name, "cottages:" .. name, def)
	end
end


--[[
minetest.register_craft({
	output  = "cottages:reet",
	recipe = { {cottages.craftitem_papyrus,cottages.craftitem_papyrus},
	           {cottages.craftitem_papyrus,cottages.craftitem_papyrus},
	},
})
]]
