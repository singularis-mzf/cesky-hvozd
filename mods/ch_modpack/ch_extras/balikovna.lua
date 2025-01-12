-- rozepsáno

local F = minetest.formspec_escape
local ifthenelse = ch_core.ifthenelse

if not minetest.get_modpath("wrench") then
	return
end




--[[
custom_state = {
	player_name = string,
	player_role = string,
}
]]
function get_formspec(custom_state)


	local pos, owner = custom_state.pos, custom_state.owner
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local is_active = node.param2 == active_param2
	local records = wa_get_records(meta)
	for i, record in ipairs(records) do
		records[i] = F(record)
	end
	local state_message
	if is_active then
		local timeout = meta:get_int("timeout")
		state_message = green.."Kotva je zapnutá"..white..", časovač vyprší: "..F(wa_time_to_string(timeout))
	else
		state_message = red.."Kotva je vypnutá."..white
	end
	local area_min = vector.offset(pos, -(pos.x % 16), -(pos.y % 16), -(pos.z % 16))
	local area_max = vector.offset(area_min, 15, 15, 15)

	local formspec = {
		ch_core.formspec_header{
			formspec_version = 6,
			size = {16, 8},
			auto_background = true,
		},
		"item_image[0.375,0.375;1,1;", wa_node_name, "]",
		"label[1.6,0.9;Soukromá světová kotva]",
		"label[0.3,2;", state_message,
			"\nKotvu vlastní: ", ch_core.prihlasovaci_na_zobrazovaci(custom_state.owner, true), white,
			"\nKotva pokrývá oblast: "..F(minetest.pos_to_string(area_min)..".."..minetest.pos_to_string(area_max)).."]",
		"button_exit[0.25,6.25;7.25,1;show;ukázat pokrytou oblast]",
		"label[9.5,0.5;záznamy:]",
		"tableoptions[background=#1e1e1e;border=true;highlight=#467832]",
		"tablecolumns[text]",
		"table[9.5,0.75;6,6.75;zaznamy;",
		table.concat(records, ","),
		";1]",
		"tooltip[zaznamy;zap = kotva se zapnula\n"..
		"vyp = kotva se vypnula\nakt = mapový blok začal být aktivní\n"..
		"dkt = mapový blok přestal být aktivní]",
	}
	if custom_state.has_rights then
		table.insert(formspec,
			"label[0.3,4;Vypršet za:\n(max. 2880 = 48 hodin)]"..
			"field[1.9,3.75;1.5,0.5;timeout;;2880]"..
			"label[3.5,4;minut.]"..
			"tooltip[timeout;60 = 1 hodina\\, 120 = 2 hodiny\\, 300 = 5 hodin\\,\n720 = 12 hodn\\, 1440 = 24 hodin\\, 2880 = 48 hodin]")
		if is_active then
			table.insert(formspec,
				"button[0.25,5;3.5,1;set;nastavit]"..
				"button[4,5;3.5,1;vyp;"..light_red.."vypnout kotvu]")
		else
			table.insert(formspec, "button[0.25,5;3.5,1;set;"..light_green.."nastavit\na zapnout]")
		end
	end
	return table.concat(formspec)
end

local function formspec_callback(custom_state, player, formname, fields)
	local player_info = ch_core.normalize_player(player)
	if player_info.player_name ~= custom_state.player_name or not custom_state.has_rights then
		return
	end
	local player_name = custom_state.player_name
	if fields.quit then
		player_name_to_formspec_state[player_name] = nil
	end
	if fields.show then
		local pos = custom_state.pos
		local x, y, z = pos.x - (pos.x % 16), pos.y - (pos.y % 16), pos.z - (pos.z % 16)
		ch_core.show_aabb({x, y, z, x + 16, y + 16, z + 16}, 16)
		return
	elseif fields.set then
		local player_role = player_info.role
		local wa_time = get_wa_time()
		local new_rel_timeout
		if player_info.role == "admin" and fields.timeout == "max" then
			new_rel_timeout = 2147483640 - wa_time
		else
			new_rel_timeout = math.ceil(tonumber(fields.timeout))
			if new_rel_timeout <= 1 then
				new_rel_timeout = 1
			elseif new_rel_timeout > wa_minutes_limit and player_role ~= "admin" then
				new_rel_timeout = wa_minutes_limit
			end
			new_rel_timeout = new_rel_timeout * 60 -- minutes to seconds
		end
		local node = minetest.get_node(custom_state.pos)
		if node.param2 == active_param2 then
			-- update timeout only
			local pos = custom_state.pos
			local meta = minetest.get_meta(pos)
			meta:set_int("timeout", wa_time + new_rel_timeout)
			wa_update_infotext(pos, node, meta, wa_time)
		elseif not wa_enable(player_name, vector.copy(custom_state.pos), minetest.get_node(custom_state.pos), new_rel_timeout, player_role == "admin") then
			ch_core.systemovy_kanal(player_name, "Pokus o zapnutí soukromé světové kotvy selhal.")
			return
		end
	elseif fields.vyp then
		wa_disable(custom_state.pos, minetest.get_node(custom_state.pos), minetest.get_meta(custom_state.pos))
	else
		return
	end
	return get_formspec(custom_state)
end

