ch_base.open_mod(minetest.get_current_modname())

-- Baked Clay by TenPlus1

local S = minetest.get_translator("bakedclay")


local clay = {
	{"natural", S("Natural")},
	{"white", S("White")},
	{"grey", S("Grey")},
	{"black", S("Black")},
	{"red", S("Red")},
	{"yellow", S("Yellow")},
	{"green", S("Green")},
	{"cyan", S("Cyan")},
	{"blue", S("Blue")},
	{"magenta", S("Magenta")},
	{"orange", S("Orange")},
	{"violet", S("Violet")},
	{"brown", S("Brown")},
	{"pink", S("Pink")},
	{"dark_grey", S("Dark Grey")},
	{"dark_green", S("Dark Green")}
}

local expect_technic = minetest.settings:get_bool("ch_expect_technic", false)
local techcnc_mod = minetest.get_modpath("technic_cnc")
local stairs_mod = minetest.get_modpath("stairs")
local stairsplus_mod = minetest.get_modpath("moreblocks")
	and minetest.global_exists("stairsplus")

for _, clay in pairs(clay) do

	-- node

	minetest.register_node("bakedclay:" .. clay[1], {
		description = S("@1 Baked Clay", clay[2]),
		tiles = {"baked_clay_" .. clay[1] ..".png"},
		groups = {cracky = 3, bakedclay = 1},
		sounds = default.node_sound_stone_defaults()
	})

	-- craft recipe

	if clay[1] ~= "natural" then

		minetest.register_craft({
			output = "bakedclay:" .. clay[1] .. " 8",
			recipe = {
				{"group:bakedclay", "group:bakedclay", "group:bakedclay"},
				{"group:bakedclay", "dye:" .. clay[1], "group:bakedclay"},
				{"group:bakedclay", "group:bakedclay", "group:bakedclay"}
			}
		})
	end

	-- stairs plus
	if stairsplus_mod then

		stairsplus:register_all("bakedclay", "baked_clay_" .. clay[1],
				"bakedclay:" .. clay[1], {
			description = S("@1 Baked Clay", clay[2]),
			tiles = {"baked_clay_" .. clay[1] .. ".png"},
			groups = {cracky = 3},
			sounds = default.node_sound_stone_defaults()
		})

		stairsplus:register_alias_all("bakedclay", clay[1],
				"bakedclay", "baked_clay_" .. clay[1])

		minetest.register_alias("stairs:slab_bakedclay_".. clay[1],
				"bakedclay:slab_baked_clay_" .. clay[1])

		minetest.register_alias("stairs:stair_bakedclay_".. clay[1],
				"bakedclay:stair_baked_clay_" .. clay[1])

	-- stairs redo
	elseif stairs_mod and stairs.mod then

		stairs.register_all("bakedclay_" .. clay[1], "bakedclay:" .. clay[1],
			{cracky = 3},
			{"baked_clay_" .. clay[1] .. ".png"},
			S("@1 Baked Clay", clay[2]),
			default.node_sound_stone_defaults())

	-- default stairs
	elseif stairs_mod then

		stairs.register_stair_and_slab("bakedclay_".. clay[1], "bakedclay:".. clay[1],
			{cracky = 3},
			{"baked_clay_" .. clay[1] .. ".png"},
			S("@1 Baked Clay Stair", clay[2]),
			S("@1 Baked Clay Slab", clay[2]),
			default.node_sound_stone_defaults())
	end

	-- register bakedclay for use in technic_cnc mod
	if techcnc_mod then

		technic_cnc.register_all("bakedclay:" .. clay[1],
		{cracky = 3, not_in_creative_inventory = 1},
		{"baked_clay_" .. clay[1] .. ".png"},
		S("@1 Baked Clay", clay[2]))
	end
end

-- cook clay block into white baked clay

minetest.register_craft({
	type = "cooking",
	output = "bakedclay:natural",
	recipe = "default:clay",
})

-- register a few extra dye colour options

minetest.register_craft( {
	type = "shapeless",
	output = "dye:dark_grey 3",
	recipe = {"dye:black", "dye:black", "dye:white"}
})

if not expect_technic then
minetest.register_craft( {
	type = "shapeless",
	output = "dye:green 4",
	recipe = {"default:cactus"}
})

minetest.register_craft( {
	type = "shapeless",
	output = "dye:brown 4",
	recipe = {"default:dry_shrub"}
})
end

-- only add light grey recipe if unifieddye mod isnt present (conflict)
if not minetest.get_modpath("unifieddyes") then

	minetest.register_craft( {
		type = "shapeless",
		output = "dye:grey 3",
		recipe = {"dye:black", "dye:white", "dye:white"}
	})
end

-- 2x2 red baked clay makes 16x clay brick
minetest.register_craft( {
	output = "default:clay_brick 16",
	recipe = {
		{"bakedclay:red", "bakedclay:red"},
		{"bakedclay:red", "bakedclay:red"},
	}
})

-- register some new flowers to fill in missing dye colours
-- flower registration (borrowed from default game)

local function add_simple_flower(name, desc, box, f_groups)

	f_groups.snappy = 3
	f_groups.flower = 1
	f_groups.flora = 1
	f_groups.attached_node = 1

	minetest.register_node("bakedclay:" .. name, {
		description = desc,
		drawtype = "plantlike",
		waving = 1,
		tiles = {"baked_clay_" .. name .. ".png"},
		use_texture_alpha = "clip",
		inventory_image = "baked_clay_" .. name .. ".png",
		wield_image = "baked_clay_" .. name .. ".png",
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		groups = f_groups,
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = box
		}
	})
end

local flowers = {
	{"delphinium", S("Blue Delphinium"),
	{-0.15, -0.5, -0.15, 0.15, 0.3, 0.15}, {color_cyan = 1}},

	{"thistle", S("Thistle"),
	{-0.15, -0.5, -0.15, 0.15, 0.2, 0.15}, {color_magenta = 1}},

	{"lazarus", S("Lazarus Bell"),
	{-0.15, -0.5, -0.15, 0.15, 0.2, 0.15}, {color_pink = 1}},

	{"mannagrass", S("Reed Mannagrass"),
	{-0.15, -0.5, -0.15, 0.15, 0.2, 0.15}, {color_dark_green = 1}}
}

for _,item in pairs(flowers) do
	add_simple_flower(unpack(item))
end

-- mapgen for new flowers

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = -0.02,
		scale = 0.04,
		spread = {x = 200, y = 200, z = 200},
		seed = 7133,
		octaves = 3,
		persist = 0.6
	},
	y_min = 10,
	y_max = 90,
	decoration = "bakedclay:delphinium"
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass", "default:dirt_with_dry_grass"},
	sidelen = 16,
	noise_params = {
		offset = -0.02,
		scale = 0.04,
		spread = {x = 200, y = 200, z = 200},
		seed = 7134,
		octaves = 3,
		persist = 0.6
	},
	y_min = 15,
	y_max = 90,
	decoration = "bakedclay:thistle"
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass", "default:dirt_with_rainforest_litter"},
	sidelen = 16,
	noise_params = {
		offset = -0.02,
		scale = 0.1,
		spread = {x = 50, y = 50, z = 50},
		seed = 7135,
		octaves = 3,
		persist = 0.6
	},
	y_min = 1,
	y_max = 90,
	decoration = "bakedclay:lazarus",
	spawn_by = "default:jungletree",
	num_spawn_by = 1
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass", "default:sand"},
	sidelen = 16,
	noise_params = {
		offset = -0.02,
		scale = 0.2,
		spread = {x = 50, y = 50, z = 50},
		seed = 7136,
		octaves = 3,
		persist = 0.6
	},
	y_min = 1,
	y_max = 15,
	decoration = "bakedclay:mannagrass",
	spawn_by = "group:water",
	num_spawn_by = 1
})

-- lucky blocks

if minetest.get_modpath("lucky_block") then

local p = "bakedclay:"

lucky_block:add_blocks({
	{"dro", {"bakedclay:"}, 10, true},
	{"fal", {p.."black", p.."blue", p.."brown", p.."cyan", p.."dark_green",
		p.."dark_grey", p.."green", p.."grey", p.."magenta", p.."orange",
		p.."pink", p.."red", p.."violet", p.."white", p.."yellow", p.."natural"}, 0},
	{"fal", {p.."black", p.."blue", p.."brown", p.."cyan", p.."dark_green",
		p.."dark_grey", p.."green", p.."grey", p.."magenta", p.."orange",
		p.."pink", p.."red", p.."violet", p.."white", p.."yellow", p.."natural"}, 0, true},
	{"dro", {p.."delphinium"}, 5},
	{"dro", {p.."lazarus"}, 5},
	{"dro", {p.."mannagrass"}, 5},
	{"dro", {p.."thistle"}, 6},
	{"flo", 5, {p.."natural", p.."black", p.."blue", p.."brown", p.."cyan",
		p.."dark_green", p.."dark_grey", p.."green", p.."grey", p.."magenta",
		p.."orange", p.."pink", p.."red", p.."violet", p.."white", p.."yellow"}, 2},
	{"nod", "default:chest", 0, {
		{name = p.."natural", max = 30},
		{name = p.."black", max = 30},
		{name = p.."blue", max = 30},
		{name = p.."brown", max = 30},
		{name = p.."cyan", max = 30},
		{name = p.."dark_green", max = 30},
		{name = p.."dark_grey", max = 30},
		{name = p.."green", max = 30},
		{name = p.."grey", max = 30},
		{name = p.."magenta", max = 30},
		{name = p.."orange", max = 30},
		{name = p.."pink", max = 30},
		{name = p.."red", max = 30},
		{name = p.."violet", max = 30},
		{name = p.."white", max = 30},
		{name = p.."yellow", max = 30}
	}},
})

end

-- flowerpot mod

if minetest.get_modpath("flowerpot") then
	flowerpot.register_node("bakedclay:delphinium")
	flowerpot.register_node("bakedclay:thistle")
	flowerpot.register_node("bakedclay:lazarus")
	flowerpot.register_node("bakedclay:mannagrass")
end

ch_base.close_mod(minetest.get_current_modname())
