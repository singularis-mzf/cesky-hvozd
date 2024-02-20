--------------------
-- Register Nodes
--------------------

local S = minetest.get_translator("church_glass")

local glass_sounds = nil
if minetest.get_modpath("sounds") then
	glass_sounds = sounds.node_glass()
elseif minetest.get_modpath("default") then
	glass_sounds = default.node_sound_glass_defaults()
elseif minetest.get_modpath("hades_sounds") then
	glass_sounds = hades_sounds.node_sound_glass_defaults()
end

local colors = {
	white = {
		color = S("White"),
		hex = "FFFFFF",
	},
	grey = {
		color = S("Grey"),
		hex = "C0C0C0",
	},
	black = {
		color = S("Black"),
		hex = "232323",
	},
	red = {
		color = S("Red"),
		hex = "FF0000",
	},
	yellow = {
		color = S("Yellow"),
		hex = "FFEE00",
	},
	green = {
		color = S("Green"),
		hex = "32CD32",
	},
	cyan = {
		color = S("Cyan"),
		hex = "00959D",
	},
	blue = {
		color = S("Blue"),
		hex = "003376",
	},
	magenta = {
		color = S("Magenta"),
		hex = "D80481",
	},
	orange = {
		color = S("Orange"),
		hex = "E0601A",
	},
	violet = {
		color = S("Violet"),
		hex = "480080",
	},
	brown = {
		color = S("Brown"),
		hex = "391A00",
	},
	pink = {
		color = S("Pink"),
		hex = "FFA5A5",
	},
	dark_grey = {
		color = S("Dark Grey"),
		hex = "696969",
	},
	dark_green = {
		color = S("Dark Green"),
		hex = "154F00",
	},
}

local strips = {
	copper = {
		strip = S("Copper"),
		hex	= "b6ac62",
		item = "default:copper_lump",
	}
}

if minetest.get_modpath("hades_core") then
	strips.copper.item = "hades_core:copper_lump"
end

if minetest.get_modpath("basic_materials") then
	strips.copper.item = "basic_materials:copper_strip"
end

if minetest.get_modpath("technic_worldgen") then
	strips.lead = {
			strip = S("Lead"),
			hex	= "847c7a",
			item = "technic:lead_lump"
		}

	if minetest.get_modpath("basic_materials") then
		strips.lead.item = "basic_materials:lead_strip"
	end
end

if minetest.get_modpath("hades_technic_worldgen") then
	strips.lead = {
			strip = S("Lead"),
			hex	= "847c7a",
			item = "technic:lead_lump"
		}

	if minetest.get_modpath("basic_materials") then
		strips.lead.item = "basic_materials:lead_strip"
	end
end

local styles = {
		-- 1
		{
			recipe = {
				{"S","S","S"},
				{"S","S","S"},
				{"S","S","S"},
			},
		},
		-- 2
		{
			recipe = {
				{"","S","S"},
				{"S","","S"},
				{"S","S","S"},
			},
		},
		-- 3
		{
			recipe = {
				{"S","","S"},
				{"","",""},
				{"S","","S"},
			},
		},
		-- 4
		{
			recipe = {
				{"","S","S"},
				{"S","S","S"},
				{"S","S",""},
			},
		},
		-- 5
		{
			recipe = {
				{"","S",""},
				{"S","","S"},
				{"","S",""},
			},
		},
		-- 6
		{
			recipe = {
				{"S","S",""},
				{"S","","S"},
				{"","S",""},
			},
		},
		-- 7
		{
			recipe = {
				{"S","","S"},
				{"","S",""},
				{"S","","S"},
			},
		},
		-- 8
		{
			recipe = {
				{"","S","S"},
				{"S","","S"},
				{"S","S","S"},
			},
		},
	}

local dye_prefix = "dye:"
local glass_fragments = "vessels:glass_fragments"

if minetest.get_modpath("hades_dye") then
	dye_prefix = "hades_dye:"
end

if minetest.get_modpath("hades_vessels") then
	glass_fragments = "hades_vessels:glass_fragments"
end

for strip,strip_data in pairs(strips) do
	local side_image = "church_glass_frame.png^[multiply:#"..strip_data.hex
	for style,style_data in pairs(styles) do
		local image = "church_glass_frame_"..style..".png^[multiply:#"..strip_data.hex
		minetest.register_node("church_glass:church_frame_"..strip.."_"..style, {
				description = "Stained Glass "..style.." "..strip_data.strip.." Frame",
				use_texture_alpha = "clip",
				inventory_image = image,
				--wield_image = "church_glass_itemname.png",
				tiles = {
					side_image,
					side_image,
					side_image,
					side_image,
					"("..image..")^[transformFX",
					image,
				},
				drawtype = "nodebox",
				sunlight_propagates = true,
				paramtype = "light",
				paramtype2 = "facedir",
				is_ground_content = false,
				light_source = 5,
				groups = {snappy=3,choppy=3,cracky=3,crumbly=3, oddly_breakable_by_hand=3},
				sounds = glass_sounds,
				node_box = {
					type = "fixed",
					fixed = {
						{ -0.5, -0.5, -0.05, 0.5, 0.5, 0.05},
					},
				},
				selection_box = {
					type = "fixed",
					fixed = {
						{ -0.5, -0.5, -0.05, 0.5, 0.5, 0.05},
					},
				},
			})
		
		local recipe = table.copy(style_data.recipe)
		for _,line in pairs(recipe) do
			for index,item in pairs(line) do
				if item~="" then
					line[index] = strip_data.item
				end
			end
		end
	
		minetest.register_craft({
			output = "church_glass:church_frame_"..strip.."_"..style,
			recipe = recipe,
		})
		
		for color,color_data in pairs(colors) do
			local image = "(church_glass_glass_"..style..".png^[colorize:#"..color_data.hex..":128)^(church_glass_frame_"..style..".png^[multiply:#"..strip_data.hex..")"
			minetest.register_node("church_glass:church_glass_"..strip.."_"..style.."_"..color, {
					description = color_data.color.." Stained Glass "..style.." "..strip_data.strip.." Frame",
					use_texture_alpha = "blend",
					inventory_image = image,
					--wield_image = "church_glass_itemname.png",
					tiles = {
						side_image,
						side_image,
						side_image,
						side_image,
						"("..image..")^[transformFX",
						image,
					},
					drawtype = "nodebox",
					sunlight_propagates = true,
					paramtype = "light",
					paramtype2 = "facedir",
					is_ground_content = false,
					light_source = 5,
					groups = {snappy=3,choppy=3,cracky=3,crumbly=3, oddly_breakable_by_hand=3},
					sounds = glass_sounds,
					node_box = {
						type = "fixed",
						fixed = {
							{ -0.5, -0.5, -0.05, 0.5, 0.5, 0.05},
						},
					},
					selection_box = {
						type = "fixed",
						fixed = {
							{ -0.5, -0.5, -0.05, 0.5, 0.5, 0.05},
						},
					},
				})
			
			minetest.register_craft({
				output = "church_glass:church_glass_"..strip.."_"..style.."_"..color,
				recipe = {
					{"church_glass:church_frame_"..strip.."_"..style, glass_fragments, dye_prefix..color},
				},
			})
		end
	end
end

for _, c in pairs({"blue", "green", "red", "violet"}) do
	minetest.register_node("church_glass:church_glass_"..c, {
		description = c.." Stained Glass",
		use_texture_alpha = "blend",
		inventory_image = "church_glass_"..c..".png",
		--wield_image = "church_glass_itemname.png",
		tiles = {
			"church_glass_sides.png",
			"church_glass_sides.png",
			"church_glass_sides.png",
			"church_glass_sides.png",
			"church_glass_"..c..".png^[transformFX",
			"church_glass_"..c..".png"
		},
		drawtype = "nodebox",
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		light_source = 5,
		groups = {snappy=3,choppy=3,cracky=3,crumbly=3, oddly_breakable_by_hand=3},
		sounds = glass_sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.05, 0.5, 0.5, 0.05},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.05, 0.5, 0.5, 0.05},
			},
		},
	})

	minetest.register_node("church_glass:church_glass_"..c.."_fancy", {
		description = c.." Stained Glass",
		use_texture_alpha = "blend",
		inventory_image = "church_glass_"..c.."_fancy.png",
		--wield_image = "church_glass_itemname.png",
		tiles = {
			"church_glass_sides.png",
			"church_glass_sides.png",
			"church_glass_sides.png",
			"church_glass_sides.png",
			"church_glass_"..c.."_fancy.png^[transformFX",
			"church_glass_"..c.."_fancy.png"
		},
		drawtype = "nodebox",
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		light_source = 5,
		groups = {snappy=3,choppy=3,cracky=3,crumbly=3, oddly_breakable_by_hand=3},
		sounds = glass_sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.05, 0.5, 0.5, 0.05},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.05, 0.5, 0.5, 0.05},
			},
		},
	})
	-----------------------------
	-- Register Craft Recipes
	-----------------------------

end
