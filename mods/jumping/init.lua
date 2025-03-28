ch_base.open_mod(minetest.get_current_modname())

local trampolinebox = {
	type = "fixed",
	fixed = {
		{-0.5, -0.2, -0.5,  0.5,    0,  0.5},

		{-0.5, -0.5, -0.5, -0.4, -0.2, -0.4},
		{ 0.4, -0.5, -0.5,  0.5, -0.2, -0.4},
		{ 0.4, -0.5,  0.4,  0.5, -0.2,  0.5},
		{-0.5, -0.5,  0.4, -0.4, -0.2,  0.5},
		}
}

local cushionbox = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5,  0.5, -0.3,  0.5},
		}
}

local trampoline_punch = function(pos, node)
	local id = string.sub(node.name, #node.name)
	if id < "6" then
		id = id + 1
		minetest.swap_node(pos, {name = string.sub(node.name, 1, #node.name - 1)..id})
		minetest.get_meta(pos):set_string("infotext", "Úroveň pružnosti: "..id)
	end
end

local power_decrease = function(pos, node)
	local id = string.sub(node.name, #node.name)
	if id > "1" then
		id = id - 1
		minetest.swap_node(pos, {name = string.sub(node.name, 1, #node.name - 1)..id})
		minetest.get_meta(pos):set_string("infotext", "Úroveň pružnosti: "..id)
	end
end

for i = 1, 6 do
	minetest.register_node("jumping:trampoline"..i, {
		description = "trampolína",
		drawtype = "nodebox",
		node_box = trampolinebox,
		selection_box = trampolinebox,
		paramtype = "light",
		on_construct = function(pos)
			minetest.get_meta(pos):set_string("infotext", "Úroveň pružnosti: "..i)
		end,
		on_punch = trampoline_punch,
		on_rightclick = power_decrease,
		drop = "jumping:trampoline1",
		tiles = {
			"jumping_trampoline_top.png",
			"jumping_trampoline_bottom.png",
			"jumping_trampoline_sides.png^jumping_trampoline_sides_overlay"..i..".png"
		},
		use_texture_alpha = "opaque",
		groups = {
				dig_immediate = 2,
				bouncy = 50 + i * 10, -- 20 + i * 20,
				fall_damage_add_percent = -70,
				not_in_creative_inventory = (i > 1 and 1 or nil),
			},
	})
end

minetest.register_node("jumping:cushion", {
	description = "polštář",
	drawtype = "nodebox",
	node_box = cushionbox,
	selection_box = cushionbox,
	paramtype = "light",
	tiles = {
		"jumping_cushion_tb.png",
		"jumping_cushion_tb.png",
		"jumping_cushion_sides.png"
	},
	use_texture_alpha = "opaque",
	groups = {dig_immediate=2, disable_jump=1, fall_damage_add_percent=-100},
})

-- register recipes if the corresponding mods are present
if minetest.get_modpath("default") then
	minetest.register_craft({
		output = "jumping:trampoline1",
		recipe = {
			{"jumping:cushion", "jumping:cushion", "jumping:cushion"},
			{"default:steel_ingot", "", "default:steel_ingot"}
		}
	})
end

if minetest.get_modpath("farming") and minetest.get_modpath("wool") then
	minetest.register_craft({
		output = "jumping:cushion",
		recipe = {
			{"farming:cotton", "group:wool", "farming:cotton"},
			{"farming:cotton", "group:wool", "farming:cotton"},
			{"farming:cotton", "farming:cotton", "farming:cotton"}
		}
	})
end
ch_base.close_mod(minetest.get_current_modname())
