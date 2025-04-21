-- grid.lua
-- routines taking the tracks and building a grid out of them

local tm = advtrains.trackmap

-- Maximum scan length for track iterator
local TS_MAX_SCAN = 1000

-- Get a character matching the class requested by chr, in the correct orientation for conndir
-- The characters will be chosen from the unicode frame set if appropriate
-- valid character classes -, =, |
local char_equiv = {
	["-"] = {"│", "/", "─", "\\\\"}, -- single-line
	["="] = {"║", "/", "═", "\\\\"}, -- double-line
	["|"] = {"─", "\\\\", "│", "/"}, -- break (i.e. TCB, perpendicular to orientation)
}
local dir_to_charmap = {
	[15] = 1,
	[ 0] = 1,
	[ 1] = 1,
	[ 2] = 2,
	[ 3] = 3,
	[ 4] = 3,
	[ 5] = 3,
	[ 6] = 4,
	[ 7] = 1,
	[ 8] = 1,
	[ 9] = 1,
	[10] = 2,
	[11] = 3,
	[12] = 3,
	[13] = 3,
	[14] = 4,
}
function tm.rotate_char_class_by_conn(chr, conndir)
	--atdebug("rotatechar", chr, conndir, "dircharmap", dir_to_charmap[conndir], "charequiv", char_equiv[chr])
	return char_equiv[chr][dir_to_charmap[conndir]]
end

-- Generate a grid map by walking tracks starting from the given position start_pos
-- For every track that is visited, node_callback is called.
-- signature: node_callback(pos, conns, connid)
-- should return a table as follows:
-- {
--   char = "X" -- the character to use in this place, defaults to guessing a fitting frame character
--   color = "colorstring" or nil -- the color to render the character with
--   stop = false -- if true, the iterator will stop following this branch
-- }
-- Returning nil will assume defaults.
-- return value: a table:
-- {
--   grid = <grid> - access abs_grid[x][y] - contains one character per cell
--   min_pos = <pos> - the minimum pos contained in this grid
--   max_pos = <pos> - the maximum pos
-- }
function tm.generate_grid_map(start_pos, node_callback)
	local ti = advtrains.get_track_iterator(start_pos, nil, TS_MAX_SCAN, true)
	local grid = {} -- grid[x][y]
	local gcolor = {} -- grid[x][y]
	local gylev = {} -- grid[x][y]
	local gminx, gmaxx, gminz, gmaxz = start_pos.x, start_pos.x, start_pos.z, start_pos.z
	
	while ti:has_next_branch() do
		pos, connid = ti:next_branch()
		repeat
			local ok, conns = advtrains.get_rail_info_at(pos)
			local c = node_callback(pos, conns, connid)
			local chr = c and c.char
			--atdebug("init",pos.x,pos.z,chr,"")
			if not chr then
				chr = tm.rotate_char_class_by_conn("=", conns[connid].c)
			end
			
			-- add the char to the grid
			if not grid[pos.x] then
				grid[pos.x] = {}
				gcolor[pos.x] = {}
				gylev[pos.x] = {}
			end
			
			-- ensure that higher rails are rendered on top
			local prev_ylev = gylev[pos.x][pos.z]
			if not prev_ylev or prev_ylev < pos.y then
				grid[pos.x][pos.z] = chr
				gylev[pos.x][pos.z] = pos.y
				if c and c.color then
					gcolor[pos.x][pos.z] = c.color
				end
			end
			
			gminx = math.min(gminx, pos.x)
			gmaxx = math.max(gmaxx, pos.x)
			gminz = math.min(gminz, pos.z)
			gmaxz = math.max(gmaxz, pos.z)
			
			if c and c.stop then break end
			pos, connid = ti:next_track()
		until not pos
	end
	return {
		grid = grid,
		gcolor = gcolor,
		min_pos = {x=gminx, z=gminz},
		max_pos = {x=gmaxx, z=gmaxz},
	}
end

