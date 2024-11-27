ch_base.open_mod(minetest.get_current_modname())
--[[

Unified Dyes

This mod provides an extension to the Minetest dye system

==============================================================================

Copyright (C) 2012-2013, Vanessa Dannenberg
Email: vanessa.e.dannenberg@gmail.com

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

==============================================================================

--]]

--=====================================================================


unifieddyes = {}

local modpath=minetest.get_modpath(minetest.get_current_modname())

unifieddyes.palette_data_bright_extended = dofile(modpath.."/palette_data_bright_extended.lua")
unifieddyes.palette_data_extended = dofile(modpath.."/palette_data_extended.lua")

function unifieddyes.get_node_palette_by_def(ndef)
	if ndef == nil then
		return nil
	end
	local real_palette = ndef.palette
	local ud_palette = ndef._ch_ud_palette or real_palette
	if ud_palette == nil then
		return nil
	end
	local palette_type, hue
	if ud_palette == "unifieddyes_palette_extended.png" then
		palette_type = "extended"
	elseif ud_palette == "unifieddyes_palette_colorwallmounted.png" then
		palette_type = "wallmounted"
	elseif ud_palette == "unifieddyes_palette_color4dir.png" then
		palette_type = "4dir"
	elseif ud_palette:sub(1, 20) == "unifieddyes_palette_" and ud_palette:sub(-5, -1) == "s.png" then
		return {
			real_palette = real_palette,
			ud_palette = ud_palette,
			palette_type = "split",
			hue = ud_palette:sub(21, -6),
		}
	else
		return nil -- unrecognized palette
	end
	return {
		real_palette = real_palette,
		ud_palette = ud_palette,
		palette_type = palette_type,
	}
end

function unifieddyes.get_node_palette(node_name)
	if node_name == nil then
		return nil
	end
	return unifieddyes.get_node_palette_by_def(minetest.registered_nodes[node_name])
end

dofile(modpath.."/color-tables.lua")
dofile(modpath.."/api.lua")
dofile(modpath.."/airbrush.lua")
dofile(modpath.."/dyes-crafting.lua")
dofile(modpath.."/aliases.lua")

-- print("[UnifiedDyes] Loaded!")
unifieddyes.init = true
ch_base.close_mod(minetest.get_current_modname())
