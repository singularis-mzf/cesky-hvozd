print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_overrides_mg")

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

-- SCREWDRIVER
minetest.override_item("screwdriver:screwdriver", {
	_ch_help = "Slouží k otáčení bloků.\nKliknutí levým tlačítkem otočí blok okolo osy, kliknutí pravým změní osu otáčení."
})



-- temp

minetest.override_item("default:aspen_wood", {
	tiles = {"(default_aspen_wood.png^[resize:128x128)^(ch_core_planks_128.png^[makealpha:255,255,255^[opacity:50^[resize:128x128)"},
})

minetest.override_item("default:acacia_wood", {
	tiles = {"(default_acacia_wood.png^[resize:128x128)^(ch_core_planks_128.png^[makealpha:255,255,255^[opacity:100^[resize:128x128)"},
})

minetest.override_item("default:junglewood", {
	tiles = {"(default_junglewood.png^[resize:128x128)^(ch_core_planks_128.png^[makealpha:255,255,255^[opacity:150^[resize:128x128)"},
})

--[[
minetest.override_item("default:pine_wood", {
	tiles = {"default_pine_wood.png^[resize:128x128^(ch_core_planks_128.png^[makealpha:255,255,255^[opacity:50^[resize:128x128)"},
})
]]

minetest.override_item("default:wood", {
	tiles = {"(default_wood.png^[resize:128x128)^(ch_core_planks_128.png^[makealpha:255,255,255^[opacity:100^[resize:128x128)"},
})


print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
