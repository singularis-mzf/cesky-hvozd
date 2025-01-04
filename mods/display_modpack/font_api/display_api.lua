--[[
	font_api mod for Minetest - Library creating textures with fonts and text
	(c) Pierre-Yves Rollo

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]
-- Integration with display API

if minetest.get_modpath("display_api") then
	--- Standard on_display_update entity callback.
	-- Node should have properly configured display_entity.
	-- @param pos Node position
	-- @param objref Object reference of entity

	font_api.on_display_update = function (pos, objref)
		local meta = minetest.get_meta(pos)
		local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
		-- if not ndef then return end
		local entity = objref:get_luaentity()
		if not entity then return end
		local def = ndef.display_entities[entity.name]
		if not def then return end

		local font = meta:get_string("font")
		if font ~= "" then
			font = font_api.get_font(font)
		else
			font = font_api.get_font(def.font_name)
		end
		local text = meta:get_string(def.meta_text or "display_text")

		-- Compute entity resolution accroding to given attributes
		local columns, aspect_ratio = def.columns, def.aspect_ratio

		if def.meta_columns then
			local new_columns = meta:get_int(def.meta_columns)
			if new_columns > 0 then
				columns = new_columns
			end
		end
		if def.meta_aspect_ratio then
			local new_aspect_ratio = meta:get_float(def.meta_aspect_ratio)
			if new_aspect_ratio > 0.0 then
				aspect_ratio = new_aspect_ratio
			end
		end

		local render_style = {
			lines = def.maxlines or def.lines,
			halign = def.halign,
			valign = def.valign,
			color = def.color,
		}
		if def.meta_halign then
			local new_halign = meta:get_int(def.meta_halign)
			if new_halign == 2 then
				render_style.halign = "left"
			elseif new_halign == 3 then
				render_style.halign = "right"
			else
				render_style.halign = "center"
			end
		end
		if def.meta_valign then
			local new_valign = meta:get_int(def.meta_valign)
			if new_valign == 2 then
				render_style.valign = "top"
			elseif new_valign == 3 then
				render_style.valign = "bottom"
			else
				render_style.valign = "center"
			end
		end
		if def.meta_color then
			local new_color = meta:get_string(def.meta_color)
			if #new_color == 6 and not new_color:match("[^0123456789ABCDEFabcdef]") then
				render_style.color = "#"..new_color
			end
		end
		local textureh = font:get_height(def.lines or def.maxlines or 1)
		if def.meta_lines then
			local new_lines = meta:get_int(def.meta_lines)
			if new_lines == 0 then
				if def.meta_lines_default ~= nil and def.meta_lines_default > 0 then
					new_lines = def.meta_lines_default
				end
			end
			if new_lines > 0 then
				render_style.lines = new_lines
				textureh = font:get_height(new_lines)
			end
		end

		local texturew
		if columns ~= nil then
			texturew = columns * (font.fixedwidth or 1)
		else
			if not aspect_ratio then
				minetest.log('warning', "[font_api] No 'aspect_ratio' specified, using default 1.")
				aspect_ratio = 1
			end
			texturew = textureh * def.size.x / def.size.y / (aspect_ratio or 1)
		end

		objref:set_properties({
			textures={ font:render(text, texturew, textureh, render_style ) },
			visual_size = def.size,
		})
	end
else
	font_api.on_display_update = function (pos, objref)
		minetest.log('error', '[font_api] font_api.on_display_update called but display_api mod not enabled.')
	end
end
