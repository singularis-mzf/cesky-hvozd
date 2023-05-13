local music_cache = {}
local music_cache_counter = 0
local music_cache_limit = 256
local min_delay = 0.1
local normal_delay = 0.5
local piano_states = {}

-- formát instrukce:
-- {
--    sound = "", -- zvuk, který přehrát
--    stop = true, -- nic nepřehrávat a skončit
--    delka = číslo, -- změnit nastavení „délka“ (tempo)
--    index = 1, -- index pro zobrazení v nápovědě (0 až 51, nebo nil)
-- }
local instructions = {
	["C"] = {index = 0, sound = "mesecons_noteblock_c"},
	["C#"] = {index = 1, sound = "mesecons_noteblock_csharp"},
	["D"] = {index = 2, sound = "mesecons_noteblock_d"},
	["D#"] = {index = 3, sound = "mesecons_noteblock_dsharp"},
	["E"] = {index = 4, sound = "mesecons_noteblock_e"},
	["F"] = {index = 5, sound = "mesecons_noteblock_f"},
	["F#"] = {index = 6, sound = "mesecons_noteblock_fsharp"},
	["G"] = {index = 7, sound = "mesecons_noteblock_g"},
	["G#"] = {index = 8, sound = "mesecons_noteblock_gsharp"},
	["A"] = {index = 9, sound = "mesecons_noteblock_a"},
	["A#"] = {index = 10, sound = "mesecons_noteblock_asharp"},
	["H"] = {index = 11, sound = "mesecons_noteblock_b"},

	["C2"] = {index = 26, sound = "mesecons_noteblock_c2"},
	["C#2"] = {index = 27, sound = "mesecons_noteblock_csharp2"},
	["D2"] = {index = 28, sound = "mesecons_noteblock_d2"},
	["D#2"] = {index = 29, sound = "mesecons_noteblock_dsharp2"},
	["E2"] = {index = 30, sound = "mesecons_noteblock_e2"},
	["F2"] = {index = 31, sound = "mesecons_noteblock_f2"},
	["F#2"] = {index = 32, sound = "mesecons_noteblock_fsharp2"},
	["G2"] = {index = 33, sound = "mesecons_noteblock_g2"},
	["G#2"] = {index = 34, sound = "mesecons_noteblock_gsharp2"},
	["A2"] = {index = 35, sound = "mesecons_noteblock_a2"},
	["A#2"] = {index = 36, sound = "mesecons_noteblock_asharp2"},
	["H2"] = {index = 37, sound = "mesecons_noteblock_b2"},

	["PAUZA"] = {index = 13},
	["DELKA1"] = {index = 14, delka = 1},
	["DELKA2"] = {index = 15, delka = 1.0 / 2.0},
	["DELKA4"] = {index = 16, delka = 1.0 / 4.0},
	["DELKA8"] = {index = 17, delka = 1.0 / 8.0},

	["STOP"] = {index = 18, stop = true},
}

local function get_score(s)
	if type(s) ~= "string" then
		minetest.log("warning", "get_score(): invalid input of type "..type(s).."!")
		return {}
	end
	local result = music_cache[s]
	if result == nil then
		music_cache_counter = music_cache_counter + 1
		if music_cache_counter > music_cache_limit then
			music_cache = {}
			music_cache_counter = 0
		end
		result = string.split(s, "%s*\n%s*", false, -1, true)
		music_cache[s] = result
	end
	return result
end

local function get_formspec(pos, player_name, meta)
	if meta == nil then
		meta = minetest.get_meta(pos)
	end
	local is_protected = minetest.is_protected(pos, player_name)
	local formspec = {
		"formspec_version[4]",
		"size[8,12]",
		"item_image[2.75,0.25;1,1;homedecor:piano]",
		"label[4,0.75;Klavír]",
		"textarea[0.375,0.75;2,11;noty;Skladba:;"..minetest.formspec_escape(meta:get_string("noty")).."]",
		is_protected and "" or "button_exit[2.75,1.75;2.5,0.75;ulozit;uložit skladbu]",
		is_protected and "" or "button_exit[2.75,2.75;2.5,0.75;uzahrat;uložit a zahrát]",
		"button[2.75,3.75;2.5,0.75;prestat;přestat hrát]",
		"button_exit[2.75,4.75;2.5,0.75;zavrit;zavřít panel]",
		"label[5.75,1;Instrukce:]",
	}
	for k, v in pairs(instructions) do
		local vindex = v.index
		if vindex ~= nil and vindex >= 0 and vindex < 52 then
			table.insert(formspec, "label[")
			if vindex < 26 then
				table.insert(formspec, "5.75,")
			else
				vindex = vindex - 26
				table.insert(formspec, "6.75,")
			end
			table.insert(formspec, (1.5 + 0.4 * vindex)..";"..minetest.formspec_escape(k).."]")
		end
	end
	return table.concat(formspec)
end

local function play_notes_internal(pos, piano_state)
	-- stop the previous note
	local sound_handle = piano_state.sound_handle
	if sound_handle ~= nil then
		minetest.sound_fade(sound_handle, 10.0, 0.0)
		-- minetest.sound_stop(sound_handle)
		piano_state.sound_handle = nil
	end

	local index = piano_state.index
	local noty = piano_state.noty
	local delay = piano_state.delka or 1

	-- stop, if the piano_state is old or index reached the final position
	local pos_hash = minetest.hash_node_position(pos)
	if piano_state ~= piano_states[pos_hash] or index > #noty then
		-- print("LADĚNÍ: => stop (index = "..index..", #noty = "..#noty..")")
		return
	end

	local nota = noty[index] or ""

	-- play a note
	local ndef = instructions[string.upper(nota)]
	if ndef == nil then
		minetest.log("warning", "Unknown note '"..nota.."' at index "..index.."!")
		ndef = {}
	end
	-- stop if needed
	if ndef.stop then
		return
	end
	-- play sound (if available)
	if ndef.sound ~= nil and ndef.sound ~= "" then
		piano_state.last_nota = nota
		piano_state.sound_handle = minetest.sound_play(ndef.sound, {pos = pos, gain = 1.0, fade = 1.0})
		-- print("LADĚNÍ: is playing sound by handle "..dump2({handle = piano_state.sound_handle}))
		-- minetest.after(normal_delay, minetest.sound_fade, piano_state.sound_handle, 1.5, 0.0)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", nota)
	end
	-- set tempo if needed
	if ndef.delka ~= nil then
		piano_state.delka = ndef.delka
		delay = 0
	end
	-- delay and continue
	if index <= #noty then
		piano_state.index = index + 1
		if delay > 0 then
			minetest.after(delay, play_notes_internal, pos, piano_state)
		else
			return play_notes_internal(pos, piano_state)
		end
	end
end

local function play_notes(pos, noty)
	local pos_hash = minetest.hash_node_position(pos)
	local piano_state = {
		noty = noty,
		index = 1,
		delka = 1,
	}
	piano_states[pos_hash] = piano_state
	if #noty > 0 then
		minetest.after(0.05, play_notes_internal, vector.copy(pos), piano_state)
	end
end

local function formspec_callback(custom_state, player, formname, fields)
	local pos = custom_state.pos
	local player_name = player:get_player_name()
	local is_protected = minetest.is_protected(pos, player_name)
	local meta = minetest.get_meta(pos)

	if fields.ulozit or fields.uzahrat then
		-- uložit skladbu
		if is_protected then
			minetest.record_protection_violation(pos, player_name)
			return
		else
			meta:set_string("noty", fields.noty:sub(1,65535))
		end
	end
	if fields.zahrat or fields.uzahrat then
		-- zahrát
		local noty = get_score(meta:get_string("noty"))
		if #noty > 0 then
			play_notes(pos, noty)
		end
	elseif fields.prestat then
		play_notes(pos, {})
	end
end

local function on_punch(pos, node, puncher, pointed_thing)
	if not puncher or not puncher:is_player() then
		return
	end
	local player_name = puncher:get_player_name()
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return
	end
	-- play a random note
	local noty = {}
	for k, v in pairs(instructions) do
		if (v.sound or "") ~= "" then
			table.insert(noty, k)
		end
	end
	if #noty == 0 then
		return
	end
	local nota = noty[math.random(1, #noty)]
	play_notes(pos, {"DELKA4", nota})
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	if not clicker or not clicker:is_player() then
		return
	end
	local player_name = clicker:get_player_name()
	ch_core.show_formspec(clicker, "ch_overrides:piano", get_formspec(pos, clicker), formspec_callback, {pos = pos}, {})
end

local def = {
	on_punch = on_punch,
	on_rightclick = on_rightclick,
	_ch_help = "po umístění klikněte na klavír pravým tlačítkem,\nbude vám umožněno naprogramovat skladbu\nprogram se skládá z tónů (např. C), z nastavení délky\n(DELKA1 = celé tóny a pauzy, DELKA2 = poloviční atd.) a dalších instrukcí",
}

minetest.override_item("homedecor:piano", def)
