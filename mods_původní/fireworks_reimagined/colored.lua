-- RED
fireworks_reimagined.register_firework_entity("fireworks_reimagined:red_firework_entity", {
	firework_explosion = function(pos, color1, color2)
		fireworks_reimagined.spawn_firework_explosion(pos, "#FF0000", "#FF0000", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "red", "fireworks_reimagined:red_firework_entity", nil, nil)
-- YELLOW
fireworks_reimagined.register_firework_entity("fireworks_reimagined:yellow_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#FFFF00", "#FFFF00", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "yellow", "fireworks_reimagined:yellow_firework_entity", nil, nil)
-- BLUE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:blue_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#0404B4", "#0404b4", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "blue", "fireworks_reimagined:blue_firework_entity", nil, nil)
-- WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:white_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#FFFFFF", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "white", "fireworks_reimagined:white_firework_entity", nil, nil)

minetest.register_alias("fireworks_redo:spawner_red", "fireworks_reimagined:firework_red")
minetest.register_alias("fireworks_redo:spawner_yellow", "fireworks_reimagined:firework_yellow")
minetest.register_alias("fireworks_redo:spawner_blue", "fireworks_reimagined:firework_blue")
minetest.register_alias("fireworks_redo:spawner_white", "fireworks_reimagined:firework_white")


-- RED WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:red_white_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#FF0000", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "red_white", "fireworks_reimagined:red_white_firework_entity", nil, nil)
-- YELLOW WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:yellow_white_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#FFFF00", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "yellow_white", "fireworks_reimagined:yellow_white_firework_entity", nil, nil)
-- BLUE WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:blue_white_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#0404B4", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "blue_white", "fireworks_reimagined:blue_white_firework_entity", nil, nil)



--==============--
--=== SPIRAL ===--
--==============--

-- RED
fireworks_reimagined.register_firework_entity("fireworks_reimagined:red_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#FF0000", "#FF0000", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_red.png", "red_spiral", "fireworks_reimagined:red_spiral_firework_entity", nil, nil)
-- YELLOW
fireworks_reimagined.register_firework_entity("fireworks_reimagined:yellow_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#FFFF00", "#FFFF00", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_yellow.png", "yellow_spiral", "fireworks_reimagined:yellow_spiral_firework_entity", nil, nil)
-- BLUE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:blue_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#0404B4", "#0404B4", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_blue.png", "blue_spiral", "fireworks_reimagined:blue_spiral_firework_entity", nil, nil)
-- WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:white_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#FFFFFF", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_white.png", "white_spiral", "fireworks_reimagined:white_spiral_firework_entity", nil, nil)

minetest.register_alias("fireworks_redo:spawner_red_spiral", "fireworks_reimagined:firework_red_spiral")
minetest.register_alias("fireworks_redo:spawner_yellow_spiral", "fireworks_reimagined:firework_yellow_spiral")
minetest.register_alias("fireworks_redo:spawner_blue_spiral", "fireworks_reimagined:firework_blue_spiral")
minetest.register_alias("fireworks_redo:spawner_white_spiral", "fireworks_reimagined:firework_white_spiral")


-- RED WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:red_white_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#FF0000", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_red_white.png", "red_white_spiral", "fireworks_reimagined:red_white_spiral_firework_entity", nil, nil)
-- YELLOW WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:yellow_white_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#FFFF00", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_yellow_white.png", "yellow_white_spiral", "fireworks_reimagined:yellow_white_spiral_firework_entity", nil, nil)
-- BLUE WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:blue_white_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#0404B4", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_blue_white.png", "blue_white_spiral", "fireworks_reimagined:blue_white_spiral_firework_entity", nil, nil)

-- FIREWORKS MOD COMPAT

-- ORANGE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:orange_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#FF903F", "#FF903F", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "orange", "fireworks_reimagined:orange_firework_entity", nil, nil)
-- GREEN
fireworks_reimagined.register_firework_entity("fireworks_reimagined:green_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#008000", "#008000", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "green", "fireworks_reimagined:green_firework_entity", nil, nil)
-- VIOLET
fireworks_reimagined.register_firework_entity("fireworks_reimagined:violet_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#6600CC", "#6600CC", "255", nil, nil)
	end
})
fireworks_reimagined.register_firework_node(nil, "violet", "fireworks_reimagined:violet_firework_entity", nil, nil)

minetest.register_alias("fireworks:red", "fireworks_reimagined:firework_red")
minetest.register_alias("fireworks:orange", "fireworks_reimagined:firework_orange")
minetest.register_alias("fireworks:green", "fireworks_reimagined:firework_green")
minetest.register_alias("fireworks:violet", "fireworks_reimagined:firework_violet")

-- MULTI

fireworks_reimagined.register_firework_entity("fireworks_reimagined:multi_firework_entity", {
	firework_explosion = function(pos, color1, color2)
		fireworks_reimagined.spawn_firework_explosion(pos, color1, color2, "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "multi", "fireworks_reimagined:multi_firework_entity", nil, nil)

--===================================--
--=== COMPAT FOR YOUR LAND SERVER ===--
--===================================--

fireworks_reimagined.register_firework_entity("fireworks_reimagined:cyan_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "#00C0C0", "#00C0C0", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "cyan", "fireworks_reimagined:cyan_firework_entity", nil, nil)

minetest.register_alias("fireworks_redo:spawner_orange", "fireworks_reimagined:firework_orange")
minetest.register_alias("fireworks_redo:spawner_green", "fireworks_reimagined:firework_green")
minetest.register_alias("fireworks_redo:spawner_purple", "fireworks_reimagined:firework_violet")
minetest.register_alias("fireworks_redo:spawner_cyan", "fireworks_reimagined:firework_cyan")
