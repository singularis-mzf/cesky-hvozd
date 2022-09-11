local function clsc(a, b)
	if a == nil or a == "" then
		return b
	else
		return a
	end
end

local default_model = ch_npc.internal.default_model
local default_textures = ch_npc.internal.default_textures

function ch_npc.update_npc(pos, node, meta)
	local update_meta = meta
	if not meta then
		meta = minetest.get_meta(pos)
	end

	local entity_pos = vector.new(pos.x, pos.y - 0.5, pos.z)
	local should_be_spawned = meta:get_string("enabled") == "true"
	local found_objects = {}

	-- search for existing objects
	local objects_inside_radius = minetest.get_objects_inside_radius(entity_pos, 0.45)
	if objects_inside_radius then
		for _, obj in ipairs(objects_inside_radius) do
			local entity = obj and obj:get_luaentity()
			if entity and entity.name == "ch_npc:npc" then
				table.insert(found_objects, obj)
			end
		end
	end

	if #found_objects > 0 and not should_be_spawned then
		-- remove existing objects
		for _, obj in ipairs(found_objects) do
			local obj_pos = obj:get_pos()
			obj:remove()
			minetest.log("action", "NPC at "..minetest.pos_to_string(obj_pos).." despawned.")
		end
	elseif (#found_objects == 0 and should_be_spawned) or (#found_objects > 0 and update_meta) then
		local model = clsc(meta:get_string("model"), default_model)
		local textures = string.split(clsc(meta:get_string("texture"), default_textures), ";", false, -1, false)
		local npc_name = meta:get_string("npc_name")
		local npc_text = meta:get_string("npc_text")
		local npc_program = clsc(meta:get_string("npc_program"), "default")

		local props_to_set = {
			mesh = model,
			textures = textures,
			infotext = npc_name,
			_npc_text = npc_text,
		}

		if #found_objects == 0 then
			-- spawn a new NPC
			local entity = minetest.add_entity(entity_pos, "ch_npc:npc")
			local dir = minetest.facedir_to_dir((node.param2 + 2) % 4)
			local rot = vector.dir_to_rotation(dir)
			entity:set_rotation(rot)
			entity:set_properties(props_to_set)
			minetest.log("action", "Spawned a new NPC at "..minetest.pos_to_string(entity_pos)..".")
		else
			-- update metadata of existing NPCs
			for _, obj in ipairs(found_objects) do
				local obj_pos = obj:get_pos()
				obj:set_properties(props_to_set)
				minetest.log("action", "NPC at "..minetest.pos_to_string(obj_pos).." updated.")
			end
		end
	end

	if should_be_spawned and node.name ~= "ch_npc:npc" then
		minetest.swap_node(pos, { name = "ch_npc:npc" })
	elseif not should_be_spawned and node.name ~= "ch_npc:npc_hidden" then
		minetest.swap_node(pos, { name = "ch_npc:npc_hidden" })
	end
end
