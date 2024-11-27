ch_base.open_mod(minetest.get_current_modname())
-- Basic wall/yard/metal signs
-- these were originally part of signs_lib


basic_signs = {}
basic_signs.path = minetest.get_modpath(minetest.get_current_modname())

dofile(basic_signs.path .. "/crafting.lua")

local S, NS = dofile(basic_signs.path .. "/intllib.lua")
basic_signs.gettext = S

signs_lib.register_sign("basic_signs:sign_wall_locked", {
	description = S("Locked Sign"),
	tiles = {
		"basic_signs_sign_wall_locked.png",
		"signs_lib_sign_wall_steel_edges.png"
	},
	inventory_image = "basic_signs_sign_wall_locked_inv.png",
	locked = true,
	entity_info = "standard",
	allow_hanging = true,
	allow_widefont = true,
	allow_onpole = true,
	allow_onpole_horizontal = true,
	allow_yard = true,
	use_texture_alpha = "clip",
})

signs_lib.register_sign("basic_signs:sign_wall_glass", {
	description = S("Glass Sign"),
	yard_mesh = "signs_lib_standard_sign_yard_two_sticks.obj",
	tiles = {
		{ name = "basic_signs_sign_wall_glass.png", backface_culling = true},
		"basic_signs_sign_wall_glass_edges.png",
		"basic_signs_pole_mount_glass.png",
		nil,
		"default_steel_block.png" -- the sticks on back of the yard sign model
	},
	inventory_image = "basic_signs_sign_wall_glass_inv.png",
	default_color = "c",
	entity_info = "standard",
	sounds = default.node_sound_glass_defaults(),
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	allow_hanging = true,
	allow_widefont = true,
	allow_onpole = true,
	allow_onpole_horizontal = true,
	allow_yard = true,
	use_texture_alpha = "blend",
})

signs_lib.register_sign("basic_signs:sign_wall_obsidian_glass", {
	description = S("Obsidian Glass Sign"),
	yard_mesh = "signs_lib_standard_sign_yard_two_sticks.obj",
	tiles = {
		{ name = "basic_signs_sign_wall_obsidian_glass.png", backface_culling = true},
		"basic_signs_sign_wall_obsidian_glass_edges.png",
		"basic_signs_pole_mount_obsidian_glass.png",
		nil,
		"default_steel_block.png" -- the sticks on back of the yard sign model
	},
	inventory_image = "basic_signs_sign_wall_obsidian_glass_inv.png",
	default_color = "c",
	entity_info = "standard",
	sounds = default.node_sound_glass_defaults(),
	groups = {cracky = 3},
	allow_hanging = true,
	allow_widefont = true,
	allow_onpole = true,
	allow_onpole_horizontal = true,
	allow_yard = true,
	use_texture_alpha = "blend",
})

minetest.register_alias("locked_sign:sign_wall_locked", "basic_signs:sign_wall_locked")

signs_lib.register_sign("basic_signs:sign_wall_plastic", {
	description = S("Plastic Sign"),
	yard_mesh = "signs_lib_standard_sign_yard_two_sticks.obj",
	tiles = {
		"basic_signs_sign_wall_plastic.png",
		"basic_signs_sign_wall_plastic_edges.png",
		"basic_signs_pole_mount_plastic.png",
		nil,
		"default_steel_block.png" -- the sticks on back of the yard sign model
	},
	inventory_image = "basic_signs_sign_wall_plastic_inv.png",
	default_color = "0",
	entity_info = "standard",
	sounds = default.node_sound_leaves_defaults(),
	groups = {snappy = 3, flammable = 2},
	allow_hanging = true,
	allow_widefont = true,
	allow_onpole = true,
	allow_onpole_horizontal = true,
	allow_yard = true,
	use_texture_alpha = "clip",
})

-- array : color, translated color, default text color

local sign_colors = {
	{"green",        S("green"),       "f"},
	{"yellow",       S("yellow"),      "0"},
	{"red",          S("red"),         "f"},
	{"white_red",    S("white_red"),   "4"},
	{"white_black",  S("white_black"), "0"},
	{"orange",       S("orange"),      "0"},
	{"blue",         S("blue"),        "f"},
	{"brown",        S("brown"),       "f"},
}

local cbox = signs_lib.make_selection_boxes(35, 25, true, 0, 0, 0, true)

for i, color in ipairs(sign_colors) do
	signs_lib.register_sign("basic_signs:sign_wall_steel_"..color[1], {
		description = S("Sign (" .. color[1] .. ", steel)"),
		paramtype2 = "facedir",
		selection_box = cbox,
		mesh = "signs_lib_standard_facedir_sign_wall.obj",
		tiles = {
			"basic_signs_steel_"..color[1]..".png",
			"signs_lib_sign_wall_steel_edges.png",
			nil,
			nil,
			"default_steel_block.png"
		},
		inventory_image = "basic_signs_steel_"..color[1].."_inv.png",
		groups = signs_lib.standard_steel_groups,
		sounds = signs_lib.standard_steel_sign_sounds,
		default_color = color[3],
		entity_info = {
			mesh = "signs_lib_standard_sign_entity_wall.obj",
			yaw = signs_lib.standard_yaw
		},
		allow_hanging = true,
		allow_widefont = true,
		allow_onpole = true,
		allow_onpole_horizontal = true,
		allow_yard = true,
		use_texture_alpha = "clip",
	})

	minetest.register_alias("basic_signs:sign_wall_steel_"..color[1].."_onpole",       "basic_signs:sign_steel_"..color[1].."_onpole")
	minetest.register_alias("basic_signs:sign_wall_steel_"..color[1].."_onpole_horiz", "basic_signs:sign_steel_"..color[1].."_onpole_horiz")
	minetest.register_alias("basic_signs:sign_wall_steel_"..color[1].."_hanging",      "basic_signs:sign_steel_"..color[1].."_hanging")
	minetest.register_alias("basic_signs:sign_wall_steel_"..color[1].."_yard",         "basic_signs:sign_steel_"..color[1].."_yard")

	table.insert(signs_lib.lbm_restore_nodes, "signs:sign_wall_"..color[1])
	minetest.register_alias("signs:sign_wall_"..color[1],                  "basic_signs:sign_wall_steel_"..color[1])

	minetest.register_alias("signs:sign_"..color[1].."_onpole",       "basic_signs:sign_steel_"..color[1].."_onpole")
	minetest.register_alias("signs:sign_"..color[1].."_onpole_horiz", "basic_signs:sign_steel_"..color[1].."_onpole_horiz")
	minetest.register_alias("signs:sign_"..color[1].."_hanging",      "basic_signs:sign_steel_"..color[1].."_hanging")
	minetest.register_alias("signs:sign_"..color[1].."_yard",         "basic_signs:sign_steel_"..color[1].."_yard")
end

signs_lib.register_sign("basic_signs:vevystavbe", {
	description = "cedule: ve výstavbě",
	paramtype2 = "facedir",
	selection_box = cbox,
	mesh = "signs_lib_standard_facedir_sign_wall.obj",
	tiles = {
		"basic_signs_ve_vystavbe.png",
		"signs_lib_sign_wall_steel_edges.png",
		nil,
		nil,
		"default_steel_block.png"
	},
	inventory_image = "basic_signs_ve_vystavbe_inv.png",
	groups = signs_lib.standard_steel_groups,
	sounds = signs_lib.standard_steel_sign_sounds,
	default_color = "0",
	entity_info = {
		mesh = "signs_lib_standard_sign_entity_wall.obj",
		yaw = signs_lib.standard_yaw
	},
	allow_hanging = true,
	allow_widefont = false,
	allow_onpole = true,
	allow_onpole_horizontal = true,
	allow_yard = true,
	use_texture_alpha = "clip",
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		signs_lib.after_place_node(pos, placer, itemstack, pointed_thing, false)
		-- signs_lib.update_sign(pos, { text = "VE VÝSTAVBĚ" })
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Ve výstavbě.\nCeduli umístil/a: "..ch_core.prihlasovaci_na_zobrazovaci(placer:get_player_name()))
		return true
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		-- signs_lib.update_sign(pos, { text = "VE VÝSTAVBĚ" })
		return nil
	end,
	on_rotate = function(pos, node, user, mode)
		return nil
	end,
})

minetest.register_craft({
	output = "basic_signs:vevystavbe 16",
	type = "shapeless",
	recipe = {"basic_signs:sign_wall_steel_white_red", "dye:black"},
})

--[[
signs_lib.register_sign("basic_signs:test", {
	description = "Testovací cedule (nepoužívejte na stavbách, je jen pro účely vývoje serveru!)",
	paramtype2 = "facedir",
	selection_box = cbox,
	mesh = "signs_lib_standard_facedir_sign_wall.obj",
	tiles = {
		"basic_signs_steel_red.png",
		"signs_lib_sign_wall_steel_edges.png",
		nil,
		nil,
		"default_steel_block.png"
	},
	inventory_image = "basic_signs_steel_red_inv.png",
	groups = signs_lib.standard_steel_groups,
	sounds = signs_lib.standard_steel_sign_sounds,
	default_color = "0",
	entity_info = {
		mesh = "signs_lib_standard_sign_entity_wall.obj",
		yaw = signs_lib.standard_yaw
	},
	allow_hanging = true,
	allow_widefont = true,
	allow_onpole = true,
	allow_onpole_horizontal = true,
	allow_yard = true,
	use_texture_alpha = "clip",
	font_size = 32,
	horiz_scaling = 0.25,
	vert_scaling = 0.25,
})
]]

ch_base.close_mod(minetest.get_current_modname())
