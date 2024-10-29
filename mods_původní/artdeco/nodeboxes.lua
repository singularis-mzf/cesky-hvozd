minetest.register_node("artdeco:arch2a", {
	description = "Limestone Arch",
	tiles = {"artdeco_2a.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{0.375, -0.5, -0.5, 0.5, 0.1875, 0.5},
			{-0.5, -0.5, -0.5, -0.375, 0.1875, 0.5},
			{0.3125, -0.125, -0.5, 0.375, 0.1875, 0.5},
			{-0.375, -0.125, -0.5, -0.3125, 0.1875, 0.5},
			{0.25, 0, -0.5, 0.3125, 0.1875, 0.5},
			{-0.3125, 0, -0.5, -0.25, 0.1875, 0.5},
			{0.1875, 0.0625, -0.5, 0.25, 0.1875, 0.5},
			{-0.25, 0.0625, -0.5, -0.1875, 0.1875, 0.5},
			{-0.1875, 0.125, -0.5, -0.0625, 0.1875, 0.5},
			{0.0625, 0.125, -0.5, 0.1875, 0.1875, 0.5},
			{-0.5, 0.1875, -0.5, 0.5, 0.5, 0.5},
		}
	},
})

minetest.register_node("artdeco:arch1a", {
	description = "Limestone Top Arch",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_2b.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{0.375, -0.5, -0.5, 0.5, 0.1875, 0.5},
			{-0.5, -0.5, -0.5, -0.375, 0.1875, 0.5},
			{0.3125, -0.125, -0.5, 0.375, 0.1875, 0.5},
			{-0.375, -0.125, -0.5, -0.3125, 0.1875, 0.5},
			{0.25, 0, -0.5, 0.3125, 0.1875, 0.5},
			{-0.3125, 0, -0.5, -0.25, 0.1875, 0.5},
			{0.1875, 0.0625, -0.5, 0.25, 0.1875, 0.5},
			{-0.25, 0.0625, -0.5, -0.1875, 0.1875, 0.5},
			{-0.1875, 0.125, -0.5, -0.0625, 0.1875, 0.5},
			{0.0625, 0.125, -0.5, 0.1875, 0.1875, 0.5},
			{-0.5, 0.1875, -0.5, 0.5, 0.5, 0.5},
		}
	},
})

minetest.register_node("artdeco:arch1b", {
	description = "Limestone Arch Walls",
	tiles = {"artdeco_2a.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{0.375, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, -0.375, 0.5, 0.5},
		}
	}
})


minetest.register_node("artdeco:arch1c", {
	description = "Limestone Plinth",
	tiles = {"artdeco_2a.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.5, 0.4375, -0.625, 0.5, 0.5, -0.5},
		}
	}
})

minetest.register_node("artdeco:arch1d", {
	description = "Limestone Bottom Plinth",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_2d.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.5, 0.4375, -0.625, 0.5, 0.5, -0.5},
		}
	}
})

minetest.register_node("artdeco:arch1e", {
	description = "Limestone Top Plinth",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_2b.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.5, 0.4375, -0.625, 0.5, 0.5, -0.5},
		}
	}
})

minetest.register_node("artdeco:dblarch1a", {
	description = "Half Arch Top",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_2b.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, 0.0625, -0.5, 0.5, 0.25, 0.5},
			{0.3125, -0.5, -0.5, 0.5, 0.1875, 0.5},
			{0.25, -0.3125, -0.5, 0.375, 0.1875, 0.5},
			{0.1875, -0.1875, -0.5, 0.3125, 0.1875, 0.5},
			{-0.0625, 0, -0.5, 0.25, 0.1875, 0.5},
			{0.0625, -0.0625, -0.5, 0.375, 0.0625, 0.5},
			{0.125, -0.125, -0.5, 0.25, 0, 0.5},
			{-0.5, 0.125, -0.5, 0.5, 0.5, 0.5},
		}
	}
})

minetest.register_node("artdeco:dblarchslab", {
	description = "Limestone Arch Bridge",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_2b.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.125, -0.5, 0.5, 0.5, 0.5},
		}
	}
})

minetest.register_node("artdeco:archwin1a", {
	description = "Silver Window Top",
	drawtype = "nodebox",
	tiles = {"artdeco_archwin3.png^[transformR90","artdeco_archwin3.png^[transformR90",
	"artdeco_archwin3.png","artdeco_archwin3.png","artdeco_archwin1a.png"},
	backface_culling = true,
	inventory_image = "artdeco_archwin1a.png",
	paramtype = "light",
	sunlight_propogates = true,
	use_texture_alpha = "blend",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{0.375, -0.5, -0.5, 0.5, 0.1875, 0.5},
			{-0.5, -0.5, -0.5, -0.375, 0.1875, 0.5},
			{0.3125, -0.125, -0.5, 0.375, 0.1875, 0.5},
			{-0.375, -0.125, -0.5, -0.3125, 0.1875, 0.5},
			{0.25, 0, -0.5, 0.3125, 0.1875, 0.5},
			{-0.3125, 0, -0.5, -0.25, 0.1875, 0.5},
			{0.1875, 0.0625, -0.5, 0.25, 0.1875, 0.5},
			{-0.25, 0.0625, -0.5, -0.1875, 0.1875, 0.5},
			{-0.1875, 0.125, -0.5, -0.0625, 0.1875, 0.5},
			{0.0625, 0.125, -0.5, 0.1875, 0.1875, 0.5},
			{-0.5, 0.1875, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.125, 0.5, 0.5, 0.125},
		}
	}
})

minetest.register_node("artdeco:archwin1b", {
	description = "Silver Window Middle",
	drawtype = "nodebox",
	tiles = {"artdeco_archwin3.png^[transformR90","artdeco_archwin3.png^[transformR90",
	"artdeco_archwin3.png","artdeco_archwin3.png","artdeco_archwin1b.png"},
	backface_culling = true,
	inventory_image = "artdeco_archwin1b.png",
	paramtype = "light",
	sunlight_propogates = true,
	use_texture_alpha = "blend",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{0.375, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, -0.375, 0.5, 0.5},
			{-0.5, -0.5, -0.125, 0.5, 0.5, 0.125},
		}
	}
})
minetest.register_node("artdeco:archwin1c", {
	description = "Silver Window Bottom",
	drawtype = "nodebox",
	tiles = {"artdeco_archwin3.png^[transformR90","artdeco_archwin3.png^[transformR90",
	"artdeco_archwin3.png","artdeco_archwin3.png","artdeco_archwin1c.png"},
	backface_culling = true,
	inventory_image = "artdeco_archwin1c.png",
	paramtype = "light",
	sunlight_propogates = true,
	use_texture_alpha = "blend",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{0.375, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, -0.375, 0.5, 0.5},
			{-0.5, -0.5, -0.125, 0.5, 0.5, 0.125},
			{-0.375, -0.5, -0.5, 0.375, -0.375, 0.5},
		}
	}
})

minetest.register_node("artdeco:archwin2a", {
	description = "Copper Window Top",
	drawtype = "nodebox",
	tiles = {"artdeco_archwin3.png^[transformR90","artdeco_archwin3.png^[transformR90",
	"artdeco_archwin3.png","artdeco_archwin3.png","artdeco_archwin2a.png"},
	backface_culling = true,
	inventory_image = "artdeco_archwin2a.png",
	paramtype = "light",
	sunlight_propogates = true,
	use_texture_alpha = "blend",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{0.375, -0.5, -0.5, 0.5, 0.1875, 0.5},
			{-0.5, -0.5, -0.5, -0.375, 0.1875, 0.5},
			{0.3125, -0.125, -0.5, 0.375, 0.1875, 0.5},
			{-0.375, -0.125, -0.5, -0.3125, 0.1875, 0.5},
			{0.25, 0, -0.5, 0.3125, 0.1875, 0.5},
			{-0.3125, 0, -0.5, -0.25, 0.1875, 0.5},
			{0.1875, 0.0625, -0.5, 0.25, 0.1875, 0.5},
			{-0.25, 0.0625, -0.5, -0.1875, 0.1875, 0.5},
			{-0.1875, 0.125, -0.5, -0.0625, 0.1875, 0.5},
			{0.0625, 0.125, -0.5, 0.1875, 0.1875, 0.5},
			{-0.5, 0.1875, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.125, 0.5, 0.5, 0.125},
		}
	}
})

minetest.register_node("artdeco:archwin2b", {
	description = "Copper Window Middle",
	drawtype = "nodebox",
	tiles = {"artdeco_archwin3.png^[transformR90","artdeco_archwin3.png^[transformR90",
	"artdeco_archwin3.png","artdeco_archwin3.png","artdeco_archwin2b.png"},
	backface_culling = true,
	inventory_image = "artdeco_archwin2b.png",
	paramtype = "light",
	sunlight_propogates = true,
	use_texture_alpha = "blend",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{0.375, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, -0.375, 0.5, 0.5},
			{-0.5, -0.5, -0.125, 0.5, 0.5, 0.125},
		}
	}
})

minetest.register_node("artdeco:archwin2c", {
	description = "Copper Window Bottom",
	drawtype = "nodebox",
	tiles = {"artdeco_archwin3.png^[transformR90","artdeco_archwin3.png^[transformR90",
	"artdeco_archwin3.png","artdeco_archwin3.png","artdeco_archwin2c.png"},
	backface_culling = true,
	inventory_image = "artdeco_archwin2c.png",
	paramtype = "light",
	sunlight_propogates = true,
	use_texture_alpha = "blend",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{0.375, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, -0.375, 0.5, 0.5},
			{-0.5, -0.5, -0.125, 0.5, 0.5, 0.125},
			{-0.375, -0.5, -0.5, 0.375, -0.375, 0.5},
		}
	}
})
minetest.register_node("artdeco:wincross1a", {
	description = "Corbel",
	drawtype = "nodebox",
	tiles = {"artdeco_wincross_1a.png", "artdeco_wincross_1a.png",
		"artdeco_wincross_1b.png", "artdeco_wincross_1b.png",
		"artdeco_wincross_1a.png", "artdeco_wincross_1d.png"},
	paramtype = "light",
	use_texture_alpha = "blend",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {choppy=2,oddly_breakable_by_hand=2},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.3125, 0.3125, 0.125, -0.125, 0.5},
			{-0.375, -0.3125, 0.375, 0.375, -0.1875, 0.4375},
			{-0.0625, -0.5, 0.375, 0.0625, -0.3125, 0.4375},
			{-0.5, -0.25, 0.3125, 0.5, -0.1875, 0.5},
			{-0.4375, -0.5, 0.4375, 0.4375, -0.25, 0.5},
			{-0.5, -0.5, 0.375, 0.5, -0.4375, 0.5},
		}
	}

})

minetest.register_node("artdeco:wincross1b", {
	description = "Windowsill",
	drawtype = "nodebox",
	tiles = {"artdeco_wincross_1a.png", "artdeco_wincross_1a.png",
		"artdeco_wincross_1c.png", "artdeco_wincross_1c.png",
		"artdeco_wincross_1a.png", "artdeco_wincross_1c.png"},
	paramtype = "light",
	use_texture_alpha = "blend",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {choppy=2,oddly_breakable_by_hand=2},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, 0.1875, 0.4375, 0.4375, 0.5, 0.5},
			{-0.5, 0.4375, 0.375, 0.5, 0.5, 0.5},
			{-0.4375, 0.375, 0.375, 0.4375, 0.4375, 0.5},
			{-0.5, 0.1875, 0.375, 0.5, 0.25, 0.5},
		}
	}
})

minetest.register_node("artdeco:lightwin1", {
	description = "Light Window Top",
	drawtype = "nodebox",
	tiles = {"artdeco_lightwin4.png","artdeco_lightwin1.png",
	"artdeco_lightwin4.png","artdeco_lightwin4.png","artdeco_lightwin1.png"},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = LIGHT_MAX-1,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1, 0.5,0.5, 0.1},
		},
	},
})

minetest.register_node("artdeco:lightwin2", {
	description = "Light Window Middle",
	drawtype = "nodebox",
	tiles = {"artdeco_lightwin2.png", "artdeco_lightwin2.png",
	"artdeco_lightwin4.png","artdeco_lightwin4.png","artdeco_lightwin2.png"},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = LIGHT_MAX-1,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1, 0.5,0.5, 0.1},
		},
	},
})

minetest.register_node("artdeco:lightwin3", {
	description = "Light Window Bottom",
	drawtype = "nodebox",
	tiles = {"artdeco_lightwin3.png","artdeco_lightwin4.png",
	"artdeco_lightwin4.png","artdeco_lightwin4.png","artdeco_lightwin3.png"},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = LIGHT_MAX-1,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1, 0.5,0.5, 0.1},
		},
	},
})

minetest.register_node("artdeco:irongrating", {
	description = "Iron Grating",
	drawtype = "nodebox",
	tiles = {"artdeco_lightwin4.png","artdeco_lightwin4.png",
	"artdeco_lightwin4.png","artdeco_lightwin4.png","artdeco_irongrating.png"},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1, 0.5,0.5, 0.1},
		},
	},
})

minetest.register_node("artdeco:column1a", {
	description = "Column Top",
	drawtype = "nodebox",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_column1a.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3, stone=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
		node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.3125, 0.3125, 0.5, 0.3125},
			{-0.25, -0.5, -0.375, 0.25, 0.5, 0.375},
			{-0.375, -0.5, -0.25, 0.375, 0.5, 0.25},
			{-0.1875, -0.5, -0.4375, 0.1875, 0.5, 0.4375},
			{-0.4375, -0.5, -0.1875, 0.4375, 0.5, 0.1875},
			},
		},
	})

minetest.register_node("artdeco:column1b", {
	description = "Column Moulding",
	drawtype = "nodebox",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_column1b.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3, stone=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
		node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.3125, 0.3125, 0.5, 0.3125},
			{-0.25, -0.5, -0.375, 0.25, 0.5, 0.375},
			{-0.375, -0.5, -0.25, 0.375, 0.5, 0.25},
			{-0.1875, -0.5, -0.4375, 0.1875, 0.5, 0.4375},
			{-0.4375, -0.5, -0.1875, 0.4375, 0.5, 0.1875},
			},
		},
	})

minetest.register_node("artdeco:column1c", {
	description = "Column Bottom",
	drawtype = "nodebox",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_column1c.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3, stone=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
		node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.3125, 0.3125, 0.5, 0.3125},
			{-0.25, -0.5, -0.375, 0.25, 0.5, 0.375},
			{-0.375, -0.5, -0.25, 0.375, 0.5, 0.25},
			{-0.1875, -0.5, -0.4375, 0.1875, 0.5, 0.4375},
			{-0.4375, -0.5, -0.1875, 0.4375, 0.5, 0.1875},
			},
		},
	})

minetest.register_node("artdeco:column1d", {
	description = "Column",
	drawtype = "nodebox",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_column1d.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3, stone=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
		node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.3125, 0.3125, 0.5, 0.3125},
			{-0.25, -0.5, -0.375, 0.25, 0.5, 0.375},
			{-0.375, -0.5, -0.25, 0.375, 0.5, 0.25},
			{-0.1875, -0.5, -0.4375, 0.1875, 0.5, 0.4375},
			{-0.4375, -0.5, -0.1875, 0.4375, 0.5, 0.1875},
			},
		},
	})

minetest.register_node("artdeco:column_base", {
	description = "Column Base",
	drawtype = "nodebox",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_column1d.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3, stone=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
		node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.3125, 0.3125, 0.5, 0.3125},
			{-0.25, -0.5, -0.375, 0.25, 0.5, 0.375},
			{-0.3125, -0.5, -0.25, 0.25, 0.5, 0.3125},
			{-0.25, -0.5, -0.375, 0.1875, 0.5, 0.375},
			{-0.4375, -0.5, -0.1875, 0.4375, 0.5, 0.1875},
			{-0.375, -0.5, -0.25, 0.375, 0.5, 0.25},
			{-0.1875, -0.5, -0.4375, 0.1875, 0.5, 0.4375},
			{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},
			{-0.4375, -0.5, -0.4375, 0.4375, -0.1875, 0.4375},
			{-0.375, -0.5, -0.375, 0.375, -0.0625, 0.375},
		}
	},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local param2 = 0

		local placer_pos = placer:getpos()
		if placer_pos then
			local dir = {
				x = p1.x - placer_pos.x,
				y = p1.y - placer_pos.y,
				z = p1.z - placer_pos.z
			}
			param2 = minetest.dir_to_facedir(dir)
		end

		if p0.y-1 == p1.y then
			param2 = param2 + 20
			if param2 == 21 then
				param2 = 23
			elseif param2 == 23 then
				param2 = 21
			end
		end

		return minetest.item_place(itemstack, placer, pointed_thing, param2)
	end,
})

minetest.register_node("artdeco:thinstonewall", {
	description = "Thin Stone Wall",
	tiles = {"artdeco_stonewall.png"},
	drawtype = "nodebox",
	node_box = {
		type = "connected",
		fixed = {{-0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875}},
		connect_front = {{-0.1875, -0.5, -0.5,  0.1875, 0.5, -0.1875}},
		connect_left = {{-0.5, -0.5, -0.1875, -0.1875, 0.5,  0.1875}},
		connect_back = {{-0.1875, -0.5,  0.1875,  0.1875, 0.5,  0.5}},
		connect_right = {{ 0.1875, -0.5, -0.1875,  0.5, 0.5,  0.1875}},
	},
	connects_to = { "group:wall", "group:stone" },
	paramtype = "light",
	is_ground_content = false,
	walkable = true,
	groups = { cracky = 3, wall = 1, stone = 2 },
	sounds = default.node_sound_stone_defaults(),
})

