-- fsrender.lua
-- Rendering of a grid of characters into a formspec

local tm = advtrains.trackmap

function tm.render_grid_formspec(formsize_x, formsize_y, gridtbl, origin_pos, width, height)
	local grid = gridtbl.grid
	local gcolor = gridtbl.gcolor
	local s = {
		"formspec_version[3]",
		"size["..formsize_x..","..formsize_y.."]",
		"no_prepend[]",
		"bgcolor[white;false;white]",
		"style_type[label;font=mono]",
		"label[0,0;",
		minetest.get_color_escape_sequence("black")
		}
	local last_color = nil
	for z=height-1, 0, -1 do
		-- render a row
		for x=0,width-1 do
			local apos_x = origin_pos.x + x
			local apos_z = origin_pos.z + z
			local chr = " "
			if grid[apos_x] and grid[apos_x][apos_z] then
				local color = gcolor[apos_x][apos_z]
				if color ~= last_color then
					-- change the color of the text
					table.insert(s, minetest.get_color_escape_sequence(color or "black"))
					last_color = color
				end
				chr = grid[apos_x][apos_z]
			end
			table.insert(s, chr)
		end
		table.insert(s,"\n")
	end
	table.insert(s, "]")
	table.insert(s, "style_type[label;font=]") -- reset font style
	return table.concat(s)
end