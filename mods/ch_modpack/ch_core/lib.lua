ch_core.open_submod("lib", {data = true})

-- DATA
-- ===========================================================================
local diakritika = {
	["Á"] = "A",
	["Ä"] = "A",
	["Č"] = "C",
	["Ď"] = "D",
	["É"] = "E",
	["Ě"] = "E",
	["Í"] = "I",
	["Ĺ"] = "L",
	["Ľ"] = "L",
	["Ň"] = "N",
	["Ó"] = "O",
	["Ô"] = "O",
	["Ŕ"] = "R",
	["Ř"] = "R",
	["Š"] = "S",
	["Ť"] = "T",
	["Ú"] = "U",
	["Ů"] = "U",
	["Ý"] = "Y",
	["Ž"] = "Z",
	["á"] = "a",
	["ä"] = "a",
	["č"] = "c",
	["ď"] = "d",
	["é"] = "e",
	["ě"] = "e",
	["í"] = "i",
	["ĺ"] = "l",
	["ľ"] = "l",
	["ň"] = "n",
	["ó"] = "o",
	["ô"] = "o",
	["ŕ"] = "r",
	["ř"] = "r",
	["š"] = "s",
	["ť"] = "t",
	["ú"] = "u",
	["ů"] = "u",
	["ý"] = "y",
	["ž"] = "z",
}

local diakritika_na_mala = {
	["Á"] = "á",
	["Ä"] = "ä",
	["Č"] = "č",
	["Ď"] = "ď",
	["É"] = "é",
	["Ě"] = "Ě",
	["Í"] = "Í",
	["Ĺ"] = "ĺ",
	["Ľ"] = "ľ",
	["Ň"] = "ň",
	["Ó"] = "ó",
	["Ô"] = "ô",
	["Ŕ"] = "ŕ",
	["Ř"] = "ř",
	["Š"] = "š",
	["Ť"] = "ť",
	["Ú"] = "ú",
	["Ů"] = "ů",
	["Ý"] = "ý",
	["Ž"] = "ž",
}

local facedir_to_rotation_data = {
	[0] = vector.new(0, 0, 0),
	[1] = vector.new(0, -0.5 * math.pi, 0),
	[2] = vector.new(0, -math.pi, 0),
	[3] = vector.new(0, 0.5 * math.pi, 0),
	[4] = vector.new(-0.5 * math.pi, 0, 0),
	[5] = vector.new(0, -0.5 * math.pi, -0.5 * math.pi),
	[6] = vector.new(0.5 * math.pi, 0, math.pi),
	[7] = vector.new(0, 0.5 * math.pi, 0.5 * math.pi),
	[8] = vector.new(0.5 * math.pi, 0, 0),
	[9] = vector.new(0, -0.5 * math.pi, 0.5 * math.pi),
	[10] = vector.new(-0.5 * math.pi, 0, math.pi),
	[11] = vector.new(0, 0.5 * math.pi, -0.5 * math.pi),
	[12] = vector.new(0, 0, 0.5 * math.pi),
	[13] = vector.new(-0.5 * math.pi, 0, 0.5 * math.pi),
	[14] = vector.new(0, -math.pi, -0.5 * math.pi),
	[15] = vector.new(0.5 * math.pi, 0, 0.5 * math.pi),
	[16] = vector.new(0, 0, -0.5 * math.pi),
	[17] = vector.new(0.5 * math.pi, 0, -0.5 * math.pi),
	[18] = vector.new(0, -math.pi, 0.5 * math.pi),
	[19] = vector.new(-0.5 * math.pi, 0, -0.5 * math.pi),
	[20] = vector.new(0, 0, math.pi),
	[21] = vector.new(0, 0.5 * math.pi, math.pi),
	[22] = vector.new(0, -math.pi, math.pi),
	[23] = vector.new(0, -0.5 * math.pi, math.pi),
}

local utf8_charlen = {}
for i = 1, 191, 1 do
	-- 1 to 127 => jednobajtové znaky
	-- 128 až 191 => nejsou dovoleny jako první bajt (=> vrátit 1 bajt)
	utf8_charlen[i] = 1
end
for i = 192, 223, 1 do
	utf8_charlen[i] = 2
end
for i = 224, 239, 1 do
	utf8_charlen[i] = 3
end
for i = 240, 247, 1 do
	utf8_charlen[i] = 4
end
for i = 248, 255, 1 do
	utf8_charlen[i] = 1 -- neplatné UTF-8
end

local utf8_sort_data_1 = {
  ["\x20"] = "\x20", -- < >
  ["\x21"] = "\x21", -- <!>
  ["\x22"] = "\x22", -- <">
  ["\x23"] = "\x23", -- <#>
  ["\x25"] = "\x24", -- <%>
  ["\x26"] = "\x25", -- <&>
  ["\x27"] = "\x26", -- <'>
  ["\x28"] = "\x27", -- <(>
  ["\x29"] = "\x28", -- <)>
  ["\x2a"] = "\x29", -- <*>
  ["\x2b"] = "\x2a", -- <+>
  ["\x2c"] = "\x2b", -- <,>
  ["\x2d"] = "\x2c", -- <->
  ["\x2e"] = "\x2d", -- <.>
  ["\x2f"] = "\x2e", -- </>
  ["\x3a"] = "\x2f", -- <:>
  ["\x3b"] = "\x30", -- <;>
  ["\x3c"] = "\x31", -- <<>
  ["\x3d"] = "\x32", -- <=>
  ["\x3e"] = "\x33", -- <>>
  ["\x3f"] = "\x34", -- <?>
  ["\x40"] = "\x35", -- <@>
  ["\x5b"] = "\x36", -- <[>
  ["\x5c"] = "\x37", -- <\>
  ["\x5d"] = "\x38", -- <]>
  ["\x5e"] = "\x39", -- <^>
  ["\x5f"] = "\x3a", -- <_>
  ["\x60"] = "\x3b", -- <`>
  ["\x7b"] = "\x3c", -- <{>
  ["\x7c"] = "\x3d", -- <|>
  ["\x7d"] = "\x3e", -- <}>
  ["\x7e"] = "\x3f", -- <~>
  ["\x24"] = "\x40", -- <$>
  ["\x61"] = "\x41", -- <a>
  ["\x41"] = "\x42", -- <A>
  ["\x62"] = "\x47", -- <b>
  ["\x42"] = "\x48", -- <B>
  ["\x64"] = "\x4d", -- <d>
  ["\x44"] = "\x4e", -- <D>
  ["\x65"] = "\x51", -- <e>
  ["\x45"] = "\x52", -- <E>
  ["\x66"] = "\x57", -- <f>
  ["\x46"] = "\x58", -- <F>
  ["\x67"] = "\x59", -- <g>
  ["\x47"] = "\x5a", -- <G>
  ["\x68"] = "\x5b", -- <h>
  ["\x48"] = "\x5c", -- <H>
  ["\x69"] = "\x61", -- <i>
  ["\x49"] = "\x62", -- <I>
  ["\x6a"] = "\x65", -- <j>
  ["\x4a"] = "\x66", -- <J>
  ["\x6b"] = "\x67", -- <k>
  ["\x4b"] = "\x68", -- <K>
  ["\x6c"] = "\x69", -- <l>
  ["\x4c"] = "\x6a", -- <L>
  ["\x6d"] = "\x6f", -- <m>
  ["\x4d"] = "\x70", -- <M>
  ["\x6e"] = "\x71", -- <n>
  ["\x4e"] = "\x72", -- <N>
  ["\x6f"] = "\x75", -- <o>
  ["\x4f"] = "\x76", -- <O>
  ["\x70"] = "\x7b", -- <p>
  ["\x50"] = "\x7c", -- <P>
  ["\x71"] = "\x7d", -- <q>
  ["\x51"] = "\x7e", -- <Q>
  ["\x72"] = "\x7f", -- <r>
  ["\x52"] = "\x80", -- <R>
  ["\x73"] = "\x85", -- <s>
  ["\x53"] = "\x86", -- <S>
  ["\x74"] = "\x89", -- <t>
  ["\x54"] = "\x8a", -- <T>
  ["\x75"] = "\x8d", -- <u>
  ["\x55"] = "\x8e", -- <U>
  ["\x76"] = "\x93", -- <v>
  ["\x56"] = "\x94", -- <V>
  ["\x77"] = "\x95", -- <w>
  ["\x57"] = "\x96", -- <W>
  ["\x78"] = "\x97", -- <x>
  ["\x58"] = "\x98", -- <X>
  ["\x79"] = "\x99", -- <y>
  ["\x59"] = "\x9a", -- <Y>
  ["\x7a"] = "\x9d", -- <z>
  ["\x5a"] = "\x9e", -- <Z>
  ["\x30"] = "\xa1", -- <0>
  ["\x31"] = "\xa2", -- <1>
  ["\x32"] = "\xa3", -- <2>
  ["\x33"] = "\xa4", -- <3>
  ["\x34"] = "\xa5", -- <4>
  ["\x35"] = "\xa6", -- <5>
  ["\x36"] = "\xa7", -- <6>
  ["\x37"] = "\xa8", -- <7>
  ["\x38"] = "\xa9", -- <8>
  ["\x39"] = "\xaa", -- <9>
}

local utf8_sort_data_2 = {
  ["\xc3\xa1"] = "\x43", -- <á>
  ["\xc3\x81"] = "\x44", -- <Á>
  ["\xc3\xa4"] = "\x45", -- <ä>
  ["\xc3\x84"] = "\x46", -- <Ä>
  ["\xc4\x8d"] = "\x4b", -- <č>
  ["\xc4\x8c"] = "\x4c", -- <Č>
  ["\xc4\x8f"] = "\x4f", -- <ď>
  ["\xc4\x8e"] = "\x50", -- <Ď>
  ["\xc3\xa9"] = "\x53", -- <é>
  ["\xc3\x89"] = "\x54", -- <É>
  ["\xc4\x9b"] = "\x55", -- <ě>
  ["\xc4\x9a"] = "\x56", -- <Ě>
  ["\x63\x68"] = "\x5d", -- <ch>
  ["\x63\x48"] = "\x5e", -- <cH>
  ["\x43\x68"] = "\x5f", -- <Ch>
  ["\x43\x48"] = "\x60", -- <CH>
  ["\xc3\xad"] = "\x63", -- <í>
  ["\xc3\x8d"] = "\x64", -- <Í>
  ["\xc4\xba"] = "\x6b", -- <ĺ>
  ["\xc4\xb9"] = "\x6c", -- <Ĺ>
  ["\xc4\xbe"] = "\x6d", -- <ľ>
  ["\xc4\xbd"] = "\x6e", -- <Ľ>
  ["\xc5\x88"] = "\x73", -- <ň>
  ["\xc5\x87"] = "\x74", -- <Ň>
  ["\xc3\xb3"] = "\x77", -- <ó>
  ["\xc3\x93"] = "\x78", -- <Ó>
  ["\xc3\xb4"] = "\x79", -- <ô>
  ["\xc3\x94"] = "\x7a", -- <Ô>
  ["\xc5\x95"] = "\x81", -- <ŕ>
  ["\xc5\x94"] = "\x82", -- <Ŕ>
  ["\xc5\x99"] = "\x83", -- <ř>
  ["\xc5\x98"] = "\x84", -- <Ř>
  ["\xc5\xa1"] = "\x87", -- <š>
  ["\xc5\xa0"] = "\x88", -- <Š>
  ["\xc5\xa5"] = "\x8b", -- <ť>
  ["\xc5\xa4"] = "\x8c", -- <Ť>
  ["\xc3\xba"] = "\x8f", -- <ú>
  ["\xc3\x9a"] = "\x90", -- <Ú>
  ["\xc5\xaf"] = "\x91", -- <ů>
  ["\xc5\xae"] = "\x92", -- <Ů>
  ["\xc3\xbd"] = "\x9b", -- <ý>
  ["\xc3\x9d"] = "\x9c", -- <Ý>
  ["\xc5\xbe"] = "\x9f", -- <ž>
  ["\xc5\xbd"] = "\xa0", -- <Ž>
}

local utf8_sort_data_3 = {
  ["\x63"] = "\x49", -- <c>
  ["\x43"] = "\x4a", -- <C>
}

local dst_dates_03 = {
	[2022] = 26,
	[2023] = 26,
	[2024] = 31,
	[2025] = 30,
	[2026] = 29,
	[2027] = 28,
	[2028] = 26,
}
local dst_dates_10 = {
	[2022] = 30,
	[2023] = 29,
	[2024] = 27,
	[2025] = 26,
	[2026] = 25,
	[2027] = 31,
	[2028] = 29,
}

local nazvy_mesicu = {
	{"leden", "ledna"},
	{"únor", "února"},
	{"březen", "března"},
	{"duben", "dubna"},
	{"květen", "května"},
	{"červen", "června"},
	{"červenec", "července"},
	{"srpen", "srpna"},
	{"září", "září"},
	{"říjen", "října"},
	{"listopad", "listopadu"},
	{"prosinec", "prosince"},
}

local dny_v_tydnu = {
	"pondělí",
	"úterý",
	"středa",
	"čtvrtek",
	"pátek",
	"sobota",
	"neděle",
}

local entity_properties_list = {
	"hp_max",
	"breath_max",
	"zoom_fov",
	"eye_height",
	"physical = false",
	"collide_with_objects",
	"collisionbox",
	"selectionbox",
	"pointable",
	"visual",
	"visual_size",
	"mesh",
	"textures",
	"colors",
	"use_texture_alpha",
	"spritediv",
	"initial_sprite_basepos",
	"is_visible",
	"makes_footstep_sound",
	"automatic_rotate",
	"stepheight",
	"automatic_face_movement_dir",
	"automatic_face_movement_max_rotation_per_sec",
	"backface_culling",
	"glow",
	"nametag",
	"nametag_color",
	"nametag_bgcolor",
	"infotext",
	"static_save",
	"damage_texture_modifier",
	"shaded",
	"show_on_minimap",
}

-- KEŠ
-- ===========================================================================
local utf8_sort_cache = {
}

-- LOKÁLNÍ FUNKCE
-- ===========================================================================


-- VEŘEJNÉ FUNKCE
-- ===========================================================================

--[[
Přidá nástroji opotřebení, pokud „player“ nemá právo usnadnění hry nebo není nil.
]]
function ch_core.add_wear(player, itemstack, wear_to_add)
	local player_name = player and player.get_player_name and player:get_player_name()
	if not player_name or not minetest.is_creative_enabled(player_name) then
		local new_wear = itemstack:get_wear() + wear_to_add
		if new_wear > 65535 then
			itemstack:clear()
		elseif new_wear >= 0 then
			itemstack:set_wear(new_wear)
		else
			itemstack:set_wear(0)
		end
	end
	return itemstack
end

--[[
Určí typ postavy (admin|creative|new|survival) a zkontroluje,
zda je to jeden z akceptovaných.
player_or_player_name může být PlayerRef nebo přihlašovací jméno postavy.
accepted_roles může být buď řetězec nebo seznam řetězců.
]]
function ch_core.check_player_role(player_or_player_name, accepted_roles)
	local role = ch_core.get_player_role(player_or_player_name)
	if role == nil then
		return nil
	end
	if type(accepted_roles) == "string" then
		return role == accepted_roles
	end
	for i, r in ipairs(accepted_roles) do
		if role == r then
			return true
		end
	end
	return false
end

--[[
Smaže recepty jako minetest.clear_craft(), ale s lepším logováním.
]]
function ch_core.clear_crafts(log_prefix, crafts)
	if log_prefix == nil then
		log_prefix = ""
	else
		log_prefix = log_prefix.."/"
	end
	local get_us_time = minetest.get_us_time
	local count = 0
	for k, v in pairs(crafts) do
		-- minetest.log("action", "Will clear craft "..log_prefix..k)
		-- print("CLEAR_CRAFTS("..log_prefix.."): "..dump2(crafts))
		if v.output ~= nil or v.type == "fuel" then
			if minetest.clear_craft(v) then
				count = count + 1
			else
				minetest.log("warning", "Craft "..log_prefix..k.." not cleared! Dump = "..dump2(v))
			end
		else
			local start = get_us_time()
			if minetest.clear_craft(v) then
				count = count + 1
				local stop = get_us_time()
				minetest.log("action", "Craft "..log_prefix..k.." cleared in "..((stop - start) / 1000.0).." ms. Dump = "..dump2(v))
			else
				minetest.log("warning", "Craft "..log_prefix..k.." not cleared! Dump = "..dump2(v))
			end
		end
	end
	return count
end

--[[
Pro zadanou hodnotu facedir vrátí rotační vektor symbolizující rotaci
z výchozího otočení (facedir = 0) do otočení cílového.
]]
function ch_core.facedir_to_rotation(facedir)
	return vector.copy(facedir_to_rotation_data[facedir % 24])
end

--[[
Najde hráčskou postavu nejbližší k dané pozici. Parametr player_name_to_ignore
je volitelný; je-li vyplněn, má obsahovat přihlašovací jméno postavy
k ignorování.

Vrací „player“ a „player:get_pos()“; v případě neúspěchu vrací nil.
]]
local get_connected_players = minetest.get_connected_players
function ch_core.get_nearest_player(pos, player_name_to_ignore)
	local result_player, result_pos, result_distance_2 = 1e+20
	for player_name, player in pairs(get_connected_players()) do
		if player_name ~= player_name_to_ignore then
			local player_pos = player:get_pos()
			local x, y, z = player_pos.x - pos.x, player_pos.y - pos.y, player_pos.z - pos.z
			local distance_2 = x * x + y * y + z * z
			if distance_2 < result_distance_2 then
				result_distance_2 = distance_2
				result_player = player
				result_pos = player_pos
			end
		end
	end
	return result_player, result_pos
end

--[[
Určí podle práv typ postavy (admin|creative|new|survival).
Pokud player_or_player_name není PlayerRef nebo jméno postavy, vrátí nil.
]]
function ch_core.get_player_role(player_or_player_name)
	if player_or_player_name == nil then
		return nil
	end
	local value_type = type(player_or_player_name)
	local player_name
	if value_type == "string" then
		player_name = player_or_player_name
	elseif value_type == "userdata" then
		player_name = player_or_player_name:get_player_name()
		if player_name == nil then
			return nil -- neplatná hodnota
		end
	else
		minetest.log("warning", "ch_core.get_player_role() called with an invalid value type "..value_type.."!")
		return nil
	end
	if player_name == "" then
		return nil -- neplatná hodnota
	end
	local privs = minetest.get_player_privs(player_name)
	if privs.protection_bypass then
		return "admin"
	elseif not privs.ch_registered_player then
		return "new"
	elseif privs.give then
		return "creative"
	else
		return "survival"
	end
end

--[[
Jednoduchá funkce, která vyhodnotí condition jako podmínku
a podle výsledku vrátí buď true_result, nebo false_result.
]]
function ch_core.ifthenelse(condition, true_result, false_result)
	if condition then
		return true_result
	else
		return false_result
	end
end

--[[
	Vytvoří pomocnou strukturu pro položku dropdown[] ve formspecu.
	Pomocná struktura obsahuje položky:
	- function get_index_from_value(value, default_index)
	- function get_value_from_index(index, default_index)
	- table index_to_value // původní předaná tabulka (musí být sekvence)
	- string formspec_list // již odzvláštněný seznam k použití ve formspecu
	- table value_to_index // mapuje text položky na první odpovídající index
]]
function ch_core.make_dropdown(index_to_value)
	local F = minetest.formspec_escape
	local escaped_values = {}
	local value_to_index = {}
	for i, value in ipairs(index_to_value) do
		escaped_values[i] = F(value)
	end
	for i = #index_to_value, 1, -1 do
		value_to_index[index_to_value[i]] = i
	end
	return {
		get_index_from_value = function(value, default_index)
			if value ~= nil then
				return value_to_index[value] or tonumber(default_index)
			else
				return tonumber(default_index)
			end
		end,
		get_value_from_index = function(index, default_index)
			index = tonumber(index)
			print("DEBUG: "..dump2({index = index or "nil", default_index = default_index or "nil", index_to_value = index_to_value[index ~= nil and index_to_value[index] ~= nil] or index_to_value[default_index], index_to_value_array = index_to_value}))
			if index ~= nil and index_to_value[index] ~= nil then
				print("DEBUG: will return index "..index)
				return index_to_value[index]
			else
				print("DEBUG: will return default_index "..(index or "nil").." ("..(index ~= nil and "true" or "false")..", "..(index ~= nil and index_to_value[index] ~= nil and "true" or "false")..")")
				return index_to_value[default_index]
			end
		end,
		index_to_value = index_to_value,
		formspec_list = table.concat(escaped_values, ","),
		value_to_index = value_to_index,
	}
end

--[[
Vytvoří kopii vstupu (input) a zapíše do ní nové hodnoty skupin podle
parametru override. Skupiny s hodnotou 0 v override z tabulky odstraní.
Je-li některý z parametrů nil, je interpretován jako prázdná tabulka.
]]
function ch_core.override_groups(input, override)
	local result
	if input ~= nil then
		result = table.copy(input)
		if override ~= nil then
			for k, v in pairs(override) do
				if v ~= 0 then
					result[k] = v
				else
					result[k] = nil
				end
			end
		end
	elseif override ~= nil then
		result = table.copy(override)
		for k, v in pairs(override) do
			if v == 0 then
				result[k] = nil
			end
		end
	else
		result = {}
	end
	return result
end

--[[
Převede zobrazovací nebo přihlašovací jméno na přihlašovací jméno,
bez ohledu na to, zda takové jméno existuje.
]]
function ch_core.jmeno_na_prihlasovaci(jmeno)
	return ch_core.odstranit_diakritiku(jmeno):gsub(" ", "_")
end

--[[
	Vrátí seznam existujících přihlašovacích jmén odpovídajících uvedenému
	jménu až na velikost písmen a diakritiku. Seznam může být i prázdný.
]]
function ch_core.jmeno_na_existujici_prihlasovaci(jmeno)
	local result = {}
	jmeno = string.lower(ch_core.odstranit_diakritiku(jmeno))
	for k, _ in pairs(ch_core.offline_charinfo) do
		if string.lower(k) == jmeno then
			table.insert(result, k)
		end
	end
	return result
end

--[[
Převede všechna písmena v řetězci na malá, funguje i na písmena s diakritikou.
]]
function ch_core.na_mala_pismena(s)
	local l = #s
	local i = 1
	local res = ""
	local c
	while i <= l do
		c = diakritika_na_mala[s:sub(i, i + 1)]
		if c then
			res = res .. c
			i = i + 2
		else
			res = res .. s:sub(i, i)
			i = i + 1
		end
	end
	return string.lower(res)
end

--[[
Vrátí počet bloků uvnitř oblasti vymezené dvěma krajními body (na pořadí nezáleží).
Výsledkem je vždy kladné celé číslo.
]]
function ch_core.objem_oblasti(pos1, pos2)
	return math.ceil(math.abs(pos1.x - pos2.x) + 1) * math.ceil(math.abs(pos1.y - pos2.y) + 1) * math.ceil(math.abs(pos1.z - pos2.z) + 1)
end

--[[
Všechna písmena s diakritikou převede na odpovídající písmena bez diakritiky.
Ostatní znaky ponechá.
]]
function ch_core.odstranit_diakritiku(s)
	local l = #s
	local i = 1
	local res = ""
	local c
	while i <= l do
		c = diakritika[s:sub(i, i + 1)]
		if c then
			res = res .. c
			i = i + 2
		else
			res = res .. s:sub(i, i)
			i = i + 1
		end
	end
	return res
end

--[[
Otestuje, zda pozice „pos“ leží uvnitř oblasti vymezené v_min a v_max.
]]
function ch_core.pos_in_area(pos, v_min, v_max)
	return v_min.x <= pos.x and pos.x <= v_max.x and
			v_min.y <= pos.y and pos.y <= v_max.y and
			v_min.z <= pos.z and pos.z <= v_max.z
end

--[[
vrátí dva vektory: první s minimálními souřadnicemi a druhý s maximálními,
obojí zaokrouhlené na celočíselné souřadnice
]]
function ch_core.positions_to_area(v1, v2)
	local x1, x2, y1, y2, z1, z2

	if v1.x <= v2.x then
		x1 = v1.x
		x2 = v2.x
	else
		x1 = v2.x
		x2 = v1.x
	end

	if v1.y <= v2.y then
		y1 = v1.y
		y2 = v2.y
	else
		y1 = v2.y
		y2 = v1.y
	end

	if v1.z <= v2.z then
		z1 = v1.z
		z2 = v2.z
	else
		z1 = v2.z
		z2 = v1.z
	end

	return vector.round(vector.new(x1, y1, z1)), vector.round(vector.new(x2, y2, z2))
end

--[[
Pokud dané přihlašovací jméno existuje, převede ho na jméno bez barev (výchozí)
nebo s barvami. Pro neexistující jména vrací zadaný řetězec.
]]
function ch_core.prihlasovaci_na_zobrazovaci(prihlasovaci, s_barvami)
	if not prihlasovaci then
		error("ch_core.prihlasovaci_na_zobrazovaci() called with bad arguments!")
	end
	if minetest.player_exists(prihlasovaci) then
		local offline_info = ch_core.get_offline_charinfo(prihlasovaci)
		local jmeno = offline_info.jmeno
		if jmeno then
			if s_barvami and offline_info.barevne_jmeno then
				return offline_info.barevne_jmeno
			end
			return jmeno
		end
	end
	return prihlasovaci
end

--[[
Zaregistruje bloky, které mají něco společného.
]]
function ch_core.register_nodes(common_def, nodes, crafts)
	if type(common_def) ~= "table" then
		error("common_def must be a table!")
	end
	if type(nodes) ~= "table" then
		error("nodes must be a table!")
	end
	if crafts ~= nil and type(crafts) ~= "table" then
		error("crafts must be a table or nil!")
	end

	for node_name, node_def in pairs(nodes) do
		local def = table.copy(common_def)
		for k, v in pairs(node_def) do
			def[k] = v
		end
		minetest.register_node(node_name, def)
	end

	if crafts ~= nil then
		for _, def in ipairs(crafts) do
			minetest.register_craft(def)
		end
	end
end

--[[
Otočí axis-aligned bounding box o zadané otočení. Nejde-li o pravoúhlé
otočení, výsledný kvádr bude větší. <zatím nezkoušeno>
]]
function ch_core.rotate_aabb(aabb, r)
	local points = {}
	for _, x in ipairs({r[1], r[4]}) do
		for _, y in ipairs({r[2], r[5]}) do
			for _, z in ipairs({r[3], r[6]}) do
				table.insert(points, vector.rotate(vector.new(x, y, z), r))
			end
		end
	end
	local p = points[1]
	local result = {p.x, p.y, p.z, p.x, p.y, p.z}
	for i = 2, 8 do
		p = points[i]
		if p.x < result[1] then
			result[1] = p.x
		elseif p.x > result[4] then
			result[4] = p.x
		end
		if p.y < result[2] then
			result[2] = p.y
		elseif p.y > result[5] then
			result[5] = p.y
		end
		if p.z < result[3] then
			result[3] = p.z
		elseif p.z > result[6] then
			result[6] = p.z
		end
	end
	return result
end

--[[
Nastaví dané postavě status „immortal“. Používá se pro postavy s právem
usnadnění hry.
]]
function ch_core.set_immortal(player, true_or_false)
	if true_or_false then
		local properties = player:get_properties()
		player:set_armor_groups({immortal = 1})
		player:set_hp(properties.hp_max)
		player:set_breath(properties.breath_max)
	else
		player:set_armor_groups({immortal = 0})
	end
	return true
end

--[[
Přesune klíče definující vlastnosti entity do podtabulky
initial_properties.
]]
function ch_core.upgrade_entity_properties(entity_def, options)
	if options == nil then
		options = {}
	end
	local base_properties = options.base_properties -- základ pro doplnění zcela chybějících vlastností
	local in_place = options.in_place ~= false -- provádět změny v původní tabulce initial_properties, je-li dostupná; výchozí: true
	local keep_fields = options.keep_fields == true -- ponechat původní pole v původní tabulce; výchozí: false

	local initial_properties
	if entity_def.initial_properties == nil then
		initial_properties = {}
	elseif in_place then
		initial_properties = entity_def.initial_properties
	else
		initial_properties = table.copy(entity_def.initial_properties)
	end
	for _, k in ipairs(entity_properties_list) do
		if entity_def[k] ~= nil then
			if initial_properties[k] == nil then
				initial_properties[k] = entity_def[k]
			end
			if not keep_fields then
				entity_def[k] = nil
			end
		end
	end
	if base_properties ~= nil then
		for k, v in pairs(base_properties) do
			if initial_properties[k] == nil then
				initial_properties[k] = v
			end
		end
	end
	entity_def.initial_properties = initial_properties
	return entity_def
end

--[[
Vrátí počet UTF-8 znaků řetězce.
]]
function ch_core.utf8_length(s)
	if s == "" then
		return 0
	end
	local i, byte, bytes, chars
	i = 1
	chars = 0
	bytes = string.len(s)
	while i <= bytes do
		byte = string.byte(s, i)
		if byte < 192 then
			i = i + 1
		else
			i = i + utf8_charlen[byte]
		end
		chars = chars + 1
	end
	return chars
end

--[[
Začne v řetězci `s` na fyzickém indexu `i` a bude se posouvat o `seek`
UTF-8 znaků doprava (pro záporný počet doleva); vrátí výsledný index
(na první bajt znaku), nebo nil, pokud posun přesáhl začátek,
resp. konec řetězce.
]]
function ch_core.utf8_seek(s, i, seek)
	local bytes = string.len(s)
	if i < 1 or i > bytes then
		return nil
	end
	local b
	if seek > 0 then
		while true do
			b = string.byte(s, i)
			if b < 192 then
				i = i + 1
			else
				i = i + utf8_charlen[b]
			end
			if i > bytes then
				return nil
			end
			seek = seek - 1
			if seek == 0 then
				return i
			end
		end
	elseif seek < 0 then
		while true do
			i = i - 1
			if i < 1 then
				return nil
			end
			b = string.byte(s, i)
			if b < 128 or b >= 192 then
				-- máme další znak
				seek = seek + 1
				if seek == 0 then
					return i
				end
			end
		end
	else
		return i
	end
end

--[[
	Je-li řetězec s delší než max_chars znaků, vrátí jeho prvních max_chars znaků
	+ "...", jinak vrátí původní řetězec.
]]
function ch_core.utf8_truncate_right(s, max_chars, dots_string)
	local i = ch_core.utf8_seek(s, 1, max_chars)
	if i then
		return s:sub(1, i - 1) .. (dots_string or "...")
	else
		return s
	end
end

--[[
Rozdělí řetězec na pole neprázdných podřetězců o stanovené maximální délce
v UTF-8 znacích; v každé části vynechává mezery na začátku a na konci části;
přednostně dělí v místech mezer. Pro prázdný řetězec
(nebo řetězec tvořený jen mezerami) vrací prázdné pole.
]]
function ch_core.utf8_wrap(s, max_chars, options)
	local i = 1 		-- index do vstupního řetězce s
	local s_bytes = string.len(s)
	local result = {}	-- výstupní pole
	local r_text = ""	-- výstupní řetězec
	local r_chars = 0	-- počet UTF-8 znaků v řetězci r
	local r_sp_begin	-- index první mezery v poslední sekvenci mezer v r_text
	local r_sp_end		-- index poslední mezery v poslední sekvenci mezer v r_text
	local b				-- kód prvního bajtu aktuálního znaku
	local c_bytes		-- počet bajtů aktuálního znaku

	-- options
	local allow_empty_lines, max_result_lines, line_separator
	if options then
		allow_empty_lines = options.allow_empty_lines -- true or false
		max_result_lines = options.max_result_lines -- nil or number
		line_separator = options.line_separator -- nil or string
	end

	while i <= s_bytes do
		b = string.byte(s, i)
		-- print("byte["..i.."] = "..b.." ("..s:sub(i, i)..") r_sp = ("..(r_sp_begin or "nil")..".."..(r_sp_end or "nil")..")")
		if r_chars > 0 or (b ~= 32 and (b ~= 10 or allow_empty_lines)) then -- na začátku řádky ignorovat mezery
			if b < 192 then
				c_bytes = 1
			else
				c_bytes = utf8_charlen[b]
			end
			-- vložit do r další znak (není-li to konec řádky)
			if b ~= 10 then
				r_text = r_text..s:sub(i, i + c_bytes - 1)
				r_chars = r_chars + 1

				if b == 32 then
					-- znak je mezera
					if r_sp_begin then
						if r_sp_end then
							-- začátek nové skupiny mezer (už nějaká byla)
							r_sp_begin = string.len(r_text)
							r_sp_end = nil
						end
					elseif not r_sp_end then
						-- začátek první skupiny mezer (ještě žádná nebyla)
						r_sp_begin = string.len(r_text)
					end
				else
					-- znak není mezera ani konec řádky
					if r_sp_begin and not r_sp_end then
						r_sp_end = string.len(r_text) - c_bytes -- uzavřít skupinu mezer
					end
				end
			end

			if r_chars >= max_chars or b == 10 then
				-- dosažen maximální počet znaků nebo znak \n => uzavřít řádku
				if line_separator and #result > 0 then
					result[#result] = result[#result]..line_separator
				end
				if r_chars < max_chars or not r_sp_begin then
					-- žádné mezery => tvrdé dělení
					table.insert(result, r_text)
					-- print("DEBUG: emit B ["..#result.."] <"..result[#result]..">")
					r_text = ""
					r_chars = 0
					r_sp_begin, r_sp_end = nil, nil
				elseif not r_sp_end then
					-- průběžná skupina mezer => rozdělit zde
					table.insert(result, r_text:sub(1, r_sp_begin - 1))
					-- print("DEBUG: emit C ["..#result.."] <"..result[#result]..">")
					r_text = ""
					r_chars = 0
					r_sp_begin, r_sp_end = nil, nil
				else
					-- byla skupina mezer => rozdělit tam
					table.insert(result, r_text:sub(1, r_sp_begin - 1))
					-- print("DEBUG: emit D ["..#result.."] <"..result[#result]..">")
					r_text = r_text:sub(r_sp_end + 1, -1)
					r_chars = ch_core.utf8_length(r_text)
					r_sp_begin, r_sp_end = nil, nil
					if r_chars > 0 and b == 10 then
						i = i - c_bytes -- read this \n-byte again
					end
				end
				if max_result_lines and #result >= max_result_lines then
					return result -- skip reading other lines
				end
			end
			i = i + c_bytes
		else
			i = i + 1
		end
	end
	if r_chars > 0 then
		if line_separator and #result > 0 then
			result[#result] = result[#result]..line_separator
		end
		if r_sp_begin and not r_sp_end then
			-- průběžná skupina mezer
			table.insert(result, r_text:sub(1, r_sp_begin - 1))
			-- print("DEBUG: emit E ["..#result.."] <"..result[#result]..">")
		else
			table.insert(result, r_text)
			-- print("DEBUG: emit F ["..#result.."] <"..result[#result]..">")
		end
	end
	return result
end

function ch_core.utf8_radici_klic(s, store_to_cache)
	local result = utf8_sort_cache[s]
	if not result then
		local i = 1
		local l = s:len()
		local c, k
		result = {}
		while i <= l do
			c = s:sub(i, i)
			k = utf8_sort_data_1[c]
			if k then
				table.insert(result, k)
				i = i + 1
			else
				k = utf8_sort_data_2[s:sub(i, i + 1)]
				if k then
					table.insert(result, k)
					i = i + 2
				else
					k = utf8_sort_data_3[c]
					table.insert(result, k or c)
					i = i + 1
					--[[ if not k then
						print("Nenalezen klíč pro znak '"..c.."'")
					end -- ]]
				end
			end
		end
		result = table.concat(result)
		if store_to_cache then
			utf8_sort_cache[s] = result
		end
	end
	return result
end

function ch_core.utf8_mensi_nez(a, b, store_to_cache)
	a = ch_core.utf8_radici_klic(a, store_to_cache)
	b = ch_core.utf8_radici_klic(b, store_to_cache)
	return a < b
end

--[[
	Smaže obsah zadaného inventáře a zaznamená to jako příkaz daného
	hráče/ky.
	player_name -- přihlašovací jméno hráče/ky
	inv -- odkaz na inventář
	listname -- listname ke smazání
	description -- heslovitý popis kontextu mazání
]]
function ch_core.vyhodit_inventar(player_name, inv, listname, description)
	if not player_name then
		player_name = "???"
	end
	if not description then
		description = "???"
	end
	local t = inv:get_list(listname)
	if t == nil then
		return false
	end
	local items = {}
	for i, stack in ipairs(t) do
		if not stack:is_empty() then
			table.insert(items, stack:to_string():sub(1, 1024))
		end
	end
	if #items > 0 then
		minetest.log("action", "Player "..player_name.." trashed "..#items.." items ("..description.."): "..table.concat(items, ", "))
		inv:set_list(listname, {})
		local trash_sound
		if #items == 1 then
			trash_sound = ch_core.trash_one_sound
		else
			trash_sound = ch_core.trash_all_sound
		end
		if trash_sound ~= nil and trash_sound ~= "" then
			minetest.sound_play(trash_sound, { to_player = player_name, gain = 1.0 })
		else
			minetest.chat_send_all("Will not play the sound, because: "..dump2({trash_one_sound = ch_core.trash_one_sound, trash_all_sound = ch_core.trash_all_sound, trash_sound = trash_sound or "nil"}))
		end
	end
	return true
end

function ch_core.vyhodit_predmet(player_name, stack, description)
	if not player_name then
		player_name = "???"
	end
	if not description then
		description = "???"
	end
	if stack == nil or stack:is_empty() then
		return false
	end
	minetest.log("action", "Player "..player_name.." trashed an item ("..description.."): "..stack:to_string():sub(1, 1024))
	local trash_sound = ch_core.trash_one_sound
	if trash_sound ~= nil and trash_sound ~= "" then
		minetest.sound_play(trash_sound, { to_player = player_name, gain = 1.0 })
	else
		minetest.chat_send_all("Will not play the sound, because: "..dump2({trash_one_sound = ch_core.trash_one_sound, trash_all_sound = ch_core.trash_all_sound, trash_sound = trash_sound or "nil"}))
	end
	return true
end

function ch_core.aktualni_cas()
	local posun = ch_core.global_data.posun_casu
	local tm = os.time() + posun
	local t = os.date("!*t", tm)
	local dst

	if t.month == 3 then
		local dst_date = dst_dates_03[t.year]
		if dst_date ~= nil then
			dst = t.day > dst_date or (t.day == dst_date and t.hour > 0)
		end
	elseif t.month == 10 then
		local dst_date = dst_dates_10[t.year]
		if dst_date ~= nil then
			dst = t.day < dst_date or (t.day == dst_date and t.hour <= 0)
		end
	else
		dst = 3 < t.month and t.month < 10
	end
	local time_offset_hours
	if dst then
		time_offset_hours = 2
	else
		time_offset_hours = 1
	end
	tm = tm + 3600 * time_offset_hours
	local lt = os.date("!*t", tm)

	local den_v_tydnu_cislo = lt.wday - 1
	if den_v_tydnu_cislo == 0 then
		den_v_tydnu_cislo = 7
	end

	return {
		rok = lt.year,
		mesic = lt.month,
		nazev_mesice_1 = nazvy_mesicu[lt.month][1],
		nazev_mesice_2 = nazvy_mesicu[lt.month][2],
		den = lt.day,
		hodina = lt.hour,
		minuta = lt.min,
		sekunda = lt.sec,
		je_letni_cas = dst,
		den_v_tydnu_cislo = den_v_tydnu_cislo,
		den_v_tydnu_nazev = dny_v_tydnu[den_v_tydnu_cislo],
		den_v_roce = lt.yday,
		utc_rok = t.year,
		utc_mesic = t.month,
		utc_den = t.day,
		utc_hodina = t.hour,
		utc_minuta = t.min,
		utc_sekunda = t.sec,
		posun_cislo = time_offset_hours,
		posun_text = "+0"..time_offset_hours..":00",
	}
end

-- KÓD INICIALIZACE
-- ===========================================================================
local dbg_table = ch_core.storage:to_table()
if not dbg_table then
	print("STORAGE: nil")
else
	for key, value in pairs(dbg_table.fields) do
		print("STORAGE: <"..key..">=<"..value..">")
	end
end

doors.login_to_viewname = ch_core.prihlasovaci_na_zobrazovaci

-- PŘÍKAZY
-- ===========================================================================
local function cmp_oci(a, b)
	return (ch_core.offline_charinfo[a].last_login or -1) < (ch_core.offline_charinfo[b].last_login or -1)
end

def = {
	description = "Vypíše seznam postav seřazený podle času posledního přihlášení.",
	privs = {server = true},
	func = function(player_name, param)
		local players = {}
		local shifted_now = os.time() - 946684800

		for other_player_name, _ in pairs(ch_core.offline_charinfo) do
			table.insert(players, other_player_name)
		end
		table.sort(players, cmp_oci)
		local result = {}
		for i, other_player_name in ipairs(players) do
			local s = "- "..other_player_name
			local offline_charinfo = ch_core.offline_charinfo[other_player_name]
			local s2 = offline_charinfo.last_login
			if s2 == 0 then
				s2 = "???"
			else
				s2 = math.floor((shifted_now - s2) / 86400)
			end
			s2 = " (posl. přihl. před "..s2.." dny, odehráno "..(math.round(offline_charinfo.past_playtime / 36) / 100).." hodin, z toho "..(math.round(offline_charinfo.past_ap_playtime / 36) / 100).." aktivně)"
			if ch_core.online_charinfo[other_player_name] then
				s2 = s2.." <je ve hře>"
			end
			if (offline_charinfo.pending_registration_type or "") ~= "" then
				s2 = s2.." <plánována registrace: "..(offline_charinfo.pending_registration_type or "")..">"
			end
			result[i] = "- "..other_player_name..s2
		end

		result = table.concat(result, "\n")
		minetest.log("warning", result)
		minetest.chat_send_player(player_name, result)
		return true
	end,
}

minetest.register_chatcommand("postavynauklid", def)
minetest.register_chatcommand("postavynaúklid", def)

ch_core.close_submod("lib")
