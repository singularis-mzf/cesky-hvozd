ch_core.open_submod("lib", {data = true})

-- DATA
-- ===========================================================================
local click_sound = {
	name = "click",
	gain = 0.05,
}
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

local diakritika_na_velka = {
	["á"] = "Á",
	["ä"] = "Ä",
	["č"] = "Č",
	["ď"] = "Ď",
	["é"] = "É",
	["Ě"] = "Ě",
	["Í"] = "Í",
	["ĺ"] = "Ĺ",
	["ľ"] = "Ľ",
	["ň"] = "Ň",
	["ó"] = "Ó",
	["ô"] = "Ô",
	["ŕ"] = "Ŕ",
	["ř"] = "Ř",
	["š"] = "Š",
	["ť"] = "Ť",
	["ú"] = "Ú",
	["ů"] = "Ů",
	["ý"] = "Ý",
	["ž"] = "Ž",
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

local hypertext_escape_replacements = {
	["\\"] = "\\\\\\\\",
	["<"] = "\\\\<",
	[">"] = "\\\\>",
	[";"] = "\\;",
	[","] = "\\,",
	["["] = "\\[",
	["]"] = "\\]",
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

local player_role_to_image = {
	admin = "ch_core_koruna.png",
	creative = "ch_core_kouzhul.png",
	new = "ch_core_slunce.png",
	none = "ch_core_empty.png",
	survival = "ch_core_kladivo.png",
}


-- KEŠ
-- ===========================================================================
local utf8_sort_cache = {
}

local lc_to_player_name = ch_core.lc_to_player_name

-- LOKÁLNÍ FUNKCE
-- ===========================================================================
local function cmp_oci(a, b)
	return (ch_data.offline_charinfo[a].last_login or -1) < (ch_data.offline_charinfo[b].last_login or -1)
end

local function get_player_role_by_privs(privs)
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
	Sestaví nové pole "groups" následujícím způsobem:
	Vezme dvojice z "base"; přepíše je dvojicemi z "inherit" (případně pouze dvojicemi vybranými pomocí "inherit_list")
	a nakonec výsledek přepíše dvojicemi z "override". Přitom dodržuje, že pokud nějaké dvojici vyjde hodnota 0,
	tato dvojice se na výstupu vůbec neobjeví. Kterýkoliv parametr může být nil; u parametrů base, inherit a override
	se to interpretuje jako prázdná tabulka. Je-li inherit_list == nil, pak se z "inherit" vezmou všechny dvojice.

	base = table or nil, -- základ, ze kterého se vychází (dvojice s nejnižší prioritou)
	override = table or nil, -- dvojice s nejvyšší prioritou (přepíšou vše ostatní)
	inherit = table or nil, -- přidat/přepsat tyto hodnoty do base
	inherit_list = {string, ...} or nil -- je-li nastaveno, pak se z inherit budou brát pouze klíče z tohoto seznamu a v uvedeném pořadí, jinak všechny klíče
]]
function ch_core.assembly_groups(default, override, inherit, inherit_list)
	local result = {}
	if default ~= nil then
		for k, v in pairs(default) do
			if v ~= 0 then
				result[k] = v
				-- result je prázdný, takže zde není třeba nastavovat nil
			end
		end
	end
	if inherit ~= nil then
		if inherit_list ~= nil then
			for _, group in ipairs(inherit_list) do
				local value = inherit[group]
				if value ~= nil then
					if value ~= 0 then
						result[group] = value
					else
						result[group] = nil
					end
				end
			end
		else
			for group, value in pairs(inherit) do
				if value ~= 0 then
					result[group] = value
				else
					result[group] = nil
				end
			end
		end
	end
	if override ~= nil then
		for group, value in pairs(override) do
			if value ~= 0 then
				result[group] = value
			else
				result[group] = nil
			end
		end
	end
	return result
end

--[[
Ověří, že předaný argument je funkce a zavolá ji s ostatními zadanými argumenty.
Vrátí její výsledek. Není-li předaný argument funkce, nevrátí nic.
]]
function ch_core.call(f, ...)
	if type(f) == "function" then
		return f(...)
	end
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
	for _, r in ipairs(accepted_roles) do
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
Jako vstup přijímá pole dávek (např. z funkce InvRef:get_list())
a vrátí počet prázdných dávek v něm (může být 0).
]]
function ch_core.count_empty_stacks(stacks)
	local count = 0
	for _, stack in ipairs(stacks) do
		if stack:is_empty() then
			count = count + 1
		end
	end
	return count
end

--[[
Serializuje pole dávek do řetězce.
Vrací tabulku:
{
	success = bool, -- true v případě úspěchu, false v případě selhání

	-- v případě úspěchu:
	result = string, -- výsledný řetězec (pro prázdný inventář je to prázdný řetězec)
	lengths = {int, ...}, -- délky itemstringů jednotlivých stacků
	orig_result_length = int, -- délka výsledného řetězce před kompresí

	-- v případě selhání:
	reason = "single_stack_limit" or "disallow_nested", -- typ selhání
	overlimit_index = int or nil, -- v případě selhání "single_stack_limit" index dávky, která překročila limit
	overlimit_length = int or nil, -- v případě selhání "single_stack_limit" délku řetězce vráceného to_string()
	nested_index = int or nil, -- v případě selhání "disallow_nested" index (první) dávky, která obsahuje vnořený inventář
}
]]
function ch_core.serialize_stacklist(stacks, single_stack_limit, disallow_nested)
	if single_stack_limit == nil then
		single_stack_limit = 65535
	end
	local data = {}
	local lengths = {}
	for i, stack in ipairs(stacks) do
		if stack:is_empty(stack) then
			data[i] = ""
			lengths[i] = 0
		else
			if disallow_nested then
				-- does not contain a nested inventory?
				local itemdef = minetest.registered_items[stack:get_name()]
				if itemdef ~= nil and itemdef._ch_nested_inventory_meta ~= nil and stack:get_meta():get_string(itemdef._ch_nested_inventory_meta) ~= "" then
					minetest.log("action", "Stacklist not serialized because of a nested inventory in "..stack:get_name()..".")
					return {
						success = false,
						reason = "disallow_nested",
						nested_index = i,
					}
				end
			end
			local s = stack:to_string()
			if #s > single_stack_limit then
				minetest.log("action", "Stacklist not serialized because of a single stack limit: "..#s.." > "..single_stack_limit..".")
				return {
					success = false,
					reason = "single_stack_limit",
					overlimit_index = i,
					overlimit_length = #s,
				}
			end
			data[i] = s
			lengths[i] = #s
		end
	end
	local orig_str = minetest.serialize(data)
	local str = minetest.encode_base64(minetest.compress(orig_str, "deflate"))
	minetest.log("action", "Stacklist serialized, resulting length = "..#str..".")
	return {
		success = true,
		result = str,
		lengths = lengths,
		orig_result_length = #orig_str,
	}
end

--[[
Deserializuje řetězec serializovaný pomocí funkce ch_core.serialize_stacklist().
V případě neúspěchu vrátí nil.
]]
function ch_core.deserialize_stacklist(str)
	local result = minetest.deserialize(minetest.decompress(minetest.decode_base64(str), "deflate"))
	if result ~= nil then
		for i = 1, #result do
			result[i] = ItemStack(result[i])
		end
	end
	return result
end

--[[
Spočítá a / b a vrátí celočíselný výsledek a zbytek.
]]
function ch_core.divrem(a, b)
	local div = math.floor(a / b)
	local rem = a % b
	return div, rem
end

--[[
	Vrátí funkci, která přijme jako první parametr název souboru (či cestu) a pokusí
	se ho načíst a spustit jako funkci Lua a vrátit výsledky.
	args = table || nil, -- pole parametrů, které mají být předávány volanému souboru,
							pokud nejsou žádné parametry specifikovány v rámci volání; žádný z parametrů nesmí být nil!
	options = nil || {
		path = string || bool || nil,
			-- je-li nil nebo true, funkce se pokusí první parametr doplnit o cestu módu, který byl načítán v momentě její konstrukce
			-- je-li false, funkce se pokusí použít cestu tak, jak je
			-- je-li string, daný řetězec se připojí před zadaný parametr a oddělí "/"
		nofail = bool || nil, -- je-li true, funkce bude tiše ignorovat selhání při načítání souboru
	}
]]
function ch_core.compile_dofile(args, options)
	if args == nil then args = {} end
	if options == nil then options = {} end
	local modname = minetest.get_current_modname()
	local modpath = modname and minetest.get_modpath(modname)
	local result = function(name, ...)
		local filepath
		assert(name)
		if options.path == nil or options.path == true then
			if modpath == nil then
				error("no mod is loading now!")
			end
			filepath = modpath.."/"..name
		elseif options.path == false then
			filepath = name
		else
			filepath = options.path.."/"..name
		end
		local largs = {...}
		if #largs == 0 then
			largs = args
		end
		local f, errmsg = loadfile(filepath)
		if f ~= nil then
			return f(unpack(largs))
		elseif options.nofail == true then
			return
		else
			error("dofile("..filepath..") failed!: "..(errmsg or "nil"))
		end
	end
	return result
end

function ch_core.extend_player_inventory(player_name, extend)
	local offline_charinfo = ch_data.offline_charinfo[player_name]
	if offline_charinfo == nil then
		minetest.log("error", "ch_core.extend_player_inventory() called on player "..player_name.." that has no offline_charinfo!")
		return false
	end
	local player = minetest.get_player_by_name(player_name)
	local target_size
	if extend then
		-- extend the inventory
		target_size = ch_core.inventory_size.extended
		if player ~= nil then
			local inv = player:get_inventory()
			local inv_size = inv:get_size("main")
			if inv_size < target_size then
				inv:set_size("main", target_size)
				minetest.log("action", "Player inventory "..player_name.."/main was extended from "..inv_size.." slots to "..target_size..".")
			end
		end
		if offline_charinfo.extended_inventory ~= 1 then
			offline_charinfo.extended_inventory = 1
			ch_data.save_offline_charinfo(player_name)
		end

	elseif not extend and offline_charinfo.extended_inventory == 1 then
		-- shrink the inventory
		target_size = ch_core.inventory_size.normal
		if player ~= nil then
			local inv = player:get_inventory()
			local inv_size = inv:get_size("main")
			if inv_size < target_size then
				inv:set_size("main", target_size)
				minetest.log("action", "Player inventory "..player_name.."/main was extended from "..inv_size.." slots to "..target_size..".")
			elseif inv_size > target_size then
				local current_items = inv:get_list("main")
				local overflown_stacks = {}
				inv:set_size("main", target_size)
				for i = target_size + 1, inv_size do
					local stack = current_items[i]
					if not stack:is_empty() then
						stack = inv:add_item("main", stack)
						if not stack:is_empty() then
							table.insert(overflown_stacks, stack)
						end
					end
				end
				minetest.log("action", "Player inventory "..player_name.."/main was shrinked from "..inv_size.." slots to "..target_size..". "..#overflown_stacks.." overflown stacks.")
				if #overflown_stacks > 0 then
					local player_pos = assert(player:get_pos())
					for _, stack in ipairs(overflown_stacks) do
						if core.add_item(player_pos, stack) == nil then
							minetest.log("error", "Spawning overflown item "..stack:to_string().." failed! The item is lost.")
						end
					end
				end
			end
		end
		if offline_charinfo.extended_inventory == 1 then
			offline_charinfo.extended_inventory = 0
			ch_data.save_offline_charinfo(player_name)
		end
	else
		-- no change
		return
	end
end

--[[
Pro zadanou hodnotu facedir vrátí rotační vektor symbolizující rotaci
z výchozího otočení (facedir = 0) do otočení cílového.
]]
function ch_core.facedir_to_rotation(facedir)
	return vector.copy(facedir_to_rotation_data[facedir % 24])
end

--[[
V zadaném textu odzvláštní všechny znaky, které mají speciální význam
uvnitř prvku hypetext[] ve formspecu. Tato funkce již v sobě zahrnuje
funkci minetest.formspec_escape, takže její obsah by už měl být doslovně
vložen do formspecu bez dalšího zpracování.
]]
function ch_core.formspec_hypertext_escape(text)
	local result = string.gsub(text, "[][><\\,;]", hypertext_escape_replacements)
	return result
end

--[[
Vrátí seznam všech známých hráčských postav (včetně těch, které nejsou ve hře).
Ke každé postavě vrátí strukturu {prihlasovaci, zobrazovací}.
Seznam je seřazený podle zobrazovacího jména postavy.
-- as_map - je-li true, vrátí seznam (neseřazený) jako mapu z přihlašovacího jména postavy
-- include_privs - je-li true, každý záznam bude navíc obsahovat položky 'role' a 'privs';
   tuto variantu nelze volat z inicializačního kódu
]]
function ch_core.get_all_players(as_map, include_privs)
	if include_privs and not minetest.get_gametime() then
		error("ch_core.get_all_players(): include_privs == true is allowed only when the game is running!")
	end
	local list, map = {}, {}
	for prihlasovaci, _ in pairs(ch_data.offline_charinfo) do
		local exists = (not include_privs) or minetest.player_exists(prihlasovaci)
		if exists then
			local record = {
				prihlasovaci = prihlasovaci,
				zobrazovaci = ch_core.prihlasovaci_na_zobrazovaci(prihlasovaci),
			}
			if include_privs then
				record.privs = minetest.get_player_privs(prihlasovaci)
				record.role = get_player_role_by_privs(record.privs)
			end
			table.insert(list, record)
			map[prihlasovaci] = record
		end
	end
	if as_map then
		return map
	end
	table.sort(list, function(a, b)
		return ch_core.utf8_mensi_nez(a.zobrazovaci, b.zobrazovaci, true)
	end)
	return list
end

--[[
Vrátí seznam všech/jen registrovaných postav, seřazený podle času posledního přihlášení,
od nejčerstvějšího po nejstarší.

registered_only - je-li true, počítá pouze registrované postavy
name_to_skip - je-li nastaveno, postava s daným přihl. jménem se nepočítá

Výsledkem je seznam struktur ve formátu:
	{
		player_name = STRING, -- přihl. jméno postavy
		last_login_before = INT, -- před kolika (kalendářními) dny se postava přihlásila; -1, není-li k dispozici
		played_hours_total = FLOAT, -- hodiny ve hře
		played_hours_actively = FLOAT, -- aktivně odehrané hodiny ve hře
		is_in_game = BOOL, -- je postava aktuálně ve hře?
		pending_registration_type = STRING or nil,
		is_registered = BOOL,
	}
]]
function ch_core.get_last_logins(registered_only, names_to_skip)
	local new_players = {} -- new players
	local reg_players = {} -- registered players
	local shifted_eod = os.time() - 946684800 -- EOD = end of day
	shifted_eod = shifted_eod + 86400 - (shifted_eod % 86400)

	if names_to_skip == nil then
		names_to_skip = {}
	elseif type(names_to_skip) == "string" then
		names_to_skip = {[names_to_skip] = true}
	elseif type(names_to_skip) ~= "table" then
		error("names_to_skip: invalid type of argument!")
	end

	for other_player_name, _ in pairs(ch_data.offline_charinfo) do
		if not names_to_skip[other_player_name] then
			if minetest.check_player_privs(other_player_name, "ch_registered_player") then
				table.insert(reg_players, other_player_name)
			elseif not registered_only then
				table.insert(new_players, other_player_name)
			end
		end
	end
	if registered_only then
		new_players = reg_players
		table.sort(new_players, cmp_oci)
	else
		table.sort(new_players, cmp_oci)
		table.sort(reg_players, cmp_oci)
		table.insert_all(new_players, reg_players)
	end
	local result = {}
	for i = #new_players, 1, -1 do
		local other_player_name = new_players[i]
		local offline_charinfo = ch_data.offline_charinfo[other_player_name]
		local info = {
			player_name = other_player_name
		}
		local last_login = offline_charinfo.last_login
		if last_login == 0 then
			info.last_login_before = -1
		else
			info.last_login_before = math.floor((shifted_eod - last_login) / 86400)
		end
		info.played_hours_total = math.round(offline_charinfo.past_playtime / 36) / 100
		info.played_hours_actively = math.round(offline_charinfo.past_ap_playtime / 36) / 100
		info.is_in_game = ch_data.online_charinfo[other_player_name] ~= nil
		if (offline_charinfo.pending_registration_type or "") ~= "" then
			info.pending_registration_type = offline_charinfo.pending_registration_type or ""
		end
		if minetest.check_player_privs(other_player_name, "ch_registered_player") then
			info.is_registered = true
		else
			info.is_registered = false
		end
		table.insert(result, info)
	end
	return result
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
Vrátí t[k]. Pokud je to nil, přiřadí tam prázdnou tabulku {} a vrátí tu.
]]
function ch_core.get_or_add(t, k)
	local result = t[k]
	if result == nil then
		result = {}
		t[k] = result
	end
	return result
end

--[[
Načte z metadat pozici uloženou pomocí ch_core.set_pos_to_meta().
Není-li tam taková uložena, vrátí vector.zero().
]]
function ch_core.get_pos_from_meta(meta, key)
	return vector.new(meta:get_float(key.."_x"), meta:get_float(key.."_y"), meta:get_float(key.."_z"))
end

--[[
Určí podle práv typ postavy (admin|creative|new|survival).
Pokud player_or_player_name není PlayerRef nebo jméno postavy, vrátí nil.
]]
function ch_core.get_player_role(player_or_player_name)
	local result = ch_core.normalize_player(player_or_player_name).role
	if result ~= "none" then
		return result
	else
		return nil
	end
end

--[[
	Vrátí seznam hráčských postav (ObjectRef) ve vymezené oblasti.
	Jde o bezprostřední náhradu za core.get_objects_inside_radius().
]]
function ch_core.get_players_inside_radius(center, radius)
	local result = {}
	for _, player in ipairs(core.get_connected_players()) do
		if vector.distance(center, player:get_pos()) <= radius then
			table.insert(result, player)
		end
	end
	return result
end

--[[
Vygeneruje šablonu pro stránku formspecu pro unified_inventory.
id -- string, required -- rozlišující textové ID pro připojení za prvky ch_scrollbar[12]_
player_viewname -- string, optional -- jméno postavy pro zobrazení v záhlaví (může být barevné)
title -- string, optional -- nadpis pro zobrazení v záhlaví
scrollbars -- table, required -- definuje maxima pro posuvníky oblastí a současně také rozložení oblastí;
	tato verze podporuje jen rozložení {left = ..., right = ...} a {top = ..., bottom = ...}
perplayer_formspec -- odpovídající parametr z rozhraní unified_inventory; definuje rozložení formuláře
online_charinfo -- table, optional -- je-li zadáno, stavy posuvníků se nastaví podle stejně pojmenovaných polí v dané tabulce, budou-li přítomna

Výstup má formát:
	{
		fs_begin, fs_middle, fs_end -- string; řetězce pro použití jako formspec; vlastní obsah vložte kolem fs_middle
		form1, form2 = {x, y, w, h, key, scrollbar_max} -- udává pozice a velikost podformulářů v okně unified_inventory;
			v praxi jsou podstatné především 'w' a 'h' (šířka a výška podoblasti)
	}
]]
function ch_core.get_ui_form_template(id, player_viewname, title, scrollbars, perplayer_formspec, online_charinfo)
    local fs = assert(perplayer_formspec)
    local fs_begin, fs_middle, fs_end = {fs.standard_inv_bg}, {}, {}
    local form1, form2 = {}, {}
    local sbar_width = 0.5
	local style

    if scrollbars.left ~= nil and scrollbars.right ~= nil then
        style = "left_right"
    elseif scrollbars.top ~= nil and scrollbars.bottom ~= nil then
        style = "top_bottom"
    else
        error("Unsupported UI formspec style!")
    end

    if style == "left_right" then
        form1.x = fs.std_inv_x
        form1.y = fs.form_header_y + 0.5
        form1.w = 10.0
        form1.h = fs.std_inv_y - fs.form_header_y - 1.25
        form1.key = "left"
        form1.scrollbar_max = scrollbars.left

        form2.x = fs.page_x - 0.25
        form2.y = 0.5
        form2.w = fs.pagecols - 1
        form2.h = fs.pagerows - 1 + fs.page_y
        form2.key = "right"
        form2.scrollbar_max = scrollbars.right
    elseif style == "top_bottom" then
        form1.x = fs.std_inv_x
        form1.y = fs.form_header_y + 0.5
        form1.w = 17.25
        form1.h = fs.std_inv_y - fs.form_header_y - 1.25
        form1.key = "top"
        form1.scrollbar_max = scrollbars.top

        form2.x = fs.page_x - 0.25
        form2.y = fs.std_inv_y - 0.5
        form2.w = fs.pagecols - 1
        form2.h = 5.5 + 0.5
        form2.scrollbar_max = scrollbars.bottom
    else
        error("not implemented yet")
    end

    if title ~= nil then
        table.insert(fs_begin, "label["..(form1.x + 0.05)..","..(form1.y - 0.3)..";")
        if player_viewname ~= nil then
            table.insert(fs_begin, minetest.formspec_escape(ch_core.colors.light_green..player_viewname..ch_core.colors.white.." — "))
        end
        table.insert(fs_begin, minetest.formspec_escape(title))
        table.insert(fs_begin, "]")
    end

    if (form1.scrollbar_max or 0) > 0 then
        table.insert(fs_begin, "scroll_container["..form1.x..","..form1.y..";"..form1.w..","..form1.h..";ch_scrollbar1_"..id..";vertical]")
        -- CONTENT will be inserted here
        table.insert(fs_middle, "scroll_container_end[]")
        -- insert a scrollbar
        if (form1.scrollbar_max or 0) > 0 then
			local scrollbar_state = online_charinfo ~= nil and online_charinfo["ch_scrollbar1_"..id]
			if scrollbar_state ~= nil then
				scrollbar_state = tostring(scrollbar_state)
			else
				scrollbar_state = ""
			end
            table.insert(fs_middle,
                "scrollbaroptions[max="..form1.scrollbar_max..";arrows=show]"..
                "scrollbar["..(form1.x + form1.w - sbar_width)..","..form1.y..";"..sbar_width..","..form1.h..";vertical;ch_scrollbar1_"..id..";"..
				scrollbar_state.."]")
        end
    else
        table.insert(fs_begin, "container["..form1.x..","..form1.y.."]")
        -- CONTENT will be inserted here
        table.insert(fs_middle, "container_end[]")
    end

    if (form2.scrollbar_max or 0) > 0 then
        table.insert(fs_middle, "scroll_container["..form2.x..","..form2.y..";"..form2.w..","..form2.h..";ch_scrollbar2_"..id..";vertical]")
        -- CONTENT will be inserted here
        table.insert(fs_end, "scroll_container_end[]")
        -- insert a scrollbar
        if (form2.scrollbar_max or 0) > 0 then
			local scrollbar_state = online_charinfo ~= nil and online_charinfo["ch_scrollbar2_"..id]
			if scrollbar_state ~= nil then
				scrollbar_state = tostring(scrollbar_state)
			else
				scrollbar_state = ""
			end
            table.insert(fs_end,
                "scrollbaroptions[max="..form2.scrollbar_max..";arrows=show]"..
                "scrollbar["..(form2.x + form2.w - sbar_width)..","..form2.y..";"..sbar_width..","..form2.h..";vertical;ch_scrollbar2_"..id..";"..
				scrollbar_state.."]")
        end
    else
        table.insert(fs_middle, "container["..form2.x..","..form2.y.."]")
        -- CONTENT will be inserted here
        table.insert(fs_end, "container_end[]")
    end

    return {
        fs_begin = table.concat(fs_begin),
        fs_middle = table.concat(fs_middle),
        fs_end = table.concat(fs_end),
        form1 = form1,
        form2 = form2,
    }
end

--[[
	Vrátí t[k1]. Pokud je to nil, vyplní t[k1] = {} a vrátí přiřazenou tabulku.
]]
function ch_core.goa1(t, k)
	local r = t[k]
	if r ~= nil then return r end
	r = {}
	t[k] = r
	return r
end

--[[
	Vrátí t[k1][k2]. Pokud některá z položek chybí, vyplní ji novou prázdnou tabulkou.
]]
function ch_core.goa2(t, k1, k2)
	local r1 = t[k1]
	if r1 == nil then
		r1 = {}
		t[k1] = {[k2] = r1}
		return r1
	end
	local r2 = r1[k2]
	if r2 == nil then
		r2 = {}
		r1[k2] = r2
		return r2
	end
	return r2
end
local goa2 = ch_core.goa2

--[[
	Vrátí t[k1][k2][k3]. Pokud některá z položek chybí, vyplní ji novou prázdnou tabulkou.
]]
function ch_core.goa3(t, k1, k2, k3)
	local r = t[k1]
	if r ~= nil then
		return goa2(r, k2, k3)
	else
		r = {}
		t[k1] = {[k2] = {[k3] = r}}
		return r
	end
end

--[[
	Vrátí t[k1][k2][k3][k4]. Pokud některá z položek chybí, vyplní ji novou prázdnou tabulkou.
]]
function ch_core.goa4(t, k1, k2, k3, k4)
	return goa2(goa2(t, k1, k2), k3, k4)
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
	Vrací funkci function(itemstack, user, pointed_thing),
	která zavolá do_item_eat() podle hodnoty skupiny ch_food,
	drink nebo ch_poison u daného předmětu. Není-li předmět v těchto
	skupinách, vrátí nil.
]]
local item_eat_cache = {}
function ch_core.item_eat(replace_with_item)
	if replace_with_item == nil then
		replace_with_item = ""
	elseif type(replace_with_item) ~= "string" then
		error("replace_with_item must be string or nil")
	end
	local result = item_eat_cache[replace_with_item]
	if result == nil then
		result = function(itemstack, user, pointed_thing)
			local name = itemstack:get_name()
			if name == nil or name == "" or minetest.registered_items[name] == nil then return end
			local food = minetest.get_item_group(name, "ch_food")
			local drink = minetest.get_item_group(name, "drink")
			local poison = minetest.get_item_group(name, "ch_poison")
			local health
			if poison ~= 0 then
				local normal = math.max(food, drink)
				if normal ~= 0 and math.random(5) ~= 3 then
					health = normal
				else
					health = -poison
				end
			else
				health = math.max(food, drink)
				if health <= 0 then
					return
				end
			end
			return minetest.do_item_eat(health, replace_with_item, itemstack, user, pointed_thing)
		end
		item_eat_cache[replace_with_item] = result
	end
	return result
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
			if index ~= nil and index_to_value[index] ~= nil then
				return index_to_value[index]
			else
				return index_to_value[default_index]
			end
		end,
		index_to_value = index_to_value,
		formspec_list = table.concat(escaped_values, ","),
		value_to_index = value_to_index,
	}
end

--[[
Přijme parametr, kterým může být:
	a) přihlašovací jméno postavy (bez ohledu na diakritiku)
	b) zobrazovací jméno postavy
	c) objekt postavy
	d) tabulka s volatelnou funkcí get_player_name()
Ve všech případech vrátí tabulku s prvky:
{
	role, -- role postavy nebo "none", pokud neexistuje
	player_name, -- skutečné přihlašovací jméno existující postavy, nebo "", pokud postava neexistuje; nikdy nebude nil
	viewname, -- zobrazovací jméno postavy (bez barev), nebo "", pokud postava neexistuje; nikdy nebude nil
	player, -- je-li postava ve hře, PlayerRef, jinak nil
	privs, -- tabulka práv postavy; pokud neexistuje, {}; nikdy nebude nil
}
]]
function ch_core.normalize_player(player_name_or_player)
	local arg_type = type(player_name_or_player)
	local player_name, player
	if arg_type == "string" then
		player_name = player_name_or_player
	elseif arg_type == "number" then
		player_name = tostring(player_name_or_player)
	elseif (arg_type == "table" or arg_type == "userdata") and type(player_name_or_player.get_player_name) == "function" then
		player_name = player_name_or_player:get_player_name()
		if type(player_name) ~= "string" then
			player_name = ""
		else
			if minetest.is_player(player_name_or_player) then
				player = player_name_or_player
			end
		end
	else
		player_name = ""
	end
	player_name = ch_core.jmeno_na_prihlasovaci(player_name)
	local correct_name = ch_data.correct_player_name_casing(player_name)
	if correct_name ~= nil then
		player_name = correct_name
	end
	if player_name ~= "" and not minetest.player_exists(player_name) then
		player_name = ch_core.jmeno_na_prihlasovaci(player_name)
		if not minetest.player_exists(player_name) then
			player_name = ""
		end
	end
	if player_name == "" then
		return {role = "none", player_name = "", viewname = "", privs = {}}
	end
	local privs = minetest.get_player_privs(player_name)
	return {
		role = get_player_role_by_privs(privs),
		player_name = player_name,
		viewname = ch_core.prihlasovaci_na_zobrazovaci(player_name),
		privs = privs,
		player = player or minetest.get_player_by_name(player_name),
	}
end

--[[
Vytvoří kopii vstupu (input) a zapíše do ní nové hodnoty skupin podle
parametru override. Skupiny s hodnotou 0 v override z tabulky odstraní.
Je-li některý z parametrů nil, je interpretován jako prázdná tabulka.

ZASTARALÁ: použijte raději ch_core.assembly_groups().
]]
function ch_core.override_groups(input, override)
	return ch_core.assembly_groups(input, override)
end

--[[
Převede zobrazovací nebo přihlašovací jméno na přihlašovací jméno,
bez ohledu na to, zda takové jméno existuje.
]]
function ch_core.jmeno_na_prihlasovaci(jmeno)
	return ch_core.odstranit_diakritiku(jmeno):gsub(" ", "_")
end

--[[
	Vrátí existující přihlašovací jméno postavy odpovídající uvedenému
	jménu až na velikost písmen a diakritiku, nebo nil, pokud
	taková postava neexistuje.
]]
function ch_core.jmeno_na_existujici_prihlasovaci(jmeno)
	if jmeno == nil then return nil end
	local result = ch_data.correct_player_name_casing(ch_core.odstranit_diakritiku(jmeno))
	if result and ch_data.offline_charinfo[result] then
		return result
	else
		return nil
	end
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
Převede všechna písmena v řetězci na velká, funguje i na písmena s diakritikou.
]]
function ch_core.na_velka_pismena(s)
	local l = #s
	local i = 1
	local res = ""
	local c
	while i <= l do
		c = diakritika_na_velka[s:sub(i, i + 1)]
		if c then
			res = res .. c
			i = i + 2
		else
			res = res .. s:sub(i, i)
			i = i + 1
		end
	end
	return string.upper(res)
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
Pokud je zadaný klient ve hře (musí jít o přihlašovací jméno), přehraje mu zvuk kliknutí.
Parametr může být nil; v takovém případě neudělá nic.
]]
function ch_core.play_click_sound_to(player_name)
	if player_name ~= nil then
		minetest.sound_play(click_sound, {to_player = player_name}, true)
	end
end

--[[
K zadané roli postavy vrátí odpovídající ikonu.
]]
function ch_core.player_role_to_image(player_role, has_creative_priv, image_height)
	if image_height ~= nil and image_height ~= 32 and image_height ~= 16 then
		error("ch_core.player_role_to_image(): image height "..image_height.." is unsupported!")
	end
	local result = assert(player_role_to_image[player_role] or player_role_to_image["none"])
	if player_role ~= "new" and has_creative_priv then
		result = "[combine:48x32:0,0="..result..":16,0="..player_role_to_image.creative
		if image_height == 16 then
			result = result.."^[resize:24x16"
		end
	elseif image_height == 16 then
		result = result.."^[resize:16x16"
	end
	return result
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
	local offline_info, jmeno
	if not prihlasovaci then
		error("ch_core.prihlasovaci_na_zobrazovaci() called with bad arguments!")
	end
	if minetest.player_exists(prihlasovaci) then
		offline_info = ch_data.get_offline_charinfo(prihlasovaci)
		if s_barvami then
			jmeno = offline_info.barevne_jmeno
			if jmeno then return jmeno end
		end
		jmeno = offline_info.jmeno
		if jmeno then return jmeno end
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
Smaže data týkající se dané postavy.
]]
function ch_core.remove_player(player_name, options)
	if options == nil then
		options = {}
	end
	player_name = ch_core.jmeno_na_prihlasovaci(player_name)
	if not minetest.player_exists(player_name) then
		return false, player_name.." neexistuje!"
	end
	local results = {player_name.." odstraněn/a:"}
	-- remove player data
	if options.player_data ~= false then
		if minetest.remove_player(player_name) == 0 then
			table.insert(results, "player_data")
		end
	end
	-- remove offline charinfo
	local f = ch_core.delete_offline_charinfo
	if options.offline_charinfo ~= false and f ~= nil then
		if f(player_name) then
			table.insert(results, "offline_charinfo")
		end
	end
	-- remove auth data
	if options.player_auth ~= false then
		if minetest.remove_player_auth(player_name) then
			table.insert(results, "player_auth")
		end
	end
	return true, table.concat(results, " ")
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
	Otočí axis-aligned bounding box takovým způsobem, jako zadaná facedir-hodnota 0 až 23
	otočí blok s paramtype2 == "facedir". Vrátí nový aabb. V případě selhání vrátí nil.
]]
function ch_core.rotate_aabb_by_facedir(aabb, facedir)
	if 0 <= facedir and facedir < 24 and facedir_to_rotation_data[facedir] then
		local a = vector.new(aabb[1], aabb[2], aabb[3])
		local b = vector.new(aabb[4], aabb[5], aabb[6])
		local r = facedir_to_rotation_data[facedir]
		a = vector.rotate(a, r)
		b = vector.rotate(b, r)
		return {
			math.min(a.x, b.x), math.min(a.y, b.y), math.min(a.z, b.z),
			math.max(a.x, b.x), math.max(a.y, b.y), math.max(a.z, b.z),
		}
	else
		return nil
	end
end

--[[
Provede operaci t[k1][k2]... s tím, že pokud je kterýkoliv z parametrů nil
nebo na nil po cestě narazí, vrátí nil. Číslo v názvu udává celkový počet
parametrů (včetně t) a musí být v rozsahu 2 až 7 včetně.
]]
function ch_core.safe_get_2(t, k1)
	if t and k1 ~= nil then return t[k1] end
	return nil
end
function ch_core.safe_get_3(t, k1, k2)
	local result
	if t and k1 ~= nil and k2 ~= nil then
		result = t[k1]
		if result ~= nil then
			return result[k2]
		end
	end
	return nil
end
function ch_core.safe_get_4(t, k1, k2, k3)
	local result
	if t and k1 ~= nil and k2 ~= nil and k3 ~= nil then
		result = t[k1]
		if result ~= nil then
			result = result[k2]
			if result ~= nil then
				return result[k3]
			end
		end
	end
	return nil
end
function ch_core.safe_get_5(t, k1, k2, k3, k4)
	local result
	if t and k1 ~= nil and k2 ~= nil and k3 ~= nil and k4 ~= nil then
		result = t[k1]
		if result ~= nil then
			result = result[k2]
			if result ~= nil then
				result = result[k3]
				if result ~= nil then
					return result[k4]
				end
			end
		end
	end
	return nil
end
function ch_core.safe_get_6(t, k1, k2, k3, k4, k5)
	local result
	if t and k1 ~= nil and k2 ~= nil and k3 ~= nil and k4 ~= nil and k5 ~= nil then
		result = t[k1]
		if result ~= nil then
			result = result[k2]
			if result ~= nil then
				result = result[k3]
				if result ~= nil then
					result = result[k4]
					if result ~= nil then
						return result[k5]
					end
				end
			end
		end
	end
	return nil
end
function ch_core.safe_get_7(t, k1, k2, k3, k4, k5, k6)
	local result
	if t and k1 ~= nil and k2 ~= nil and k3 ~= nil and k4 ~= nil and k5 ~= nil and k6 ~= nil then
		result = t[k1]
		if result ~= nil then
			result = result[k2]
			if result ~= nil then
				result = result[k3]
				if result ~= nil then
					result = result[k4]
					if result ~= nil then
						result = result[k5]
						if result ~= nil then
							return result[k6]
						end
					end
				end
			end
		end
	end
	return nil
end

--[[
Provede operaci t[k1][k2]... s tím, že pokud je kterýkoliv z parametrů nil
nebo na nil po cestě narazí, vrátí nil. Číslo v názvu udává celkový počet
parametrů (včetně t) a musí být v rozsahu 2 až 7 včetně.
V této verzi knihovny neprovádí kontrolu, zda je t indexovatelné.
]]
function ch_core.safe_get_2(t, k1)
	if t and k1 ~= nil then return t[k1] end
	return nil
end
function ch_core.safe_get_3(t, k1, k2)
	local result
	if t and k1 ~= nil and k2 ~= nil then
		result = t[k1]
		if result ~= nil then
			return result[k2]
		end
	end
	return nil
end
function ch_core.safe_get_4(t, k1, k2, k3)
	local result
	if t and k1 ~= nil and k2 ~= nil and k3 ~= nil then
		result = t[k1]
		if result ~= nil then
			result = result[k2]
			if result ~= nil then
				return result[k3]
			end
		end
	end
	return nil
end
function ch_core.safe_get_5(t, k1, k2, k3, k4)
	if k4 ~= nil then
		local result = ch_core.safe_get_4(t, k1, k2, k3)
		if result ~= nil then
			return result[k4]
		end
	end
	return nil
end
function ch_core.safe_get_6(t, k1, k2, k3, k4, k5)
	if k4 ~= nil and k5 ~= nil then
		local result = ch_core.safe_get_4(t, k1, k2, k3)
		if result ~= nil then
			result = result[k4]
			if result ~= nil then
				return result[k5]
			end
		end
	end
	return nil
end
function ch_core.safe_get_7(t, k1, k2, k3, k4, k5, k6)
	if k4 ~= nil and k5 ~= nil and k6 ~= nil then
		local result = ch_core.safe_get_4(t, k1, k2, k3)
		if result ~= nil then
			result = result[k4]
			if result ~= nil then
				result = result[k5]
				if result ~= nil then
					return result[k6]
				end
			end
		end
	end
	return nil
end

--[[
Provede operaci t[k1][k2]... = v s tím, že pokud je kterýkoliv z parametrů
kromě „v“ nil nebo na nil po cestě narazí, vrátí false.
Pokud přiřazení uspěje, vrátí true.
Číslo v názvu udává celkový počet parametrů (včetně t a v)
a musí být v rozsahu 3 až 8 včetně.
V této verzi knihovny neprovádí kontrolu, zda je t indexovatelné.
]]
function ch_core.safe_set_3(t, k1, v)
	if t and k1 ~= nil then
		t[k1] = v
		return true
	end
	return false
end
function ch_core.safe_set_4(t, k1, k2, v)
	if k2 ~= nil then
		t = ch_core.safe_get_2(t, k1)
		if t then
			t[k2] = v
			return true
		end
	end
	return false
end
function ch_core.safe_set_5(t, k1, k2, k3, v)
	if k3 ~= nil then
		t = ch_core.safe_get_3(t, k1, k2)
		if t then
			t[k3] = v
			return true
		end
	end
	return false
end
function ch_core.safe_set_6(t, k1, k2, k3, k4, v)
	if k4 ~= nil then
		t = ch_core.safe_get_4(t, k1, k2, k3)
		if t then
			t[k4] = v
			return true
		end
	end
	return false
end
function ch_core.safe_set_7(t, k1, k2, k3, k4, k5, v)
	if k5 ~= nil then
		t = ch_core.safe_get_5(t, k1, k2, k3, k4)
		if t then
			t[k5] = v
			return true
		end
	end
	return false
end
function ch_core.safe_set_8(t, k1, k2, k3, k4, k5, k6, v)
	if k6 ~= nil then
		t = ch_core.safe_get_6(t, k1, k2, k3, k4, k5)
		if t then
			t[k6] = v
			return true
		end
	end
	return false
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
Uloží do metadat souřadnice x, y, z včetně desetinné části.
]]
function ch_core.set_pos_to_meta(meta, key, pos)
	local x_key, y_key, z_key = key.."_x", key.."_y", key.."_z"
	meta:set_float(x_key, pos.x)
	meta:set_float(y_key, pos.y)
	meta:set_float(z_key, pos.z)
	local stored_pos = vector.new(meta:get_float(x_key), meta:get_float(y_key), meta:get_float(z_key))
	if not vector.equals(pos, stored_pos) then
		minetest.log("warning", "Position truncated when stored to metadata: "..vector.to_string(pos).." truncated to: "..vector.to_string(stored_pos))
	end
	return pos
end

--[[
Přesune klíče definující vlastnosti entity do podtabulky initial_properties.
Provádí úpravy přímo v předané tabulce a vrací ji (tzn. nevytváří kopii).
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
					r_text = ""
					r_chars = 0
					r_sp_begin, r_sp_end = nil, nil
				elseif not r_sp_end then
					-- průběžná skupina mezer => rozdělit zde
					table.insert(result, r_text:sub(1, r_sp_begin - 1))
					r_text = ""
					r_chars = 0
					r_sp_begin, r_sp_end = nil, nil
				else
					-- byla skupina mezer => rozdělit tam
					table.insert(result, r_text:sub(1, r_sp_begin - 1))
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
		else
			table.insert(result, r_text)
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
def = {
	description = "Vypíše seznam neregistrovaných postav seřazený podle času posledního přihlášení.",
	privs = {server = true},
	func = function(player_name, param)
		local last_logins = ch_core.get_last_logins(false)
		local result = {}

		for i = #last_logins, 1, -1 do
			local info = last_logins[i]
			local viewname = ch_core.prihlasovaci_na_zobrazovaci(info.player_name)
			local s = "- "..viewname.." (posl. přihl. před "..info.last_login_before.." dny, odehráno "..info.played_hours_total..
				" hodin, z toho "..info.played_hours_actively.." aktivně)"
			if info.is_in_game then
				s = s.." <je ve hře>"
			end
			if info.pending_registration_type ~= nil then
				s = s.." <plánovaná registrace: "..info.pending_registration_type..">"
			end
			if info.is_registered then
				s = s.." <registrovaná postava>"
			end
			table.insert(result, s)
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
