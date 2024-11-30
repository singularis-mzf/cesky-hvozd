--[[
		display_api mod for Minetest - Library to add dynamic display
		capabilities to nodes
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

-- Prefered gap between node and entity
-- Entity positionment is up to mods but it is a good practice to use this
-- variable as spacing between entity and node
display_api.entity_spacing = 0.002

-- Maximum entity position relative to the node pos
local max_entity_pos = 1.5

local wallmounted_rotations = {
	[0]={x=1, y=0, z=0}, [1]={x=3, y=0, z=0},
	[2]={x=0, y=3, z=0}, [3]={x=0, y=1, z=0},
	[4]={x=0, y=0, z=0}, [5]={x=0, y=2, z=0},
	[6]={x=1, y=0, z=0}, [7]={x=1, y=1, z=1},
}

local facedir_rotations = {
	[ 0]={x=0, y=0, z=0}, [ 1]={x=0, y=3, z=0},
	[ 2]={x=0, y=2, z=0}, [ 3]={x=0, y=1, z=0},
	[ 4]={x=3, y=0, z=0}, [ 5]={x=0, y=3, z=3},
	[ 6]={x=1, y=0, z=2}, [ 7]={x=0, y=1, z=1},
	[ 8]={x=1, y=0, z=0}, [ 9]={x=0, y=3, z=1},
	[10]={x=3, y=0, z=2}, [11]={x=0, y=1, z=3},
	[12]={x=0, y=0, z=1}, [13]={x=3, y=0, z=1},
	[14]={x=2, y=0, z=1}, [15]={x=1, y=0, z=1},
	[16]={x=0, y=0, z=3}, [17]={x=1, y=0, z=3},
	[18]={x=2, y=0, z=3}, [19]={x=3, y=0, z=3},
	[20]={x=0, y=0, z=2}, [21]={x=0, y=1, z=2},
	[22]={x=0, y=2, z=2}, [23]={x=0, y=3, z=2},
}

-- Compute other useful values depending on wallmounted and facedir param
local wallmounted_values = {}
local facedir_values = {}

local function compute_values(r)
	local function rx(v) return { x=v.x, y=v.z, z=-v.y} end
	local function ry(v) return { x=-v.z, y=v.y, z=v.x} end
	local function rz(v) return { x=v.y, y=-v.x, z=v.z} end

	local d = { x = 0, y = 0, z = 1 }
	local w = { x = 1, y = 0, z = 0 }
	local h = { x = 0, y = 1, z = 0 }

	-- Important to keep z rotation first (not same results)
	for _ = 1, r.z do d, w, h = rz(d), rz(w), rz(h) end
	for _ = 1, r.x do d, w, h = rx(d), rx(w), rx(h) end
	for _ = 1, r.y do d, w, h = ry(d), ry(w), ry(h) end

	return {
		rotation=r, depth=d, width=w, height=h,
		restricted=(r.x==0 and r.z==0) }
end

for i, r in pairs(facedir_rotations) do
	facedir_values[i] = compute_values(r)
end

for i, r in pairs(wallmounted_rotations) do
	wallmounted_values[i] = compute_values(r)
end

-- Detect rotation restriction
local rotation_restricted = nil
minetest.register_entity('display_api:dummy_entity', {
	initial_properties = {
		collisionbox = { 0, 0, 0, 0, 0, 0 },
		visual = "upright_sprite",
		textures = {}
	},
})

function display_api.is_rotation_restricted()
	if rotation_restricted == nil then
		local objref = minetest.add_entity(
			{x=0, y=0, z=0}, 'display_api:dummy_entity')
		if objref then
			rotation_restricted = objref.set_rotation == nil
			objref:remove()
		end
	end
	return rotation_restricted
end

-- Clip position property to maximum entity position

local function clip_pos_prop(posprop)
	if posprop then
		return math.max(-max_entity_pos, math.min(max_entity_pos, posprop))
	else
		return 0
	end
end

-- Get values needed for orientation computation of node

local function get_orientation_values(node)
	local ndef = minetest.registered_nodes[node.name]

	if ndef then
		local paramtype2 = ndef.paramtype2
		if paramtype2 == "wallmounted" or paramtype2 == "colorwallmounted" then
			return wallmounted_values[node.param2 % 8]
		elseif paramtype2 == "facedir" or paramtype2 == "colorfacedir"  then
			return facedir_values[node.param2 % 32]
		else
			-- No orientation or unknown orientation type
			return facedir_values[0]
		end
	end
end

-- Gets the display entities attached with a node.
-- Add missing and remove duplicates

local function get_display_objrefs(pos, create)
	local objrefs = {}
	local node = minetest.get_node_or_nil(pos)
	if node == nil then
		return objrefs
	end
	local meta = minetest.get_meta(pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef and ndef.display_entities then
		for name, _ in pairs(ndef.display_entities) do
			local handle = meta:get_int("display_entity_"..name)
			if handle ~= 0 then
				local entity, objref = ch_core.get_entity_by_handle(handle, name)
				if entity ~= nil then
					objrefs[name] = assert(objref)
				end
			end
		end
		--[[
		for _, objref in
			ipairs(minetest.get_objects_inside_radius(pos, max_entity_pos)) do
			local entity = objref:get_luaentity()
			if entity and ndef.display_entities[entity.name] and
				 entity.nodepos and vector.equals(pos, entity.nodepos) then
				if objrefs[entity.name] then
					objref:remove() -- Remove duplicates
				else
					objrefs[entity.name] = objref
				end
			end
		end
		]]
		if create then
			-- Add missing
			for name, _ in pairs(ndef.display_entities) do
				if not objrefs[name] then
					local new_object = minetest.add_entity(pos, name, minetest.serialize({ nodepos = pos }))
					local new_entity = new_object:get_luaentity()
					local new_handle = ch_core.get_handle_of_entity(new_entity)
					if new_handle ~= nil then
						meta:set_int("display_entity_"..name, new_handle)
						objrefs[name] = new_object
					end
				end
			end
		end
	end
	return objrefs
end

--- Force entity update : position and texture
function display_api.update_entities(pos)

	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	local ov = get_orientation_values(node)
	if not ndef or not ov then
		return
	end

	for _, objref in pairs(get_display_objrefs(pos, true)) do
		local edef = ndef.display_entities[objref:get_luaentity().name]
		local depth = clip_pos_prop(edef.depth)
		local right = clip_pos_prop(edef.right)
		local top = clip_pos_prop(edef.top)

		objref:set_pos({
			x = pos.x + ov.depth.x*depth + ov.width.x*right - ov.height.x*top,
			y = pos.y + ov.depth.y*depth + ov.width.y*right - ov.height.y*top,
			z = pos.z + ov.depth.z*depth + ov.width.z*right - ov.height.z*top,
		})

		if objref.set_rotation then
			objref:set_rotation({
				x = ov.rotation.x*math.pi/2 + (edef.pitch or 0),
				y = ov.rotation.y*math.pi/2 + (edef.yaw or 0),
				z = ov.rotation.z*math.pi/2,
			})
		else
			if ov.rotation.x ~=0 or ov.rotation.y ~= 0 then
				minetest.log("warning", string.format(
					"[display_api] unable to rotate correctly entity for node at %s without set_rotation method.",
					minetest.pos_to_string(pos)))
			end
			objref:set_yaw(ov.rotation.y*math.pi/2 + (edef.yaw or 0))
		end

		-- Call on_display_update callback of a node for one of its display entities
		if edef.on_display_update then
			edef.on_display_update(pos, objref)
		end
	end
end

--- On_activate callback for display_api entities. Calls on_display_update callbacks
--- of corresponding node for each entity.
function display_api.on_activate(entity, staticdata)
	if entity then
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = minetest.deserialize(staticdata)
			if data and type(data) == "table" then
				entity.nodepos = data.nodepos
			end
			entity.object:set_armor_groups({immortal=1})
		end

		if entity.nodepos then
			local node = core.get_node(entity.nodepos)
			local ndef = core.registered_nodes[node.name]
			if ndef and ndef.display_entities then
				local edef = ndef.display_entities[entity.name]
				if edef then
					local meta = core.get_meta(entity.nodepos)
					local meta_name = "display_entity_"..entity.name
					local old_handle = meta:get_int(meta_name)
					if old_handle == 0 then
						old_handle = nil
					end
					local new_handle, error_message = ch_core.register_entity(entity, old_handle)
					if new_handle == nil then
						-- entity registration failed!
						core.log("error", "Entity registration failed: "..(error_message or "nil"))
					else
						if old_handle == nil or new_handle ~= old_handle then
							meta:set_int(meta_name, new_handle)
							print("DEBUG: handle metadata "..meta_name.." updated to "..new_handle.." at "..core.pos_to_string(entity.nodepos))
						end
						-- Call on_display_update callback of the entity to build texture
						if edef.on_display_update then
							edef.on_display_update(entity.nodepos, entity.object)
						end
						return
					end
				end
			end
		end
		-- If we got here, this display entity is buggy and should be removed
		entity.object:remove()
	end
end

--- On_place callback for display_api items.
-- Does nothing more than preventing node from being placed on ceiling or ground
-- TODO:When MT<5 is not in use anymore, simplify this
function display_api.on_place(itemstack, placer, pointed_thing, override_param2)
	local ndef = itemstack:get_definition()
	local dir = {
		x = pointed_thing.under.x - pointed_thing.above.x,
		y = pointed_thing.under.y - pointed_thing.above.y,
		z = pointed_thing.under.z - pointed_thing.above.z,
	}

	local rotation_restriction = display_api.is_rotation_restricted()

	if rotation_restriction then
		-- If item is not placed on a wall, use the player's view direction instead
		if dir.x == 0 and dir.z == 0 then
			dir = placer:get_look_dir()
		end
		dir.y = 0
	end

	local param2 = 0
	if ndef then
		if ndef.paramtype2 == "wallmounted" or
			ndef.paramtype2 == "colorwallmounted" then
			param2 = minetest.dir_to_wallmounted(dir)

		elseif ndef.paramtype2 == "facedir" or
			ndef.paramtype2 == "colorfacedir"  then
			param2 = minetest.dir_to_facedir(dir, not rotation_restriction)
		end
	end
	return minetest.item_place(itemstack, placer, pointed_thing,
		param2 + (override_param2 or 0))
end

--- On_construct callback for display_api items.
-- Creates entities and update them.
function display_api.on_construct(pos)
	display_api.update_entities(pos)
end

--- On_destruct callback for display_api items.
-- Removes entities.
function display_api.on_destruct(pos)
	for _, objref in pairs(get_display_objrefs(pos)) do
		objref:remove()
	end
end

-- On_rotate (screwdriver) callback for display_api items. Prevents invalid
-- rotations and reorients entities.
function display_api.on_rotate(pos, node, user, _, new_param2)
	node.param2 = new_param2
	local ov = get_orientation_values(node)
	if not ov then
		return
	end

	if ov.restricted or not display_api.is_rotation_restricted() then
		minetest.swap_node(pos, node)
		display_api.update_entities(pos)
		return true
	else
		return false
	end
end

--- Creates display entity with some fields and the on_activate callback
function display_api.register_display_entity(entity_name)
	if not minetest.registered_entities[entity_name] then
		minetest.register_entity(':'..entity_name, {
			initial_properties = {
				collisionbox = { 0, 0, 0, 0, 0, 0 },
				visual = "upright_sprite",
				textures = {},
				pointable = false,
			},
			on_activate = display_api.on_activate,
			on_deactivate = ch_core.unregister_entity,
			get_staticdata = function(self)
				return minetest.serialize({ nodepos = self.nodepos })
			end,
		})
	end
end

minetest.register_lbm({
	label = "Update display_api entities",
	name = "display_api:update_entities",
	run_at_every_load = true,
	nodenames = {"group:display_api",
		"group:display_modpack_node", "group:display_lib_node"}, -- See deprecated(1)
	action = function(pos, node) display_api.update_entities(pos) end,
})
