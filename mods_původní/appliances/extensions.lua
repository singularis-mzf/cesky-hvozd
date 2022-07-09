
local modpath = minetest.get_modpath(minetest.get_current_modname());

appliances.all_extensions = {}

-- supply by power
dofile(modpath.."/power_supply.lua");
-- supply by items
dofile(modpath.."/item_supply.lua");
-- general supply input (liquid etc.)
dofile(modpath.."/supply.lua");
-- control
dofile(modpath.."/control.lua");
-- supply by battery (for tools)
dofile(modpath.."/battery_supply.lua");

