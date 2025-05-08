local creeper_face = {
	{"#00FF00", "#00FF00", "#00FF00", "#000000", "#000000", "#00FF00", "#00FF00", "#00FF00"},
	{"#00FF00", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#00FF00"},
	{"#000000", "#000000", "#00FF00", "#00FF00", "#00FF00", "#00FF00", "#000000", "#000000"},
	{"#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000"},
	{"#000000", "#00FF00", "#00FF00", "#000000", "#000000", "#00FF00", "#00FF00", "#000000"},
	{"#00FF00", "#00FF00", "#00FF00", "#000000", "#000000", "#00FF00", "#00FF00", "#00FF00"},
	{"#00FF00", "#000000", "#00FF00", "#000000", "#000000", "#00FF00", "#000000", "#00FF00"},
	{"#00FF00", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#00FF00"},
}

if minetest.get_modpath("mcl_core") or minetest.get_modpath("vlf_core") then
	register_firework_entity("fireworks_reimagined:creeper_firework_entity", {
		firework_shape = "test",
		time_remaining = 3,
		firework_explosion = function(pos, shape)
			register_firework_explosion(pos, 0.2, creeper_face, 3)
		end
	})
	register_firework_node("creeper", "fireworks_reimagined:creeper_firework_entity", 0)
end
