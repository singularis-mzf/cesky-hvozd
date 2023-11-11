
local S = technic.getter

technic.register_recipe_type("extracting", { description = S("Extracting") })

function technic.register_extractor_recipe(data)
	data.time = data.time or 4
	technic.register_recipe("extracting", data)
end

if minetest.get_modpath("dye") then
	-- check if we are using dye or unifieddyes
	local unifieddyes = minetest.get_modpath("unifieddyes")

	-- register recipes with the same crafting ratios as `dye` provides
	local dye_recipes = {
		{"technic:coal_dust",                 "dye:black 2"},
		{"default:blueberries",               "dye:blue 2"},
		{"farming:blueberries",               "dye:blue 2"},
		{"flowers:mushroom_brown",            "dye:brown 1"},
		{"flowers:mushroom_red",              "dye:red 1"},
		{"default:grass_1",                   "dye:green 1"},
		{"default:dry_shrub",                 "dye:brown 4"},
		{"default:junglegrass",               "dye:green 2"},
		{"default:cactus",                    "dye:green 4"},
		{"flowers:geranium",                  "dye:blue 4"},
		{"flowers:dandelion_white",           "dye:white 4"},
		{"flowers:dandelion_yellow",          "dye:yellow 4"},
		{"flowers:tulip",                     "dye:orange 4"},
		{"flowers:rose",                      "dye:red 4"},
		{"flowers:viola",                     "dye:violet 4"},
		{"farming:raspberries",               "dye:magenta 2"},
		{"farming:onion",                     "dye:yellow 4"},
		{"farming:rhubarb",                   "dye:yellow 4"},
		{"bushes:blackberry",                 unifieddyes and "unifieddyes:magenta_s50 4" or "dye:violet 4"},
		{"bushes:blueberry",                  unifieddyes and "unifieddyes:magenta_s50 4" or "dye:magenta 4"},
		{"wine:bottle_brandy",                "farming:bottle_ethanol 2"},
		{"wine:bottle_tequila",               "farming:bottle_ethanol 2"},
		{"wine:bottle_vodka",                 "farming:bottle_ethanol 2"},
		{"wine:bottle_slivovice",             "farming:bottle_ethanol 4"},
	}

	for _, data in ipairs(dye_recipes) do
		technic.register_extractor_recipe({input = {data[1]}, output = data[2]})
	end

	-- overwrite the existing crafting recipes
	local dyes = {"white", "red", "yellow", "blue", "violet", "orange"}
	local crafts_to_clear = {}
	for _, color in ipairs(dyes) do
		crafts_to_clear[color] = {
			type = "shapeless",
			recipe = {"group:flower,color_"..color},
		}
	end
	ch_core.clear_crafts("extractor_recipes", crafts_to_clear)
	for _, color in ipairs(dyes) do
		minetest.register_craft({
			type = "shapeless",
			output = "dye:"..color.." 1",
			recipe = {"group:flower,color_"..color},
		})
	end

	crafts_to_clear = {
		{
			type = "shapeless",
			recipe = {"group:coal"},
		},
		{
			output = "farming:bottle_ethanol"
		},
	}

	ch_core.clear_crafts("extractor_recipes2", crafts_to_clear)
	minetest.register_craft({
		type = "shapeless",
		output = "dye:black 1",
		recipe = {"group:coal"},
	})

	if unifieddyes then
		ch_core.clear_crafts("extractor_recipes3", {{
			type = "shapeless",
			recipe = {"default:cactus"},
		}})
		minetest.register_craft({
			type = "shapeless",
			output = "dye:green 1",
			recipe = {"default:cactus"},
		})
	end
end
