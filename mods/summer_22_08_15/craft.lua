local colors = {
	"red",
	"orange",
	"black",
	"yellow",
	"green",
	"blue",
	"violet",
	"white",
}

for _, colour in ipairs(colors) do

	minetest.register_craft({
		output = "summer:sdraia_"..colour.."",
		recipe = {
			{"default:stick", "wool:"..colour, "", },
			{"default:paper", "default:paper", "default:paper", },
			{"default:stick", "", "default:stick", }
		}
	})

	minetest.register_craft({
		output = "summer:ombrellone_"..colour.."",
		recipe = {
			{"default:paper", "wool:"..colour, "default:paper", },
			{"", "default:stick", "", },
			{"", "default:stick", "", }
		}
	})

	minetest.register_craft({
		output = "summer:ombrellone_n_"..colour.."",
		recipe = {
			{"", "wool:"..colour, "" },
			{"default:paper", "default:stick", "default:paper" },
			{"", "default:stick", "" }
		}
	})

	minetest.register_craft({
		output = "summer:asciugamano_"..colour.."",
		recipe = {
			{"wool:"..colour,"wool:"..colour},
			{"", ""},
		}
	})

--[[porta  

	minetest.register_craft({
		output = "summer:porta_"..colour.."_ch",
		recipe = {
			{"group:wood", "wool:"..colour, "", },
			{"wool:"..colour, "group:wood", "", },
			{"group:wood", "group:wood", "", }
		}
	})
]]
end

minetest.register_craft({
	output = "summer:rake",
	recipe = {
		{"default:stick", "default:steel_ingot", "default:stick", },
		{"", "default:stick", "", },
		{"", "default:gold_ingot", "", }
	}
})

minetest.register_craft({
	output = "summer:graniteBC 8",
	recipe = {
		{ "summer:graniteB", "summer:graniteB", "summer:graniteB" },
		{ "summer:graniteB", "dye:white", "summer:graniteB" },
		{ "summer:graniteB", "summer:graniteB", "summer:graniteB" },
	},
})
minetest.register_craft({
	output = '"summer:graniteB" 4',
	recipe = {
		{ "bakedclay:blue", "bakedclay:blue", "" },
		{ "bakedclay:blue", "bakedclay:blue", "" },
		{ "", "", "" },
	},
})
minetest.register_craft({
	output = '"summer:graniteR" 5',
	recipe = {
		{ "summer:mattoneR", "summer:mattoneR", "summer:mattoneR" },
		{ "summer:mattoneR", "summer:mattoneR", "summer:mattoneR" },
		{ "summer:mattoneR", "summer:mattoneR", "summer:mattoneR" },
	},
})

minetest.register_craft({
	output = '"summer:graniteA" 5',
	recipe = {
		{ "summer:mattoneA", "summer:mattoneA", "summer:mattoneA" },
		{ "summer:mattoneA", "summer:mattoneA", "summer:mattoneA" },
		{ "summer:mattoneA", "summer:mattoneA", "summer:mattoneA" },
	},
})
minetest.register_craft({
	output = '"summer:granite" 5',
	recipe = {
		{ "summer:mattoneG", "summer:mattoneG", "summer:mattoneG" },
		{ "summer:mattoneG", "summer:mattoneG", "summer:mattoneG" },
		{ "summer:mattoneG", "summer:mattoneG", "summer:mattoneG" },
	},
})
minetest.register_craft({
	output = '"summer:graniteP" 5',
	recipe = {
		{ "summer:mattoneP", "summer:mattoneP", "summer:mattoneP" },
		{ "summer:mattoneP", "summer:mattoneP", "summer:mattoneP" },
		{ "summer:mattoneP", "summer:mattoneP", "summer:mattoneP" },
	},
})
