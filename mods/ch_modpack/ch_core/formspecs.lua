ch_core.open_submod("formspecs", {data = true, lib = true})

--[[
	Vrátí jméno (formname) aktuálně zobrazeného formuláře
	nebo nil, pokud není žádný formulář právě zobrazen pomocí funkce
	ch_core.show_formspec().
]]
function ch_core.get_current_formspec_name(player_name_or_player)
	local p_type = type(player_name_or_player)
	local player_name
	if p_type == "string" then
		player_name = player_name_or_player
	elseif p_type == "userdata" then
		if player_name_or_player:is_player() then
			player_name = player_name_or_player:get_player_name()
		else
			error("Invalid argument: non-player userdata passed!")
		end
	else
		error("Invalid call to ch_core.show_formspec! type "..p_type.." passed as player_name_or_player!")
	end

	local online_charinfo = ch_core.online_charinfo[player_name]
	if not online_charinfo then
		minetest.log("warning", "online_charinfo for "..player_name.." to show a formspec "..formname.." not found!")
		return nil
	end
	local formspec_state = online_charinfo.formspec_state
	if not formspec_state then
		return nil
	end
	return formspec_state.formname
end

--[[
	Zobrazí hráči/ce formulář a nastaví callback pro jeho obsluhu.
	Callback nemusí být zavolán v nestandardních situacích jako
	v případě odpojení klienta.
]]
function ch_core.show_formspec(player_name_or_player, formname, formspec, callback, custom_state, options)
	local p_type = type(player_name_or_player)
	local player_name
	if p_type == "string" then
		player_name = player_name_or_player
	elseif p_type == "userdata" then
		if player_name_or_player:is_player() then
			player_name = player_name_or_player:get_player_name()
		else
			error("Invalid argument: non-player userdata passed!")
		end
	else
		error("Invalid call to ch_core.show_formspec! type "..p_type.." passed as player_name_or_player!")
	end

	local online_charinfo = ch_core.online_charinfo[player_name]
	if not online_charinfo then
		minetest.log("warning", "online_charinfo for "..player_name.." to show a formspec "..formname.." not found!")
		return false
	end
	online_charinfo.formspec_state = {
		callback = callback or function(...) return true end,
		custom_state = custom_state,
		formname = formname,
	}

	minetest.show_formspec(player_name, formname, formspec)
	return true
end

local function on_player_receive_fields(player, formname, fields)
	local player_name = player and player:get_player_name()
	if not player_name then
		return
	end
	local online_charinfo = ch_core.online_charinfo[player_name]
	if not online_charinfo then
		minetest.log("warning", "Received fields form formspec "..(formname or "nil").." of player "..player_name..", but online_charinfo is not available!")
		return
	end
	local formspec_state = online_charinfo.formspec_state
	online_charinfo.formspec_state = nil
	if not formspec_state then
		return -- formspec not by ch_core
	end
	if formspec_state.formname ~= formname then
		minetest.log("warning", player_name..": received fields of form "..(formname or "nil").." when "..(formspec_state.formname or "nil").." was expected")
		return
	end
	local result = formspec_state.callback(formspec_state.custom_state, player, formname, fields, {}) -- custom_state, player, formname, fields
	local quit = fields and fields.quit == "true"
	-- result:
	--        string => show as formspec
	if type(result) == "string" then
		online_charinfo.formspec_state = formspec_state
		minetest.show_formspec(player_name, formname, result)
		return true
	else
		if not quit then
			online_charinfo.formspec_state = formspec_state
		end
		return true
	end
end
minetest.register_on_player_receive_fields(on_player_receive_fields)

--[[ PŘÍKLAD POUŽITÍ:
minetest.register_chatcommand("test", {
	description = "Jen test",
	func = function(player_name, param)
		local formspec = "size[8,8]button_exit[0,0;2,2;exitbutton;EXIT BUTTON]button[0,3;2,2;nonexitbutton;NON EXIT]"
		local callback = function(custom_state, player, formname, fields)
			custom_state.counter = custom_state.counter + 1
			print("DEBUG ("..custom_state.counter.."): "..dump2(fields))
		end
		ch_core.show_formspec(player_name, "ch_core:jen_test", formspec, callback, {counter = 0}, {test = true})
	end,
})
]]

ch_core.close_submod("formspecs")
