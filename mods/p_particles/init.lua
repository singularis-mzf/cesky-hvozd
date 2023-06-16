-- This code creates particles
-- viewable by seperate parties when punching or placing a node,
-- both are disablable in settings if you only wish to have one.
-- there are also less noticeable particles from the surrounding nodes when one is dug

--NOTE: Punch particles already exist and are built in but this mod simply adds more for beauty

local punch_particles = minetest.settings:get_bool("punch_particles", true)
local place_particles = minetest.settings:get_bool("place_particles", true)
local dug_particles = minetest.settings:get_bool("dug_particles", true)



local function get_node_side_particles(pos, i)
	sides = {
		vector.new(pos.x+(math.random(-50, 50)/100), pos.y+math.random(0.51, 0.51), pos.z+(math.random(-50, 50)/100)),
		vector.new(pos.x+(math.random(-50, 50)/100), pos.y+math.random(-0.51, -0.51), pos.z+(math.random(-50, 50)/100)),

		vector.new(pos.x+math.random(0.51, 0.51), pos.y+(math.random(-50, 50)/100), pos.z+(math.random(-50, 50)/100)),
		vector.new(pos.x+math.random(-0.51, -0.51), pos.y+(math.random(-50, 50)/100), pos.z+(math.random(-50, 50)/100)),

		vector.new(pos.x+(math.random(-50, 50)/100), pos.y+(math.random(-50, 50)/100), pos.z+math.random(0.51, 0.51)),
		vector.new(pos.x+(math.random(-50, 50)/100), pos.y+(math.random(-50, 50)/100), pos.z+math.random(-0.51, -0.51)),
	}
	return sides[i]
end

local function particle_node(pos, node, inside)
	local def = minetest.registered_nodes[node.name]
	for i=1, 6 do
		for _i = 1, 10 do
			local roundnode = minetest.get_node(get_node_side_particles(pos, i))
			local _node = node
			if inside then
				_node = roundnode
			end

			if not roundnode or roundnode and (roundnode.name == "air" or roundnode.name == "ignore") or inside then
				minetest.add_particle({
					pos = get_node_side_particles(pos, i),
					velocity = vector.add(vector.zero(), { x = math.random(-10, 10)/100, y = math.random(-10, 10)/100, z = math.random(-10, 10)/100 }),
					acceleration = { x = 0, y = -9.81, z = 0 },
					expirationtime = math.random(5,40)/100,
					size = 0,
					collisiondetection = true,
					vertical = false,
					drag = vector.new(1,1,1),
					node = _node,
					node_tile = i,
				})
			end
		end
	end
end

local groups_1 = {"crumbly", "cracky", "snappy", "choppy", "wood", "tree"}
local falses = {on_punch = false, on_placenode = false, on_dignode = false}
local generates_particles_cache = {air = falses, ignore = falses}

local function generates_particles(node_name)
	local result = generates_particles_cache[node_name]
	if result ~= nil then
		return result
	end
	local ndef = minetest.registered_nodes[node_name]
	if ndef == nil then
		minetest.log("warning", "generates_particles_cache["..node_name.."] cached as falses, because it is an unknown node!")
		generates_particles_cache[node_name] = falses
		return falses
	end
	result = table.copy(falses)
	for _, group in ipairs(groups_1) do
		if minetest.get_item_group(node_name, group) > 0 then
			result.on_punchnode = true
		end
	end
	if ((ndef.sounds or {}).dug or {}).name == "default_dug_metal" then
		result.on_punchnode = false
	end
	if result.on_punchnode then
		result.on_placenode = true
	end
	if result.on_punchnode or (ndef.liquidtype or "none") == "none" and (ndef.drawtype or "normal") == "normal" then
		result.on_dignode = true
	end
	if not place_particles then
		result.on_placenode = false
	end
	if not dug_particles then
		result.on_dignode = false
	end
	if not punch_particles then
		result.on_punchnode = false
	end
	if not (result.on_placenode or result.on_punchnode or result.on_dignode) then
		result = falses
	end
	-- minetest.log("warning", "DEBUG: liquid_type == '"..(ndef.liquidtype or "none").."', drawtype == '"..(ndef.drawtype or "normal").."', place_particles == "..(place_particles and "true" or "false")..", dug_particles == "..(dug_particles and "true" or "false"))
	generates_particles_cache[node_name] = result
	return result
end

local function on_punchnode(pos, node, puncher, pointed_thing)
	local node_def, node_groups, wielded_item, tool_def, tool_capabilities, is_diggable

	node_def = minetest.registered_nodes[node.name]
	if node_def == nil then return end -- unknown node
	node_groups = node_def.groups or {}
	wielded_item = puncher and puncher:is_player() and puncher:get_wielded_item()
	if wielded_item == nil then return end -- puncher is not a player
	if wielded_item:is_empty() then return end -- player has not a tool
	tool_def = minetest.registered_items[wielded_item:get_name()]
	if tool_def == nil then return end -- wielded tool is undefined
	tool_capabilities = tool_def.tool_capabilities
	is_diggable = (tool_capabilities ~= nil and minetest.get_dig_params(node_groups, tool_capabilities).diggable) or minetest.get_dig_params(node_groups, minetest.registered_items[""].tool_capabilities).diggable
	if not is_diggable then return end -- the node is not diggable by this tool

	if generates_particles(node.name).on_punch then
		particle_node(pos, node)
	end
end

local function on_placenode(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if pointed_thing == nil then
		return -- probably automated placing of nodes
	end
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pos)
		if generates_particles(node.name).on_placenode then
			particle_node(pos, node)
		end
	end
	if generates_particles(newnode.name).on_placenode then
		particle_node(pos, newnode)
	end
end

local function on_dignode(pos, oldnode, digger)
	if generates_particles(oldnode.name).on_dignode then
		particle_node(pos, oldnode, true)
	end
end

minetest.register_on_punchnode(on_punchnode)
minetest.register_on_placenode(on_placenode)
minetest.register_on_dignode(on_dignode)
