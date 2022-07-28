

windmill = {}

windmill.register_windmill = function( nodename, descr, animation_png, animation_png_reverse, scale, inventory_image, animation_speed, craft_material, sel_radius )

	local selection_box_large = {
		type = "wallmounted",
		wall_side   = {-0.4, -sel_radius, -sel_radius, -0.2, sel_radius, sel_radius},
	}
	local selection_box_small = {
		type = "wallmounted",
		wall_side   = {-0.4, -0.5 * sel_radius, -0.5 * sel_radius, -0.2, 0.5 * sel_radius, 0.5 * sel_radius},
	}
	local def = {
		description = descr.." (velký, po směru h.r.)",
		drawtype = "signlike", 
		visual_scale = scale,
		tiles = {
			{name=animation_png, animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=animation_speed}},
		},
		inventory_image = inventory_image.."^[transformFX",
		wield_image     = inventory_image.."^[transformFX",
		wield_scale = {x=1, y=1, z=1},
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = false,
		light_source = 1, -- reflecting a bit of light might be expected
		selection_box = selection_box_large,
		groups = {choppy=2,dig_immediate=3,attached_node=1},
		legacy_wallmounted = true,
	}
	minetest.register_node(nodename.."_large", table.copy(def))

	def.description = descr.." (malý, po směru h.r.)"
	def.selection_box = selection_box_small
	def.visual_scale = scale / 2.0
	minetest.register_node(nodename.."_small", table.copy(def))

	-- this one rotates in the opposite direction than the first one
	def.description = descr.." (malý, proti směru h. r.)"
	def.tiles = {
		{name=animation_png_reverse, animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=animation_speed}},
	}
	def.inventory_image = inventory_image
	def.wield_image     = inventory_image
	minetest.register_node(nodename.."_small_reverse", table.copy(def))

	def.description = descr.." (velký, proti směru h. r.)"
	def.visual_scale = scale
	def.selection_box = selection_box_large
	minetest.register_node(nodename.."_large_reverse", table.copy(def))

	minetest.register_craft({output = nodename.."_large_reverse", recipe = {{nodename.."_large"}}}) 
	minetest.register_craft({output = nodename.."_large", recipe = {{nodename.."_large_reverse"}}}) 
	minetest.register_craft({output = nodename.."_small_reverse", recipe = {{nodename.."_small"}}}) 
	minetest.register_craft({output = nodename.."_small", recipe = {{nodename.."_small_reverse"}}}) 

	local tmp = {nodename.."_small", nodename.."_small"}
	minetest.register_craft({output = nodename.."_large", recipe = {tmp, tmp}})
	tmp = {nodename.."_small_reverse", nodename.."_small_reverse"}
	minetest.register_craft({output = nodename.."_large_reverse", recipe = {tmp, tmp}})

	minetest.register_craft({
		output = nodename.."_small",
		recipe = {
				{ craft_material,       "",                    craft_material },
				{ "",                   "default:stick",       "",             },
				{ craft_material,       "",                    craft_material },
		},
	})

	minetest.register_craft({
		output = nodename.."_small_reverse",
		recipe = {
				{ "",                   craft_material,        "",             },
				{ craft_material,       "default:stick",       craft_material, },
				{ "",                   craft_material,        "",             },
		},
	})
end


windmill.register_windmill( "windmill:windmill_rotors",       "větrný mlýn: vrtule",
			"windmill.png", "windmill_reverse.png",
			6.0, "windmill_4blade_inv.png", 1.0, "default:steel_ingot", 2.9 );

windmill.register_windmill( "windmill:windmill_modern", "větrný mlýn: moderní",
			"windmill_3blade_cw.png", "windmill_3blade_ccw.png",
			6.0, "windmill_3blade_inv.png", 1.0, "basic_materials:plastic_sheet", 2.9 );

windmill.register_windmill( "windmill:windmill_sails", "větrný mlýn: s plachtami",
			"windmill_wooden_cw_with_sails.png", "windmill_wooden_ccw_with_sails.png",
			6.0, "windmill_wooden_inv.png", 1.0, "wool:white", 3 );

windmill.register_windmill( "windmill:windmill_idle",  "větrný mlýn: dřevěné vrtule",
			"windmill_wooden_cw.png", "windmill_wooden_ccw.png",
			6.0, "windmill_wooden_no_sails_inv.png", 2.0, "default:wood", 3 );

-- this one is smaller than the other ones
windmill.register_windmill( "windmill:windmill_farm", "větrný mlýn: 12 malých vrtulí",
			"windmill_farm_cw.png", "windmill_farm_ccw.png",
			3.0, "windmill_farm_inv.png", 0.5, "default:stick", 1.5 );

minetest.register_node("windmill:axis", {
	description = "úchyt na vrtule větrného mlýnu",
	drawtype = "nodebox",
	tiles = {"default_wood.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {choppy=2,dig_immediate=3},
	node_box = {
		type = "fixed",
		fixed = {{-0.25, -0.5, -0.25, 0.25, 0.4, 0.25},
			 {-0.1,-0.1,-0.5,0.1,0.1,0.5}},
	},
	selection_box = {
		type = "fixed",
		fixed = {{-0.25, -0.5, -0.25, 0.25, 0.4, 0.25},
			 {-0.1,-0.1,-0.5,0.1,0.1,0.5}},
	},
})

minetest.register_craft({
	output = "windmill:axis",
	recipe = {
		{"default:steel_ingot", "default:stick", "default:steel_ingot" },
	},
})
