
appliances = {};

local modpath = minetest.get_modpath(minetest.get_current_modname());

appliances.translator = minetest.get_translator("appliances")

appliances.have_mesecons = (minetest.get_modpath("mesecons")~=nil) or (minetest.get_modpath("hades_mesecons")~=nil);
appliances.have_pipeworks = minetest.get_modpath("pipeworks")~=nil;
appliances.have_technic = (minetest.get_modpath("technic")~=nil) or (minetest.get_modpath("hades_technic")~=nil);

appliances.have_unified = minetest.get_modpath("unified_inventory")~=nil;
appliances.have_craftguide = (minetest.get_modpath("craftguide")~=nil) or (minetest.get_modpath("hades_craftguide2")~=nil);
appliances.have_i3 = minetest.get_modpath("i3")~=nil;

appliances.have_tt = minetest.get_modpath("tt")~=nil;

dofile(modpath.."/functions.lua");
dofile(modpath.."/appliance.lua");
dofile(modpath.."/tool.lua");
dofile(modpath.."/extensions.lua");

