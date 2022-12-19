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
