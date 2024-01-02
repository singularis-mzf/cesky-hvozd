ch_core.open_submod("formspecs", {data = true, lib = true})

local formspec_header_cache = {}
local formspec_header_template = {"", "", "", "", "", ""}

local function def_to_string(label, defitem, separator)
	if defitem == nil then
		return ""
	end
	local t = type(defitem)
	if t == "string" then
		return label.."["..defitem.."]"
	elseif t == "number" or t == "bool" then
		return label.."["..tostring(defitem).."]"
	elseif t == "table" then
		return label.."["..table.concat(defitem, separator).."]"
	else
		return ""
	end
end

local ifthenelse = ch_core.ifthenelse

--[[
	Sestaví záhlaví formspecu. Dovolené klíče jsou:
	-- cache_key (speciální)
	-- formspec_version
	-- size
	-- position
	-- anchor
	-- padding
	-- no_prepend (bool)
	-- listcolors
	-- bgcolor
	-- background
	-- background9
	-- set_focus
	cache_key je volitelný textový klíč použitý k kešování výsledku;
	není-li nil, měl by to být jedinečný řetězec, který lze vygenerovat
	např. příkazem:
	tr -cd A-Za-z0-9 < /dev/urandom | head -c 16; echo
]]
function ch_core.formspec_header(def)
	local cache_key = def.cache_key
	local result
	if cache_key ~= nil then
		result = formspec_header_cache[cache_key]
		if result ~= nil then
			return result
		end
	end

	local fsw, fsh, size_element

	if def.size ~= nil then
		if type(def.size) ~= "table" then
			error("def.size must be a table or nil!")
		end
		local s = def.size
		fsw, fsh = s[1], s[2]
		size_element = {"size["..tostring(s[1])}
		for i = 2, #s - 1, 1 do
			size_element[i] = tostring(s[i])
		end
		size_element[#s] = tostring(s[#s]).."]"
		size_element = table.concat(size_element, ",")
	else
		fsw, fsh = 10, 10
		size_element = ""
	end

	result = {
		def_to_string("formspec_version", def.formspec_version, ""), -- 1
		size_element, -- 2
		def_to_string("position", def.position, ","), -- 3
		def_to_string("anchor", def.anchor, ","), -- 4
		def_to_string("padding", def.padding, ","), -- 5
		ifthenelse(def.no_prepend == true, "no_prepend[]", ""), -- 6
		def_to_string("listcolors", def.listcolors, ";"), -- 7
		def_to_string("bgcolor", def.bgcolor, ";"), -- 8
		def_to_string("background", def.background, ";"), -- 9
		def_to_string("background9", def.background9, ";"), -- 10
		def_to_string("set_focus", def.set_focus, ";"), -- 11
	}
	if not def.background and not def.background9 and def.formspec_version ~= nil and def.formspec_version > 1 then
		if def.auto_background == true then
			if result[7] == "" then
				-- colors according to Technic Chests:
				result[7] = "listcolors[#7b7b7b;#909090;#000000;#6e823c;#ffffff]"
			end
			result[10] = "background9[0,0;1,1;ch_core_formspec_bg.png;true;16]"
			-- result[9] = "background[0,0;"..fsw..","..fsh..";ch_core_formspec_bg.png]"
		end
	end
	result = table.concat(result)
	if cache_key ~= nil then
		formspec_header_cache[cache_key] = result
	end
	return result
end

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

--[[
	Aktualizuje zobrazený formulář voláním předané funkce.
	Vrací: true = formulář úspěšně nahrazen, false = nahrazebí selhalo,
	nil = formulář měl být nahrazen, ale update_callback vrátil nil.
]]
function ch_core.update_shown_formspec(player_name, formname, update_callback)
	local online_charinfo = player_name and ch_core.online_charinfo[player_name]
	if not online_charinfo then
		return false
	end
	local formspec_state = online_charinfo.formspec_state
	if not formspec_state or formspec_state.formname ~= formname then
		return false
	end
	local update_result = update_callback(formspec_state.custom_state)
	if update_result ~= nil then
		minetest.show_formspec(player_name, formname, update_result)
		return true
	end
end

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
