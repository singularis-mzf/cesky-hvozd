local are_wires_walkable = mesecon.is_wire_walkable()

local crossover_rules = {
	{--first wire
		{x=-1,y=0,z=0},
		{x=1,y=0,z=0},
	},
	{--second wire
		{x=0,y=0,z=-1},
		{x=0,y=0,z=1},
	},
}

local crossover_states = {
	"mesecons_extrawires:crossover_off",
	"mesecons_extrawires:crossover_01",
	"mesecons_extrawires:crossover_10",
	"mesecons_extrawires:crossover_on",
}

minetest.register_node("mesecons_extrawires:crossover_off", {
	description = "izolovaný mesespoj: křížení",
	drawtype = "mesh",
	mesh = "mesecons_extrawires_crossover.b3d",
	tiles = {
		"jeija_insulated_wire_ends_off.png",
		"jeija_insulated_wire_sides_off.png",
		"jeija_insulated_wire_sides_off.png",
		"jeija_insulated_wire_ends_off.png"
	},
	paramtype = "light",
	is_ground_content = false,
	walkable = are_wires_walkable,
	-- stack_max = 99,
	selection_box = {type="fixed", fixed={-16/32, -16/32, -16/32, 16/32, -5/32, 16/32}},
	groups = mesecon.wire_groups_mesecon3_in_ci,
	sounds = mesecon.node_sound.default,
	mesecons = {
		conductor = {
			states = crossover_states,
			rules = crossover_rules,
		}
	},
	on_blast = mesecon.on_blastnode,
})

minetest.register_node("mesecons_extrawires:crossover_01", {
	description = "Ty hackeře!",
	drop = "mesecons_extrawires:crossover_off",
	drawtype = "mesh",
	mesh = "mesecons_extrawires_crossover.b3d",
	tiles = {
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_sides_on.png",
		"jeija_insulated_wire_sides_off.png",
		"jeija_insulated_wire_ends_off.png"
	},
	paramtype = "light",
	is_ground_content = false,
	walkable = are_wires_walkable,
	-- stack_max = 99,
	selection_box = {type="fixed", fixed={-16/32, -16/32, -16/32, 16/32, -5/32, 16/32}},
	groups = mesecon.wire_groups_mesecon3_not_in_ci,
	sounds = mesecon.node_sound.default,
	mesecons = {
		conductor = {
			states = crossover_states,
			rules = crossover_rules,
		}
	},
	on_blast = mesecon.on_blastnode,
})

minetest.register_node("mesecons_extrawires:crossover_10", {
	description = "Ty hackeře!",
	drop = "mesecons_extrawires:crossover_off",
	drawtype = "mesh",
	mesh = "mesecons_extrawires_crossover.b3d",
	tiles = {
		"jeija_insulated_wire_ends_off.png",
		"jeija_insulated_wire_sides_off.png",
		"jeija_insulated_wire_sides_on.png",
		"jeija_insulated_wire_ends_on.png"
	},
	paramtype = "light",
	is_ground_content = false,
	walkable = are_wires_walkable,
	-- stack_max = 99,
	selection_box = {type="fixed", fixed={-16/32, -16/32, -16/32, 16/32, -5/32, 16/32}},
	groups = mesecon.wire_groups_mesecon3_not_in_ci,
	sounds = mesecon.node_sound.default,
	mesecons = {
		conductor = {
			states = crossover_states,
			rules = crossover_rules,
		}
	},
	on_blast = mesecon.on_blastnode,
})

minetest.register_node("mesecons_extrawires:crossover_on", {
	description = "Ty hackeře!",
	drop = "mesecons_extrawires:crossover_off",
	drawtype = "mesh",
	mesh = "mesecons_extrawires_crossover.b3d",
	tiles = {
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_sides_on.png",
		"jeija_insulated_wire_sides_on.png",
		"jeija_insulated_wire_ends_on.png"
	},
	paramtype = "light",
	is_ground_content = false,
	walkable = are_wires_walkable,
	-- stack_max = 99,
	selection_box = {type="fixed", fixed={-16/32, -16/32, -16/32, 16/32, -5/32, 16/32}},
	groups = mesecon.wire_groups_mesecon3_not_in_ci,
	sounds = mesecon.node_sound.default,
	mesecons = {
		conductor = {
			states = crossover_states,
			rules = crossover_rules,
		}
	},
	on_blast = mesecon.on_blastnode,
})

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_extrawires:crossover_off",
	recipe = {
		"mesecons_insulated:insulated_off",
		"mesecons_insulated:insulated_off",
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_insulated:insulated_off 2",
	recipe = {
		"mesecons_extrawires:crossover_off",
	},
})
