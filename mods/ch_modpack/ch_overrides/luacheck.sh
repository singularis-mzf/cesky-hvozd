#!/bin/bash
luacheck init.lua
luacheck mod_overrides/{books,cavestuff,currency,darkage,default,farming,homedecor_kitchen,homedecor_misc,jonez,moreblocks,moretrees,screwdriver,technic_cnc,ts_furniture}.lua
luacheck chests.lua extra_recipes.lua falling_nodes.lua ores.lua poles.lua security.lua shelves.lua trash_cans.lua tool_breaking.lua ui_settings.lua
