local Ombrellone_list = {
	{ "Red Ombrellone", "red"},
	{ "White Ombrellone", "white"},
	{ "Orange Ombrellone", "orange"},
    { "Black Ombrellone", "black"},
	{ "Yellow Ombrellone", "yellow"},
	{ "Green Ombrellone", "green"},
	{ "Blue Ombrellone", "blue"},
	{ "Violet Ombrellone", "violet"},
}

for i in ipairs(Ombrellone_list) do
	local ombrellonedesc = Ombrellone_list[i][1]
	local colour = Ombrellone_list[i][2]
    
   minetest.register_node("summer:ombrellone_"..colour.."", {
	    description = ombrellonedesc.."",
	    drawtype = "mesh",
		mesh = "omb_o.obj",
	    tiles = {"ball_"..colour..".png",
	    },	    
        inventory_image = "ombo_"..colour.."_q.png",
	    
       wield_image  = {"ombo_"..colour.."_q.png"},
	    paramtype = "light",
	    paramtype2 = "facedir",
	    sunlight_propagates = true,
	    walkable = false,
	    selection_box = {
	        type = "fixed",
	        fixed = { -0.25, -0.5, -0.25, 0.25,0.5, 0.25 },
	    },
		groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3, not_in_creative_inventory=0},
		--sounds = default.node_sound_glass_defaults(),
        drop = "summer:ombrellone_"..colour.."_ch",        
		on_rightclick = function(pos, node, clicker)
	        node.name = "summer:ombrellone_"..colour.."_ch"
	        minetest.set_node(pos, node)
	    end,
	})


minetest.register_node("summer:ombrellone_"..colour.."_ch", {
	    description = ombrellonedesc.." ch",
	    drawtype = "mesh",
		mesh = "omb_c.obj",
	    tiles = {"ball_"..colour..".png",
	    },
        inventory_image = "ombc_"..colour.."_q.png",
	    
        wield_image  = {"ombc_"..colour.."_q.png"},
	    paramtype = "light",
	    paramtype2 = "facedir",
	    sunlight_propagates = true,
	    walkable = false,
	    selection_box = {
	        type = "fixed",
	        fixed = { -0.25, -0.5, -0.25, 0.25,0.5, 0.25 },
	    },
		groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3, not_in_creative_inventory=0},
		--sounds = default.node_sound_glass_defaults(),
		drop = "summer:ombrellone_"..colour,
		on_rightclick = function(pos, node, clicker)
	        node.name = "summer:ombrellone_"..colour..""
	        minetest.set_node(pos, node)
	    end,
	})


end
