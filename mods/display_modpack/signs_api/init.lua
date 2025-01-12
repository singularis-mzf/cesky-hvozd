ch_base.open_mod(minetest.get_current_modname())
--[[
    signs mod for Minetest - Various signs with text displayed on
    (c) Pierre-Yves Rollo

    This file is part of signs.

    signs is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    signs is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with signs.  If not, see <http://www.gnu.org/licenses/>.
--]]


signs_api = {}
signs_api.name = minetest.get_current_modname()
signs_api.path = minetest.get_modpath(signs_api.name)

-- Load support for intllib.
local S, NS = dofile(signs_api.path.."/intllib.lua")
signs_api.intllib = S
local F = function(...) return minetest.formspec_escape(S(...)) end

function signs_api.set_display_text(pos, text, font)
	local meta = minetest.get_meta(pos)
	meta:set_string("display_text", text)
	if text and text ~= "" then
		meta:set_string("infotext", "\""..text.."\"")
	else
		meta:set_string("infotext", "")
	end
	if font then
		meta:set_string("font", font)
	end
	display_api.update_entities(pos)
end

local number_enum_cache = {
	"1",
	"1,2",
	"1,2,3",
	"1,2,3,4",
	"1,2,3,4,5",
	"1,2,3,4,5,6",
	"1,2,3,4,5,6,7",
	"1,2,3,4,5,6,7,8",
	"1,2,3,4,5,6,7,8,9",
}

local function get_number_enum(n)
	if n <= 9 then
		return number_enum_cache[n] or assert(number_enum_cache[6])
	else
		local result = {assert(number_enum_cache[9])}
		for i = 10, n do
			result[i - 8] = tostring(i)
		end
		return table.concat(result, ",")
	end
end

function signs_api.set_formspec(pos)
	local meta = minetest.get_meta(pos)
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	if ndef and ndef.display_entities and ndef.display_entities["signs:display_text"] then
		local edef = ndef.display_entities["signs:display_text"]
		local formspec = {
			"formspec_version[6]"..
			"size[11,7.5]"..
			default.gui_bg..
			default.gui_bg_img..default.gui_slots..
			"style_type[textarea;font=mono]"..
			"textarea[0.5,0.5;10,1;;;         |         |         |         |         |]"..
			"textarea[0.5,1;10,2.25;display_text;;",
			core.formspec_escape(meta:get_string("display_text")),
			"]"..
			"style_type[textarea;font=normal]"..
			"style[font_field,lastchange_field;border=false]",
		}
		if edef.meta_lines then
			local lines = meta:get_int(edef.meta_lines)
			if lines < 1 then
				lines = edef.meta_lines_default or edef.maxlines or edef.lines or 1
			end
			table.insert(formspec, "label[0.5,3.75;řádků:]"..
				"dropdown[1.5,3.5;1,0.5;lines;")
			table.insert(formspec, get_number_enum(edef.maxlines or 6))
			table.insert(formspec, ";"..lines..";true]"..
				"tooltip[lines;Maximální počet řádků\\, který cedule zobrazí.\n"..
				"Toto nastavení ovlivňuje velikost písma: čím více řádků\\, tím menší písmo.]")
		elseif edef.maxlines then
			table.insert(formspec, "label[0.5,3.75;řádků: "..edef.maxlines.."]")
		end
		if edef.meta_halign then
			table.insert(formspec,
				"label[2.75,3.75;vodorovně:]"..
				"dropdown[4.5,3.5;2.25,0.5;halign;na střed,vlevo,vpravo;"..meta:get_int(edef.meta_halign)..";true]")
		end
		if edef.meta_valign then
			table.insert(formspec,
				"label[7,3.75;svisle:]"..
				"dropdown[8,3.5;2.5,0.5;valign;"..
				"na střed,nahoře,dole,"..
				"na střed (R180),dole (R180),nahoře (R180),"..
				"na střed (FY),dole (FY),nahoře (FY),"..
				"na střed (FX),nahoře (FX),dole (FX);"..
				meta:get_int(edef.meta_valign)..";true]")
		end
		table.insert(formspec,
			"label[0.5,4.5;písmo: "..core.formspec_escape(meta:get_string("font")).."]"..
			"button[2.75,4.3;2,0.5;font;změnit písmo]"..
			"label[0.5,5.25;ceduli spravuje:]"..
			"field[2.75,5;2.5,0.5;owner;;"..ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("owner")).."]"..
			"tooltip[owner;Kdo ceduli spravuje může nastavit jen Administrace\\, pokud má však cedule normální úroveň přístupu\\,\n"..
			"může na ni psát kterákoliv přijatá postava.]"..
			"label[5.5,5.25;přístup:]"..
			"dropdown[7,5;3,0.5;access_level;normální,sdílená cedule,zamčená cedule;"..meta:get_int("access_level")..";true]"..
			"tooltip[access_level;Úroveň přístupu může nastavit jen správce/yně cedule nebo Administrace.\n"..
			"Normální a sdílené cedule může měnit či vytěžit jakákoliv přijatá postava\\, zamčené cedule jen správce/yně či Administrace.]")
		if edef.meta_color then
			table.insert(formspec,
				"label[0.5,6;barva textu:]"..
				"field[2.25,5.75;1.5,0.5;color;;"..meta:get_string(edef.meta_color).."]"..
				"tooltip[color;Barva se zadává ve formátu RRGGBB (bez mřížky). Vyprázdněním pole nastavíte výchozí barvu textu.]"..
				"image_button[4,5.65;0.75,0.75;\\[combine:8x8:1\\,1=ch_core_white_pixel.png\\\\^\\[resize\\\\:6x6^\\[multiply:#000000;black;]"..
				"image_button[4.75,5.65;0.75,0.75;\\[combine:8x8:1\\,1=ch_core_white_pixel.png\\\\^\\[resize\\\\:6x6^\\[multiply:#ffffff;white;]"..
				"image_button[5.5,5.65;0.75,0.75;\\[combine:8x8:1\\,1=ch_core_white_pixel.png\\\\^\\[resize\\\\:6x6^\\[multiply:#00ff00;green;]"..
				"image_button[6.25,5.65;0.75,0.75;\\[combine:8x8:1\\,1=ch_core_white_pixel.png\\\\^\\[resize\\\\:6x6^\\[multiply:#ffbb00;orange;]"..
				"image_button[7,5.65;0.75,0.75;\\[combine:8x8:1\\,1=ch_core_white_pixel.png\\\\^\\[resize\\\\:6x6^\\[multiply:#c0aa1c;gold;]"..
				"tooltip[black;barva textu: černá]"..
				"tooltip[white;barva textu: bílá]"..
				"tooltip[green;barva textu: zelená]"..
				"tooltip[orange;barva textu: oranžová]"..
				"tooltip[gold;barva textu: zlatá]")
		elseif edef.color then
			table.insert(formspec,
				"label[0.5,6;barva textu: "..core.formspec_escape(edef.color).."]")
		end
		table.insert(formspec,
			"label[0.5,6.75;poslední změna: "..core.formspec_escape(meta:get_string("last_change")).."]"..
			"button_exit[7.5,6.25;3,0.75;ok;uložit a zavřít]")
		local fs = table.concat(formspec)
		meta:set_string("formspec", fs)
	end
end

core.register_lbm({
	label = "Update display_api formspecs",
	name = "signs_api:update_formspecs_20250104",
	nodenames = {"group:display_api"},
	bulk_action = function(pos_list, dtime_s)
		for _, pos in ipairs(pos_list) do
			signs_api.set_formspec(pos)
		end
	end,
})

-- access_level:
-- 0 = not set (= public)
-- 1 = public
-- 2 = shared (currently = public)
-- 3 = locked (only owner/admin can make changes)

function signs_api.on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) or not fields then
		return
	end
	local ndef = core.registered_nodes[core.get_node(pos).name]
	if not ndef or not ndef.display_entities or not ndef.display_entities["signs:display_text"] then
		return
	end
	local meta = core.get_meta(pos)
	local owner = meta:get_string("owner")
	local player_name = player:get_player_name()
	local player_is_admin = ch_core.get_player_role(player_name) == "admin"
	local player_is_owner = owner ~= "" and owner == player_name
	-- check access_level:
	if not player_is_admin and meta:get_int("access_level") == 3 and not player_is_owner then
		return
	end

	local changes = {}
	local edef = ndef.display_entities["signs:display_text"]
	-- text:
	if fields.display_text then
		if fields.display_text ~= meta:get_string("display_text") then
			table.insert(changes, "display_text to >>>"..fields.display_text.."<<<")
		end
		signs_api.set_display_text(pos, fields.display_text)
	end
	-- lines:
	if edef.meta_lines and fields.lines then
		local new_value = tonumber(fields.lines) or 0
		if new_value > 0 and new_value ~= meta:get_int(edef.meta_lines) then
			meta:set_int(edef.meta_lines, new_value)
			table.insert(changes, "lines to "..new_value)
		end
	end
	-- halign:
	if edef.meta_halign and fields.halign then
		local new_value = tonumber(fields.halign) or 1
		if new_value ~= meta:get_int(edef.meta_halign) then
			meta:set_int(edef.meta_halign, new_value)
			table.insert(changes, "halign to "..new_value)
		end
	end
	-- valign:
	if edef.meta_valign and fields.valign then
		local new_value = tonumber(fields.valign) or 1
		if new_value ~= meta:get_int(edef.meta_valign) then
			meta:set_int(edef.meta_valign, new_value)
			table.insert(changes, "valign to "..new_value)
		end
	end
	-- owner:
	if player_is_admin and fields.owner then
		local new_owner = ch_core.jmeno_na_prihlasovaci(fields.owner)
		if new_owner ~= owner then
			owner = new_owner
			table.insert(changes, "owner to "..new_owner)
		end
		meta:set_string("owner", new_owner)
	end
	-- access level:
	if (player_is_owner or player_is_admin) and fields.access_level then
		local new_value = tonumber(fields.access_level)
		if new_value ~= nil and new_value ~= 0 and new_value ~= meta:get_int("access_level") then
			table.insert(changes, "access_level to "..new_value)
			meta:set_int("access_level", new_value)
		end
	end
	-- color:
	if edef.meta_color then
		local new_color
		if fields.black then
			new_color = "000000"
		elseif fields.white then
			new_color = "ffffff"
		elseif fields.green then
			new_color = "00ff00"
		elseif fields.orange then
			new_color = "ffbb00"
		elseif fields.gold then
			new_color = "c0aa1c"
		elseif fields.color and (#fields.color == 0 or (#fields.color == 6 and not fields.color:match("[^0123456789ABCDEFabcdef]"))) then
			new_color = fields.color
		end
		if new_color ~= nil and new_color ~= meta:get_string(edef.meta_color) then
			meta:set_string(edef.meta_color, new_color)
			table.insert(changes, "color to #"..new_color)
		end
	end

	-- last change:
	if #changes > 0 then
		local cas = ch_time.aktualni_cas()
		meta:set_string("last_change", cas:YYYY_MM_DD().." "..ch_core.prihlasovaci_na_zobrazovaci(player_name))
		core.log("action", player_name.." changed a sign at "..core.pos_to_string(pos)..":\n- "..table.concat(changes, "\n- "))
		signs_api.set_formspec(pos)
		display_api.update_entities(pos)
	end

	if fields.font then
		font_api.show_font_list(player, pos, function(player_name, pos) signs_api.set_formspec(pos) end)
	end

	--[[
		if fields.font then
			signs_api.set_display_text(pos, fields.display_text)
			font_api.show_font_list(player, pos)
		elseif fields.ok then

		if fields and (fields.ok or fields.key_enter) then
			signs_api.set_display_text(pos, fields.display_text)
		end
		if fields and (fields.font) then
			signs_api.set_display_text(pos, fields.display_text)
			font_api.show_font_list(player, pos)
		end
		]]
end

-- On place callback for direction signs
-- (chooses which sign according to look direction)
function signs_api.on_place_direction(itemstack, placer, pointed_thing)
	local name = itemstack:get_name()
	local ndef = minetest.registered_nodes[name]
	local restriction = display_api.is_rotation_restricted()

	local bdir = {
		x = pointed_thing.under.x - pointed_thing.above.x,
		y = pointed_thing.under.y - pointed_thing.above.y,
		z = pointed_thing.under.z - pointed_thing.above.z}

	local pdir = placer:get_look_dir()

	local ndir, test

	if ndef.paramtype2 == "facedir" then
		-- If legacy mode, only accept upright nodes
		if restriction and bdir.x == 0 and bdir.z == 0 then
			-- Ceiling or floor pointed (facedir chosen from player dir)
			ndir = minetest.dir_to_facedir({x=pdir.x, y=0, z=pdir.z})
		else
			-- Wall pointed or no rotation restriction
			ndir = minetest.dir_to_facedir(bdir, not restriction)
		end

		test = { [0]=-pdir.x, pdir.z, pdir.x, -pdir.z, -pdir.x, [8]=pdir.x }
	end

	if ndef.paramtype2 == "wallmounted" then
		ndir = minetest.dir_to_wallmounted(bdir)
		-- If legacy mode, only accept upright nodes
		if restriction and (ndir == 0 or ndir == 1) then
			ndir = minetest.dir_to_wallmounted({x=pdir.x, y=0, z=pdir.z})
		end

		test = { [0]=-pdir.x, -pdir.x, pdir.z, -pdir.z, -pdir.x, pdir.x}
	end

	-- Only for direction signs
	-- TODO:Maybe improve ground and ceiling placement in every directions
	if ndef.signs_other_dir then
		if test[ndir] > 0 then
			itemstack:set_name(ndef.signs_other_dir)
		end
		itemstack = minetest.item_place(itemstack, placer, pointed_thing, ndir)
		itemstack:set_name(name)

		return itemstack
	else
		return minetest.item_place(itemstack, placer, pointed_thing, ndir)
	end
end

-- Handles screwdriver rotation
-- (see "if" block below for rotation restriction mode).
signs_api.on_rotate = function(pos, node, player, mode, new_param2)
	-- If rotation mode is 1 and sign is directional, swap direction between
	-- each rotation.
	if mode == 1 then
		local ndef = minetest.registered_nodes[node.name]
		if ndef.signs_other_dir then
			-- Switch direction
			node = {name = ndef.signs_other_dir,
				param1 = node.param1, param2 = node.param2}
			minetest.swap_node(pos, node)
			display_api.update_entities(pos)
			-- Rotate only if not "main" sign
			-- TODO:Improve detection of "main" direction sign
			if ndef.groups and ndef.groups.not_in_creative_inventory then
				return display_api.on_rotate(pos, node, player, mode, new_param2)
			else
				return true
			end
		end
	end
	return display_api.on_rotate(pos, node, player, mode, new_param2)
end

-- Legacy mode with rotation restriction
-- TODO:When MT < 5.0 no more in use, to be removed
if display_api.is_rotation_restricted() then
	signs_api.on_rotate = function(pos, node, player, mode, new_param2)
		-- If rotation mode is 2 and sign is directional, swap direction.
		-- Otherwise use display_api's on_rotate function.
		if mode == 2 then
			local ndef = minetest.registered_nodes[node.name]
			if ndef.signs_other_dir then
				minetest.swap_node(pos, {name = ndef.signs_other_dir,
					param1 = node.param1, param2 = node.param2})
				display_api.update_entities(pos)
				return true
			end
		end
		return display_api.on_rotate(pos, node, player, mode, new_param2)
	end
end

local function shape_selector_after_change(pos, old_node, new_node, player, nodespec)
	display_api.update_entities(pos)
end

local function update_box(fields, box_name, on_pole_offset)
	local result = fields[box_name]
	if result == nil then
		return
	end
	result = table.copy(result)
	fields[box_name] = result
	local fixed = table.copy(result.fixed)
	result.fixed = fixed
	if type(fixed[1]) == "table" then
		error("Multi-nodebox signs are not supported yet")
	end
	fixed[3] = fixed[3] + on_pole_offset
	fixed[6] = fixed[6] + on_pole_offset
	return result
end

function signs_api.register_sign(mod, name, model)
	-- Default fields
	local fields = {
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "facedir",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {-model.width/2, -model.height/2, 0.5,
					 model.width/2, model.height/2, 0.5 - model.depth},
		},
		groups = {choppy=2, dig_immediate=2, not_blocking_trains=1, display_api=1},
		sounds = default.node_sound_defaults(),
		display_entities = {
			["signs:display_text"] = {
					on_display_update = font_api.on_display_update,
					depth = 0.5 - display_api.entity_spacing - model.depth,
					size = { x = model.width, y = model.height },
					aspect_ratio = 1/2,
					maxlines = 1,
			},

		},
		on_place = display_api.on_place,
		on_construct = 	function(pos)
				local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
				local meta = minetest.get_meta(pos)
				meta:set_string("font", ndef.display_entities.font_name or
				                        font_api.get_default_font_name())
				signs_api.set_formspec(pos)
				display_api.on_construct(pos)
			end,
		on_destruct = display_api.on_destruct,
		on_rotate = signs_api.on_rotate,
		on_receive_fields =  signs_api.on_receive_fields,
		on_punch = function(pos, node, player, pointed_thing)
				signs_api.set_formspec(pos)
				display_api.update_entities(pos)
			end,
		can_dig = function(pos, player)
				local controls = player and player:is_player() and player:get_player_control()
				if not controls or controls.aux1 then
					local meta = core.get_meta(pos)
					if meta:get_int("access_level") == 3 then
						local owner = meta:get_string("owner")
						if player:get_player_name() ~= owner and not core.check_player_privs(player, "protection_bypass") then
							minetest.chat_send_player(player:get_player_name(), "Tato cedule je zamčená a patří postavě: "..ch_core.prihlasovaci_na_zobrazovaci(owner).."!")
							return false
						end
					end
					return true
				end
				if minetest.get_modpath("technic") then
					local wielded_item = player:get_wielded_item()
					if not wielded_item:is_empty() and technic.power_tools[wielded_item:get_name()] then
						return true
					end
				end
				minetest.chat_send_player(player:get_player_name(), "*** pro odstranění většiny cedulí, štítku, směrovek a plakátů musíte při odstraňování držet Aux1 nebo použít elektrický nástroj")
				return false
			end,
		preserve_metadata = function(pos, oldnode, oldmeta, drops)
			if #drops == 1 and (oldmeta.display_text or "") ~= "" then
				local idef = core.registered_items[drops[1]:get_name()]
				local ndef = core.registered_nodes[oldnode.name]
				local edef = ndef and ndef.display_entities and ndef.display_entities["signs:display_text"]
				local meta = drops[1]:get_meta()
				meta:set_string("font", oldmeta.font or "")
				meta:set_string("display_text", oldmeta.display_text)
				meta:set_string("infotext", oldmeta.infotext or "")
				meta:set_string("text", oldmeta.text or "")
				if idef ~= nil and idef.description ~= nil then
					meta:set_string("description", idef.description..": "..ch_core.utf8_truncate_right(oldmeta.display_text, 80, "(...)"))
				end
				if edef ~= nil then
					if edef.meta_color then
						meta:set_string("meta_color", oldmeta[edef.meta_color] or "")
					end
					if edef.meta_halign then
						meta:set_int("meta_halign", oldmeta[edef.meta_halign] or 0)
					end
					if edef.meta_lines then
						meta:set_int("meta_lines", oldmeta[edef.meta_lines] or 0)
					end
					if edef.meta_valign then
						meta:set_int("meta_valign", oldmeta[edef.meta_valign] or 0)
					end
				end
			end
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local new_owner = (placer and placer:get_player_name()) or ""
			local meta = core.get_meta(pos)
			meta:set_int("access_level", 1)
			meta:set_string("owner", new_owner)

			local itemmeta = itemstack:get_meta()
			if itemmeta:get_string("display_text") ~= "" then
				local ndef = core.registered_nodes[core.get_node(pos).name]
				local edef = ndef and ndef.display_entities and ndef.display_entities["signs:display_text"]
				meta:set_string("display_text", itemmeta:get_string("display_text"))
				meta:set_string("font", itemmeta:get_string("font"))
				meta:set_string("last_change", itemmeta:get_string("last_change"))
				meta:set_string("infotext", itemmeta:get_string("infotext"))
				meta:set_string("text", itemmeta:get_string("text"))
				if edef ~= nil then
					if edef.meta_color then
						meta:set_string(edef.meta_color, itemmeta:get_string("meta_color"))
					end
					if edef.meta_halign then
						meta:set_int(edef.meta_halign, itemmeta:get_int("meta_halign"))
					end
					if edef.meta_lines then
						local value = itemmeta:get_int("meta_lines")
						if value == 0 and edef.meta_lines_default ~= nil and edef.meta_lines_default > 0 then
							value = edef.meta_lines_default
						end
						meta:set_int(edef.meta_lines, value)
					end
					if edef.meta_valign then
						meta:set_int(edef.meta_valign, itemmeta:get_int("meta_valign"))
					end
				end
				display_api.update_entities(pos)
			end
			signs_api.set_formspec(pos)
		end,
	}

	-- Node fields override
	for key, value in pairs(model.node_fields) do
		if key == "groups" then
			for key2, value2 in pairs(value) do
				fields[key][key2] = value2
			end
		elseif (key == "preserve_metadata" or key == "after_place_node") and value == false then
			fields[key] = nil
		else
			fields[key] = value
		end
	end

	if not fields.wield_image then fields.wield_image = fields.inventory_image end

	-- Entity fields override
	for key, value in pairs(model.entity_fields) do
		fields.display_entities["signs:display_text"][key] = value
	end

	minetest.register_node(mod..":"..name, fields)

	if model.allow_on_pole then
		local on_pole_offset = 0.375

		fields = table.copy(fields)
		if fields.drawtype == "nodebox" then
			update_box(fields, "node_box", on_pole_offset)
			update_box(fields, "selection_box", on_pole_offset)
			update_box(fields, "collision_box", on_pole_offset)
		elseif fields.drawtype == "mesh" then
			fields.mesh = fields.mesh:gsub("%.obj", "_onpole.obj")
			update_box(fields, "selection_box", on_pole_offset)
			update_box(fields, "collision_box", on_pole_offset)
		else
			error("Sign "..mod..":"..name.." cannot be allowed on poles with a drawtype "..(fields.drawtype or "nil").."!")
		end
		if fields.description ~= nil then
			fields.description = fields.description.." (na tyč)"
		end
		fields.groups = table.copy(fields.groups or {})
		fields.groups.not_in_creative_inventory = 1
		if fields.drop == nil then
			fields.drop = mod..":"..name
		end
		if fields.signs_other_dir ~= nil then
			fields.signs_other_dir = fields.signs_other_dir.."_on_pole"
		end
		fields.inventory_image = "signs_api_pole.png^[resize:32x32^("..fields.inventory_image..")"

		fields.display_entities = table.copy(fields.display_entities)
		fields.display_entities["signs:display_text"] = table.copy(fields.display_entities["signs:display_text"])
		local tmp = fields.display_entities["signs:display_text"]
		tmp.depth = tmp.depth + on_pole_offset

		minetest.register_node(mod..":"..name.."_on_pole", fields)
		minetest.register_craft({
			output = mod..":"..name.."_on_pole",
			recipe = {{"default:fence_wood", mod..":"..name}, {"", ""}},
			replacements = {{"default:fence_wood", "default:fence_wood"}},
		})
		minetest.register_craft({
			output = mod..":"..name,
			recipe = {{mod..":"..name.."_on_pole"}},
		})
		if mod:match("^:") then
			mod = mod:sub(2,-1)
		end
		local nodes = {mod..":"..name, mod..":"..name.."_on_pole"}
		if signs_api.shape_selector_mode == "with_dirsigns" and name:match("_sign$") then
			local sname = mod..":"..name:sub(1,-6)
			for _, dir in ipairs({"_left_sign", "_right_sign"}) do
				if core.registered_nodes[sname..dir] then
					table.insert(nodes, sname..dir)
				end
				if core.registered_nodes[sname..dir.."_on_pole"] then
					table.insert(nodes, sname..dir.."_on_pole")
				end
			end
		end
		if signs_api.shape_selector_mode ~= "suppress" then
			ch_core.register_shape_selector_group({
				columns = 2,
				nodes = nodes,
				after_change = shape_selector_after_change,
			})
		end
	end
end

-- Text entity for all signs
display_api.register_display_entity("signs:display_text")

ch_base.close_mod(minetest.get_current_modname())
