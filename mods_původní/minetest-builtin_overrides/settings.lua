local s = minetest.settings

builtin_overrides.settings = {
	color_privs = s:get_bool("builtin_overrides.color_privs", true),
}
