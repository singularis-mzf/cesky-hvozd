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

ch_core.odstranit_mezery = function(s)
	return string.gsub(s, " ", "")
end

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

unified_inventory.string_lower_extended = ch_core.na_mala_pismena
unified_inventory.string_remove_extended_chars = ch_core.odstranit_diakritiku
