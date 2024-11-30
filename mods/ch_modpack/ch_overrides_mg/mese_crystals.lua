-- MESE CRYSTALS
minetest.override_item("default:stone_with_mese", {
	drawtype = "mesh",
	mesh = "underch_crystal.obj",
	tiles = {{name = "dfcaverns_glow_mese.png^[brighten", backface_culling = true}},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 2,
	sunlight_propagates = true,
	-- TODO: selection_box and collision_box
})

minetest.override_item("default:mese_crystal", {
	on_place = function(itemstack, placer, pointed_thing)
		local shadow_stack = ItemStack(itemstack)
		shadow_stack:set_name("default:stone_with_mese")
		local result = minetest.item_place(shadow_stack, placer, pointed_thing)
		if result:get_count() ~= itemstack:get_count() then
			itemstack:set_count(result:get_count())
		end
		return itemstack
	end,
})
