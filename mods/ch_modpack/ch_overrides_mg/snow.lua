-- SNOW
local box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5},
	},
}
minetest.override_item("default:snow", {
	tiles = {{name = "default_snow.png", backface_culling = true}},
	drawtype = "mesh",
	mesh = "ch_overrides_mg_snow.obj",
	collision_box = box,
	selection_box = box,
})
