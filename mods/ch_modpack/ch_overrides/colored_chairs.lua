if minetest.get_modpath("bakedclay") and minetest.get_modpath("default") then

	local bakedclay_colors = {
		black = "000000",
		blue =  "1414dc",
		brown = "391a00",
		cyan =  "14dcdc",
		dark_green = "146614",
		dark_grey = "494949",
		green =  "14dc14",
		grey =  "7f7f7f",
		magenta =  "dc14dc",
		-- natural =  "000000",
		orange =  "dc7814",
		pink =  "ff7272",
		red = "dc1414",
		violet =  "7814dc",
		white =  "ffffff",
		yellow = "dcdc14",
	}

	local furniture_types = {
		"kneeling_bench",
		"small_table",
		"bench",
		"table",
		"tiny_table",
		"chair",
	}

	local default_chair = minetest.registered_nodes["ts_furniture:default_wood_chair"]
	local normal_sounds = default_chair.sounds or default.node_sound_wood_defaults()
	local normal_tiles = default_chair.tiles[1]
	-- {"baked_clay_" .. clay[1] ..".png"}

	for color, color_code in pairs(bakedclay_colors) do
		ts_furniture.register_furniture("bakedclay:"..color, "Colored "..color, normal_tiles.."^[colorize:#"..color_code..":224^[colorize:#606060:32")
		for _, furntype in ipairs(furniture_types) do
			local name = "ts_furniture:bakedclay_"..color.."_"..furntype
			if minetest.registered_nodes[name] then
				minetest.override_item(name, {
					groups = minetest.registered_nodes["ts_furniture:default_wood_"..furntype].groups,
					sounds = normal_sounds,
				})
				minetest.clear_craft({output = name})
				minetest.register_craft({type = "shapeless", output = name, recipe = {"group:ts_"..furntype, "dye:"..color}})
			end
		end
	end
end
