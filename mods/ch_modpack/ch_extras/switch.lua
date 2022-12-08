local def, nbox

local F = minetest.formspec_escape

local mesecons_off, mesecons_on

if minetest.get_modpath("mesecons_switch") then
	mesecons_off = { receptor = { state = mesecon.state.off }}
	mesecons_on = { receptor = { state = mesecon.state.on }}
end

local function update_infotext(pos)
	local node = minetest.get_node(pos)
	local group = minetest.get_item_group(node.name, "ch_extras_switch")
	if group == 0 then
		return false
	end
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local locked = meta:get_int("locked")

	local infotext = {}
	if owner ~= "" then
		table.insert(infotext, "návěstidlo patří postavě: "..ch_core.prihlasovaci_na_zobrazovaci(owner))
	end
	if locked ~= 0 then
		table.insert(infotext, "<zamčeno>")
	end
	if infotext[1] then
		infotext = table.concat(infotext, "\n")
	else
		infotext = ""
	end
	meta:set_string("infotext", infotext)
	return true
end

local function get_formspec(pos, player)
	local node = minetest.get_node(pos)
	local group = minetest.get_item_group(node.name, "ch_extras_switch")
	if group == 0 then
		return false
	end
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local locked = meta:get_int("locked")
	local has_protection_bypass = minetest.check_player_privs(player, "protection_bypass")

	local formspec = {
		"formspec_version[4]",
		"size[12,6]",
		"field[11.0,0.25;0.5,0.5;ignore;;]",
		"label[0.375,0.5;Ovládací panel výměnového návěstidla]",
		"label[0.375,1.0;Vlastník/ice:]",
		"field[2.5,0.75;5,0.5;vlastnikice;;", F(ch_core.prihlasovaci_na_zobrazovaci(owner)), "]",
		has_protection_bypass and "button[7.75,0.75;2,0.5;vlastnikicenast;nastavit]" or "",
		"label[0.375,1.75;Zamčeno: ", locked ~= 0 and "ano" or "ne", "]",
		"button[2.75,1.5;2,0.5;", locked ~= 0 and "odemknout;odemknout" or "zamknout;zamknout", "]",
		"label[5,1.75;Zamčenou návěst může přestavit]",
		"label[5,2.0;jen vlastník/ice či Administace.]",
		"label[0.375,2.5;Stav: ", group == 2 and "vedlejší směr" or "hlavní směr", "]",
		"button[2.75,2.25;2,0.5;prepnout;přepnout]",
		"button_exit[1,4.8;10,0.75;zavrit;Zavřít ovládací panel]",
	}
	formspec = table.concat(formspec)
	return formspec
end

local function switch_switch(pos, node, player_name, check_privs)
	if not node then
		node = minetest.get_node(pos)
	end
	local group = minetest.get_item_group(node.name, "ch_extras_switch")
	if group == 0 then
		minetest.log("warning", "switch_switch called on inappropriate node "..node.name.."!")
		return false
	end
	if check_privs then
		if minetest.is_protected(pos, player_name) then
			minetest.record_protection_violation(pos, player_name)
			return false
		end
		if not minetest.check_player_privs(player_name, {railway_operator = true}) then
			ch_core.systemovy_kanal(player_name, "Nemáte právo přehazovat výhybky!")
			return false
		end
		local meta = minetest.get_meta(pos)
		local owner, locked = meta:get_string("owner"), meta:get_int("locked")
		if locked ~= 0 and player_name ~= owner and not minetest.check_player_privs(player_name, "protection_bypass") then
			return false
		end
	end

	node.name = minetest.registered_nodes[node.name]._alt_shape
	minetest.swap_node(pos, node)
	if group == 1 then
		if mesecons_on then
			mesecon.receptor_on(pos)
		end
		minetest.log("action", (player_name or "SYSTEM").." set turnout at "..minetest.pos_to_string(pos).." to ON state ("..node.name..")")
	else
		if mesecons_on then
			mesecon.receptor_off(pos)
		end
		minetest.log("action", (player_name or "SYSTEM").." set turnout at "..minetest.pos_to_string(pos).." to OFF state ("..node.name..")")
	end
	if mesecons_on then
		minetest.sound_play("mesecons_switch", { pos = pos }, true)
	end
	update_infotext(pos)
	return true
end

local function formspec_callback(custom_state, player, formname, fields)
	if fields.quit then
		return false
	end
	local do_update_infotext = false
	local player_name = player:get_player_name()
	local pos = custom_state.pos
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "ch_extras_switch") == 0 then
		return false -- invalid node
	end
	if fields.prepnout then
		switch_switch(pos, node, player_name, true)
	end
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if player_name == owner and fields.zamknout then
		meta:set_int("locked", 1)
		do_update_infotext = true
	end
	if player_name == owner and fields.odemknout then
		meta:set_int("locked", 0)
		do_update_infotext = true
	end
	if fields.vlastnikicenast and minetest.check_player_privs(player, "server") then
		local login_name = ch_core.jmeno_na_prihlasovaci(fields.vlastnikice)
		if ch_core.offline_charinfo[login_name] then
			meta:set_string("owner", login_name)
			do_update_infotext = true
		else
			ch_core.systemovy_kanal(player_name, "Postava "..fields.vlastnikice.." neexistuje!")
		end
	end

	if do_update_infotext then
		update_infotext(pos)
	end
	return get_formspec(pos, player)
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_name = clicker and clicker:get_player_name()
	if not player_name then
		return
	end
	if clicker:get_player_control().aux1 then
		ch_core.show_formspec(clicker, "ch_extras:switch", get_formspec(pos, clicker), formspec_callback, {pos = pos}, {})
		return
	end
	switch_switch(pos, node, player_name, true)
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	local player_name = placer and placer:get_player_name()
	if player_name then
		meta:set_string("owner", player_name)
		update_infotext(pos)
	end
end

local function can_dig(pos, player)
	local player_name = player and player:get_player_name()

	if not player_name then
		return false -- only player can dig this
	end
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return false
	end
	local meta = minetest.get_meta(pos)
	local owner, locked = meta:get_string("owner"), meta:get_int("locked")
	if locked ~= 0 and not minetest.check_player_privs(player, "protection_bypass") and owner ~= "" and owner ~= player_name then
		return false
	end
	return true
end

local groups_off = {
	ch_extras_switch = 1,
	dig_immediate = 2,
}
local groups_on = {
	ch_extras_switch = 2,
	dig_immediate = 2,
	not_in_creative_inventory = 1,
}

local tiles_straight = {
	"ch_extras_switch_off.png",
	"ch_extras_switch_off.png",
	"ch_extras_switch_off.png",
	"ch_extras_switch_off.png",
	"ch_extras_switch_off.png",
	"ch_extras_switch_straight.png",
}
local tiles_arrow = table.copy(tiles_straight)
tiles_arrow[6] = "ch_extras_switch_arrow.png"

local tiles_arrow_r = table.copy(tiles_straight)
tiles_arrow_r[6] = "ch_extras_switch_arrow.png^[transformR180"

def = {
	description = "výměnové návěstidlo",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	light_source = 4,
	sounds = default.node_sound_stone_defaults(),
	after_place_node = after_place_node,
	can_dig = can_dig,
	on_rightclick = on_rightclick,
}

ch_core.register_nodes(
	def,
	{
		["ch_extras:switch_off"] = {
			tiles = tiles_straight,
			groups = groups_off,
			mesecons = mesecons_off,
			_alt_shape = "ch_extras:switch_on",
		},
		["ch_extras:switch_on"] = {
			tiles = tiles_arrow,
			groups = groups_on,
			mesecons = mesecons_on,
			drop = "ch_extras:switch_off",
			_alt_shape = "ch_extras:switch_off",
		},
		["ch_extras:switch_r_off"] = {
			description = "výměnové návěstidlo (opačná logika)",
			tiles = tiles_arrow,
			groups = groups_off,
			mesecons = mesecons_off,
			_alt_shape = "ch_extras:switch_r_on",
		},
		["ch_extras:switch_r_on"] = {
			description = "výměnové návěstidlo (opačná logika)",
			tiles = tiles_straight,
			groups = groups_on,
			mesecons = mesecons_on,
			drop = "ch_extras:switch_r_off",
			_alt_shape = "ch_extras:switch_r_off",
		},
		["ch_extras:switch_lr_off"] = {
			description = "výměnové návěstidlo (vlevo/vpravo)",
			tiles = tiles_arrow,
			groups = groups_off,
			mesecons = mesecons_off,
			_alt_shape = "ch_extras:switch_lr_on",
		},
		["ch_extras:switch_lr_on"] = {
			description = "výměnové návěstidlo (vlevo/vpravo)",
			tiles = tiles_arrow_r,
			groups = groups_on,
			mesecons = mesecons_on,
			drop = "ch_extras:switch_lr_off",
			_alt_shape = "ch_extras:switch_lr_off",
		},
	},
	{
		{
			output = "ch_extras:switch_off",
			recipe = {
				{"dye:black", "dye:white", "dye:black"},
				{"default:steel_ingot", "default:cobble", "default:steel_ingot"},
				{"mesecons:wire_00000000_off", "", "mesecons:wire_00000000_off"},
			},
		}, {
			output = "ch_extras:switch_r_off", recipe = {{"ch_extras:switch_off"}}
		}, {
			output = "ch_extras:switch_off", recipe = {{"ch_extras:switch_r_off"}}
		}, {
			output = "ch_extras:switch_lr_off 2", recipe = {{"ch_extras:switch_r_off", "ch_extras:switch_r_off"}, {"", ""}}
		}, {
			output = "ch_extras:switch_r_off", recipe = {{"ch_extras:switch_lr_off"}}
		}
	})
