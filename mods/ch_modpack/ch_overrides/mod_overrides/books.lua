if minetest.get_modpath("default") and minetest.get_modpath("technic_cnc") then
	-- Give the machine the correct textures:
	local tiles = {
		{ name = "technic_cnc_top.png", backface_culling = true },
		{ name = "technic_cnc_bottom.png", backface_culling = true },
		{ name = "technic_cnc_side.png", backface_culling = true },
		{ name = "technic_cnc_side.png", backface_culling = true },
		{ name = "technic_cnc_side.png", backface_culling = true },
		{ name = "technic_cnc_top.png^[transformFY^[resize:64x64^(default_book.png^[resize:64x64)", backface_culling = true },
	}
	minetest.override_item("books:machine", {tiles = tiles})
end
