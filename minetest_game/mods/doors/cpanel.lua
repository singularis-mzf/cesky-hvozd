local player_to_door_pos = {}

function doors.show_control_panel(player, door_pos)
	local node = minetest.get_node(door_pos)
	--[[ if not doors.registered_doors[node.name] and not doors.registered_trapdoors[node.name] then
		return false -- not a door
	end ]]
	local obj = doors.get(door_pos)
	if not obj then
		return false -- not a door
	end
	local meta = minetest.get_meta(door_pos)
	local owner, owner_type = meta:get_string("owner"), "owner"
	if owner == "" then
		owner, owner_type = meta:get_string("placer"), "placer"
		if owner == "" then
			owner_type = "none"
		end
	end

	local vlastnik_ice, toggle_id
	local t_vlastnik_ice, t_hotelove, t_zavirasamo, t_stav, t_toggle
	local fs_zavirasamo
	-- , hotelove_text, zavirasamo_text, zavirasamo_fs, nazevdveri, stav_text, toggle_id, toggle_text

	if owner ~= "" then
		vlastnik_ice = doors.login_to_viewname(owner)
	else
		vlastnik_ice = "není"
	end
	if owner_type == "placer" then
		t_vlastnik_ice = "Dveře postavil/a"
	else
		t_vlastnik_ice = "Vlastník/ice"
	end
	local hes = meta:get_int("hes")
	if hes ~= 0 then
		t_hotelove = "ano (kód "..hes..")"
	else
		t_hotelove = "ne"
	end
	local zavirasamo = meta:get_int("zavirasamo") > 0
	if  zavirasamo then
		t_zavirasamo = "ano"
		fs_zavirasamo = "zavirasamovyp;vypnout"
	else
		t_zavirasamo = "ne"
		fs_zavirasamo = "zavirasamozap;zapnout"
	end
	if obj:state() then
		t_stav = "otevřeno"
		toggle_id = "closedoor"
		t_toggle = "zavřít dveře"
	else
		t_stav = "zavřeno"
		toggle_id = "opendoor"
		t_toggle = "otevřít dveře"
	end

	local formspec = {
		"formspec_version[4]",
		"size[12,6]",
		"field[11.0,0.25;0.5,0.5;ignore;;]",
		"label[0.375,0.5;Ovládací panel dveří]",
		"label[0.375,1.0;", t_vlastnik_ice, ": ", vlastnik_ice, "]",
		"label[0.375,1.5;Soukromé: ", owner_type == "owner" and "ano" or "ne", "]",
		"label[0.375,2.0;Hotelové: ", t_hotelove, "]",
		"label[0.375,2.5;(pro zapnutí musí vlastník/ice použít na dveře nenastavený klíč ke dveřím)]",
		"label[0.375,3.0;Zavírá samo: ", t_zavirasamo, "]",
		"label[0.375,3.5;Název dveří:]",
		"field[2.2,3.28;5,0.5;nazevdveri;;", meta:get_string("nazev"), "]",
		"button[7.5,3.28;2,0.5;ulozit;uložit]",
		"button[3,2.75;2,0.5;", fs_zavirasamo, "]",
		"label[0.375,4.0;Stav: ", t_stav, "]",
		"button[2.6,3.85;2,0.5;", toggle_id, ";", t_toggle, "]",
		"button_exit[1,4.8;10,0.75;zavrit;Zavřít ovládací panel]",
	}
	local player_name = player:get_player_name()
	player_to_door_pos[player_name] = door_pos
	minetest.show_formspec(player_name, "doors:door_cpanel", table.concat(formspec))
end

local function on_player_receive_fields(player, formname, fields)
	if formname ~= "doors:door_cpanel" then
		return
	end
	if not player or not player:is_player() or not minetest.check_player_privs(player, "ch_registered_player") then
		return false
	end
	local player_name = player:get_player_name()
	local door_pos = player_to_door_pos[player_name]
	if not door_pos then
		minetest.log("warning", "Door position for player "..player_name.." has not been saved!")
		return false
	end
	local door_node = minetest.get_node(door_pos)
	local door_obj = doors.get(door_pos)
	if not door_obj then
		minetest.log("warning", door_node.name.." is not a registered door!")
		return false
	end

	if fields.quit then
		return true
	end
	local is_openned = door_obj:state()
	local meta = minetest.get_meta(door_pos)

	if (not is_openned and fields.opendoor) or (is_openned and fields.closedoor) then
		door_obj:toggle(player)
		door_node = minetest.get_node(door_pos)
	end

	-- Check configuration rights:
	local hasConfigRights
	local owner = meta:get_string("owner")
	if owner == "" then
		owner = meta:get_string("placer")
	end
	hasConfigRights = player_name == owner or minetest.check_player_privs(player, "protection_bypass")

	if hasConfigRights then
		-- buttons:
		if fields.ulozit then
			meta:set_string("nazev", fields.nazevdveri or "")
		end
		if fields.zavirasamovyp then
			meta:set_int("zavirasamo", 0)
		elseif fields.zavirasamozap then
			meta:set_int("zavirasamo", 5)
		end
		doors.update_infotext(door_pos, door_node, meta)
	elseif fields.ulozit or fields.zavirasamovyp or fields.zavirasamozap then
		minetest.chat_send_player(player_name, "Nemáte právo konfigurovat tyto dveře!")
	end

	doors.show_control_panel(player, door_pos)
	return true
end

minetest.register_on_player_receive_fields(on_player_receive_fields)
