ch_base.open_mod(minetest.get_current_modname())
-- from Bushes classic mod (originally by unknown, maintained by VanessaE),
-- reduced by Singularis

-- support for i18n
local S = minetest.get_translator("bushes_classic")

-- Gooseberry
minetest.register_craftitem(":bushes:gooseberry", {
	description = S("Gooseberry"),
	inventory_image = "bushes_gooseberry.png",
	groups = {food_berry = 1, food_gooseberry = 1, flammable = 2, ch_food = 1},
	on_use = ch_core.item_eat(),
})

local bushes = {
	["strawberry"] = {
		description = S("Strawberry Bush"),
		berry = "farming:strawberry",
		berry_name_raw = "Strawberry",
                      --[[
		raw_pie = S("Raw Strawberry pie"),
		cooked_pie = S("Cooked Strawberry pie"),
		cooked_pie_2 = S("Slice @1", S("of ") ]]
	},
	["blackberry"] = {
		description = S("Blackberry Bush"),
		berry = "farming:blackberry",
		berry_name_raw = "Blackberry",
	},
	["blueberry"] = {
		description = S("Blueberry Bush"),
		berry = "farming:blueberries",
		berry_group = "food_blueberries",
		berry_name_raw = "Blueberry",
	},
	["raspberry"] = {
		description = S("Raspberry Bush"),
		berry = "farming:raspberries",
		berry_name_raw = "Raspberry",
	},
	["gooseberry"] = {
		description = S("Gooseberry Bush"),
		berry = "bushes:gooseberry",
		berry_group = "food_gooseberry",
		berry_name_raw = "Gooseberry",
	},
	["fruitless"] = {
		description = S("Currently fruitless Bush"),
	},
}

local grow_interval = 5
local berries_on_bush = 20

local function on_punch_gooseberry(pos, node, puncher, pointed_thing)
	if minetest.is_player(puncher) and pointed_thing.type == "node" then
		local player_name = puncher:get_player_name()
		if minetest.is_protected(pos, player_name) then
			minetest.record_protection_violation(pos, player_name)
			return
		end
		local meta = minetest.get_meta(pos)
		local cas = ch_core.aktualni_cas()
		local limit = meta:get_int("berry_limit")
		if limit < cas.znamka32 + berries_on_bush * grow_interval and math.random(0, 9) < 8 then
			meta:set_int("berry_limit", math.max(limit, cas.znamka32) + grow_interval)
			local inv = puncher:get_inventory()
			local remains = inv:add_item("main", ItemStack("bushes:gooseberry"))
			if not remains:is_empty() then
				minetest.add_item(puncher:get_pos(), remains)
			end
		end
	end
end

local def = {
	drawtype = "mesh",
	mesh = "bushes_bush.obj",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	groups = {snappy = 3, bush = 1, flammable = 2, attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	-- drop = "",
}

for id, bushdef in pairs(bushes) do
	def.description = bushdef.description
	def.tiles = {"bushes_bush_"..id..".png"}
	if id == "gooseberry" then
		def.on_punch = on_punch_gooseberry
	else
		def.on_punch = nil
	end
	minetest.register_node("bushes_classic:"..id.."_bush", table.copy(def))
end

-- Basket
--[[
minetest.register_craft({
	output = "bushes:basket_empty",
	recipe = {
		{ "default:stick", "default:stick", "default:stick" },
		{ "", "default:stick", "" },
	},
})
]]

for berry, bushdef in pairs(bushes) do

	local berry_group = bushdef.berry_group
	if berry_group == nil then
		berry_group = "food_"..berry
	end

	-- Raw pie
	if bushdef.berry_name_raw ~= nil then
		minetest.register_craftitem(":bushes:"..berry.."_pie_raw", {
			description = S("Raw "..bushdef.berry_name_raw.." Pie"),
			inventory_image = "bushes_"..berry.."_pie_raw.png",
			on_use = ch_core.item_eat(),
			groups = {ch_food = 4},
		})

		minetest.register_craft({
			output = "bushes:"..berry.."_pie_raw 1",
			recipe = {
				{ "group:"..berry_group, "group:"..berry_group, "group:"..berry_group },
				{ "group:food_sugar", "farming:flour", "group:food_sugar" },
			},
		})

	-- Cooked pie
		minetest.register_craftitem(":bushes:"..berry.."_pie_cooked", {
			description = S("Cooked "..bushdef.berry_name_raw.." Pie"),
			inventory_image = "bushes_"..berry.."_pie_cooked.png",
			on_use = ch_core.item_eat(),
			groups = {ch_food = 6},
		})

		minetest.register_craft({
			type = "cooking",
			output = "bushes:"..berry.."_pie_cooked",
			recipe = "bushes:"..berry.."_pie_raw",
			cooktime = 30,
		})

		-- Slice of pie
		minetest.register_craftitem(":bushes:"..berry.."_pie_slice", {
			description = S("Slice of "..bushdef.berry_name_raw.." Pie"),
			inventory_image = "bushes_"..berry.."_pie_slice.png",
			on_use = ch_core.item_eat(),
			groups = {ch_food = 1},
		})

		minetest.register_craft({
			output = "bushes:"..berry.."_pie_slice 6",
			recipe = {
				{ "bushes:"..berry.."_pie_cooked" },
			},
		})

		--[[
		-- Basket with pies
		minetest.register_craft({
			output = "bushes:basket_"..berry.." 1",
			recipe = {
			{ "bushes:"..berry.."_pie_cooked", "bushes:"..berry.."_pie_cooked", "bushes:"..berry.."_pie_cooked" },
			{ "", "bushes:basket_empty", "" },
			},
		})
		]]
	end
end

minetest.register_craftitem(":bushes:mixed_berry_pie_raw", {
	description = S("Raw Mixed Berry Pie"),
	inventory_image = "bushes_mixed_berry_pie_raw.png",
	on_use = ch_core.item_eat(),
	groups = {ch_food = 4},
})

minetest.register_craft({
	output = "bushes:mixed_berry_pie_raw 2",
	recipe = {
		{ "group:food_berry", "group:food_berry", "group:food_berry" },
		{ "group:food_sugar", "farming:flour", "group:food_sugar" },
	},
})

minetest.register_craftitem(":bushes:mixed_berry_pie_cooked", {
	description = S("Cooked Mixed Berry Pie"),
	inventory_image = "bushes_mixed_berry_pie_cooked.png",
	on_use = ch_core.item_eat(),
	groups = {ch_food = 6},
})

minetest.register_craft({
	type = "cooking",
	output = "bushes:mixed_berry_pie_cooked",
	recipe = "bushes:mixed_berry_pie_raw",
	cooktime = 30,
})

-- Slice of pie
minetest.register_craftitem(":bushes:mixed_berry_pie_slice", {
	description = S("Slice of @1", S("Cooked Mixed Berry pie")),
	inventory_image = "bushes_mixed_berry_pie_slice.png",
	on_use = ch_core.item_eat(),
	groups = {ch_food = 1},
})

minetest.register_craft({
	output = "bushes:mixed_berry_pie_slice 6",
	recipe = {
		{ "bushes:mixed_berry_pie_cooked" },
	},
})
ch_base.close_mod(minetest.get_current_modname())
