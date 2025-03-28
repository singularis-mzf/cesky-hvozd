--[[
Copyright (c) 2023-2024 Singularis

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local Hsx = dofile("./hsx.lua")

local hue_names = {
	"red",
	"vermilion",
	"orange",
	"amber",
	"yellow",
	"lime",
	"chartreuse",
	"harlequin",
	"green",
	"malachite",
	"spring",
	"turquoise",
	"cyan",
	"cerulean",
	"azure",
	"sapphire",
	"blue",
	"indigo",
	"violet",
	"mulberry",
	"magenta",
	"fuchsia",
	"rose",
	"crimson",
}

-- 24 hue-values
local hues = {
	0.000,
	0.042,
	0.083,
	0.125,
	0.167,
	0.208,
	0.250,
	0.292,
	0.333,
	0.375,
	0.417,
	0.458,
	0.500,
	0.542,
	0.583,
	0.625,
	0.667,
	0.708,
	0.750,
	0.792,
	0.833,
	0.875,
	0.917,
	0.958,
}

--[[
original values:
-- 10 rows - saturation / value values
local rows = {
	{ 0.206, 248 }, -- 1 -- mdle -- příjemné barvy, hlavně na světlejších blocích
	{ 0.332, 244 }, -- 2 -- pastelově -- výraznější barvy, takové by měly být základní
	{ 0.417, 242 }, -- 3 -- světle -- velmi výrazné barvy, maximum snesitelnosti
	{ 0.700, 234 }, -- 4 -- polosvětle -- příliš křiklavé barvy, nutno snížit sytost; dávají smysl jen na tmavších blocích
	{ 0.890, 229 }, -- 5 -- normální -- extrémně křiklavé, nesnesitelné, nehodí se na nic
	{ 0.575, 180 }, -- 6 -- nízká sytost -- výrazné tmavší barvy, ale snesitelné; hodí se na světlé i tmavé bloky
	{ 0.894, 151 }, -- 7 -- středně -- velmi křiklavé, nesnesitelné
	{ 0.572, 117 }, -- 8 -- středně (nízká sytost) -- velmi tmavé a výrazné, ale snesitelné
	{ 0.894, 76 }, -- 9 -- tmavě -- velmi velmi tmavé, hodí se jedině hnědá, ale i ta by měla mít nižší sytost
	{ 0.576, 59 }, -- 10 -- tmavě (nízká sytost) -- dobrá hnědá, ale jinak už jsou sotva poznat odstíny; tak tmavé by barvy neměly být
}
]]

-- 10 rows - saturation / value values
-- saturace:
-- 0.2 jemná, příjemná
-- 0.3 základní (výraznější barvy)
-- 0.4 křiklavé
-- u tmavších barev + 0.2
local rows = {
	-- { saturation, value }
	{ 0.100, 248 }, -- 1 -- mdle
	{ 0.200, 244 }, -- 2 -- pastelově
	{ 0.300, 242 }, -- 3 -- světle
	{ 0.650, 240 }, -- 4 -- polosvětle => křiklavě
	{ 0.500, 229 }, -- 5 -- normální
	{ 0.350, 200 }, -- 6 -- nízká sytost
	{ 0.500, 120 }, -- 7 -- středně
	{ 0.300, 120 }, -- 8 -- středně (nízká sytost)
	{ 0.450, 70 }, -- 9 -- tmavě
	{ 0.200, 50 }, -- 10 -- tmavě (nízká sytost)
}

local brows = { -- křiklavá paleta
	{ 0.300, 248 }, -- 1 -- mdle
	{ 0.400, 244 }, -- 2 -- pastelově
	{ 0.500, 242 }, -- 3 -- světle
	{ 0.980, 240 }, -- 4 -- křiklavě
	{ 0.800, 229 }, -- 5 -- normální
	{ 0.600, 200 }, -- 6 -- nízká sytost
	{ 0.850, 100 }, -- 7 -- středně
	{ 0.500, 100 }, -- 8 -- středně (nízká sytost)
	{ 0.850, 60 }, -- 9 -- tmavě
	{ 0.500, 40 }, -- 10 -- tmavě (nízká sytost)
}

local function round(x)
	if x < 0 then
		return math.ceil(x - 0.5)
	else
		return math.floor(x + 0.5)
	end
end

local black = {0, 0, 0}
local white = {255, 255, 255}

local palette = {}
local bpalette = {}

-- colors palette
for i_row = 1, 10 do
	local row, brow = rows[i_row], brows[i_row]
	for i_hue = 1, 24 do
		local hue = hues[i_hue]
		local r, g, b = Hsx.hsv2rgb(hue, row[1], row[2])
		palette[24 * (i_row - 1) + (i_hue - 1)] = round(r).." "..round(g).." "..round(b)
		r, g, b = Hsx.hsv2rgb(hue, brow[1], brow[2])
		bpalette[24 * (i_row - 1) + (i_hue - 1)] = round(r).." "..round(g).." "..round(b)
	end
end

-- white/grey/black palette
for i = 0, 15 do
	local v = round((255 - 20) * (1.0 - i / 15.0) + 20)
	palette[240 + i] = v.." "..v.." "..v
	v = round((255 - 5) * (1.0 - i / 15.0) + 5)
	bpalette[240 + i] = v.." "..v.." "..v
end



local function seq(sequences)
	local result = {}
	local i = 1
	local k = 1
	while sequences[i] ~= nil and sequences[i + 1] ~= nil do
		for j = sequences[i], sequences[i + 1] do
			result[k] = j
			k = k + 1
		end
		i = i + 2
	end
	return result
end

local function generate_color4dir_map()
	local result = {240, 242, 244, 247, 249, 251, 253, 255}
	for _, irow in ipairs({0, 2, 3, 4, 5, 6, 8}) do
		for _, icolumn in ipairs({0, 2, 4, 8, 12, 16, 18, 20}) do
			table.insert(result, 24 * irow + icolumn)
		end
	end
	if #result ~= 64 then
	error("Invalid count: "..#result)
	end
	return result
end

local function emit_palette(filename, width, height, colors, palette_table)
	local ppm = io.open("out/"..filename..".ppm", "w")
	local lua = io.open("out/"..filename..".lua", "w")
	local limit = width * height
	ppm:write("P3\n# Generated by a palette generator\n"..width.." "..height.."\n255\n")
	lua:write("return {\n")

	for i = 1, limit do
		local color_index = colors[i] or -1
		local color = palette_table[color_index] or "255 255 255"
		local lua_color = "{"..color:gsub(" ", ",")..","..color_index.."},"
		ppm:write(color.."\n")
		lua:write(lua_color.."\n")
	end

	lua:write("}\n")
	ppm:close()
	lua:close()
	print("convert out/"..filename..".ppm out/unifieddyes_palette_"..filename..".png")
end

local colorwallmounted_map = {
	240, 244, 247, 251, 255, 64, 56, 48,
	96, 96 + 2, 96 + 4, 96 + 8, 96 + 12, 96 + 16, 96 + 18, 96 + 20,
	144, 144 + 2, 144 + 4, 144 + 8, 144 + 12, 144 + 16, 144 + 18, 144 + 20,
	192, 192 + 2, 192 + 4, 192 + 8, 192 + 12, 192 + 16, 192 + 18, 192 + 20,
}
local color4dir_map = generate_color4dir_map()

emit_palette("extended", 24, 11, seq({0, 255}), palette)
emit_palette("bright_extended", 24, 11, seq({0, 255}), bpalette)
emit_palette("colorwallmounted", 8, 4, colorwallmounted_map, palette)
emit_palette("color4dir", 8, 8, color4dir_map, palette)
emit_palette("bright_color4dir", 8, 8, color4dir_map, bpalette)

for i = 1, 24 do
	local hue_name = hue_names[i]
	local hue_base_index = i - 1
	local indices = {
		hue_base_index + 24 * 0,
		hue_base_index + 24 * 4,
		hue_base_index + 24 * 5,
		hue_base_index + 24 * 2,
		hue_base_index + 24 * 6,
		hue_base_index + 24 * 7,
		hue_base_index + 24 * 8,
		hue_base_index + 24 * 9,
	}
	emit_palette(hue_name.."s", 8, 1, indices, palette)
	emit_palette("bright_"..hue_name.."s", 8, 1, indices, bpalette)
end
emit_palette("greys", 8, 1, {-1, 240, 244, 247, 251, 255, -1, -1}, palette)
emit_palette("bright_greys", 8, 1, {-1, 240, 244, 247, 251, 255, -1, -1}, bpalette)
