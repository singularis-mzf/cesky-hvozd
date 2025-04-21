local tx = {}
setmetatable(tx, {__call = function(_, ...) return tx.base(...) end})

function tx.escape(str)
	return (string.gsub(tostring(str), [[([%^:\])]], [[\%1]]))
end

local function getargs(...)
	return select("#", ...), {...}
end

local function curry(f, x)
	return function(...)
		return f(x, ...)
	end
end

local function xmkmodifier(func)
	return function(self, ...)
		table.insert(self, (func(...)))
		return self
	end
end

local function mkmodifier(fmt, spec)
	return xmkmodifier(function(...)
		local count = select("#", ...)
		local args = {...}
		for k, f in pairs(spec) do
			args[k] = f(args[k])
		end
		return string.format(fmt, unpack(args, 1, count))
	end)
end

-- Texture object
local tx_lib = {}
local tx_mt = {
	__index = tx_lib,
	__tostring = function(self)
		return table.concat(self, "^")
	end,
	__concat = function(a, b)
		return tx.raw(("%s^%s"):format(tostring(a), tostring(b)))
	end,
}

function tx.raw(str)
	return setmetatable({str}, tx_mt)
end
function tx.base(str)
	return tx.raw(tx.escape(str))
end
-- TODO: use [fill when 5.8.0 becomes widely used client-side
function tx.fill(w, h, color)
	return tx"advtrains_hud_bg.png":resize(w, h):colorize(color)
end

-- Most texture modifiers
tx_lib.colorize = xmkmodifier(function(c, a)
	local str = ("[colorize:%s"):format(tx.escape(c))
	if a then
		str = str .. ":" .. a
	end
	return str
end)
tx_lib.multiply = mkmodifier("[multiply:%s", {tx.escape})
tx_lib.resize = mkmodifier("[resize:%dx%d", {})
tx_lib.transform = mkmodifier("[transform%s", {tx.escape})

-- [combine

local combine = {}

function combine:add(x, y, ent)
	table.insert(self.st, ([[%d,%d=%s]]):format(x, y, tx.escape(tostring(ent))))
	return self
end

local combine_mt = {
	__index = combine,
	__tostring = function(self)
		return table.concat(self.st, ":")
	end,
}

function tx.combine(w, h, bg)
	local base = ("[combine:%dx%d"):format(w, h)
	local obj = setmetatable({width = w, height = h, st = {base}}, combine_mt)
	if bg then
		obj:add_fill(0, 0, w, h, bg)
	end
	return obj
end

function combine:add_fill(x, y, ...)
	return self:add(x, y, tx.fill(...))
end

local function add_multicolor_fill(n, self, x, y, w, h, ...)
	local argc, argv = getargs(...)
	local t = 0
	for k = 1, argc, 2 do
		t = t + argv[k]
	end
	local newargs = {x, y, w, h}
	local sk, wk = n, n+2
	local s = newargs[wk]/t
	for k = 1, argc, 2 do
		local v = argv[k] * s
		newargs[wk] = v
		newargs[5] = argv[k+1]
		self:add_fill(unpack(newargs))
		newargs[sk] = newargs[sk] + v
	end
	return self
end
combine.add_multicolor_fill_topdown = curry(add_multicolor_fill, 2)
combine.add_multicolor_fill_leftright = curry(add_multicolor_fill, 1)

local function add_segmentbar(n, self, x, y, w, h, m, c, ...)
	local argc, argv = getargs(...)
	local baseargs = {x, y, w, h}
	local ss = (baseargs[n+2]+m)/c
	local bs = ss - m
	for k = 1, argc, 3 do
		local lower, upper, fill = argv[k], argv[k+1], argv[k+2]
		lower = math.max(0, math.floor(lower))+1
		upper = math.min(c, math.floor(upper))
		if lower <= upper then
			local args = {x, y, w, h, fill}
			args[n+2] = bs
			args[n] = args[n] + ss*(lower-1)
			for i = lower, upper do
				self:add_fill(unpack(args))
				args[n] = args[n] + ss
			end
		end
	end
	return self
end
combine.add_segmentbar_topdown = curry(add_segmentbar, 2)
combine.add_segmentbar_leftright = curry(add_segmentbar, 1)

local function add_lever(n, self, x, y, w, h, hs, ss, val, hf, sf)
	local baseargs = {x, y, w, h}
	local sargs = {x, y, w, h, sf}
	sargs[5-n] = ss
	sargs[n+2] = baseargs[n+2] + ss - hs
	for k = 1, 2 do
		sargs[k] = baseargs[k] + (baseargs[k+2] - sargs[k+2])/2
	end
	self:add_fill(unpack(sargs))
	local hargs = {x, y, w, h, hf}
	hargs[n+2] = hs
	hargs[n] = baseargs[n] + (baseargs[n+2]-hs)*val
	self:add_fill(unpack(hargs))
	return self
end
combine.add_lever_topdown = curry(add_lever, 2)
combine.add_lever_leftright = curry(add_lever, 1)

--[[ Seven-segment display
 -1-
6   2
 -7-
5   3
 -4-
--]]
local sevenseg_digits = {
	["0"] = {1, 2, 3, 4, 5, 6},
	["1"] = {2, 3},
	["2"] = {1, 2, 4, 5, 7},
	["3"] = {1, 2, 3, 4, 7},
	["4"] = {2, 3, 6, 7},
	["5"] = {1, 3, 4, 6, 7},
	["6"] = {1, 3, 4, 5, 6, 7},
	["7"] = {1, 2, 3},
	["8"] = {1, 2, 3, 4, 5, 6, 7},
	["9"] = {1, 2, 3, 4, 6, 7},
}

function combine:add_str7seg(x0, y0, tw, th, str, fill)
	--[[ w and h (as width/height of individual (horizontal) segments) have the following properties:
	tw = n(w+3h)-h
	th = 2w+3h
	--]]
	local len = #str
	local h = (2*tw-len*th)/(3*len-2)
	local w = (th-3*h)/2
	local ws = w+3*h
	local segs = {
		{h, 0, w, h},
		{w+h, h, h, w},
		{w+h, w+2*h, h, w},
		{h, 2*(w+h), w, h},
		{0, w+2*h, h, w},
		{0, h, h, w},
		{h, w+h, w, h},
	}
	for i = 1, len do
		for _, k in pairs(sevenseg_digits[string.sub(str, i, i)] or {}) do
			local s = segs[k]
			self:add_fill(s[1]+x0, s[2]+y0, s[3], s[4], fill)
		end
		x0 = x0 + ws
	end
	return self
end

function combine:add_n7seg(x, y, w, h, n, prec, ...)
	if not (type(n) == "number" and type(prec) == "number") then
		error("passed non-numeric value or precision to numeric display")
	elseif prec < 0 then
		error("negative length")
	end
	local pfx = ""
	if n >= 0 then
		n = math.min(10^prec-1, n)
	else
		n = math.min(10^(prec-1)-1, -n)
		pfx = "-"
	end
	local str = ("%d"):format(n)
	return self:add_str7seg(x, y, w, h, pfx .. ("0"):rep(prec-#str-#pfx) .. str, ...)
end

return tx
