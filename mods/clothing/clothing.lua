if (minetest.settings:get_bool("clothing_enable_craft", true) == false) then
  if (minetest.settings:get_bool("clothing_register_clothes", true) == true) then
    local modpath = minetest.get_modpath(minetest.get_current_modname())
    
    dofile(modpath.."/colors_pictures.lua")
    dofile(modpath.."/clothes.lua")
    
    --clothing.basic_colors = nil;
    clothing.colors = nil;
    clothing.pictures = nil;
    minetest.log("warning", "Register of machines is disabled.")
  else
    minetest.log("warning", "Register of clothes and machines is disabled.")
  end
  return
else
  if (minetest.get_modpath("appliances")==nil) then
    error("Cannot register clothes and machines because of missing mod appliances. Please install mod appliances or disable register of clothes and machines by disabling clothing_enable_craft in settings (aviable from Minetest main menu).")
	  return
  end
end
local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/colors_pictures.lua")
dofile(modpath.."/craftitems.lua")
dofile(modpath.."/clothes.lua")
dofile(modpath.."/spinning_machine.lua")
dofile(modpath.."/loom.lua")
dofile(modpath.."/dirty_water.lua")
dofile(modpath.."/dye_machine.lua")
dofile(modpath.."/mannequin.lua")
dofile(modpath.."/sewing_table.lua")
dofile(modpath.."/crafting.lua")

--clothing.basic_colors = nil;
clothing.colors = nil;
clothing.pictures = nil;

