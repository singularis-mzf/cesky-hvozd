
local expect_clothing = minetest.settings:get_bool("ch_expect_clothing", false)

minetest.register_craft({
	output = 'clothing:yarn_spool_empty',
	recipe = {
		{'group:stick'},
		{'stairs:slab_wood'},
	},
})

minetest.register_craft({
  output = 'clothing:bone_needle',
  recipe = {
    {'group:bone'},
    {'group:bone'},
  },
})

minetest.register_craft({
	output = 'clothing:spinning_machine',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'farming:string', 'group:wood'},
		{'group:wood', "group:wood", 'group:wood'},
	},
})

minetest.register_craft({
	output = 'clothing:loom',
	recipe = {
		{'group:stick', 'default:pinewood', 'group:stick'},
		{'group:stick', 'default:pinewood', 'group:stick'},
		{'default:pinewood', "default:pinewood", 'default:pinewood'},
	},
})

minetest.register_craft({
	output = 'clothing:dye_machine_empty',
	recipe = {
		{'group:wood', 'group:stick', 'group:wood'},
		{'group:wood', 'group:stick', 'group:wood'},
		{'group:wood', "group:wood", 'group:wood'},
	},
})

minetest.register_craft({
	output = 'clothing:sewing_table',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:stick', 'clothing:bone_needle', 'group:stick'},
		{'group:stick', 'clothing:bone_needle', 'group:stick'},
	},
})

if clothing.have_farming then
	if not expect_clothing then
		ch_core.clear_crafts("clothing1", {{
			--output = "farming:string 2"
			recipe = {
			{"farming:cotton"},
			{"farming:cotton"},
			},
		}})
	end
	minetest.register_craft({
		output = "farming:string",
		recipe = {
		{"clothing:yarn_spool_white"},
		{"clothing:yarn_spool_white"},
		},
		replacements = {
		{"clothing:yarn_spool_white", "clothing:yarn_spool_empty"},
		{"clothing:yarn_spool_white", "clothing:yarn_spool_empty"},
		},
	})
end

if not expect_clothing and minetest.registered_items["farming:hemp_fibre"] then
	ch_core.clear_crafts("clothing2", {{
		--output = "farming:cotton 3"
		recipe = {
		{"farming:hemp_fibre"},
		{"farming:hemp_fibre"},
		{"farming:hemp_fibre"},
		},
	}})
end

for color, data in pairs(clothing.colors) do
	minetest.register_craft({
		type = "shapeless",
		output = "clothing:gloves_"..color,
		recipe = {"clothing:glove_right_"..color, "clothing:glove_left_"..color},
	})
	minetest.register_craft({
		type = "shapeless",
		output = "clothing:glove_right_"..color,
		recipe = {"clothing:gloves_"..color},
		replacements = {
			{"clothing:gloves_"..color, "clothing:glove_left_"..color},
		},
	})
	if data.hex2 then
		minetest.register_craft({
			type = "shapeless",
			output = "clothing:gloves_"..color.."_stripy",
			recipe = {"clothing:glove_right_"..color.."_stripy", "clothing:glove_left_"..color.."_stripy"},
		})
		minetest.register_craft({
			type = "shapeless",
			output = "clothing:glove_right_"..color.."_stripy",
			recipe = {"clothing:gloves_"..color.."_stripy"},
			replacements = {
				{"clothing:gloves_"..color.."_stripy", "clothing:glove_left_"..color.."_stripy"},
			},
		})
	end
end
