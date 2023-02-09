minetest.register_node("summer:angstairA", {
	description = "Angolo_scala_granito_bianco",

	tiles = {
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png"	
	},
--inventory_image = "s_s_A.png",
	--wield_image = "s_s_A.png",
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
    	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0, 0.5, 0.5}, -- NodeBox1
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}, -- NodeBox2
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox3
		}
	},
    --material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='"summer:mattoneA" 7',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),

})

minetest.register_craft({
	output = 'summer:angstairA',
	recipe = {
		{'summer:mattoneA','summer:mattoneA','               '},
		{'summer:mattoneA','summer:mattoneA','               '},
		{'summer:mattoneA','summer:mattoneA','summer:mattoneA'},
	}
})

minetest.register_node("summer:angstairA2", {
description = "Spigolo_scala_granito_bianco",
	tiles = {
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png"		
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0, 0, 0.5, 0.5}, -- NodeBox2
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox3
		}
	},
   -- material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='summer:mattoneA 5',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:angstairA2',
	recipe = {
		{'               ','summer:mattoneA','               '},
		{'               ','summer:mattoneA','               '},
		{'summer:mattoneA','summer:mattoneA','summer:mattoneA'},
	}
})
minetest.register_node("summer:stairA", {
	description = "Scala_granito_bianco",
	tiles = {
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- Node1
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}, -- Node2
		}
	},
   -- material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
--	drop ='summer:mattoneA 6',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:stairA',
	recipe = {
		{'summer:mattoneA','               ','               '},
		{'summer:mattoneA','summer:mattoneA','               '},
		{'summer:mattoneA','summer:mattoneA','summer:mattoneA'},
	}
})
minetest.register_node("summer:battiscopaA", {
description = "Battiscopa_granito_bianco",
	tiles = {
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}, -- NodeBox3
			{-0.5, -0.5, -0.375, 0.5, 0.25, 0.5}, -- NodeBox4
			{-0.5, 0, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
		}
	},
  --  material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
--	drop ='summer:mattoneA 8',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:battiscopaA',
	recipe = {
		{'summer:mattoneA','summer:mattoneA','summer:mattoneA'},
		{'summer:mattoneA','summer:mattoneA','               '},
		{'summer:mattoneA','summer:mattoneA','summer:mattoneA'},
	}
})
minetest.register_node("summer:slabA", {
	description = "Scala_granito_bianco",
	tiles = {
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png",
		"graniteA.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- Node1
		--	{-0.5, -0.5, 0, 0.5, 0.5, 0.5}, -- Node2
		}
	},
   -- material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
--	drop ='summer:mattoneA 6',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:slabA',
	recipe = {
		{'               ','               ','               '},
		{'               ','               ','               '},
		{'summer:mattoneA','summer:mattoneA','summer:mattoneA'},
	}
})
--P
minetest.register_node("summer:angstairP", {
	description = "Angolo_scala_granito_rosa",

	tiles = {
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png"	
	},
--inventory_image = "s_s_P.png",
	--wield_image = "s_s_P.png",
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
    	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0, 0.5, 0.5}, -- NodeBox1
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}, -- NodeBox2
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox3
		}
	},
  --  material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='"summer:mattoneP" 7',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),

})

minetest.register_craft({
	output = 'summer:angstairP',
	recipe = {
		{'summer:mattoneP','summer:mattoneP','               '},
		{'summer:mattoneP','summer:mattoneP','               '},
		{'summer:mattoneP','summer:mattoneP','summer:mattoneP'},
	}
})

minetest.register_node("summer:angstairP2", {
description = "Spigolo_scala_granito_rosa",
	tiles = {
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png"		
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0, 0, 0.5, 0.5}, -- NodeBox2
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox3
		}
	},
  --  material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	drop ='summer:mattoneP 5',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:angstairP2',
	recipe = {
		{'               ','summer:mattoneP','               '},
		{'               ','summer:mattoneP','               '},
		{'summer:mattoneP','summer:mattoneP','summer:mattoneP'},
	}
})
minetest.register_node("summer:stairP", {
	description = "Scala_granito_rosa",
	tiles = {
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- Node1
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}, -- Node2
		}
	},
  --  material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='summer:mattoneP 6',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:stairP',
	recipe = {
		{'summer:mattoneP','               ','               '},
		{'summer:mattoneP','summer:mattoneP','               '},
		{'summer:mattoneP','summer:mattoneP','summer:mattoneP'},
	}
})
minetest.register_node("summer:battiscopaP", {
description = "Battiscopa_granito_rosa",
	tiles = {
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}, -- NodeBox3
			{-0.5, -0.5, -0.375, 0.5, 0.25, 0.5}, -- NodeBox4
			{-0.5, 0, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
		}
	},
  --  material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='summer:mattoneP 8',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:battiscopaP',
	recipe = {
		{'summer:mattoneP','summer:mattoneP','summer:mattoneP'},
		{'summer:mattoneP','summer:mattoneP','               '},
		{'summer:mattoneP','summer:mattoneP','summer:mattoneP'},
	}
})
minetest.register_node("summer:slabP", {
	description = "Scala_granito_rosa",
	tiles = {
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png",
		"graniteP.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- Node1
		--	{-0.5, -0.5, 0, 0.5, 0.5, 0.5}, -- Node2
		}
	},
   -- material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='summer:mattoneP 6',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:slabP',
	recipe = {
		{'               ','               ','               '},
		{'               ','               ','               '},
		{'summer:mattoneP','summer:mattoneP','summer:mattoneP'},
	}
})
--R
minetest.register_node("summer:angstairR", {
	description = "Angolo_scala_granito_rosso",

	tiles = {
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png"	
	},
--inventory_image = "s_s_R.png",
	--wield_image = "s_s_R.png",
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
    	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0, 0.5, 0.5}, -- NodeBox1
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}, -- NodeBox2
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox3
		}
	},
   -- material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	drop ='"summer:mattoneR" 7',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),

})

minetest.register_craft({
	output = 'summer:angstairR',
	recipe = {
		{'summer:mattoneR','summer:mattoneR','               '},
		{'summer:mattoneR','summer:mattoneR','               '},
		{'summer:mattoneR','summer:mattoneR','summer:mattoneR'},
	}
})

minetest.register_node("summer:angstairR2", {
description = "Spigolo_scala_granito_rosso",
	tiles = {
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png"		
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0, 0, 0.5, 0.5}, -- NodeBox2
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox3
		}
	},
   -- material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='summer:mattoneR 5',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:angstairR2',
	recipe = {
		{'               ','summer:mattoneR','               '},
		{'               ','summer:mattoneR','               '},
		{'summer:mattoneR','summer:mattoneR','summer:mattoneR'},
	}
})
minetest.register_node("summer:stairR", {
	description = "Scala_granito_rosso",
	tiles = {
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- Node1
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}, -- Node2
		}
	},
   -- material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='summer:mattoneR 6',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:stairR',
	recipe = {
		{'summer:mattoneR','               ','               '},
		{'summer:mattoneR','summer:mattoneR','               '},
		{'summer:mattoneR','summer:mattoneR','summer:mattoneR'},
	}
})
minetest.register_node("summer:battiscopaR", {
description = "Battiscopa_granito_rosso",
	tiles = {
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}, -- NodeBox3
			{-0.5, -0.5, -0.375, 0.5, 0.25, 0.5}, -- NodeBox4
			{-0.5, 0, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
		}
	},
   -- material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='summer:mattoneR 8',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:battiscopaR',
	recipe = {
		{'summer:mattoneR','summer:mattoneR','summer:mattoneR'},
		{'summer:mattoneR','summer:mattoneR','               '},
		{'summer:mattoneR','summer:mattoneR','summer:mattoneR'},
	}
})
minetest.register_node("summer:slabR", {
	description = "Scala_granito_rosso",
	tiles = {
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png",
		"graniteR.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- Node1
		--	{-0.5, -0.5, 0, 0.5, 0.5, 0.5}, -- Node2
		}
	},
   -- material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='summer:mattoneR 6',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:slabR',
	recipe = {
		{'               ','               ','               '},
		{'               ','               ','               '},
		{'summer:mattoneR','summer:mattoneR','summer:mattoneR'},
	}
})
--G
minetest.register_node("summer:angstair", {
	description = "Angolo_scala_granito_grigio",

	tiles = {
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png"	
	},
--inventory_image = "s_s_.png",
	--wield_image = "s_s_.png",
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
    	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0, 0.5, 0.5}, -- NodeBox1
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}, -- NodeBox2
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox3
		}
	},
  --  material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='"summer:mattone" 7',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),

})

minetest.register_craft({
	output = 'summer:angstair',
	recipe = {
		{'summer:mattone','summer:mattone','               '},
		{'summer:mattone','summer:mattone','               '},
		{'summer:mattone','summer:mattone','summer:mattone'},
	}
})

minetest.register_node("summer:angstair2", {
description = "Spigolo_scala_granito_grigio",
	tiles = {
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png"		
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0, 0, 0.5, 0.5}, -- NodeBox2
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox3
		}
	},
  --  material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='summer:mattone 5',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:angstair2',
	recipe = {
		{'               ','summer:mattone','               '},
		{'               ','summer:mattone','               '},
		{'summer:mattone','summer:mattone','summer:mattone'},
	}
})
minetest.register_node("summer:stair", {
	description = "Scala_granito_grigio",
	tiles = {
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- Node1
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}, -- Node2
		}
	},
  --  material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='summer:mattone 6',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:stair',
	recipe = {
		{'summer:mattone','               ','               '},
		{'summer:mattone','summer:mattone','               '},
		{'summer:mattone','summer:mattone','summer:mattone'},
	}
})
minetest.register_node("summer:battiscopa", {
description = "Battiscopa_granito_grigio",
	tiles = {
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}, -- NodeBox3
			{-0.5, -0.5, -0.375, 0.5, 0.25, 0.5}, -- NodeBox4
			{-0.5, 0, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
		}
	},
 --   material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='summer:mattone 8',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:battiscopa',
	recipe = {
		{'summer:mattone','summer:mattone','summer:mattone'},
		{'summer:mattone','summer:mattone','               '},
		{'summer:mattone','summer:mattone','summer:mattone'},
	}
})
minetest.register_node("summer:slab", {
	description = "Scala_granito_grigio",
	tiles = {
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png",
		"granite.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- Node1
			--{-0.5, -0.5, 0, 0.5, 0.5, 0.5}, -- Node2
		}
	},
  --  material = minetest.digprop_constanttime(1),
	groups = {cracky = 3, stone = 1},
	--drop ='summer:mattone 6',
	--legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'summer:slab',
	recipe = {
		{'               ','               ','               '},
		{'               ','               ','               '},
		{'summer:mattone','summer:mattone','summer:mattone'},
	}
})
