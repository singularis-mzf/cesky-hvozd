local granite = {
	{"granite", "Granite grey"},
	{"graniteR", "Granite corten"},
	{"graniteA", "Granite avory"},
	{"graniteP", "Granite pink"},
	{"graniteB", "Granite black"},
	{"graniteBC", "Granite black center"},
}

local stairs_mod = minetest.get_modpath("stairs")
local stairsplus_mod = minetest.get_modpath("moreblocks")
	and minetest.global_exists("stairsplus")

for _, granite in pairs(granite) do
if stairsplus_mod then

		stairsplus:register_all("summer", granite[1], "summer:" .. granite[1], {
			description = granite[2] .. " Summer",
			tiles = {granite[1] .. ".png"},
			groups = {cracky = 3},
			sounds = default.node_sound_stone_defaults(),
		})

		stairsplus:register_alias_all("summer", granite[1], "summer", granite[1])
		minetest.register_alias("stairs:slab_summer_".. granite[1], "summer:slab_baked_granite_" .. granite[1])
		minetest.register_alias("stairs:stair_summer_".. granite[1], "summer:stair_baked_granite_" .. granite[1])

	-- register all stair types for stairs redo
	elseif stairs_mod and stairs.mod then

		stairs.register_all("summer_" .. granite[1], "summer:" .. granite[1],
			{cracky = 3},
			{granite[1] .. ".png"},
			granite[2] .. " Summer",
			default.node_sound_stone_defaults())

	-- register stair and slab using default stairs
	elseif stairs_mod then

		stairs.register_stair_and_slab("summer_".. granite[1], "summer:".. granite[1],
			{cracky = 3},
			{granite[1] .. ".png"},
			granite[2] .. " Summer Stair",
			granite[2] .. " Summer Slab",
			default.node_sound_stone_defaults())
	end
end
  --GRANITE
minetest.register_node("summer:granite", {
	description = "Granite",
	tiles = {"granite.png"},
    --material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='"summer:mattoneG" 9',
	stack_max = 9999,
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("summer:graniteA", {
	description = "GraniteA",
	tiles = {"graniteA.png"},
    --material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='"summer:mattoneA" 9',
	stack_max = 9999,
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("summer:graniteP", {
	description = "GraniteP",
	tiles = {"graniteP.png"},
    --material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='"summer:mattoneP" 9',
	stack_max = 9999,
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("summer:graniteR", {
	description = "GraniteR",
	tiles = {"graniteR.png"},
    --material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='summer:mattoneR 9',
	stack_max = 9999,
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

      minetest.register_node("summer:graniteBC", {
	description = "Granite",
	tiles = {"graniteBC.png"},
    --material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='"summer:mattoneG" 9',
	stack_max = 9999,
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})
    minetest.register_node("summer:graniteB", {
	description = "Granite",
	tiles = {"graniteB.png"},
    --material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='"summer:mattoneG" 9',
	stack_max = 9999,
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})


