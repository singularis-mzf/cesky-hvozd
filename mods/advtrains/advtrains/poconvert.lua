local unescape_string
do
	local schartbl = { -- https://en.wikipedia.org/wiki/Escape_sequences_in_C
		a = "\a",
		b = "\b",
		e = string.char(0x1b),
		f = "\f",
		n = "\n",
		r = "\r",
		t = "\t",
		v = "\v",
	}
	local function replace_single(pfx, c)
		local pl = #pfx
		if pl % 2 == 0 then
			return string.sub(pfx, 1, pl/2) .. c
		end
		return string.sub(pfx, 1, math.floor(pl/2)) .. (schartbl[c] or c)
	end
	unescape_string = function(str)
		return string.gsub(str, [[(\+)([abefnrtv'"?])]], replace_single)
	end
end

local function readstring_aux(str, pos)
	local _, spos = string.find(str, [[^%s*"]], pos)
	if not spos then
		return nil
	end
	local ipos = spos
	while true do
		local _, epos, m = string.find(str, [[(\*)"]], ipos+1)
		if not epos then
			return error("String extends beyond the end of input")
		end
		ipos = epos
		if #m % 2 == 0 then
			return unescape_string(string.sub(str, spos+1, epos-1)), epos+1
		end
	end
end

local function readstring(str, pos)
	local st = {}
	local nxt = pos
	while true do
		local s, npos = readstring_aux(str, nxt)
		if not s then
			if not st[1] then
				return nil, nxt
			else
				return table.concat(st), nxt
			end
		end
		nxt = npos
		table.insert(st, s)
	end
end

local function readtoken(str, pos)
	local _, epos, tok = string.find(str, [[^%s*(%S+)]], pos)
	if epos == nil then
		return nil, pos
	end
	return tok, epos+1
end

local function readcomment_add_flags(flags, s)
	for flag in string.gmatch(s, ",%s*([^,]+)") do
		flags[flag] = true
	end
end

local function readcomment_aux(str, pos)
	local _, epos, sval = string.find(str, "^\n*#([^\n]*)", pos)
	if not epos then
		return nil
	end
	return sval, epos+1
end

local function readcomment(str, pos)
	local st = {}
	local nxt = pos
	local flags = {}
	while true do
		local s, npos = readcomment_aux(str, nxt)
		if not npos then
			local t = {
				comment = table.concat(st, "\n"),
				flags = flags,
			}
			return t, nxt
		end
		if string.sub(s, 1, 1) == "," then
			readcomment_add_flags(flags, s)
		end
		table.insert(st, s)
		nxt = npos
	end
end

local function readpo(str)
	local st = {}
	local pos = 1
	while true do
		local entry, nxt = readcomment(str, pos)
		local msglines = 0
		while true do
			local tok, npos = readtoken(str, nxt)
			if tok == nil or string.sub(tok, 1, 1) == "#" then
				break
			elseif string.sub(tok, 1, 3) ~= "msg" then
				return error("Invalid token: " .. tok)
			elseif entry[tok] ~= nil then
				break
			else
				local value, npos = readstring(str, npos)
				assert(value ~= nil, "No string provided for " .. tok)
				entry[tok] = value
				nxt = npos
				msglines = msglines+1
			end
		end
		if msglines == 0 then
			return st
		elseif entry.msgid ~= "" then
			assert(entry.msgid ~= nil, "Missing untranslated string")
			assert(entry.msgstr ~= nil, "Missing translated string")
			table.insert(st, entry)
		end
		pos = nxt
	end
end

local escape_lookup = {
	["="] = "@=",
	["\n"] = "@n"
}
local function escape_string(st)
	return (string.gsub(st, "[=\n]", escape_lookup))
end

local function convert_po_string(textdomain, str)
	local st = {string.format("# textdomain: %s", textdomain)}
	for _, entry in ipairs(readpo(str)) do
		local line = ("%s=%s"):format(escape_string(entry.msgid), escape_string(entry.msgstr))
		if entry.flags.fuzzy then
			line = "#" .. line
		end
		table.insert(st, line)
	end
	return table.concat(st, "\n")
end

local function convert_po_file(textdomain, inpath, outpath)
	local f, err = io.open(inpath, "rb")
	assert(f, err)
	local str = convert_po_string(textdomain, f:read("*a"))
	f:close()
	minetest.safe_file_write(outpath, str)
	return str
end

local function convert_flat_po_directory(textdomain, modpath)
	assert(textdomain, "No textdomain specified for po file conversion")
	local mp = modpath or minetest.get_modpath(textdomain)
	assert(mp ~= nil, "No path to write for " .. textdomain)
	local popath = mp .. "/po"
	local trpath = mp .. "/locale"
	for _, infile in pairs(minetest.get_dir_list(popath, false)) do
		local lang = string.match(infile, [[^([^%.]+)%.po$]])
		if lang then
			local inpath = popath .. "/" .. infile
			local outpath = ("%s/%s.%s.tr"):format(trpath, textdomain, lang)
			convert_po_file(textdomain, inpath, outpath)
		end
	end
end

return {
	from_string = convert_po_string,
	from_file = convert_po_file,
	from_flat = convert_flat_po_directory,
}
