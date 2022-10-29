ch_core.open_submod("localize_chatcommands", {data = true, lib = true, privs = true})

local defs = {
	admin = {
		description = "Vypíše jméno postavy správce/kyně serveru.",
	},
	ban = {
		description = "Vyhostí hráče/ky na IP adrese daného klienta nebo zobrazí seznam vyhoštění.",
	},
	clearinv = {
		description = "Vyprázdní váš inventář, případně inventář jiné postavy.",
	},
	clearobjects = {
		description = "Smaže ze světa všechny objekty.",
	},
	clearpassword = {
		description = "Nastaví postavě prázdné heslo.",
	},
	days = {
		description = "Vypíše počet dní od založení světa.",
	},
	deleteblocks = {
		description = "Smaže z databáze mapové bloky v oblasti pos1 až pos2 (<pos1> a <pos2> musejí být v závorkách).",
	},
	help = {
		czech_command = "pomoc",
		description = "Vypíše nápovědu pro příkazy nebo seznam práv (-t: výstup do četu)",
	},
}

local function extract_fields(t, ...)
	local result = {}
	for _, k in ipairs({...}) do
		if t[k] ~= nil then
			result[k] = t[k]
		end
	end
	return result
end

local p_d_p = {"params", "description", "privs"}

for command, def in pairs(defs) do
	if minetest.registered_chatcommands[command] then
		local override = {}
		local valid = false
		for _, k in ipairs(p_d_p) do
			if def[k] ~= nil then
				override[k] = def[k]
				valid = true
			end
		end
		if def.func == nil and def.override_func ~= nil and minetest.registered_chatcommands[command].func ~= nil then
			override.func = def.func(minetest.registered_chatcommands[command].func)
			valid = true
		end

		if valid then
			minetest.override_chatcommand(command, override)
		end
		if def.czech_command then
			minetest.register_chatcommand(def.czech_command,
				extract_fields(minetest.registered_chatcommands[command], "params", "description", "privs", "func"))
		end
	else
		minetest.log("warning", "Chat command /"..command.." not exists to be localized!")
	end
end

if minetest.get_modpath("builtin_overrides") then
	builtin_overrides.login_to_viewname = ch_core.prihlasovaci_na_zobrazovaci
end

local def = {
	params = "[jméno postavy]",
	description = "Vypíše vaše práva nebo práva jiné postavy.",
	func = function(player_name, param)
		local privs_def = minetest.registered_chatcommands.privs
		-- print("DEBUG: "..dump2(minetest.registered_chatcommands.privs))
		return privs_def.func(player_name, ch_core.jmeno_na_prihlasovaci(param))
	end,
}

minetest.register_chatcommand("prava", def)
minetest.register_chatcommand("práva", def)

ch_core.close_submod("localize_chatcommands")
