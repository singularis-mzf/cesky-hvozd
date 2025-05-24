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
	local old_on_place = {
		["farming:melon_8"] = minetest.registered_nodes["farming:melon_8"].on_place or minetest.item_place,
		["farming:pumpkin_8"] = minetest.registered_nodes["farming:pumpkin_8"].on_place or minetest.item_place,
	}
	local overrides = {
		drawtype = "mesh",
		mesh = "technic_cnc_oblate_spheroid.obj",
		tiles = {{name = "farming_melon_side.png", backface_culling = true}},
		use_texture_alpha = "oblique",
		paramtype2 = "colorfacedir",
		palette = "ch_overrides_melon_palette.png",
		on_growth = function(pos, node, elapsed)
			local facedir = node.param2 % 32
			local new_color = math.random(1, 8) - 1
			node.param2 = 32 * new_color + facedir
			minetest.swap_node(pos, node)
		end,
		on_place = function(itemstack, placer, pointed_thing)
			local name = itemstack:get_name()
			local on_place = old_on_place[name] or minetest.item_place
			local result = on_place(itemstack, placer, table.copy(pointed_thing))
			if pointed_thing.type == "node" then
				local node = minetest.get_node(pointed_thing.above)
				if node.name == name then
					local facedir = node.param2 % 32
					local new_color = math.random(1, 8) - 1
					node.param2 = 32 * new_color + facedir
					minetest.swap_node(pointed_thing.above, node)
				end
			end
			return result
		end,
	}
	minetest.override_item("farming:melon_8", table.copy(overrides))
	overrides.tiles = {{name = "farming_pumpkin_side.png", backface_culling = true}}
	minetest.override_item("farming:pumpkin_8", overrides)
end

-- Food
local extra_food = {
	["default:apple"] = 2,
	["default:blueberries"] = 2,
	["flowers:mushroom_brown"] = 1,
	["flowers:mushroom_red"] = -5,
}

local bowls = {
	["farming:porridge"] = "farming:bowl",
	["farming:cactus_juice"] = "vessels:drinking_glass",
	["farming:bibimbap"] = "farming:bowl",
	["farming:salad"] = "farming:bowl",
	["farming:smoothie_berry"] = "vessels:drinking_glass",
	["farming:smoothie_raspberry"] = "vessels:drinking_glass",
	["farming:spanish_potatoes"] = "farming:bowl",
	["farming:potato_omelet"] = "farming:bowl",
	["farming:paella"] = "farming:bowl",
	["farming:soy_milk"] = "vessels:drinking_glass",
}

for name, def in pairs(minetest.registered_items) do
	if name:sub(1, 8) == "farming:" and def.on_use ~= nil and def.groups ~= nil and (def.groups.ch_food ~= nil or def.groups.drink ~= nil) then
		minetest.override_item(name, {on_use = ch_core.item_eat(bowls[name])})
	end
end
for name, value in pairs(extra_food) do
	if minetest.registered_items[name] ~= nil then
		local groups = minetest.registered_items[name].groups or {}
		if value >= 0 then
			groups.ch_food = value
		else
			groups.ch_poison = -value
		end
		minetest.override_item(name, {groups = groups, on_use = ch_core.item_eat()})
	end
end


core.override_item("farming:glass_water", {
	groups = ch_core.override_groups(assert(core.registered_items["farming:glass_water"].groups), {drink = 2}),
	on_use = ch_core.item_eat("vessels:drinking_glass"),
})
