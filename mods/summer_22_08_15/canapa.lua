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

--sdraia
minetest.register_craft({
		output = "summer:sdraia_"..colour.."",
		recipe = {
			{"", "wool:"..colour, "", },
			{"cannabis:canapa_fiber", "cannabis:canapa_plastic", "cannabis:canapa_fiber", },
			{"", "cannabis:canapa_fiber", "", }
		}
	})

--portacenere
	
		minetest.register_craft({
		output = "summer:Portacenere_"..colour.."",
		recipe = {
			{"cannabis:canapa_fiber", "", "cannabis:canapa_fiber" },
			{"cannabis:canapa_plastic", "", "cannabis:canapa_plastic" },
			{"cannabis:canapa_plastic", "wool:"..colour, "cannabis:canapa_plastic" }
		}
	})
--occhiali
minetest.register_craft({
		output = "summer:occhiali_"..colour.."",
		recipe = {
			{"", "wool:"..colour, "", },
			{"", "cannabis:canapa_fiber", "", },
			{"cannabis:canapa_plastic", "", "cannabis:canapa_plastic", }
		}
	})
--porta
	minetest.register_craft({
		output = "summer:porta_"..colour.."_ch",
		recipe = {
			{"cannabis:canapa_fiber", "wool:"..colour, "", },
			{"wool:"..colour, "cannabis:canapa_fiber", "", },
			{"cannabis:canapa_fiber", "cannabis:canapa_fiber", "", }
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
			{"cannabis:canapa_fiber", "cannabis:canapa_fiber", "cannabis:canapa_fiber", }
		}
	})
	
--________________________________________________________

--ombrellone
--________________________________________________________
	minetest.register_craft({
		output = "summer:ombrellone_"..colour.."",
		recipe = {
			{"", "wool:"..colour, "", },
			{"", "cannabis:canapa_plastic", "", },
			{"", "cannabis:canapa_fiber", "", }
		}
	})
	


	minetest.register_craft({
		output = "summer:ombrellone_n_"..colour.."",
		recipe = {
			{"cannabis:canapa_fiber", "wool:"..colour, "cannabis:canapa_fiber" },
			{"", "cannabis:canapa_plastic", "" },
			{"", "cannabis:canapa_plastic", "" }
		}
	})
	
	
	
--________________________________________________________
	
--chest
--________________________________________________________
minetest.register_craft({
		output = "summer:chest"..colour.."",
		recipe = {
		{"cannabis:canapa_plastic","dye:"..colour.."","cannabis:canapa_plastic"},
		{"group:wood","","group:wood"},
		{"group:wood","group:wood","group:wood"}
		
		}
	})
	
	
	minetest.register_craft({
		output = "summer:chest_lock"..colour.."",
		recipe = {
		{"summer:chest"..colour.."","cannabis:high_performance_ingot",""}
		--{"","",""},
		--{"","",""}
		
		}
	})
	
end
end

