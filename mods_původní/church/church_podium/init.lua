
screwdriver = screwdriver or {}

local podiums = {}

-------------------
-- Register Nodes
-------------------

podiums.materials = {
	{"acacia_wood", "Acacia Wood", "default_acacia_wood.png", "default:acacia_wood"},
	{"aspen_wood", "Aspen Wood", "default_aspen_wood.png", "default:aspen_wood"},
	{"junglewood", "Jungle Wood", "default_junglewood.png", "default:junglewood"},
	{"pine_wood", "Pine Wood", "default_pine_wood.png", "default:pine_wood"},
	{"wood", "Appletree Wood", "default_wood.png", "default:wood"},
}

podiums.materials = {}

if minetest.get_modpath("default") then
	table.insert(podiums.materials, {"acacia_wood", "Acacia Wood", "default_acacia_wood.png", "default:acacia_wood", "stairs:slab_acacia_wood"})
	table.insert(podiums.materials, {"aspen_wood", "Aspen Wood", "default_aspen_wood.png", "default:aspen_wood", "stairs:slab_aspen_wood"})
	table.insert(podiums.materials, {"junglewood", "Jungle Wood", "default_junglewood.png", "default:junglewood", "stairs:slab_junglewood"})
	table.insert(podiums.materials, {"pine_wood", "Pine Wood", "default_pine_wood.png", "default:pine_wood", "stairs:slab_pine_wood"})
	table.insert(podiums.materials, {"wood", "Appletree Wood", "default_wood.png", "default:wood", "stairs:slab_wood"})
end

if minetest.get_modpath("hades_trees") then
	table.insert(podiums.materials, {"wood", "Temperate Wood", "default_wood.png", "hades_trees:wood", "hades_stairs:slab_wood"})
	table.insert(podiums.materials, {"pale_wood", "Pale Wood", "hades_trees_pale_wood.png", "hades_trees:pale_wood", "hades_stairs:slab_pale_wood"})
	table.insert(podiums.materials, {"cream_wood", "Cream Wood", "hades_trees_cream_wood.png", "hades_trees:cream_wood", "hades_stairs:slab_cream_wood"})
	table.insert(podiums.materials, {"lush_wood", "Lush Wood", "hades_trees_lush_wood.png", "hades_trees:lush_wood", "hades_stairs:slab_lush_wood"})
	table.insert(podiums.materials, {"jungle_wood", "Jungle Wood", "hades_trees_jungle_wood.png", "hades_trees:jungle_wood", "hades_stairs:slab_jungle_wood"})
	table.insert(podiums.materials, {"charred_wood", "Charred Wood", "hades_trees_charred_wood.png", "hades_trees:charred_wood", "hades_stairs:slab_charred_wood"})
	table.insert(podiums.materials, {"canvas_wood", "Canvas Wood", "hades_trees_canvas_wood.png", "hades_trees:canvas_wood", "hades_stairs:slab_canvas_wood"})
end

local wood_sounds = nil
if minetest.get_modpath("sounds") then
	wood_sounds = sounds.node_wood()
elseif minetest.get_modpath("default") then
	wood_sounds = default.node_sound_wood_defaults()
elseif minetest.get_modpath("hades_sounds") then
	wood_sounds = hades_sounds.node_sound_wood_defaults()
end

for _, row in ipairs(podiums.materials) do
	local name = row[1]
	local desc = row[2]
	local tiles = row[3]
	local craft_material = row[4]
	local slab_material = row[5]

	minetest.register_node(":church_podiums:podium_top_"..name, {
		drawtype = "nodebox",
		description = desc.." Podium",
		tiles = { tiles },
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		drop = "",
		groups = {oddly_breakable_by_hand= 2, choppy = 3, not_in_creative_inventory = 1},
		sounds = wood_sounds,
		on_rotate = screwdriver.rotate_simple,
		node_box = {
			type = "fixed",
			fixed = {
			{-0.5, -0.3125, -0.5, 0.5, -0.25, 0.5},
			{-0.4375, -0.375, -0.4375, 0.4375, -0.3125, 0.4375},
			{-0.375, -0.5, -0.4375, 0.375, -0.375, 0.375},
			{-0.5, -0.25, 0.4375, 0.5, 0, 0.5},
			{-0.5, -0.25, -0.4375, -0.4375, -0.1875, 0.4375},
			{-0.5, -0.1875, -0.25, -0.4375, -0.125, 0.4375},
			{-0.5, -0.125, -0.0625, -0.4375, -0.0625, 0.4375},
			{-0.5, -0.0625, 0.125, -0.4375, 0, 0.4375},
			{0.4375, -0.25, -0.4375, 0.5, -0.1875, 0.4375},
			{0.4375, -0.1875, -0.25, 0.5, -0.125, 0.4375},
			{0.4375, -0.125, -0.0625, 0.5, -0.0625, 0.4375},
			{0.4375, -0.0625, 0.125, 0.5, 0, 0.4375},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
			},
		}
  })

	minetest.register_node(":church_podiums:podium_bottom_" ..name, {
		drawtype = "nodebox",
		description = desc.." Podium",
		--inventory_image = "podiums_" ..name.. "_inv.png",
		--wield_image = "podiums_" ..name.. "_inv.png",
		tiles = { tiles },
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {oddly_breakable_by_hand= 2, choppy = 3},
		sounds = wood_sounds,
		on_rotate = screwdriver.rotate_simple,
		node_box = {
			type = "fixed",
			fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
			{-0.4375, -0.4375, -0.4375, 0.4375, -0.375, 0.4375},
			{-0.375, -0.375, -0.4375, 0.375, -0.1875, 0.375},
			{0.25, -0.1875, 0.3125, 0.375, 0.5, 0.375},
			{-0.375, -0.5, 0.3125, -0.25, 0.5, 0.375},
			{-0.375, -0.1875, 0.25, 0.375, 0.5, 0.3125},
			{-0.3125, -0.1875, -0.4375, -0.25, 0.5, 0.25},
			{0.25, -0.1875, -0.4375, 0.3125, 0.5, 0.3125},
			{-0.25, 0.4375, -0.4375, 0.25, 0.5, 0.25},
			{-0.25, 0.0625, -0.375, 0.25, 0.125, 0.25},
			},
		},
		selection_box = {
   type = "fixed",
   fixed = {
    {-0.5, -0.5, -0.5, 0.5, 1.125, 0.5},
   },
	},
	after_place_node =function(pos, placer)
	local p1 = {x=pos.x, y=pos.y+1, z=pos.z}
	local n1 = minetest.get_node(p1)
		if n1.name == "air" then
			minetest.add_node(p1, {name="church_podiums:podium_top_" ..name, param2=minetest.dir_to_facedir(placer:get_look_dir())})
		end
	end,
	after_destruct = function(pos,oldnode)
	local node = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z})
		if node.name == "church_podiums:podium_top_" ..name then
			minetest.dig_node({x=pos.x,y=pos.y+1,z=pos.z})
		end
	end,

	})


---------------------------
-- Register Craft Recipes
---------------------------
	if craft_material then
		minetest.register_craft({
			output = "church_podiums:podium_bottom_" ..name,
			recipe = {
				{slab_material},
				{craft_material},
				{slab_material},
			}
		})
	end

end
