local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

builtin_overrides = {
	author = "flux",
	license = "AGPL_v3",
	version = {year = 2022, month = 9, day = 6},
	fork = "ceskyhvozd",

	modname = modname,
	modpath = modpath,
	S = S,

	has = {
	},

	log = function(level, messagefmt, ...)
		return minetest.log(level, ("[%s] %s"):format(modname, messagefmt:format(...)))
	end,

	dofile = function(...)
		return dofile(table.concat({modpath, ...}, DIR_DELIM) .. ".lua")
	end,
}

builtin_overrides.dofile("settings")
builtin_overrides.dofile("sort_privs")
builtin_overrides.dofile("sort_status")
builtin_overrides.dofile("split_long_messages")
