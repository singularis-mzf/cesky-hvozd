ch_base.open_mod(core.get_current_modname())

ch_formspec = {
    CLOSE = "@@CLOSE/FORMSPEC@@",
}

local pname_to_state = {--[[
    [player_name] = {
        callback = function,
        custom_state = any,
        formname = string, -- = session id
    }
]]}
local next_session_id = 1

local function process_player(player_or_name)
    local player, player_name
    if player_or_name ~= nil then
        if type(player_or_name) == "string" then
            player_name = player_or_name
            player = core.get_player_by_name(player_name)
            if player ~= nil then
                return player, player_name
            end
        elseif core.is_player(player_or_name) then
            player_name = player:get_player_name()
            return player_or_name, player_name
        end
    end
end

function ch_formspec.show(player, formspec, callback, custom_state)
    local player_name
    player, player_name = process_player(player)
    if player == nil then
        return
    end
    if type(formspec) == "function" then
        formspec = formspec(custom_state, player)
    end
    if formspec == nil then
        return
    end
    if type(formspec) ~= "string" then
        core.log("error", "ch_formspec.show() called with invalid formspec type!")
        return
    end
    if callback == nil then
        callback = function() end
    elseif type(callback) ~= "function" then
        core.log("error", "ch_formspec.show() called with invalid callback type!")
        return
    end
    local formname = string.format("ch_formspec:fs%04d", next_session_id)
    pname_to_state[player_name] = {
        callback = callback,
        custom_state = custom_state,
        formname = formname,
    }
    next_session_id = next_session_id + 1
    core.show_formspec(player_name, formname, formspec)
    return formname
end

function ch_formspec.update(player, formname, new_formspec)
    local player_name
    player, player_name = process_player(player)
    if player == nil then
        return false
    end
    local state = pname_to_state[player_name]
    if state == nil or state.formname ~= formname then
        return false
    end
    if type(new_formspec) == "function" then
        new_formspec = new_formspec(custom_state, player)
    end
    if new_formspec == nil then
        return
    end
    if type(new_formspec) ~= "string" then
        core.log("error", "ch_formspec.update() called with invalid formspec type!")
        return
    end
    core.show_formspec(player_name, formname, new_formspec)
    return true
end

function ch_formspec.close(player, formname, call_callback)
    local player_name
    player, player_name = process_player(player)
    if player == nil then
        return false
    end
    local state = pname_to_state[player_name]
    if state ~= nil and state.formname == formname then
        core.close_formspec(player_name, formname)
        pname_to_state[player_name] = nil
        if call_callback then
            state.callback(state.custom_state, player, {quit = "true"}, formname)
        end
        return true
    end
end

local function on_player_receive_fields(player, formname, fields)
	local player_name = assert(player:get_player_name())
	local state = pname_to_state[player_name]
	if state == nil then
		return -- formspec not by ch_formspec
	end
	if state.formname ~= formname then
		core.log("warning", player_name..": received fields of form "..(formname or "nil").." when "..(state.formname or "nil").." was expected")
		pname_to_state[player_name] = nil
		return
	end
    local quit = fields.quit == "true"
    if quit then
        pname_to_state[player_name] = nil
    end
	local result = state.callback(state.custom_state, player, fields, formname)
	if type(result) == "string" then
        if result ~= ch_formspec.CLOSE then
            -- update the formspec
            pname_to_state[player_name] = state
            core.show_formspec(player_name, formname, result)
        elseif not quit then
            -- close the formspec:
            pname_to_state[player_name] = nil
            core.close_formspec(player_name, state.formname)
        end
    else
        if result ~= nil then
            core.log("error", "Invalid type from ch_formspec callback: "..type(result))
        end
	end
	return true
end
core.register_on_player_receive_fields(on_player_receive_fields)

local CompiledFields = {}

function ch_core.compile_fields(fdef)
    local result = {}
    setmetatable(result, {__index = CompiledFields})
    for _, def in ipairs(fdef) do
        if type(def) == "table" then
            local t = def[1] or "nil"
            local name = def[2]
            local default = def[3]
            local option = def[4]
            if t == "animated_image" then
                table.insert(result, {"animated_image", assert(name), default or 1})
            elseif t == "field" or t == "textarea" then
                table.insert(result, {"field", assert(name), default or ""})
            elseif t == "textlist" then
                -- TODO
            elseif t == "tabheader" then
            elseif t == "dropdown" then
            elseif t == "checkbox" then
            elseif t == "scrollbar" then
            elseif t == "table" then
                if option == nil or option == "row" then
                    option = 1
                elseif option == "column" then
                    option = 2
                elseif option == "event" then
                    option = 3
                    if default == nil then
                        default = {type = "INV", row = 1, col = 1}
                    end
                else
                    core.log("warning", "Invalid option "..tostring(option).." for a table field '"..name.."'!")
                    option = 1
                end
                table.insert(result, {"table", assert(name), default or 1, option})
            else
                core.log("warning", "Field type '"..t.."' not supported by compiled fields!")
            -- TODO: hypertext
            end
        end
    end
end

function CompiledFields:update(custom_state, fields)
    local tbl = self
    for i = 1, #tbl do
        local def = self[i]
        local name = def[2]
        local f = fields[name]
        if f ~= nil then
            local field_type = def[1]
            if field_type == "field" then
                custom_state[name] = f
            elseif field_type == "table" then
                local option = def[4]
                local event = core.explode_table_event(f)
                if option == 1 then
                    custom_state[name] = event.row
                    -- POKRAČOVAT.........................................................
                elseif option == 2 then
                else
                end
            end
        elseif custom_state[name] == nil then
            custom_state[name] = def[3]
        end

        if t[1] == "field" then
            if fields[name] ~= nil then
                
            elseif custom_state[name] == nil then
                custom_state[name] = def[3]
            end
        elseif t == "table" then
            if fields[name] =
        end
    end
end









-- local function formspec_callback(custom_state, player, formname, fields)

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
	Pokud nevrátí řetězec, update_formspec skončí a vrátí false.
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














ch_base.close_mod(core.get_current_modname())
