ch_core.open_submod("registrace", {chat = true, data = true, lib = true, nametag = true})

local survival_creative = {survival = true, creative = true}
local default_privs_to_reg_type = {
	ch_registered_player = survival_creative,
	creative = {new = true, creative = true},
	fast = true,
	give = {creative = true},
	hiking = survival_creative,
	home = true,
	interact = true,
	peaceful_player = true,
	shout = true,
	track_builder = survival_creative,
}
local reg_types = {
	new = "nová postava",
	survival = "dělnický styl hry",
	creative = "kouzelnický styl hry",
}

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
	local reg_type_desc = reg_types[reg_type]
	if not reg_type_desc then
		return false, "unknown registration type "..reg_type
	end

	for priv, priv_setting in pairs(default_privs_to_reg_type) do
		if priv_setting == true or (type(priv_setting) == "table" and priv_setting[reg_type]) then
			extra_privs[priv] = true
		end
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
	minetest.set_player_privs(player_name, extra_privs)
	local new_privs = minetest.privs_to_string(minetest.get_player_privs(player_name))
	minetest.log("action", "Player "..player_name.." privs set to: "..new_privs)
	ch_core.systemovy_kanal(player_name, "Vaše registrace byla nastavena do režimu „"..reg_type_desc.."“. Zkontrolujte si, prosím, vaše nová práva příkazem /práva.")
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
