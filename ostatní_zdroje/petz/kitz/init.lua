kitz = {} --the global variable
local modname = "kitz" --the modname
local modpath = minetest.get_modpath(modname) --the modpath
--load the apis:
assert(loadfile(modpath.."/api/api_consts.lua"))()
assert(loadfile(modpath.."/api/api_cron.lua"))()
assert(loadfile(modpath.."/api/api_clear_mobs.lua"))()
assert(loadfile(modpath.."/api/api_drops.lua"))()
assert(loadfile(modpath.."/api/api_sound.lua"))()
assert(loadfile(modpath.."/api/api_replace.lua"))()
assert(loadfile(modpath.."/api/api_feed_tame.lua"))()
assert(loadfile(modpath.."/api/api_helper_functions.lua"))()
assert(loadfile(modpath.."/api/api_commands.lua"))()
assert(loadfile(modpath.."/api/api_math.lua"))()
assert(loadfile(modpath.."/api/api_log.lua"))()
assert(loadfile(modpath.."/engine.lua"))()
