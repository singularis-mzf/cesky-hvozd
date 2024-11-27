ch_base.open_mod(minetest.get_current_modname())

local podiums = {}

-------------------
-- Register Nodes
-------------------

local podiums = {
	materials = {
		{"acacia_wood", "z akáciového dřeva", "default_acacia_wood.png", "default:acacia_wood", "moreblocks:slab_acacia_wood"},
		{"aspen_wood", "z osikového dřeva", "default_aspen_wood.png", "default:aspen_wood", "moreblocks:slab_aspen_wood"},
		{"junglewood", "z dřeva džunglovníku", "default_junglewood.png", "default:junglewood", "moreblocks:slab_junglewood"},
		{"pine_wood", "z borového dřeva", "default_pine_wood.png", "default:pine_wood", "moreblocks:slab_pine_wood"},
		{"wood", "z jabloňového dřeva", "default_wood.png", "default:wood", "moreblocks:slab_wood"},
	},
}

local podium_top_box = {
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
}

local podium_bottom_box = {
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
}

local podium_box = {}
local coefficient = 0.8

for _, aabb in ipairs(podium_bottom_box) do
	aabb[2] = (aabb[2] + 0.5) * coefficient - 0.5
	aabb[5] = (aabb[5] + 0.5) * coefficient - 0.5
	table.insert(podium_box, aabb)
end
for _, aabb in ipairs(podium_top_box) do
	aabb[2] = (aabb[2] + 1.5) * coefficient - 0.5
	aabb[5] = (aabb[5] + 1.5) * coefficient - 0.5
	table.insert(podium_box, aabb)
end

for _, row in ipairs(podiums.materials) do
	local name, desc, tiles, craft_material, slab_material = row[1], row[2], row[3], row[4], row[5]
	minetest.register_node(":church_podiums:podium_" ..name, {
		drawtype = "nodebox",
		description = assert(minetest.registered_nodes[craft_material].description)..": řečnický pult",
		--inventory_image = "podiums_" ..name.. "_inv.png",
		--wield_image = "podiums_" ..name.. "_inv.png",
		tiles = { tiles },
		paramtype = "light",
		paramtype2 = "4dir",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {oddly_breakable_by_hand= 2, choppy = 3},
		sounds = default.node_sound_wood_defaults(),
		node_box = {
			type = "fixed",
			fixed = podium_box,
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			},
		},
	})


---------------------------
-- Register Craft Recipes
---------------------------
	if craft_material then
		minetest.register_craft({
			output = "church_podiums:podium_" ..name,
			recipe = {
				{slab_material},
				{craft_material},
				{slab_material},
			}
		})
	end

end
ch_base.close_mod(minetest.get_current_modname())
