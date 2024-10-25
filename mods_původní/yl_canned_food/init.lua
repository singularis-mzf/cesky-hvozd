-- Version 1.0.0
-- Author AliasAlreadyTaken
-- License MIT

-- Changelog

local mod_start_time = minetest.get_us_time()
minetest.log("action", "[MOD] yl_canned_food loading")

yl_canned_food = {}
yl_canned_food.error = {}
yl_canned_food.modname = minetest.get_current_modname()
yl_canned_food.modstorage = minetest.get_mod_storage()
yl_canned_food.modpath = minetest.get_modpath("yl_canned_food") .. DIR_DELIM
yl_canned_food.worldpath = minetest.get_worldpath() .. DIR_DELIM

dofile(yl_canned_food.modpath .. "texts.lua")
dofile(yl_canned_food.modpath .. "information.lua")
dofile(yl_canned_food.modpath .. "config.lua")
dofile(yl_canned_food.modpath .. "internal.lua")
--dofile(yl_canned_food.modpath .. "initialize.lua")
dofile(yl_canned_food.modpath .. "items.lua")

local mod_end_time = (minetest.get_us_time() - mod_start_time) / 1000000
minetest.log("action", "[MOD] yl_canned_food loaded in [" .. mod_end_time .. "s]")
