ch_core.require_submod("lib", "data")

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

-- Všechna písmena s diakritikou převede na odpovídající písmena
-- bez diakritiky. Ostatní znaky ponechá.
ch_core.odstranit_diakritiku = function(s)
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
ch_core.odstranit_mezery = function(s)
	return string.gsub(s, " ", "")
end]]

-- Převede všechna písmena v řetězci na malá, funguje i na písmena
-- s diakritikou.
ch_core.na_mala_pismena = function(s)
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

-- Pokud dané přihl. jméno existuje, převede ho na jméno bez barev (výchozí)
-- nebo s barvami. Pro neexistující jména vrací původní řetězec.
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

-- Převede zobrazovací nebo přihlašovací jméno
-- na přihlašovací jméno; postava nemusí existovat
-- (tzn. existenci je nutno ověřit podle vráceného jména).
function ch_core.jmeno_na_prihlasovaci(jmeno)
	return ch_core.odstranit_diakritiku(jmeno):gsub(" ", "_")
end

local dbg_table = ch_core.storage:to_table()
if not dbg_table then
	print("STORAGE: nil")
else
	for key, value in pairs(dbg_table.fields) do
		print("STORAGE: <"..key..">=<"..value..">")
	end
end

----
---- Unified Inventory:
unified_inventory.string_lower_extended = ch_core.na_mala_pismena
unified_inventory.string_remove_extended_chars = ch_core.odstranit_diakritiku

ch_core.submod_loaded("lib")
