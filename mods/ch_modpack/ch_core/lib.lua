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

-- LOKÁLNÍ FUNKCE
-- ===========================================================================


-- VEŘEJNÉ FUNKCE
-- ===========================================================================

--[[
Převede zobrazovací nebo přihlašovací jméno na přihlašovací jméno,
bez ohledu na to, zda takové jméno existuje.
]]
function ch_core.jmeno_na_prihlasovaci(jmeno)
	return ch_core.odstranit_diakritiku(jmeno):gsub(" ", "_")
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
function ch_core.utf8_truncate_right(s, max_chars)
	local i = ch_core.utf8_seek(s, 1, max_chars)
	if i then
		return s:sub(1, i - 1) .. "..."
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
				-- dosažen maximální počet znaků => uzavřít řádku
				if line_separator and #result > 0 then
					result[#result] = result[#result]..line_separator
				end
				if not r_sp_begin then
					-- žádné mezery => tvrdé dělení
					table.insert(result, r_text)
					r_text = ""
					r_chars = 0
				elseif not r_sp_end then
					-- průběžná skupina mezer => rozdělit zde
					table.insert(result, r_text:sub(1, r_sp_begin - 1))
					r_text = ""
					r_chars = 0
					r_sp_begin = nil
				else
					-- byla skupina mezer => rozdělit tam
					table.insert(result, r_text:sub(1, r_sp_begin - 1))
					r_text = r_text:sub(r_sp_end + 1, -1)
					r_chars = ch_core.utf8_length(r_text)
					r_sp_begin = nil
					r_sp_end = nil
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

ch_core.close_submod("lib")
