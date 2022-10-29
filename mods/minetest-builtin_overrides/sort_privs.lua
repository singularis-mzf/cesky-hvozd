local lc_cmp = futil.lc_cmp

local basic_privs = minetest.string_to_privs(minetest.settings:get("default_privs") or "interact, shout")
for priv in pairs(minetest.string_to_privs(minetest.settings:get("basic_privs") or "interact, shout")) do
	basic_privs[priv] = true
end

local admin_privs = {}

minetest.register_on_mods_loaded(function()
	for priv, def in pairs(minetest.registered_privileges) do
		if def.give_to_admin then
			admin_privs[priv] = true
		end
	end
end)

local function sort_privs(priv_string, delim)
	local sorted_privs = {}

    for name in priv_string:gmatch("[%w_%-]+") do
        table.insert(sorted_privs, name)
    end

    table.sort(sorted_privs, lc_cmp)

	if builtin_overrides.settings.color_privs then
		for i = 1, #sorted_privs do
			local priv = sorted_privs[i]
			if admin_privs[priv] and not basic_privs[priv] then
				sorted_privs[i] = minetest.colorize("#6666FF", priv)

			elseif not basic_privs[priv] then
				sorted_privs[i] = minetest.colorize("#66FF66", priv)
			end
		end
	end

	return table.concat(sorted_privs, delim)
end

local old_privs_func = minetest.registered_chatcommands["privs"].func
local S = minetest.get_translator("builtin_overrides")

minetest.override_chatcommand("privs", {
	func = function(name, param)
		local rv, msg = old_privs_func(name, param)

		if not rv then
			return rv, msg
		end

		msg = futil.strip_translation(msg)

		local playername, privs = msg:match("^Privileges of ([^:]+): (.*)$")

		if not (playername and privs) then
			return rv, msg
		end

		return rv, S("Práva postavy @1: @2", builtin_overrides.login_to_viewname(playername), sort_privs(privs, ", "))
	end,
})
