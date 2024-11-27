ch_base.open_mod(minetest.get_current_modname())
local S = minetest.get_translator(minetest.get_current_modname())

local ring_big_bell = function(pos)
	minetest.sound_play( "bell_bell",
		{ pos = pos, gain = 1.5, max_hear_distance = 300,})
end
-- actually ring the bell
local ring_bell_once = function()
   for i,v in ipairs( bell_positions ) do
      ring_big_bell(v)
   end
end

local ring_bell_multiple = function(rings)
	for i=1, rings do
		minetest.after( (i-1)*5,  ring_bell_once )
	end
end

---------------------------------------------------------
--- Node definitions

local bell_base = {
	paramtype = "light",
    description = S("Bell"),
    stack_max = 1,

    on_punch = function (pos,node,puncher)
        ring_big_bell(pos)
	end,

	on_construct = function(pos)
       -- remember that there is a bell at that position
       table.insert( bell_positions, pos )
       save_bell_positions()
	end,

	on_destruct = function(pos)
       local found = 0
       -- actually remove the bell from the list
       for i,v in ipairs( bell_positions ) do
          if(v ~= nil and vector.equals(v, pos)) then
             table.remove( bell_positions, i)
			 save_bell_positions()
			 break
          end
       end
    end,

    groups = {cracky=2},
}

if minetest.get_modpath("mesecons") then
	bell_base.mesecons = {
		effector = {
			action_on = ring_big_bell,
		}
	}
end


local ring_small_bell = function(pos)
	minetest.sound_play( "bell_small",
		{ pos = pos, gain = 1.5, max_hear_distance = 60,})
end


local small_bell_base = {
    description = S("Small bell"),
	paramtype = "light",
    stack_max = 1,
    on_punch = function (pos,node,puncher)
        ring_small_bell(pos)
	end,
    groups = {cracky=2},
}

if minetest.get_modpath("mesecons") then
	small_bell_base.mesecons = {
		effector = {
			action_on = ring_small_bell,
		}
	}
end

----------------------------------------------------

if minetest.settings:get_bool("bell_enable_model", true) then
----------------
-- Model-type bell
	local bell_def = {
		drawtype = "mesh",
		mesh = "bell_bell.obj",
		tiles = {
			{ name = "bell_hull.png", backface_culling = true }, -- 
			{ name = "bell_hull.png", backface_culling = true }, -- 
			{ name = "bell_hull.png", backface_culling = true }, -- 
			{ name = "default_wood.png", backface_culling = true }, --
			},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			},
		},
		paramtype2 = "facedir",
        drop = {
			max_items = 1,
			items = {
				{
					items = {"bell:bell"},
				},
			}
		 }
	}
	
	for k, v in pairs(bell_base) do
		bell_def[k] = v
	end
	
	minetest.register_node("bell:bell", bell_def)
	
	local small_bell_def = 
	{	drawtype = "mesh",
		mesh = "bell_small_bell.obj",
		tiles = {
			{ name = "bell_hull.png", backface_culling = true }, -- 
			{ name = "bell_hull.png", backface_culling = true }, -- 
			{ name = "bell_hull.png", backface_culling = true }, -- 
			{ name = "default_wood.png", backface_culling = true }, --
			},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.375, -0.25, -0.375, 0.375, 0.5, 0.375},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.375, -0.25, -0.375, 0.375, 0.5, 0.375},
			},
		},
		paramtype2 = "facedir",
        drop = {
			max_items = 1,
			items = {
				{
					items = {"bell:bell_small"},
				},
			}
		 }
	}
	
	for k, v in pairs(small_bell_base) do
		small_bell_def[k] = v
	end
	
	minetest.register_node("bell:bell_small", small_bell_def)

else
--------------------
-- Plantlike-type bell
	local bell_def = {
		tiles = {"bell_bell.png"},
		inventory_image = 'bell_bell.png',
		wield_image = 'bell_bell.png',
		drawtype = "plantlike",
	}
	for k, v in pairs(bell_base) do
		bell_def[k] = v
	end
	
	minetest.register_node("bell:bell", bell_def)
	
	local small_bell_def = {
		tiles = {"bell_bell.png"},
		inventory_image = 'bell_bell.png',
		wield_image = 'bell_bell.png',
		drawtype = "plantlike",
	}
	for k, v in pairs(small_bell_base) do
		small_bell_def[k] = v
	end
	
	minetest.register_node("bell:bell_small", small_bell_def)
end

---------------------------------------------------------
--- Recipes

if minetest.get_modpath("default") then
	minetest.register_craft({
		output = "bell:bell_small",
		recipe = {
			{"",                  "default:goldblock", ""                 },
			{"default:goldblock", "default:goldblock", "default:goldblock"},
			{"default:goldblock", "",                  "default:goldblock"},
		},
	})
	minetest.register_craft({
		output = "bell:bell",
		recipe = {
			{"default:goldblock", "default:goldblock", "default:goldblock"},
			{"default:goldblock", "default:goldblock", "default:goldblock"},
			{"default:goldblock", "",                  "default:goldblock"},
		},
	})
end

if minetest.get_modpath("mcl_core") then
	minetest.register_craft({
		output = "bell:bell_small",
		recipe = {
			{"",                  "mcl_core:goldblock", ""                 },
			{"mcl_core:goldblock", "mcl_core:goldblock", "mcl_core:goldblock"},
			{"mcl_core:goldblock", "",                  "mcl_core:goldblock"},
		},
	})
	minetest.register_craft({
		output = "bell:bell",
		recipe = {
			{"mcl_core:goldblock", "mcl_core:goldblock", "mcl_core:goldblock"},
			{"mcl_core:goldblock", "mcl_core:goldblock", "mcl_core:goldblock"},
			{"mcl_core:goldblock", "",                  "mcl_core:goldblock"},
		},
	})
end
ch_base.close_mod(minetest.get_current_modname())
