local register_firework_node = fireworks_reimagined.register_firework_node
register_firework_node(nil, "sphere", nil, nil, nil, true)
register_firework_node(nil, "star", nil, nil, nil, true)
register_firework_node(nil, "ring", nil, nil, nil, true)
register_firework_node(nil, "burst", nil, nil, nil, true)
register_firework_node(nil, "cube", nil, nil, nil, true)
--register_firework_node(nil, "spiral", nil, nil, nil, true)
register_firework_node(nil, "chaotic", nil, nil, nil, nil)
register_firework_node(nil, "flame", nil, nil, nil, true)
register_firework_node(nil, "snowflake", nil, nil, nil, true)
register_firework_node(nil, "christmas_tree", nil, nil, nil, true)
register_firework_node(nil, "present", nil, nil, nil, true)
register_firework_node(nil, "hour_glass", nil, nil, nil, true)

fireworks_reimagined.register_firework_entity("fireworks_reimagined:moving_spiral_entity", {
	spiral = true,
	spiral_force = 10,
	firework_explosion = function(pos, color1, color2)
		fireworks_reimagined.spawn_firework_explosion(pos, color1, color2, "255", nil, nil)
	end,
	on_activate = function(self, staticdata, dtime_s)
        local obj = self.object
        local pos = obj:get_pos()

        minetest.add_particlespawner({
            amount = 20,
            time = 0,
            minpos = {x = 0, y = 0, z = 0},
            maxpos = {x = 0, y = 0, z = 0},
            minvel = {x = -1, y = 1, z = -1},
            maxvel = {x = 1, y = 2, z = 1},
            minacc = {x = 0, y = -9.81, z = 0},
            maxacc = {x = 0, y = -9.81, z = 0},
            minexptime = 1,
            maxexptime = 2,
            minsize = 1,
            maxsize = 2,
            collisiondetection = true,
            collision_removal = true,
            vertical = false,
            texture = "black.png^[colorize:" .. "#FF0000",
            attached = obj
        })
    end,
})

fireworks_reimagined.register_firework_entity("fireworks_reimagined:spiral_firework_entity", {
	spiral = true,
	spiral_force = 30,
	thrust = 15,
	spiral_radius = 0.1,
	firework_explosion = function(pos, color1, color2)
		fireworks_reimagined.spawn_firework_explosion(pos, color1, color2, "255", nil, nil)
	end,
})

fireworks_reimagined.register_firework_node(nil, "spiral", nil, nil, nil, nil, true)
