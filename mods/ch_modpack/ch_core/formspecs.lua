ch_core.open_submod("formspecs", {data = true, lib = true})

--[[
	player_name => {
		callback = function,
		custom_state = ...,
		formname = string,
		object_id = int,
	}
]]
local formspec_states = {}
local formspec_states_next_id = 1

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
		if #defitem == 0 then
			return label.."[]"
		else
			t = {}
			for i = 1, #defitem do
				t[i] = tostring(defitem[i])
			end
			t[1] = label.."["..t[1]
			t[#t] = t[#t].."]"
			return table.concat(t, separator)
		end
	else
		return ""
	end
end

local ifthenelse = ch_core.ifthenelse

--[[
	Sestaví záhlaví formspecu. Dovolené klíče jsou:
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
	-- auto_background (speciální, vylučuje se s background a background9)
]]
function ch_core.formspec_header(def)
	local result, size_element

	if def.size ~= nil then
		if type(def.size) ~= "table" then
			error("def.size must be a table or nil!")
		end
		local s = def.size
		size_element = {"size["..tostring(s[1])}
		for i = 2, #s - 1, 1 do
			size_element[i] = tostring(s[i])
		end
		size_element[#s] = tostring(s[#s]).."]"
		size_element = table.concat(size_element, ",")
	else
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
	return table.concat(result)
end

--[[
	Má-li daná postava zobrazen daný formspec, uzavře ho a vrátí true.
	Jinak vrátí false.
	Je-li call_callback true, nastavený callback se před uzavřením zavolá
	s fields = {quit = "true"} a jeho návratová hodnota bude odignorována.
]]
function ch_core.close_formspec(player_name_or_player, formname, call_callback)
	if formname == nil or formname == "" then
		return false -- formname invalid
	end
	local p = ch_core.normalize_player(player_name_or_player)
	if p.player == nil then
		return false -- player invalid or not online
	end
	local formspec_state = formspec_states[p.player_name]
	if formspec_state == nil or formspec_state.formname ~= formname then
		return false -- formspec not open or the formname is different
	end
	if call_callback then
		formspec_state.callback(formspec_state.custom_state, p.player, formname, {quit = "true"})
	end
	minetest.close_formspec(p.player_name, formname)
	if formspec_states[p.player_name] ~= nil and formspec_states[p.player_name].object_id == formspec_state.object_id then
		formspec_states[p.player_name] = nil
	end
	return true
end

--[[
	Zobrazí hráči/ce formulář a nastaví callback pro jeho obsluhu.
	Callback nemusí být zavolán v nestandardních situacích jako
	v případě odpojení klienta.
]]
function ch_core.show_formspec(player_name_or_player, formname, formspec, callback, custom_state, options)
	local p = ch_core.normalize_player(player_name_or_player)
	if p.player == nil then return false end -- player invalid or not online

	if formname == nil or formname == "" then
		-- generate random formname
		formname = "ch_core:"..minetest.sha1(tostring(bit.bxor(minetest.get_us_time(), math.random(1, 1099511627775))), false)
	end

	local id = formspec_states_next_id
	formspec_states_next_id = id + 1
	formspec_states[p.player_name] = {
		callback = callback or function(...) return end,
		custom_state = custom_state,
		formname = formname,
		object_id = id,
	}

	minetest.show_formspec(p.player_name, formname, formspec)
	return formname
end

--[[
	Aktualizuje již zobrazený formspec. Vrátí true v případě úspěchu.
	formspec_or_function může být buď řetězec, nebo funkce, která bude
	pro získání řetězce zavolána s parametry: (player_name, formname, custom_state).
	Pokud nevrátí řetězec, update_formspec skončí a vrátí false..
]]
function ch_core.update_formspec(player_name_or_player, formname, formspec_or_function)
	if formname == nil or formname == "" then
		return false -- formname invalid
	end
	local p = ch_core.normalize_player(player_name_or_player)
	if p.player == nil then
		return false -- player invalid or not online
	end
	local formspec_state = formspec_states[p.player_name]
	if formspec_state == nil or formspec_state.formname ~= formname then
		return false -- formspec not open or the formname is different
	end
	local t = type(formspec_or_function)
	local formspec
	if t == "string" then
		formspec = formspec_or_function
	elseif t == "function" then
		formspec = formspec_or_function(p.player_name, formname, formspec_state.custom_state)
		if type(formspec) ~= "string" then
			return false
		end
	else
		return false -- invalid formspec argument
	end
	minetest.show_formspec(p.player_name, formname, formspec)
	return true
end

local function on_player_receive_fields(player, formname, fields)
	local player_name = assert(player:get_player_name())
	local formspec_state = formspec_states[player_name]
	if formspec_state == nil then
		return -- formspec not by ch_core
	end
	if formspec_state.formname ~= formname then
		minetest.log("warning", player_name..": received fields of form "..(formname or "nil").." when "..(formspec_state.formname or "nil").." was expected")
		formspec_states[player_name] = nil
		return
	end
	local result = formspec_state.callback(formspec_state.custom_state, player, formname, fields, {}) -- custom_state, player, formname, fields
	if type(result) == "string" then
	--        string => show as formspec
		formspec_states[player_name] = formspec_state
		minetest.show_formspec(player_name, formname, result)
	elseif fields ~= nil and fields.quit == "true" and formspec_states[player_name] ~= nil and formspec_states[player_name].object_id == formspec_state.object_id then
		formspec_states[player_name] = nil
	end
	return true
end
minetest.register_on_player_receive_fields(on_player_receive_fields)

ch_core.close_submod("formspecs")
