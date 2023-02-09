local Portacenere_list = {
	{ "Red Portacenere", "red"},
	{ "Orange Portacenere", "orange"},
    { "Black Portacenere", "black"},
	{ "Yellow Portacenere", "yellow"},
	{ "Green Portacenere", "green"},
	{ "Blue Portacenere", "blue"},
	{ "Violet Portacenere", "violet"},
	{ "White Portacenere", "white"},
}

for i in ipairs(Portacenere_list) do
	local Portaceneredesc = Portacenere_list[i][1]
	local colour = Portacenere_list[i][2]
    
   minetest.register_node("summer:Portacenere_"..colour.."", {
	    description = Portaceneredesc.."",
	    drawtype = "mesh",
		mesh = "portacenere_o.obj",
	    tiles = {"portacenere_"..colour..".png",
	    },	    
    --    inventory_image = "summer_ombo_n_"..colour..".png",
	    
      --  wield_image  = {"summer_ombo_n_"..colour..".png",
	    --},
	    paramtype = "light",
	    paramtype2 = "facedir",
	    sunlight_propagates = true,
	    walkable = false,
	    selection_box = {
	        type = "fixed",
	        fixed = { -0.130, -0.5, -0.130, 0.25,-0.25, 0},
	    },
		groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,not_in_creative_inventory = 0},
		--sounds = default.node_sound_glass_defaults(),
        drop = "summer:Portacenere_"..colour.."_ch",        
		on_rightclick = function(pos, node, clicker)
	        node.name = "summer:Portacenere_"..colour.."_ch"
	        minetest.set_node(pos, node)
	    end,
	})


minetest.register_node("summer:Portacenere_"..colour.."_ch", {
	    description = Portaceneredesc.." ch",
	    drawtype = "mesh",
		mesh = "portacenere_c.obj",
	    tiles = {"portacenere_"..colour..".png",
	    },
       -- inventory_image = "summer_ombc_n_"..colour..".png",
	    
        --wield_image  = {"summer_ombc_n_"..colour..".png",
	    --},
	    paramtype = "light",
	    paramtype2 = "facedir",
	    sunlight_propagates = true,
	    walkable = false,
	    selection_box = {
	        type = "fixed",
	        fixed = { -0.130, -0.5, -0.130, 0.25,-0.25, 0 },
	    },
		groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3, not_in_creative_inventory=1},
		--sounds = default.node_sound_glass_defaults(),
		drop = "summer:Portacenere_"..colour.."ch",
		on_rightclick = function(pos, node, clicker)
	        node.name = "summer:Portacenere_"..colour..""
	        minetest.set_node(pos, node)
	    end,
	})

	
end
