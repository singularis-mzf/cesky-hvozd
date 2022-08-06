local corner_selectionbox = {
		type = "fixed",
		fixed = { -16/32, -16/32, -16/32, 5/32, -12/32, 5/32 },
}

local corner_get_rules = function (node)
	local rules =
	{{x = 1,  y = 0,  z =  0},
	 {x = 0,  y = 0,  z = -1}}

	for i = 0, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end

	return rules
end

local are_wires_walkable = mesecon.is_wire_walkable()

minetest.register_node("mesecons_extrawires:corner_on", {
	drawtype = "mesh",
	mesh = "mesecons_extrawires_corner.obj",
	tiles = {
		{ name = "jeija_insulated_wire_sides_on.png", backface_culling = true },
		{ name = "jeija_insulated_wire_ends_on.png", backface_culling = true },
	},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = are_wires_walkable,
	sunlight_propagates = true,
	selection_box = corner_selectionbox,
	groups = mesecon.wire_groups_not_in_ci,
	drop = "mesecons_extrawires:corner_off",
	sounds = mesecon.node_sound.default,
	mesecons = {conductor =
	{
		state = mesecon.state.on,
		rules = corner_get_rules,
		offstate = "mesecons_extrawires:corner_off"
	}},
	on_blast = mesecon.on_blastnode,
	on_rotate = mesecon.on_rotate_horiz,
})

minetest.register_node("mesecons_extrawires:corner_off", {
	drawtype = "mesh",
	description = "Izolovaný mesespoj: roh",
	mesh = "mesecons_extrawires_corner.obj",
	tiles = {
		{ name = "jeija_insulated_wire_sides_off.png", backface_culling = true },
		{ name = "jeija_insulated_wire_ends_off.png", backface_culling = true },
	},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = true,
	sunlight_propagates = true,
	selection_box = corner_selectionbox,
	groups = mesecon.wire_groups_in_ci,
	sounds = mesecon.node_sound.default,
	mesecons = {conductor =
	{
		state = mesecon.state.off,
		rules = corner_get_rules,
		onstate = "mesecons_extrawires:corner_on"
	}},
	on_blast = mesecon.on_blastnode,
	on_rotate = mesecon.on_rotate_horiz,
})

minetest.register_craft({
	output = "mesecons_extrawires:corner_off 3",
	recipe = {
		{"mesecons_insulated:insulated_off", "mesecons_insulated:insulated_off"},
		{"", "mesecons_insulated:insulated_off"},
	}
})
