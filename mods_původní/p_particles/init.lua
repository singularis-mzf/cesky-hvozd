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
					size = 1,
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

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
  if punch_particles then
  	particle_node(pos, node)
  end
end)

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
  if place_particles then
		if pointed_thing.type == "node" and minetest.get_node(pointed_thing.under) then
			particle_node(pointed_thing.under, minetest.get_node(pointed_thing.under))
		end
    particle_node(pos, newnode)
  end
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
	if dug_particles then
		particle_node(pos, oldnode, true)
	end
end)
