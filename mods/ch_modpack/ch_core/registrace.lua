ch_core.open_submod("registrace", {chat = true, data = true, lib = true, nametag = true})

function ch_core.registrovat(player_name, reg_type, extra_privs)
	if extra_privs == nil then
		extra_privs = {}
	elseif type(extra_privs) == "string" then
		extra_privs = minetest.string_to_privs(extra_privs)
	end
	if type(extra_privs) ~= "table" then
		error("Invalid extra_privs type: "..type(extra_privs))
	else
		extra_privs = table.copy(extra_privs)
	end
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if not offline_charinfo then
		return false, "offline_charinfo not found!"
	end
	if reg_type ~= "survival" and reg_type ~= "creative" and reg_type ~= "new" then
		return false, "unknown registration type "..reg_type
	end
	local player = minetest.get_player_by_name(player_name)
	if not player then
		return false, "the player is offline"
	end
	local inv = player:get_inventory()
	local old_lists = inv:get_lists()
	minetest.log("action", "Will clear inventories of "..player_name..", old inventories: "..dump2(old_lists))
	local empty_stack = ItemStack()
	for inv_name, inv_list in pairs(old_lists) do
		if inv_name ~= "hand" then
			local list_size = #inv_list
			for i = 1, list_size do
				inv_list[i] = empty_stack
			end
			inv:set_list(inv_name, inv_list)
		end
	end
	local new_lists = inv:get_lists()
	minetest.log("action", "Cleared inventories of "..player_name..", new inventories: "..dump2(new_lists))
	if reg_type == "new" then
		extra_privs.fast = true
		extra_privs.hiking = true
		extra_privs.home = true
		extra_privs.interact = true
		extra_privs.peaceful_player = true
		extra_privs.shout = true
		minetest.set_player_privs(player_name, extra_privs)
		local new_privs = minetest.privs_to_string(minetest.get_player_privs(player_name))
		minetest.log("action", "Player "..player_name.." privs set to: "..new_privs)
		ch_core.systemovy_kanal(player_name, "Vaše registrace byla nastavena do režimu „nová postava“. Zkontrolujte si, prosím, vaše nová práva příkazem /práva.")
	elseif reg_type == "survival" then
		extra_privs.fast = true
		extra_privs.hiking = true
		extra_privs.home = true
		extra_privs.interact = true
		extra_privs.peaceful_player = true
		extra_privs.shout = true
		extra_privs.ch_registered_player = true
		minetest.set_player_privs(player_name, extra_privs)
		local new_privs = minetest.privs_to_string(minetest.get_player_privs(player_name))
		minetest.log("action", "Player "..player_name.." privs set to: "..new_privs)
		ch_core.systemovy_kanal(player_name, "Vaše registrace byla nastavena do režimu „dělnický styl hry“. Zkontrolujte si, prosím, vaše nová práva příkazem /práva.")
	elseif reg_type == "creative" then
		extra_privs.fast = true
		extra_privs.hiking = true
		extra_privs.home = true
		extra_privs.interact = true
		extra_privs.peaceful_player = true
		extra_privs.shout = true
		extra_privs.give = true
		extra_privs.ch_registered_player = true
		minetest.set_player_privs(player_name, extra_privs)
		local new_privs = minetest.privs_to_string(minetest.get_player_privs(player_name))
		minetest.log("action", "Player "..player_name.." privs set to: "..new_privs)
		ch_core.systemovy_kanal(player_name, "Vaše registrace byla nastavena do režimu „kouzelnický styl hry“. Zkontrolujte si, prosím, vaše nová práva příkazem /práva.")
	else
		error("Internal error - invalid reg_type "..reg_type.."!")
	end
	player:set_nametag_attributes(ch_core.compute_player_nametag(ch_core.online_charinfo[player_name], offline_charinfo))
	offline_charinfo.past_playtime = 0
	offline_charinfo.past_ap_playtime = 0
	offline_charinfo.ap_level = 1
	offline_charinfo.ap_xp = 0
	ch_core.save_offline_charinfo(player_name, {"ap_level", "ap_xp", "past_ap_playtime", "past_playtime"})
	return true
end

local function on_joinplayer(player_name)
	local player = minetest.get_player_by_name(player_name)
	if not player then
		minetest.log("warning", "on_joinplayer: failed to fetch player object for registration of "..(player_name or "nil"))
	end
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)
	if offline_charinfo.pending_registration_type == "" then
		return
	end
	local result, error_message = ch_core.registrovat(player_name, offline_charinfo.pending_registration_type, offline_charinfo.pending_registration_privs)
	if result then
		offline_charinfo.pending_registration_privs = ""
		offline_charinfo.pending_registration_type = ""
		ch_core.save_offline_charinfo(player_name, {"pending_registration_privs", "pending_registration_type"})
		return
	else
		minetest.log("warning", "Registration of "..player_name.." failed: "..(error_message or "nil"))
	end
end

minetest.register_on_joinplayer(function(player, last_login)
	local player_name = player:get_player_name()
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)
	if offline_charinfo.pending_registration_type ~= "" then
		minetest.after(0.5, on_joinplayer, player_name)
	end
end)

local def = {
	params = "<new|survival|creative> <jméno_postavy> [extra_privs]",
	description = "registrovat",
	privs = {server = true},
	func = function(player_name, param)
		local reg_type, player_to_register, extra_privs = string.match(param, "^(%S+) (%S+) (%S+)$")
		if not reg_type then
			reg_type, player_to_register = string.match(param, "^(%S+) (%S+)$")
		end
		if not reg_type then
			return false, "Neplatné zadání!"
		end
		player_to_register = ch_core.jmeno_na_prihlasovaci(player_to_register)
		local offline_charinfo = ch_core.offline_charinfo[player_to_register]
		if not offline_charinfo then
			return false, "Postava "..player_to_register.." neexistuje!"
		end
		local online_charinfo = ch_core.online_charinfo[player_to_register]
		if online_charinfo then
			-- register immediately
			local result, err_text = ch_core.registrovat(player_to_register, reg_type, extra_privs or "")
			if result then
				return true, "Postava registrována."
			else
				return false, "Registrace selhala; "..err_text
			end
		else
			offline_charinfo.pending_registration_type = reg_type
			offline_charinfo.pending_registration_privs = extra_privs or ""
			ch_core.save_offline_charinfo(player_to_register, {"pending_registration_type", "pending_registration_privs"})
			return true, "Registrace naplánována."
		end
	end,
}

minetest.register_chatcommand("registrovat", def)

ch_core.close_submod("registrace")
