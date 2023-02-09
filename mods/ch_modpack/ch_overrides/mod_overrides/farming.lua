local def = {
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5 - 2 / 32, 0.5},
	},
	paramtype = "light",
	paramtype2 = "facedir",
}

if minetest.get_modpath("screwdriver") then
	def.on_rotate = screwdriver.rotate_simple
end

for _, name in ipairs({"dry_soil", "soil"}) do
	minetest.override_item("farming:"..name, def)
end

def.node_box = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, 0.5 - 3 / 32, 0.5},
}
for _, name in ipairs({"dry_soil_wet", "soil_wet"}) do
	minetest.override_item("farming:"..name, def)
end


if minetest.get_modpath("technic_cnc") then
	minetest.override_item("farming:melon_8", {
		drawtype = "mesh",
		mesh = "technic_cnc_oblate_spheroid.obj",
		tiles = {name = "farming_melon_side.png", backface_culling = true},
		paramtype2 = "facedir",
	})
	minetest.override_item("farming:pumpkin_8", {
		drawtype = "mesh",
		mesh = "technic_cnc_oblate_spheroid.obj",
		tiles = {name = "farming_pumpkin_side.png", backface_culling = true},
		paramtype2 = "facedir",
	})
end
