--[[
Minetest Mod Storage Drawers - A Mod adding storage drawers

Copyright (C) 2017-2019 Linus Jahn <lnj@kaidan.im>
Copyright (C) 2016 Mango Tango <mtango688@gmail.com>

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

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

-- Load support for intllib.
local MP = core.get_modpath(core.get_current_modname())
local F = core.formspec_escape
local S, NS = dofile(MP.."/intllib.lua")

-- GUI
function drawers.get_upgrade_slots_bg(x,y)
	local out = ""
	--for i = 0, 4, 1 do
	local i = 0
	out = out .."image["..x+i..","..y..";1,1;drawers_upgrade_slot_bg.png]"
	-- end
	return out
end

function drawers.gen_info_text(basename, count, factor, stack_max, owner, is_public)
	local maxCount = stack_max * factor
	local percent = count / maxCount * 100
	-- round the number (float -> int)
	percent = math.floor(percent + 0.5)
	local owner_viewname
	if owner == nil or owner == "" then
		owner_viewname = S("none")
	else
		owner_viewname = ch_core.prihlasovaci_na_zobrazovaci(owner)
	end

	local result
	if count == 0 then
		result = basename
	else
		result = tostring(count).." "..basename
	end
	result = result.."\n"..S("(@1% full, capacity @2)", tostring(percent), maxCount)
	if is_public then
		result = S("public drawer (managed by @1)", owner_viewname).."\n"..result
	else
		result = result.."\n"..S("owner: @1", owner_viewname)
	end
	return result
end

function drawers.get_inv_image(name)
	local texture = "blank.png"
	local def = core.registered_items[name]
	if not def then return end

	if def.inventory_image and #def.inventory_image > 0 then
		texture = def.inventory_image
	else
		if not def.tiles then return texture end
		local tiles = table.copy(def.tiles)

		for k,v in pairs(tiles) do
			if type(v) == "table" then
				tiles[k] = v.name
			end
		end

		-- tiles: up, down, right, left, back, front
		-- inventorycube: up, front, right
		if #tiles <= 2 then
			texture = core.inventorycube(tiles[1], tiles[1], tiles[1])
		elseif #tiles <= 5 then
			texture = core.inventorycube(tiles[1], tiles[3], tiles[3])
		else -- full tileset
			texture = core.inventorycube(tiles[1], tiles[6], tiles[3])
		end
	end

	return texture
end

function drawers.spawn_visuals(pos)
	local node = core.get_node(pos)
	local ndef = core.registered_nodes[node.name]
	local drawerType = ndef.groups.drawer
	local param2 = ch_core.get_nodedir(node.name) or node.param2

	-- data for the new visual
	drawers.last_drawer_pos = pos
	drawers.last_drawer_type = drawerType

	if drawerType == 1 then -- 1x1 drawer
		drawers.last_visual_id = ""
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name"))

		local bdir = core.facedir_to_dir(param2)
		local fdir = vector.new(-bdir.x, 0, -bdir.z)
		local pos2 = vector.add(pos, vector.multiply(fdir, 0.45))

		local obj = core.add_entity(pos2, "drawers:visual")
		if not obj then return end

		if bdir.x < 0 then obj:set_yaw(0.5 * math.pi) end
		if bdir.z < 0 then obj:set_yaw(math.pi) end
		if bdir.x > 0 then obj:set_yaw(1.5 * math.pi) end

		drawers.last_texture = nil
	elseif drawerType == 2 then
		local bdir = core.facedir_to_dir(param2)

		local fdir1
		local fdir2
		if param2 == 2 or param2 == 0 then
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x, -0.5, -bdir.z)
		else
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x, -0.5, -bdir.z)
		end

		local objs = {}

		drawers.last_visual_id = 1
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name1"))
		local pos1 = vector.add(pos, vector.multiply(fdir1, 0.45))
		objs[1] = core.add_entity(pos1, "drawers:visual")

		drawers.last_visual_id = 2
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name2"))
		local pos2 = vector.add(pos, vector.multiply(fdir2, 0.45))
		objs[2] = core.add_entity(pos2, "drawers:visual")

		for i,obj in pairs(objs) do
			if bdir.x < 0 then obj:set_yaw(0.5 * math.pi) end
			if bdir.z < 0 then obj:set_yaw(math.pi) end
			if bdir.x > 0 then obj:set_yaw(1.5 * math.pi) end
		end
	else -- 2x2 drawer
		local bdir = core.facedir_to_dir(param2)

		local fdir1
		local fdir2
		local fdir3
		local fdir4
		if param2 == 2 then
			fdir1 = vector.new(-bdir.x + 0.5, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x - 0.5, 0.5, -bdir.z)
			fdir3 = vector.new(-bdir.x + 0.5, -0.5, -bdir.z)
			fdir4 = vector.new(-bdir.x - 0.5, -0.5, -bdir.z)
		elseif param2 == 0 then
			fdir1 = vector.new(-bdir.x - 0.5, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x + 0.5, 0.5, -bdir.z)
			fdir3 = vector.new(-bdir.x - 0.5, -0.5, -bdir.z)
			fdir4 = vector.new(-bdir.x + 0.5, -0.5, -bdir.z)
		elseif param2 == 1 then
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z + 0.5)
			fdir2 = vector.new(-bdir.x, 0.5, -bdir.z - 0.5)
			fdir3 = vector.new(-bdir.x, -0.5, -bdir.z + 0.5)
			fdir4 = vector.new(-bdir.x, -0.5, -bdir.z - 0.5)
		else
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z - 0.5)
			fdir2 = vector.new(-bdir.x, 0.5, -bdir.z + 0.5)
			fdir3 = vector.new(-bdir.x, -0.5, -bdir.z - 0.5)
			fdir4 = vector.new(-bdir.x, -0.5, -bdir.z + 0.5)
		end

		local objs = {}

		drawers.last_visual_id = 1
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name1"))
		local pos1 = vector.add(pos, vector.multiply(fdir1, 0.45))
		objs[1] = core.add_entity(pos1, "drawers:visual")

		drawers.last_visual_id = 2
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name2"))
		local pos2 = vector.add(pos, vector.multiply(fdir2, 0.45))
		objs[2] = core.add_entity(pos2, "drawers:visual")

		drawers.last_visual_id = 3
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name3"))
		local pos3 = vector.add(pos, vector.multiply(fdir3, 0.45))
		objs[3] = core.add_entity(pos3, "drawers:visual")

		drawers.last_visual_id = 4
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name4"))
		local pos4 = vector.add(pos, vector.multiply(fdir4, 0.45))
		objs[4] = core.add_entity(pos4, "drawers:visual")


		for i,obj in pairs(objs) do
			if bdir.x < 0 then obj:set_yaw(0.5 * math.pi) end
			if bdir.z < 0 then obj:set_yaw(math.pi) end
			if bdir.x > 0 then obj:set_yaw(1.5 * math.pi) end
		end
	end
end

function drawers.remove_visuals(pos)
	local objs = core.get_objects_inside_radius(pos, 0.56)
	if not objs then return end

	for _, obj in pairs(objs) do
		if obj and obj:get_luaentity() and
				obj:get_luaentity().name == "drawers:visual" then
			obj:remove()
		end
	end
end

--[[
	Returns the visual object for the visualid of the drawer at pos.

	visualid can be: "", "1", "2", ... or 1, 2, ...
]]
function drawers.get_visual(pos, visualid)
	local drawer_visuals = drawers.drawer_visuals[core.hash_node_position(pos)]
	if not drawer_visuals then
		return nil
	end

	-- not a real index (starts with 1)
	local index = tonumber(visualid)
	if visualid == "" then
		index = 1
	end

	return drawer_visuals[index]
end

function drawers.update_drawer_upgrades(pos)
	local node = core.get_node(pos)
	local ndef = core.registered_nodes[node.name]
	local drawerType = ndef.groups.drawer

	-- default number of slots/stacks
	local stackMaxFactor = ndef.drawer_stack_max_factor

	-- storage percent with all upgrades
	local storagePercent = 100

	-- get info of all upgrades
	local inventory = core.get_meta(pos):get_inventory():get_list("upgrades")
	for _,itemStack in pairs(inventory) do
		local iname = itemStack:get_name()
		local idef = core.registered_items[iname]
		local addPercent = 100 * itemStack:get_count()

		storagePercent = storagePercent + addPercent
	end

	--						i.e.: 150% / 100 => 1.50
	stackMaxFactor = math.floor(stackMaxFactor * (storagePercent / 100))
	-- calculate stack_max factor for a single drawer
	stackMaxFactor = stackMaxFactor / drawerType

	-- set the new stack max factor in all visuals
	local drawer_visuals = drawers.drawer_visuals[core.hash_node_position(pos)]
	if not drawer_visuals then return end

	for _,visual in pairs(drawer_visuals) do
		visual:setStackMaxFactor(stackMaxFactor)
	end
end

function drawers.randomize_pos(pos)
	local rndpos = table.copy(pos)
	local x = math.random(-50, 50) * 0.01
	local z = math.random(-50, 50) * 0.01
	rndpos.x = rndpos.x + x
	rndpos.y = rndpos.y + 0.25
	rndpos.z = rndpos.z + z
	return rndpos
end

function drawers.node_tiles_front_other(front, other)
	return {other, other, other, other, other, front}
end

local ifthenelse = ch_core.ifthenelse

local function get_formspec(custom_state)
	local pos = assert(custom_state.pos)
	local meta = core.get_meta(pos)
	local owner, owner_viewname_fs = meta:get_string("owner")
	if owner ~= "" then
		owner_viewname_fs = F(ch_core.prihlasovaci_na_zobrazovaci(owner))
	else
		owner_viewname_fs = "není"
	end
	local player_role = ch_core.get_player_role(custom_state.player_name)
	if player_role ~= "admin" and custom_state.player_name == owner then
		player_role = "owner"
	elseif player_role == "survival" or player_role == "creative" then
		player_role = "player"
	end
	-- pos, node, meta
	local formspec = {
		ch_core.formspec_header({
			formspec_version = 4,
			size = {10.75, 8.25},
			-- bgcolor = {"#080808BB", "true"},
			listcolors = {"#00000069", "#5A5A5A", "#141318", "#30434C", "#FFF"},
			-- background = {"5,5", "1,1", "gui_formbg.png", "true"},
			auto_background = true,
		}),
		"list[nodemeta:"..pos.x.."\\,"..pos.y.."\\,"..pos.z..";upgrades;2,0.5;1,1;]"..
		"list[current_player;main;0.5,3;8,4;]"..
		"checkbox[2,2.25;public;veřejný zásobník;",
		ifthenelse(meta:get_int("public") ~= 0, "true", "false"),
		"]"..
		"button_exit[9.75,0.25;0.75,0.75;close;X]",
	}
	if player_role == "admin" or player_role == "owner" then
		table.insert(formspec, "field[5.25,2;2.75,0.5;owner;vlastník/ice:;"..owner_viewname_fs.."]"..
			"button[8.25,1.75;2,0.75;setowner;nastavit]")
	else
		table.insert(formspec, "label[5.25,2.25;vlastník/ice: "..owner_viewname_fs.."]")
	end
	return table.concat(formspec)
end

local function formspec_callback(custom_state, player, formname, fields)
	if not fields.public and not fields.setowner then
		return
	end
	local player_info = ch_core.normalize_player(player)
	local meta = core.get_meta(custom_state.pos)
	local owner = meta:get_string("owner")
	if player_info.role ~= "admin" and player_info.player_name ~= owner then
		return -- access denied
	end
	if fields.public then
		meta:set_int("public", ifthenelse(fields.public == "true", 1, 0))
	end
	if fields.setowner then
		local new_owner = ch_core.jmeno_na_existujici_prihlasovaci(fields.owner)
		if new_owner ~= nil then
			meta:set_string("owner", new_owner)
		end
	end
	drawers.update_drawer_upgrades(custom_state.pos)
end

function drawers.show_formspec(player, pos, node, meta)
	local player_info = ch_core.normalize_player(player)
	if player_role == "new" then
		ch_core.systemovy_kanal(player_info.player_name, "Turistické postavy nemohou používat zásobníky!")
		return
	end
	local custom_state = {
		player_name = player_info.player_name,
		pos = pos,
	}
	local formspec = get_formspec(custom_state)
	ch_core.show_formspec(player, "drawers:drawer", formspec, formspec_callback, custom_state, {})
end
