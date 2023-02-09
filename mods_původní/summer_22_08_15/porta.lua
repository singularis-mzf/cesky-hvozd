
local Porta_list = {
	{ "Red Door", "red"},
	{ "Orange Door", "orange"},
    { "Black Door", "black"},
	{ "Yellow Door", "yellow"},
	{ "Green Door", "green"},
	{ "Blue Door", "blue"},
	{ "Violet Door", "violet"},
}
--[[	{ S("Red Door"), "red"},
	{ S("Orange Door"), "orange"},
    { S("Black Door"), "black"},
	{ S("Yellow Door"), "yellow"},
	{ S("Green Door"), "green"},
	{ S("Blue Door"), "blue"},
	{ S("Violet Door"), "violet"},
}]]
for i in ipairs(Porta_list) do
	local portadesc = Porta_list[i][1]
	local colour = Porta_list[i][2]
    
   minetest.register_node("summer:porta_"..colour.."", {
	    description = portadesc.."",
	    drawtype = "mesh",
		mesh = "porta_2.obj",
	    tiles = {"porta_"..colour..".png",
	    },	    
       inventory_image = "summer_p_"..colour..".png",
	    
        wield_image  = {"summer_p_"..colour..".png",
	   },
	    paramtype = "light",
	    paramtype2 = "facedir",
	    sunlight_propagates = true,
	    walkable = true,
	    selection_box = {
	        type = "fixed",
	        fixed = { -0.40, -0.5,-0.5,- 0.5,1.5, 0.5 },
	    },
	    collision_box = {
	        type = "fixed",
	        fixed = { -0.40, -0.5,-0.5,- 0.5,1.5, 0.5 },
	    },
	    
		groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,not_in_creative_inventory=1},
		sounds = default.node_sound_wood_defaults(),
		--sound_close="summer_porta_ch", 
        drop = "summer:porta_"..colour.."_ch",        
		on_rightclick = function(pos, node, clicker)
	        node.name = "summer:porta_"..colour.."_ch" 
	        minetest.set_node(pos, node) 
	        
	        minetest.sound_play("summer_porta_ch", {
	to_player = "",
	gain = 2.0,
})
	        
	    end,
	})


minetest.register_node("summer:porta_"..colour.."_ch", {
	    description = portadesc.." ch",
	    drawtype = "mesh",
		mesh = "porta.obj",
	    tiles = {"porta_"..colour..".png",
	    },
        inventory_image = "summer_p_"..colour..".png",
	    
        wield_image  = {"summer_p_"..colour..".png",
	    },
	    paramtype = "light",
	    paramtype2 = "facedir",
	    sunlight_propagates = true,
	    walkable = true,
	    selection_box = {
	        type = "fixed",
	        fixed = { -0.5, -0.5, 0.40, 0.5,1.5, 0.5},
	    },
	    collision_box = {
	        type = "fixed",
	        fixed = { -0.5, -0.5, 0.40, 0.5,1.5, 0.5},
	    },
		groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3, not_in_creative_inventory=0},
		sounds = default.node_sound_wood_defaults(),
			
		drop = "summer:porta_"..colour.."_ch",
		on_rightclick = function(pos, node, clicker)
	        node.name = "summer:porta_"..colour..""
	        minetest.set_node(pos, node) 
	    minetest.sound_play("summer_porta_op", {
	to_player = "",
	gain = 2.0,
})
	    end,
	})


	
end
