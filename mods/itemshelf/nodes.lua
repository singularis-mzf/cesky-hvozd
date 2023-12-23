-- Default nodes for Itemshelf mod
-- By Zorman2000

local default_shelf = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, 0.4375, 0.5, 0.5, 0.5}, -- NodeBox1
		{-0.5, -0.5, -0.5, -0.4375, 0.5, 0.4375}, -- NodeBox2
		{-0.4375, -0.5, -0.5, 0.4375, -0.4375, 0.4375}, -- NodeBox3
		{0.4375, -0.5, -0.5, 0.5, 0.5, 0.4375}, -- NodeBox4
		{-0.4375, 0.4375, -0.5, 0.4375, 0.5, 0.4375}, -- NodeBox5
		{-0.4375, -0.0625, -0.5, 0.4375, 0.0625, 0.4375}, -- NodeBox6
	}
}

local default_half_shelf = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, 0.4375, 0.5, 0.5, 0.5}, -- NodeBox1
		{-0.5, -0.5, -0.125, -0.4375, 0.5, 0.5}, -- NodeBox2
		{0.4375, -0.5, -0.125, 0.5, 0.5, 0.5}, -- NodeBox3
		{-0.5, -0.0625, -0.125, 0.5, 0.0625, 0.5}, -- NodeBox4
		{-0.5, 0.4375, -0.125, 0.5, 0.5, 0.5}, -- NodeBox5
		{-0.5, -0.5, -0.125, 0.5, -0.4375, 0.5}, -- NodeBox6
	}
}

local default_half_shelf_open = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.125, -0.4375, 0.5, 0.5}, -- NodeBox2
		{0.4375, -0.5, -0.125, 0.5, 0.5, 0.5}, -- NodeBox3
		{-0.5, -0.0625, -0.125, 0.5, 0.0625, 0.5}, -- NodeBox4
		{-0.5, 0.4375, -0.125, 0.5, 0.5, 0.5}, -- NodeBox5
		{-0.5, -0.5, -0.125, 0.5, -0.4375, 0.5}, -- NodeBox6
	}
}

local function register_node_and_recipe(item_name, material_name, display_prefix, texture)
	-- Backwards compatibility to keep existing node names same
	if material_name ~= "" then material_name = material_name.."_" end

	local slab = stairsplus:get_shape(item_name, "slab", "_1")
	if slab == nil then
		slab = material_name
	end

	itemshelf.register_shelf(material_name.."small_shelf", {
		description = "hluboká výkladní skříňka na 4 věci (" .. display_prefix..")",
		textures = {
			texture,
			texture,
			texture,
			texture,
			texture,
			texture
		},
		nodebox = default_shelf,
		capacity = 4,
		shown_items = 4
	})

	minetest.register_craft({
		output = "itemshelf:"..material_name.."small_shelf",
		recipe = {
			{item_name, item_name, item_name},
			{"", slab, ""},
			{item_name, item_name, item_name},
		}
	})

	itemshelf.register_shelf(material_name.."large_shelf", {
		description = "hluboká výkladní skříňka na 6 věcí (" .. display_prefix..")",
		textures = {
			texture,
			texture,
			texture,
			texture,
			texture,
			texture
		},
		nodebox = default_shelf,
		capacity = 6,
		shown_items = 6
	})
	
	minetest.register_craft({
		output = "itemshelf:"..material_name.."large_shelf",
		recipe = {
			{item_name, item_name, item_name},
			{item_name, slab, item_name},
			{item_name, item_name, item_name},
		}
	})

	itemshelf.register_shelf(material_name.."half_depth_shelf_small", {
		description = "mělká výkladní skříňka na 4 věci (" .. display_prefix..")",
		textures = {
			texture,
			texture,
			texture,
			texture,
			texture,
			texture
		},
		nodebox = default_half_shelf,
		capacity = 4,
		shown_items = 4,
		half_depth = true,
	})

	minetest.register_craft({
		output = "itemshelf:"..material_name.."half_depth_shelf_small",
		recipe = {
			{item_name, item_name, ""},
			{"", slab, ""},
			{item_name, item_name, ""},
		}
	})

	itemshelf.register_shelf(material_name.."half_depth_shelf_large", {
		description = "mělká výkladní skříňka na 6 věcí (" .. display_prefix..")",
		textures = {
			texture,
			texture,
			texture,
			texture,
			texture,
			texture
		},
		nodebox = default_half_shelf,
		capacity = 6,
		shown_items = 6,
		half_depth = true,
	})

	minetest.register_craft({
		output = "itemshelf:"..material_name.."half_depth_shelf_large",
		recipe = {
			{item_name, item_name, ""},
			{item_name, slab, ""},
			{item_name, item_name, ""},
		}
	})

	-- Half-depth open-back shelf, 4 items
	itemshelf.register_shelf(material_name.."half_depth_open_shelf", {
		description = "výkladní regál na 4 věci (" .. display_prefix..")",
		textures = {
			texture,
			texture,
			texture,
			texture,
			texture,
			texture
		},
		nodebox = default_half_shelf_open,
		capacity = 4,
		shown_items = 4,
		half_depth = true,
	})

	minetest.register_craft({
		output = "itemshelf:"..material_name.."half_depth_open_shelf",
		recipe = {
			{item_name, "", item_name},
			{"", slab, ""},
			{item_name, "", item_name},
		}
	})

	-- Half-depth open-back shelf, 6 items
	itemshelf.register_shelf(material_name.."half_depth_open_shelf_large", {
		description = "výkladní regál na 6 věci (" .. display_prefix..")",
		textures = {
			texture,
			texture,
			texture,
			texture,
			texture,
			texture
		},
		nodebox = default_half_shelf_open,
		capacity = 6,
		shown_items = 6,
		half_depth = true,
	})

	minetest.register_craft({
		output = "itemshelf:"..material_name.."half_depth_open_shelf_large",
		recipe = {
			{item_name, "", item_name},
			{slab, item_name, ""},
			{item_name, "", item_name},
		}
	})
end

-- Register nodes and recipes on all minetest_game wood types
register_node_and_recipe("default:wood", "", "jabloňové dřevo", "default_wood.png")
register_node_and_recipe("default:pine_wood", "pine", "borové dřevo", "default_pine_wood.png")
-- register_node_and_recipe("default:aspen_wood", "aspen", "osikové dřevo", "default_aspen_wood.png")
register_node_and_recipe("default:acacia_wood", "acacia", "akáciové dřevo", "default_acacia_wood.png")
register_node_and_recipe("default:junglewood", "jungle", "džunglovníkové dřevo", "default_junglewood.png")
if minetest.get_modpath("moretrees") then
	register_node_and_recipe("moretrees:rubber_tree_planks", "rubbertree", "kaučukovníkové dřevo", "moretrees_rubber_tree_wood.png")
end
