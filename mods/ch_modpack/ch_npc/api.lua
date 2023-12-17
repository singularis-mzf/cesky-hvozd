local default_npc = ch_npc.registered_npcs["default"]

function ch_npc.update_npc(pos, node, meta)
	if not meta then
		meta = minetest.get_meta(pos)
	end
	local should_be_spawned = meta:get_string("enabled") == "true"
	local old_model = meta:get_string("shown_model")
	local old_npc = ch_npc.registered_npcs[old_model]
	local old_entity_pos = vector.add(pos, (old_npc or default_npc).offset)

	-- search for existing objects
	local found_objects = {}
	if old_npc ~= nil then
		local objects_inside_radius = minetest.get_objects_inside_radius(old_entity_pos, 0.45)
		for _, obj in ipairs(objects_inside_radius) do
			local entity = obj and obj:get_luaentity()
			if entity and entity.name == "ch_npc:npc" then
				table.insert(found_objects, obj)
			end
		end
	end

	if (not should_be_spawned and #found_objects > 0) or (should_be_spawned and #found_objects > 1)  then
		-- remove existing objects
		for _, obj in ipairs(found_objects) do
			local obj_pos = obj:get_pos()
			obj:remove()
			minetest.log("action", "NPC at "..minetest.pos_to_string(obj_pos).." despawned.")
		end
		found_objects = {}
		meta:set_string("shown_model", "")
	end

	if should_be_spawned then
		local new_model = meta:get_string("npc_model")
		local new_npc = ch_npc.registered_npcs[new_model]
		if not new_npc then
			new_model = "default"
			new_npc = default_npc
		end
		local new_entity_pos = vector.add(pos, new_npc.offset)
		local npc_name = meta:get_string("npc_name")
		local npc_dialog = meta:get_string("npc_dialog")

		local props_to_set = {
			mesh = new_npc.mesh,
			textures = new_npc.textures,
			collisionbox = new_npc.collisionbox,
			infotext = npc_name,
		}

		if #found_objects == 0 then
			-- spawn a new NPC
			local obj = minetest.add_entity(new_entity_pos, "ch_npc:npc")
			local entity = obj:get_luaentity()
			if not entity.memory then entity.memory = {} end -- workaround because of mobkit crash
			local rotation = vector.dir_to_rotation(minetest.facedir_to_dir((node.param2 + 2) % 4))
			obj:set_rotation(rotation)
			obj:set_properties(props_to_set)
			mobkit.remember(entity, "node_pos", vector.new(pos.x, pos.y, pos.z))
			meta:set_string("shown_model", new_model)
			minetest.log("action", "Spawned a new NPC at "..minetest.pos_to_string(new_entity_pos)..".")
		else
			-- update metadata of an existing NPC
			local obj = found_objects[1]
			local entity = obj:get_luaentity()
			local old_pos = obj:get_pos()
			obj:set_properties(props_to_set)
			obj:set_pos(new_entity_pos)
			mobkit.remember(entity, "node_pos", vector.new(pos.x, pos.y, pos.z))
			meta:set_string("shown_model", new_model)
			minetest.log("action", "NPC at "..minetest.pos_to_string(old_pos).." => "..minetest.pos_to_string(new_entity_pos).." updated.")
		end
	end

	if should_be_spawned and node.name ~= "ch_npc:npc" then
		minetest.swap_node(pos, { name = "ch_npc:npc" })
	elseif not should_be_spawned and node.name ~= "ch_npc:npc_hidden" then
		minetest.swap_node(pos, { name = "ch_npc:npc_hidden" })
	end
end
