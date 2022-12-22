local S = minetest.get_translator("itemframes")

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local entity_args = {}
local sd_disallow = minetest.get_modpath("screwdriver") and screwdriver.disallow or nil

minetest.register_entity("itemframes:item",{
	hp_max = 1,
	visual="wielditem",
	visual_size={x = 0.33, y = 0.33},
	collisionbox = {0, 0, 0, 0, 0, 0},
	physical = false,
	textures = {"air"},
	on_activate = function(self, staticdata)
		if entity_args.nodename ~= nil and entity_args.texture ~= nil then
			self.nodename = entity_args.nodename
			self.texture = entity_args.texture

			entity_args.nodename = nil
			entity_args.texture = nil
		else
			if staticdata ~= nil and staticdata ~= "" then
				local data = staticdata:split(';')
				if data and data[1] and data[2] then
					self.nodename = data[1]
					self.texture = data[2]
				end
			end
		end
		if self.texture ~= nil then
			self.object:set_properties({textures = {self.texture}})
		end
		if self.nodename == "itemframes:pedestal" then
			self.object:set_properties({automatic_rotate = 1})
		end
		if self.texture ~= nil and self.nodename ~= nil then
			local entity_pos = vector.round(self.object:get_pos())
			local objs = minetest.get_objects_inside_radius(entity_pos, 0.5)
			for _, obj in ipairs(objs) do
				if obj ~= self.object and
				   obj:get_luaentity() and
				   obj:get_luaentity().name == "itemframes:item" and
				   obj:get_luaentity().nodename == self.nodename and
				   obj:get_properties() and
				   obj:get_properties().textures and
				   obj:get_properties().textures[1] == self.texture then
					minetest.log("action","[itemframes] Removing extra " ..
						self.texture .. " found in " .. self.nodename .. " at " ..
						minetest.pos_to_string(entity_pos))
					self.object:remove()
					break
				end
			end
		end
	end,
	get_staticdata = function(self)
		if self.nodename ~= nil and self.texture ~= nil then
			return self.nodename .. ';' .. self.texture
		end
		return ""
	end,
})

local upvectors = {
	[0] = vector.new(0, 1, 0),
	[1] = vector.new(0, 0, 1),
	[2] = vector.new(0, 0, -1),
	[3] = vector.new(1, 0, 0),
	[4] = vector.new(-1, 0, 0),
	[5] = vector.new(0, -1, 0),
}

local function facedir_to_rotation(param2)
	param2 = param2 % 24
	return vector.dir_to_rotation(minetest.facedir_to_dir(param2), upvectors[math.floor(param2 / 4)])
end

local function is_locked(meta, player_name)
	return meta:get_int("locked") ~= 0 and player_name ~= meta:get_string("owner") and not minetest.check_player_privs(player_name, "protection_bypass")
end

local function remove_item(pos, node)
	local objs = nil
	local kind = minetest.get_item_group(node.name, "itemframe")
	if kind == 1 then
		objs = minetest.get_objects_inside_radius(pos, .5)
	elseif kind == 2 then
		objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y+1,z=pos.z}, .5)
	end
	if objs then
		for _, obj in ipairs(objs) do
			if obj and obj:get_luaentity() and obj:get_luaentity().name == "itemframes:item" then
				obj:remove()
			end
		end
	end
end

local function update_item(pos, node)
	local kind = minetest.get_item_group(node.name, "itemframe")
	if kind ~= 1 and kind ~= 2 then
		return
	end
	remove_item(pos, node)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack("item", 1)
	if not stack:is_empty() then
		local item = stack:get_name()
		local entity_pos
		if kind == 1 then
			entity_pos = vector.add(pos, vector.multiply(minetest.facedir_to_dir(node.param2), 6.5 / 16))
		else
			entity_pos = vector.offset(pos, 0, 12 / 16 + 0.33, 0)
		end
		entity_args.nodename = node.name
		entity_args.texture = item
		local e = minetest.add_entity(entity_pos,"itemframes:item")
		if minetest.get_item_group(node.name, "itemframe") == 1 then
			e:set_rotation(facedir_to_rotation(node.param2))
		end
	end
end

local function on_construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("item", 1)
end

local function get_formspec(pos, player)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local owner, locked = meta:get_string("owner"), meta:get_int("locked")
	local kind = minetest.get_item_group(node.name, "itemframe")

	local formspec = {
		"formspec_version[4]",
		"size[10.75,8.25]",
		"item_image[0.5,0.5;0.8,0.8;"..node.name.."]",
		"list[nodemeta:", pos.x, ",", pos.y, ",", pos.z, ";item;1.5,0.4;1,1;]",
		"label[3.0,0.75;Vlastník/ice: ", ch_core.prihlasovaci_na_zobrazovaci(owner), "]",
		"label[3.0,1.25;Soukrom", kind == 1 and "á" or "ý", ": ", locked == 0 and "ne" or "ano", "]",
		"button[5.25,1.0;4,0.5;", locked == 0 and "" or "un", "lock;přepnout na ",
		locked == 0 and "soukrom" or "veřejn", kind == 1 and "ou" or "ý", "]",
		"list[current_player;main;0.5,2.0;8,4;]",
		"listring[]",
		"button_exit[0.5,7;9.8,0.75;zavrit;Zavřít]",
	}

	return table.concat(formspec)
end

local function formspec_callback(custom_state, player, formname, fields)
	local pos = custom_state.pos
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "itemframe") == 0 then
		return false
	end
	if not fields.quit then
		local player_name = player:get_player_name()
		local meta = minetest.get_meta(pos)
		if player_name == meta:get_string("owner") or minetest.check_player_privs(player_name, "protection_bypass") then
			if fields.lock then
				meta:set_int("locked", 1)
			end
			if fields.unlock then
				meta:set_int("locked", 0)
			end
		end

		return get_formspec(pos, player)
	end
end

local function on_rightclick(pos, node, clicker, itemstack)
	if clicker and clicker:get_player_name() then
		ch_core.show_formspec(clicker, "itemframes:formspec", get_formspec(pos, clicker), formspec_callback, {pos = pos}, {})
	end
end

local function can_dig(pos, player)
	if not player then return end
	local name = player and player:get_player_name()
	local meta = minetest.get_meta(pos)
	return not is_locked(meta, name)
end

local function after_place_node(pos, placer, itemstack)
	local meta = minetest.get_meta(pos)
	meta:set_string("owner", placer:get_player_name())
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	local player_name = player and player:get_player_name()
	if not player_name then
		return 0
	end
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return 0
	end
	local meta = minetest.get_meta(pos)
	if is_locked(meta, player_name) then
		return 0
	end
	local inv = meta:get_inventory()
	local new_stack = ItemStack(stack:get_name())
	local old_meta = stack:get_meta()
	local new_meta = new_stack:get_meta()
	new_meta:set_int("palette_index", old_meta:get_int("palette_index"))
	inv:set_stack(listname, index, new_stack)
	update_item(pos, minetest.get_node(pos))
	return 0
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	local player_name = player and player:get_player_name()
	if not player_name then
		return 0
	end
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return 0
	end
	local meta = minetest.get_meta(pos)
	if is_locked(meta, player_name) then
		return 0
	end
	local inv = meta:get_inventory()
	inv:set_stack(listname, index, ItemStack())
	remove_item(pos, minetest.get_node(pos))
	return 0
end

local function on_rotate(pos, node, user, mode, new_param2)
	local player_name = player and player:get_player_name()
	if not player_name then
		return false
	end
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return false
	end
	node.param2 = new_param2
	minetest.swap_node(pos, node)
	update_item(pos, node)
	return true
end

local function on_destruct(pos)
	remove_item(pos, minetest.get_node(pos))
end

local itemframe_node_box = {
	type = "fixed",
	fixed = {-0.5, -0.5, 7/16, 0.5, 0.5, 0.5}
}

local def = {
	description = S("Item frame"),
	drawtype = "nodebox",
	node_box = itemframe_node_box,
	selection_box = itemframe_node_box,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {choppy = 2, dig_immediate = 2, itemframe = 1},
	sounds = default.node_sound_wood_defaults(),

	after_place_node = after_place_node,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	can_dig = can_dig,
	on_construct = on_construct,
	on_destruct = on_destruct,
	on_punch = update_item,
	on_rightclick = on_rightclick,
	on_rotate = on_rotate,
}

ch_core.register_nodes(def,
	{
		["itemframes:frame"] = {
			description = S("Item frame"),
			tiles = {"itemframes_frame.png"},
			inventory_image = "itemframes_frame.png",
			wield_image = "itemframes_frame.png",
		},
		["itemframes:frame_brown"] = {
			description = S("Item frame (brown)"),
			tiles = {"itemframes_frame_brown.png"},
			inventory_image = "itemframes_frame_brown.png",
			wield_image = "itemframes_frame_brown.png",
		},
		["itemframes:frame_invis"] = {
			description = S("Item frame (invisible)"),
			tiles = {"itemframes_invisible.png"},
			inventory_image = "itemframes_invisible_inv.png^default_invisible_node_overlay.png",
			wield_image = "itemframes_invisible.png^default_invisible_node_overlay.png",
			use_texture_alpha = "clip",
			walkable = false,
		},
	},
	{
		{
			output = 'itemframes:frame',
			recipe = {
				{'group:stick', 'group:stick', 'group:stick'},
				{'group:stick', homedecor.materials.paper, 'default:stick'},
				{'group:stick', 'group:stick', 'group:stick'},
			}
		},
		{
			output = 'itemframes:frame_brown',
			recipe = {
				{'group:stick', 'group:stick', 'group:stick'},
				{'group:stick', 'group:wood', 'default:stick'},
				{'group:stick', 'group:stick', 'group:stick'},
			}
		},
		{
			output = "itemframes:frame_invis",
			recipe = {{homedecor.materials.paper, "mesecons_materials:glue"}}
		},
	});

def = {
	description = S("Pedestal"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed", fixed = {
			{-7/16, -8/16, -7/16, 7/16, -7/16, 7/16}, -- bottom plate
			{-6/16, -7/16, -6/16, 6/16, -6/16, 6/16}, -- bottom plate (upper)
			{-0.25, -6/16, -0.25, 0.25, 11/16, 0.25}, -- pillar
			{-7/16, 11/16, -7/16, 7/16, 12/16, 7/16}, -- top plate
		}
	},
	--selection_box = {
	--	type = "fixed",
	--	fixed = {-7/16, -0.5, -7/16, 7/16, 12/16, 7/16}
	--},
	tiles = {"itemframes_pedestal.png"},
	paramtype = "light",
	groups = {cracky = 3, dig_stone = 2, itemframe = 2},
	sounds = default.node_sound_stone_defaults(),

	after_place_node = after_place_node,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	can_dig = can_dig,
	on_construct = on_construct,
	on_destruct = on_destruct,
	on_punch = update_item,
	on_rightclick = on_rightclick,
	on_rotate = sd_disallow,
}
minetest.register_node("itemframes:pedestal", def)

-- automatically restore entities lost from frames/pedestals
-- due to /clearobjects or similar
minetest.register_lbm({
	label = "Maintain itemframe and pedestal entities",
	name = "itemframes:maintain_entities",
	nodenames = {"group:itemframe"},
	run_at_every_load = true,
	action = function(pos1, node1)
		minetest.after(0,
			function(pos, node)
				local meta = minetest.get_meta(pos)
				local itemstring = meta:get_string("item")
				if itemstring ~= "" then
					local kind, entity_pos = minetest.get_item_group(node.name, "itemframe")
					if kind == 1 then
						entity_pos = pos
					elseif kind == 2 then
						entity_pos = vector.offset(pos, 0, 1, 0)
					else
						return
					end
					local objs = minetest.get_objects_inside_radius(entity_pos, 0.5)
					if #objs == 0 then
						minetest.log("action","[itemframes] Replacing missing " ..
							itemstring .. " in " .. node.name .. " at " ..
							minetest.pos_to_string(pos))
						update_item(pos, node)
					end
				end
			end,
		pos1, node1)
	end
})

minetest.register_lbm({
	label = "Convert old itemframes and pedestals",
	name = "itemframes:convert_old",
	nodenames = {"group:itemframe"},
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if not inv:get_lists()["item"] then
			-- old itemframe found!
			minetest.log("warning", "Old "..node.name.." found at "..minetest.pos_to_string(pos))
			inv:set_size("item", 1)
			meta:set_string("infotext", "")
			local item = meta:get_string("item")
			if item ~= "" then
				inv:set_stack("item", 1, ItemStack(item))
			end
			meta:set_string("item", "")
			minetest.after(1, update_item, pos, node)
		end
	end
})

minetest.register_craft({
	output = 'itemframes:pedestal',
	recipe = {
		{homedecor.materials.stone, homedecor.materials.stone, homedecor.materials.stone},
		{'', homedecor.materials.stone, ''},
		{'', homedecor.materials.stone, ''},
	}
})

-- stop mesecon pistons from pushing itemframes and pedestals
if minetest.get_modpath("mesecons_mvps") then
	mesecon.register_mvps_stopper("itemframes:frame")
	mesecon.register_mvps_stopper("itemframes:pedestal")
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

