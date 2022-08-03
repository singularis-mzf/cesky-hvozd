local S
if minetest.get_modpath("intllib") then
    S = intllib.Getter()
else
    S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end
end

advtrains.register_wagon("moretrains_wagon_tank", {
	mesh="moretrains_wagon_tank.b3d",
	textures = {"moretrains_wagon_tank.png"},
	seats = {},
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.719,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock 2"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Industrial tank wagon (silver)"), "moretrains_wagon_tank_inv.png")

advtrains.register_wagon("moretrains_wagon_tank2", {
	mesh="moretrains_wagon_tank.b3d",
	textures = {"moretrains_wagon_tank2.png"},
	seats = {},
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.719,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock 2"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Industrial tank wagon (blue)"), "moretrains_wagon_tank2_inv.png")


advtrains.register_wagon("moretrains_wagon_wood", {
	mesh="moretrains_wagon_wood.b3d",
	textures = {"moretrains_wagon_wood.png"},
	seats = {},
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.784,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Industrial wood wagon (empty)"), "moretrains_wagon_wood_inv.png")

advtrains.register_wagon("moretrains_wagon_wood_loaded", {
	mesh="moretrains_wagon_wood_loaded.b3d",
	textures = {"moretrains_wagon_wood.png"},
	seats = {},
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.784,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Industrial wood wagon (default tree)"), "moretrains_wagon_wood_loaded_inv.png")

advtrains.register_wagon("moretrains_wagon_wood_acacia", {
	mesh="moretrains_wagon_wood_loaded.b3d",
	textures = {"moretrains_wagon_wood_acacia.png"},
	seats = {},
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.784,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Industrial wood wagon (acacia)"), "moretrains_wagon_wood_acacia_inv.png")

advtrains.register_wagon("moretrains_wagon_wood_jungle", {
	mesh="moretrains_wagon_wood_loaded.b3d",
	textures = {"moretrains_wagon_wood_jungle.png"},
	seats = {},
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.784,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Industrial wood wagon (jungle)"), "moretrains_wagon_wood_jungle_inv.png")

advtrains.register_wagon("moretrains_wagon_wood_pine", {
	mesh="moretrains_wagon_wood_loaded.b3d",
	textures = {"moretrains_wagon_wood_pine.png"},
	seats = {},
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.784,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Industrial wood wagon (pine)"), "moretrains_wagon_wood_pine_inv.png")

advtrains.register_wagon("moretrains_wagon_wood_aspen", {
	mesh="moretrains_wagon_wood_loaded.b3d",
	textures = {"moretrains_wagon_wood_aspen.png"},
	seats = {},
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.784,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Industrial wood wagon (aspen)"), "moretrains_wagon_wood_aspen_inv.png")



advtrains.register_wagon("moretrains_wagon_box", {
	mesh="moretrains_wagon_box.b3d",
	textures = {"moretrains_wagon_box.png"},
	seats = {},
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.672,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Box wagon"), "moretrains_wagon_box_inv.png")

minetest.register_craft({
	output = 'advtrains:moretrains_wagon_wood',
	recipe = {
		{'default:stick', 'default:stick', 'default:stick'},
		{'group:wood', 'default:chest', 'group:wood'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})

minetest.register_craft({
	output = "advtrains:moretrains_wagon_wood_loaded",
	type = "shapeless",
	recipe = {"advtrains:moretrains_wagon_wood", "default:tree", "default:tree"},
})

minetest.register_craft({
	output = "advtrains:moretrains_wagon_wood_aspen",
	type = "shapeless",
	recipe = {"advtrains:moretrains_wagon_wood", "default:aspen_tree", "default:aspen_tree"},
})

minetest.register_craft({
	output = "advtrains:moretrains_wagon_wood_jungle",
	type = "shapeless",
	recipe = {"advtrains:moretrains_wagon_wood", "default:jungletree", "default:jungletree"},
})

minetest.register_craft({
	output = "advtrains:moretrains_wagon_wood_pine",
	type = "shapeless",
	recipe = {"advtrains:moretrains_wagon_wood", "default:pine_tree", "default:pine_tree"},
})

minetest.register_craft({
	output = "advtrains:moretrains_wagon_wood_acacia",
	type = "shapeless",
	recipe = {"advtrains:moretrains_wagon_wood", "default:acacia_tree", "default:acacia_tree"},
})

minetest.register_craftitem("moretrains_industrial:item_tank", {
	description = S("tank (for tankwagon)"),
	inventory_image = "moretrains_item_tank.png"
})

minetest.register_craft({
	output = "moretrains_industrial:item_tank",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "bucket:bucket_empty", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})

minetest.register_craft({
	output = 'advtrains:moretrains_wagon_tank',
	recipe = {
		{'', '', ''},
		{'default:steel_ingot', 'moretrains_industrial:item_tank', 'default:steel_ingot'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})

minetest.register_craft({
	output = 'advtrains:moretrains_wagon_tank2',
	recipe = {
		{'', 'dye:blue', ''},
		{'default:steel_ingot', 'moretrains_industrial:item_tank', 'default:steel_ingot'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})

minetest.register_craft({
	output = 'advtrains:moretrains_wagon_box',
	recipe = {
		{'default:copper_ingot', 'default:copper_ingot', 'default:copper_ingot'},
		{'default:junglewood', 'default:chest', 'default:junglewood'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})



