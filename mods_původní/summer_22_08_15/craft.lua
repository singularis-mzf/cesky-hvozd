if minetest.get_modpath("wool") and minetest.get_modpath("dye")then
local lchest_list = {
	{ "Red chest", "red"},
	{ "Orange chest", "orange"},
    { "Black ", "black"},
	{ "Yellow chest", "yellow"},
	{ "Green chest", "green"},
	{ "Blue chest", "blue"},
	{ "Violet chest", "violet"},
	{"white chest", "white"}
}

for i in ipairs(lchest_list) do
	local desc = lchest_list[i][1]
	local colour = lchest_list[i][2]

--rake
minetest.register_craft({
		output = "summer:rake",
		recipe = {
			{"default:stick", "default:steel_ingot", "default:stick", },
			{"", "default:stick", "", },
			{"", "default:gold_ingot", "", }
		}
	})
--sdraia
minetest.register_craft({
		output = "summer:sdraia_"..colour.."",
		recipe = {
			{"default:stick", "wool:"..colour, "", },
			{"default:paper", "default:paper", "default:paper", },
			{"default:stick", "", "default:stick", }
		}
	})

	--portacenere
		minetest.register_craft({
		output = "summer:Portacenere_"..colour.."",
		recipe = {
			{"group:wood", "", "group:wood" },
			{"default:stick", "default:paper", "default:stick" },
			{"default:paper", "wool:"..colour, "default:paper" }
		}
	})

--porta  

	minetest.register_craft({
		output = "summer:porta_"..colour.."_ch",
		recipe = {
			{"group:wood", "wool:"..colour, "", },
			{"wool:"..colour, "group:wood", "", },
			{"group:wood", "group:wood", "", }
		}
	})
--occhiali
minetest.register_craft({
		output = "summer:occhiali_"..colour.."",
		recipe = {
			{"", "wool:"..colour, "", },
			{"default:stick", "", "default:stick", },
			{"default:glass", "default:stick", "default:glass", }
		}
	})


--________________________________________________________

--asciugamano
--________________________________________________________	

minetest.register_craft({
		output = "summer:asciugamano_"..colour.."",
		recipe = {
			{"","","", },
			{"wool:"..colour, "", "", },
			{"default:ladder_wood", "default:ladder_wood", "default:ladder_wood", }
		}
	})

--________________________________________________________
--breccia
--________________________________________________________

    --craft BRECCIA BLOCK
	minetest.register_craft({
		output = '"summer:breccia" 4',
		recipe = {
			{ "summer:pietra", "summer:pietra", "summer:pietra" },
			{ "summer:pietra", "summer:pietra", "summer:pietra" },
			{ "summer:pietra", "summer:pietra", "summer:pietra" },
		},
	})

	minetest.register_craft({
		output ='"summer:desert_breccia_2" 4',
		recipe = {
			{ "summer:desert_pietra", "summer:desert_pietra", "summer:desert_pietra" },
			{ "summer:desert_pietra", "summer:desert_pietra", "summer:desert_pietra" },
			{ "summer:desert_pietra", "summer:desert_pietra", "summer:desert_pietra" },
		},
	})

	minetest.register_craft({
		output = '"summer:breccia_2" 4',
		recipe = {
			{ "summer:pietraA", "summer:pietraA", "summer:pietraA" },
			{ "summer:pietraA", "summer:pietraA", "summer:pietraA" },
			{ "summer:pietraA", "summer:pietraA", "summer:pietraA" },
		},
	})

	minetest.register_craft({
		output = '"summer:desert_breccia" 4',
		recipe = {
			{ "summer:pietraP", "summer:pietraP", "summer:pietraP" },
			{ "summer:pietraP", "summer:pietraP", "summer:pietraP" },
			{ "summer:pietraP", "summer:pietraP", "summer:pietraP" },
		},
	})	
	
	--____________________________________________________
	--granite
	--____________________________________________________
	
	--craft GRANITE
minetest.register_craft({
		output = '"summer:graniteBC" 5',
		recipe = {
			{ "", "", "" },
			{ "summer:pietraA", "", "" },
			{ "summer:graniteB", "", "" },
		},
	})
	minetest.register_craft({
		output = '"summer:graniteB" 5',
		recipe = {
			{ "", "", "" },
			{ "summer:graniteP", "summer:graniteA", "" },
			{ "summer:graniteR", "summer:graniteG", "" },
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
--________________________________________________________




--________________________________________________________
--ombrellone
--________________________________________________________
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
	
	
	
--________________________________________________________
	
--chest
--________________________________________________________
minetest.register_craft({
		output = "summer:chest"..colour.."",
		recipe = {
		{"default:stone","dye:"..colour.."","default:stone"},
		{"group:wood","","group:wood"},
		{"group:wood","group:wood","group:wood"}
		
		}
	})
	
	
	minetest.register_craft({
		output = "summer:chest_lock"..colour.."",
		recipe = {
		{"summer:chest"..colour.."","default:diamond",""}
		--{"","",""},
		--{"","",""}
		
		}
	})
	
end

end
