 local vetro_list = {
	{ "Red vetro", "red"},
	{ "Orange vetro", "orange"},
    { "Black vetro", "black"},
	{ "Yellow vetro", "yellow"},
	{ "Green vetro", "green"},
	{ "Dark vetro", "dark_green"},
	{ "Cyan vetro", "cyan"},
	{ "Grey vetro", "grey"},
	{ "Withe vetro", "white"},
	{ "Fuxia vetro", "magenta"},
	{ "Trasparent vetro", "trasp"},
	{ "Blue vetro", "blue"},
	{ "Violet vetro", "violet"},
}

for i in ipairs(vetro_list) do
	local vetrodesc = vetro_list[i][1]
	local colour = vetro_list[i][2]
 

--trasparente con cornice colorata
    
   minetest.register_node("summer:vetro_"..colour.."", {
	    description = vetrodesc.."trasparente incorniciata",
	    tiles = {"vetro_"..colour..".png"},	    
        sunlight_propagates = true,
        drawtype = "glasslike",
       -- use_texture_alpha = true,
        paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
	   	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,not_in_creative_inventory=0},
		drop = "summer:vetro_"..colour.."",        
		sounds = default.node_sound_glass_defaults(),
        
 
   })
   --trasparente cornice colorata vetro unito
   
      minetest.register_node("summer:vetro_unito_"..colour.."", {
	    description = vetrodesc.."trasparente incorniciata unito",
	    tiles = {"vetro_"..colour..".png","vetro_trasp.png"},	    
        sunlight_propagates = true,
        drawtype = "glasslike_framed",
        use_texture_alpha = true,
        paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
	   	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,not_in_creative_inventory=0},
		drop = "summer:vetro_unito_"..colour.."",        
		sounds = default.node_sound_glass_defaults(),
        
 
   })
   --colorato con cornice colorato
   
      minetest.register_node("summer:vetro_colorato_"..colour.."", {
	    description = vetrodesc.."cornice colorato",
	    tiles = {"vetro_traspc_"..colour..".png"},	    
        sunlight_propagates = true,
        drawtype = "glasslike",
        use_texture_alpha = true,
        paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
	   	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,not_in_creative_inventory=0},
		drop = "summer:vetro_colorato_"..colour.."",        
		sounds = default.node_sound_glass_defaults(),
        
 --colorato con cornice colorato unito
   })
         minetest.register_node("summer:vetro_colorato_unito_"..colour.."", {
	    description = vetrodesc.."unito colorato",
	    tiles = {"vetro_traspc_"..colour..".png","vetro_trasp_"..colour..".png"},	    
        sunlight_propagates = true,
        drawtype = "glasslike_framed",
        use_texture_alpha = true,
        paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
	   	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,not_in_creative_inventory=0},
		drop = "summer:vetro_colorato_unito_"..colour.."",        
		sounds = default.node_sound_glass_defaults(),
        
 
   })
   --senza cornice
        minetest.register_node("summer:vetro_colorato_uni_"..colour.."", {
	    description = vetrodesc.." uniforme colorato",
	    tiles = {"vetro_trasp_"..colour..".png",},	    
        sunlight_propagates = true,
        drawtype = "glasslike",
        use_texture_alpha = true,
        paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
	   	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,not_in_creative_inventory=0},
		drop = "summer:vetro_colorato_uni_"..colour.."",        
		sounds = default.node_sound_glass_defaults(),
        
 
   })
   minetest.register_craftitem("summer:vetro_traspp", {
	description = "vetrino",
	inventory_image = "vetro_traspp.png",
	--groups = {stick = 1, flammable = 2},
})
  minetest.register_craft({
	type = "cooking",
	cooktime = 10,
	output = "summer:vetro_traspp",
	recipe = "summer:mattoneG"
})
 minetest.register_craft({
	type = "cooking",
	cooktime = 10,
	output = "summer:vetro_traspp",
	recipe = "summer:mattoneA"
})
minetest.register_craft({
	type = "cooking",
	cooktime = 10,
	output = "summer:vetro_traspp",
	recipe = "summer:mattoneR"
})
minetest.register_craft({
	type = "cooking",
	cooktime = 10,
	output = "summer:vetro_traspp",
	recipe = "summer:mattoneP"
})
--vetro senza cornce
   	minetest.register_craft({
		output = "summer:vetro_colorato_uni_"..colour.."",
		recipe = {
			{"", "dye:"..colour, "", },
			{"", "summer:vetro_traspp","", },
			{"", "", "", }
		}
	})
	--vetro cornice trasp
   	minetest.register_craft({
		output = "summer:vetro_"..colour.."",
		recipe = {
			{"default:stick", "dye:"..colour, "default:stick", },
			{"default:stick", "summer:vetro_traspp","default:stick", },
			{"default:stick", "default:stick", "default:stick", }
		}
	})
	--vetro cornice trasp unito
	minetest.register_craft({
		output = "summer:vetro_unito_"..colour.."",
		recipe = {
			{"", "dye:"..colour, "", },
			{"", "summer:vetro_traspp","", },
			{"default:stick", "default:stick", "default:stick", }
		}
	})
	--vetro cornice colorato
	minetest.register_craft({
		output = "summer:vetro_colorato_"..colour.."",
		recipe = {
			{"default:stick", "dye:"..colour, "default:stick" },
			{"default:stick", "summer:vetro_"..colour,"default:stick" },
			{"default:stick", "default:stick", "default:stick" }
		}
	})
	--vetro cornice colorato unito
	minetest.register_craft({
		output = "summer:vetro_colorato_unito_"..colour.."",
		recipe = {
			{"", "dye:"..colour, "" },
			{"", "summer:vetro_"..colour,"" },
			{"default:stick", "default:stick", "default:stick" }
		}
	})
	--trasp
	minetest.register_craft({
		output = "summer:vetro_colorato_trasp",
		recipe = {
			{"default:stick", "default:stick", "default:stick" },
			{"default:stick", "summer:vetro_traspp","default:stick" },
			{"default:stick", "default:stick", "default:stick" }
		}
	})
	minetest.register_craft({
		output = "summer:vetro_colorato_unito_trasp",
		recipe = {
			{"", "", "" },
			{"", "summer:vetro_traspp","" },
			{"default:stick", "default:stick", "default:stick" }
		}
	})
	minetest.register_craft({
		output = "summer:vetro_unito_trasp",
		recipe = {
			{"default:stick", "", "", },
			{"default:stick", "summer:vetro_traspp","", },
			{"default:stick", "", "", }
		}
	})
		minetest.register_craft({
		output = "summer:vetro_colorato_uni_trasp",
		recipe = {
			{"", "", "", },
			{"summer:vetro_traspp", "summer:vetro_traspp","", },
			{"summer:vetro_traspp", "summer:vetro_traspp", "", }
		}
	})
		minetest.register_craft({
		output = "summer:vetro_trasp",
		recipe = {
			{"default:stick", "default:stick", "default:stick", },
			{"default:stick", "summer:vetro_traspp","default:stick", },
			{"default:stick", "", "default:stick", }
		}
	})
end
