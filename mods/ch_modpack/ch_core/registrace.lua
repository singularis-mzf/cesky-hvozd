ch_core.open_submod("registrace", {chat = true, data = true, lib = true, nametag = true})

local survival_creative = {survival = true, creative = true}
local default_privs_to_reg_type = {
	ch_registered_player = survival_creative,
	creative = {new = true},
	fast = true,
	give = {creative = true},
	hiking = survival_creative,
	home = true,
	interact = true,
	peaceful_player = true,
	railway_operator = survival_creative,
	shout = true,
	track_builder = survival_creative,
	train_operator = survival_creative,
}
local reg_types = {
	new = "turistická postava",
	survival = "dělnický styl hry",
	creative = "kouzelnický styl hry",
}
local function get_flashlight()
	local stack = ItemStack("technic:flashlight")
	stack:set_wear(1)
	local meta = stack:get_meta()
	meta:set_string("", "return {charge=30000}")
	return stack
end
local function get_replacer()
	local stack = ItemStack("replacer:replacer")
	stack:set_wear(1)
	local meta = stack:get_meta()
	meta:set_string("", "return {charge=50000}")
	return stack
end
local default_items = {
	{stack = ItemStack("ch_extras:magic_wand"), creative = true},
	{stack = ItemStack("ch_extras:jumptool"), new = true, survival = true, creative = true},
	{stack = ItemStack("rotate:wrench_copper_cw"), survival = true, creative = true},
	{stack = get_replacer(), survival = true, creative = true},
	{stack = ItemStack("ch_extras:periskop"), new = true, survival = true, creative = true},
	{stack = ItemStack("ch_extras:sickle_steel"), survival = true},
	{stack = ItemStack("ch_extras:teleporter_unsellable"), new = true, survival = true},
	{stack = ItemStack("unified_inventory:bag_large"), survival = true, creative = true},
	{stack = ItemStack("bridger:scaffolding 100"), survival = true, creative = true},
	{stack = ItemStack("towercrane:base"), survival = true, creative = true},
	{stack = ItemStack("bike:bike"), new = true, survival = true, creative = false},
	{stack = ItemStack("anvil:hammer"), survival = true},
	--{stack = ItemStack("airtanks:bronze_tank"), survival = true, creative = true},
	{stack = ItemStack("ch_core:kcs_kcs 1000"), survival = true},
	{stack = ItemStack("ch_extras:lupa"), new = true, survival = true},
	{stack = ItemStack("orienteering:builder_compass_1"), survival = true, creative = true},
	{stack = ItemStack("basic_signs:vevystavbe"), survival = true, creative = true},
	{stack = ItemStack("ch_extras:teleporter_unsellable 100"), creative = true},

	{stack = get_flashlight(), min_index = 17, new = true, survival = true, creative = true},
	{stack = ItemStack("orienteering:map"), min_index = 18, new = true, survival = true, creative = true},
	{stack = ItemStack("orienteering:triangulator"), min_index = 19, survival = true, creative = true},
}

for i, item in ipairs(default_items) do
	item.i = i
	if item.min_index == nil then
		item.min_index = 2
	end
end
table.sort(default_items, function(a, b) return a.min_index < b.min_index or (a.min_index == b.min_index and a.i < b.i) end)

local function compute_initial_inventory(reg_type)
	local empty_stack = ItemStack()
	local initial_inventory = {}
	local i_in = 1
	local item = default_items[1]

	for i_out = 1, 32 do
		while item ~= nil and not item[reg_type] do
			-- skip items not for the current reg_type
			i_in = i_in + 1
			item = default_items[i_in]
		end
		if item == nil then
			-- all items were assigned
			break
		end
		if item.min_index > i_out then
			initial_inventory[i_out] = empty_stack
		else
			initial_inventory[i_out] = item.stack
			i_in = i_in + 1
			item = default_items[i_in]
		end
	end
	return initial_inventory
end

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

	-- compute privs
	for priv, priv_setting in pairs(default_privs_to_reg_type) do
		if priv_setting == true or (type(priv_setting) == "table" and priv_setting[reg_type]) then
			extra_privs[priv] = true
		end
	end

	-- reset the bank account
	if reg_type == "new" and ch_core.get_player_role(player_name) ~= "new" then
		ch_core.overridable.reset_bank_account(player_name)
	end

	print("Will compute initial inventory for reg_type \""..(reg_type or "nil").."\"")
	local initial_inventory = compute_initial_inventory(reg_type)
	print("Computed initial inventory for reg_type \""..(reg_type or "nil").."\": "..dump2({initial_inventory = initial_inventory, reg_type = reg_type}))
	local player = minetest.get_player_by_name(player_name)
	if not player then
		return false, "the player is offline"
	end
	local inv = player:get_inventory()
	local bags_inv = minetest.get_inventory({type = "detached", name = player_name.."_bags"})
	local empty_stack = ItemStack()
	local old_lists = inv:get_lists()
	minetest.log("action", "Will clear inventories of "..player_name..", old inventories: "..dump2(old_lists))
	old_lists.hand = nil
	old_lists.main = nil
	for inv_name, _ in pairs(old_lists) do
		inv:set_list(inv_name, {})
	end
	inv:set_list("main", initial_inventory)
	local new_lists = inv:get_lists()
	local bags_count = 0
	if bags_inv ~= nil then
		for i = 1, 8 do
			local bag = bags_inv:get_stack("bag"..i, 1)
			if bag ~= nil and not bag:is_empty() then
				bags_inv:set_stack("bag"..i, 1, empty_stack)
				bags_count = bags_count + 1
			end
		end
	end
	minetest.log("action", "Cleared inventories of "..player_name.." ("..bags_count.." bags), new inventories: "..dump2(new_lists))
	minetest.set_player_privs(player_name, extra_privs)
	local new_privs = minetest.privs_to_string(minetest.get_player_privs(player_name))
	minetest.log("action", "Player "..player_name.." privs set to: "..new_privs)
	local message = "Vaše registrace byla nastavena do režimu „"..reg_type_desc.."“."
	if reg_type ~= "new" then
		message = message.." Zkontrolujte si, prosím, svoje nová práva příkazem /práva."
	end
	ch_core.systemovy_kanal(player_name, message)
	player:set_nametag_attributes(ch_core.compute_player_nametag(ch_core.online_charinfo[player_name], offline_charinfo))
	offline_charinfo.past_playtime = 0
	offline_charinfo.past_ap_playtime = 0
	offline_charinfo.ap_level = 1
	offline_charinfo.ap_xp = 0
	ch_core.save_offline_charinfo(player_name, {"ap_level", "ap_xp", "past_ap_playtime", "past_playtime"})
	ch_core.ap_add(player_name, offline_charinfo)
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
	local online_charinfo = ch_core.get_joining_online_charinfo(player_name) or {}
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)
	if offline_charinfo.pending_registration_type ~= "" and online_charinfo.news_role ~= "disconnect" and online_charinfo.news_role ~= "invalid_name" then
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
