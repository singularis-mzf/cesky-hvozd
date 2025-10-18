-- c_doors by TumeniNodes, Nathan.S, and Napiophelios Jan 2017

screwdriver = screwdriver or {}
c_doors = {}

-- shall the doors be made from existing non-centered doors, or crafted from scratch?
c_doors.from_doors = true

-- centered doors
dofile(minetest.get_modpath("c_doors").."/c_doors.lua")
-- centered windows
dofile(minetest.get_modpath("c_doors").."/c_windows.lua")

