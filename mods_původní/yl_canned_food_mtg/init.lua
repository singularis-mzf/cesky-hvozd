-- Version 1.0.1
-- Author AliasAlreadyTaken
-- License MIT

-- Changelog
-- 1.0.0 Release
-- 1.0.1 Bugfix dependency

local mod_start_time = minetest.get_us_time()
minetest.log("action", "[MOD] yl_canned_food_mtg loading")

yl_canned_food_mtg = {}
yl_canned_food_mtg.error = {}
yl_canned_food_mtg.modname = minetest.get_current_modname()
-- yl_canned_food_mtg.modstorage = minetest.get_mod_storage()
yl_canned_food_mtg.modpath = minetest.get_modpath("yl_canned_food_mtg") .. DIR_DELIM
yl_canned_food_mtg.worldpath = minetest.get_worldpath() .. DIR_DELIM

dofile(yl_canned_food_mtg.modpath .. "texts.lua")
dofile(yl_canned_food_mtg.modpath .. "information.lua")
dofile(yl_canned_food_mtg.modpath .. "config.lua")
dofile(yl_canned_food_mtg.modpath .. "setup.lua")
dofile(yl_canned_food_mtg.modpath .. "data.lua")
dofile(yl_canned_food_mtg.modpath .. "internal.lua")
dofile(yl_canned_food_mtg.modpath .. "initialize.lua")
dofile(yl_canned_food_mtg.modpath .. "features.lua")

local mod_end_time = (minetest.get_us_time() - mod_start_time) / 1000000
minetest.log("action", "[MOD] yl_canned_food_mtg loaded in [" .. mod_end_time .. "s]")
