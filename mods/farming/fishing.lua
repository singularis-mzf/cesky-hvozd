--[[

This fishing routine is inspired by the great work Rootyjr did for MineClone2
Taken from Ethereal NG (The MIT License (MIT) Copyright (c) 2016 TenPlus1)

]]--

local S = farming.intllib

local fish_items = {
	"animalworld:carp",
	{"mobs_jellyfish:jellyfish", "ocean"},
	{"mobs_fish:clownfish", "savanna"},
	{"mobs_fish:tropical", "savanna"},
}

local junk_items = {
	"farming:bowl",
	"default:stick",
	"farming:string",
	"default:papyrus",
	"dye:black",
	-- {"ethereal:bamboo", "bamboo"}
}

local bonus_items = {
	"mobs:nametag",
	"mobs:saddle",
	"flowers:waterlily",
	"default:book",
}

local default_item = "default:dirt"

local random = math.random -- yup we use this a lot

--[[
-- add item function
local function add_item(fish, junk, bonus)

	if fish and fish ~= "" then
		table.insert(fish_items, fish)
	end

	if junk and junk ~= "" then
		table.insert(junk_items, junk)
	end

	if bonus and bonus ~= "" then
		table.insert(bonus_items, bonus)
	end
end
]]

local effect = function(pos)

	minetest.add_particle({
		pos = {
			x = pos.x + random() - 0.5,
			y = pos.y + 0.1,
			z = pos.z + random() - 0.5
		},
		velocity = {x = 0, y = 4, z = 0},
		acceleration = {x = 0, y = -5, z = 0},
		expirationtime = random() * 0.5,
		size = random(),
		collisiondetection = false,
		vertical = false,
		texture = "bubble.png"
	})
end


-- fishing bob entity
minetest.register_entity("farming:bob_entity", {

	initial_properties = {
		textures = {"ethereal_fishing_bob.png"},
		visual_size = {x = 0.5, y = 0.5},
		collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
		physical = false,
		pointable = false,
		static_save = false,
	},
	timer = 0,

	on_step = function(self, dtime)

		local pos = self.object:get_pos()
		local node = minetest.get_node(pos)
		local def = minetest.registered_nodes[node.name]

-- casting rod into water
if not self.cast then

		-- remove if we hit something hard
		if (def and def.walkable) or node.name == "ignore" then

			self.object:remove() ; --print("-- hit block")

			return
		end

		-- while bob is in water
		if def and def.liquidtype == "source"
		and minetest.get_item_group(node.name, "water") > 0 then

			-- incase of lag find water level
			local free_fall, blocker = minetest.line_of_sight(
				{x = pos.x, y = pos.y + 2, z = pos.z},
				{x = pos.x, y = pos.y    , z = pos.z})

			-- do we have worms for bait, if so take one
			local player = self.fisher and minetest.get_player_by_name(self.fisher)
			local inv = player and player:get_inventory()
			local bait = 0

			if inv and inv:contains_item("main", "farming:worm") then
				inv:remove_item("main", "farming:worm")
				bait = 20
			end

			-- re-position fishing bob and set to cast
			pos = {x = pos.x, y = blocker.y + 0.45, z = pos.z}

			self.object:set_acceleration({x = 0, y = 0, z = 0})
			self.object:set_velocity({x = 0, y = 0, z = 0})
			self.object:set_pos(pos)
			self.bait = bait
			self.cast = true

			-- splash
			effect(pos) ; effect(pos) ; effect(pos) ; effect(pos)

			minetest.sound_play("default_water_footstep", {pos = pos, gain = 0.1}, true)
		end

else -- already cast and waiting for fish

		-- we need a name
		if self.fisher == nil or self.fisher == "" then

			self.object:remove() ; --print("-- no name")

			return
		end

		local player = minetest.get_player_by_name(self.fisher)

		-- we need an actual person
		if not player then

			self.object:remove() ; --print("-- no player")

			return
		end

		local wield = player:get_wielded_item()

		-- we also need a rod to fish with
		if not wield or wield:get_name() ~= "farming:fishing_rod" then

			self.object:remove() ; --print("-- no rod")

			return
		end

		-- remove bob if player is too far away
		local pla_pos = player:get_pos()

		if (pla_pos.y - pos.y) > 15
		or (pla_pos.y - pos.y) < -15
		or (pla_pos.x - pos.x) > 15
		or (pla_pos.x - pos.x) < -15
		or (pla_pos.z - pos.z) > 15
		or (pla_pos.z - pos.z) < -15 then

			self.object:remove() ; --print("-- out of range")

			return
		end

		-- when in water, bob.
		if def and def.liquidtype == "source"
		and minetest.get_item_group(def.name, "water") ~= 0 then

			self.old_y = self.old_y or pos.y

			-- choose random time to wait (minus bait time for worm)
			if not self.patience or self.patience <= 0 then

				self.patience = random(10, (45 - self.bait))
				self.bait = 0
			end

			-- add particles if bobber bobbing
			if self.bob then

				effect(pos)

				-- handle timer
				if self.timer < self.patience then
					self.timer = self.timer + dtime
				else
					self.patience = 0
					self.timer = 0
					self.bob = false
				end
			else
				-- handle timer
				if self.timer < self.patience then
					self.timer = self.timer + dtime
				else
					-- waiting over, bob that bobber and play splash sound
					self.bob = true
					self.patience = 1.5 -- timeframe to catch fish after bob
					self.timer = 0

					self.object:set_velocity({x = 0, y = -1, z = 0})
					self.object:set_acceleration({x = 0, y = 3, z = 0})

					minetest.sound_play("default_water_footstep", {
						pos = pos, gain = 0.1}, true)
				end
			end
		else
			-- reset to original position after dive.
			if self.old_y and pos.y > self.old_y then

				self.object:set_velocity({x = 0, y = 0, z = 0})
				self.object:set_acceleration({x = 0, y = 0, z = 0})
				self.object:set_pos({x = pos.x, y = self.old_y, z = pos.z})
				--print("-- reset bob y pos")
			end

			-- remove if not in water and not bobbing
			if not self.bob then
				self.object:remove() ; --print("-- not in water")
			end
		end

end -- if not self.cast

	end -- on_step
})


-- narrow item list depending on biome if applicable
local find_item = function(list, pos)

	local item
	local items = {}
	local data= minetest.get_biome_data(pos)
	local biome = data and minetest.get_biome_name(data.biome) or ""

	for n = 1, #list do

		item = list[n]

		if type(item) == "string" then

			table.insert(items, item)

		elseif type(item) == "table" then

			if item[2] == "" or biome:find(item[2]) then
				table.insert(items, item[1])
			end
		end

	end

--print("==biome: " .. biome, dump(items))

	if #items > 0 then
		return items[random(#items)]
	end

	return ""
end


-- fishing rod function that throws pre bob, places bob and catches fish when it moves
local use_rod = function(itemstack, player, pointed_thing)

	local pos = player:get_pos()
	local objs = minetest.get_objects_inside_radius(pos, 15)
	local found = true
	local ent

	-- loop through entities and look for bobs
	for n = 1, #objs do

		ent = objs[n]:get_luaentity()

		if ent
		and ent.fisher
		and ent.name == "farming:bob_entity"
		and player:get_player_name() == ent.fisher then

			found = false

			if ent.bob == true then

				local item
				local r = random(100)

				if r < 86 then

					item = find_item(fish_items, pos)

				elseif r > 85 and r < 96 then

					item = find_item(junk_items, pos)

				else

					item = find_item(bonus_items, pos)
				end

				minetest.log("action", "Fishing of "..player:get_player_name().." succeeded with score "..r.." and will return "..item)
				print("[farming] Fishing of "..player:get_player_name().." succeeded with score "..r.." and will return "..item)

				-- make sure item exists, if not replace with default item
				if not minetest.registered_items[item] then
					item = default_item
				end

--print ("---caught", item, r)

				item = ItemStack(item)

				local inv = player:get_inventory()

				if inv:room_for_item("main", item) then
					inv:add_item("main", item)
				else
					minetest.add_item(pos, item)
				end
			end

			ent.object:remove()

			return itemstack
		end
	end

	-- loop through entities and look for bobs
	for n = 1, #objs do

		ent = objs[n]:get_luaentity()

		if ent
		and ent.fisher
		and ent.name == "farming:bob_entity"
		and player:get_player_name() == ent.fisher then

			found = false

			break
		end
	end

	if found == true then

		local playerpos = player:get_pos()
		local dir = player:get_look_dir()
		local pos = {x = playerpos.x, y = playerpos.y + 1.5, z = playerpos.z}

		minetest.sound_play("default_water_footstep", {pos = pos, gain = 0.1}, true)

		-- place actual bob
		local obj = minetest.add_entity(pos, "farming:bob_entity")

		obj:set_velocity({x = dir.x * 8, y = dir.y * 8, z = dir.z * 8})
		obj:set_acceleration({x = dir.x * -3, y = -9.8, z = dir.z * -3})
		obj:get_luaentity().fisher = player and player:get_player_name()
	end
end


-- scan area for bobs that belong to player and remove
local remove_bob = function(player)

	local objs = minetest.get_objects_inside_radius(player:get_pos(), 15)
	local name = player:get_player_name()
	local ent

	for n = 1, #objs do

		ent = objs[n]:get_luaentity()

		if ent and ent.name == "farming:bob_entity" then

			-- only remove players own bob
			if ent.fisher and ent.fisher == name then
				ent.object:remove()
			end
		end
	end
end


-- remove bob if player signs off
minetest.register_on_leaveplayer(function(player)
	remove_bob(player)
end)


-- remove bob if player dies
minetest.register_on_dieplayer(function(player)
	remove_bob(player)
end)


-- fishing rod
minetest.register_tool("farming:fishing_rod", {
	description = S("Fishing Rod (USE to cast and again when the time is right)"),
	_ch_help = "Slouží k lovení ryb z vody.\nLevý klik na vodu pro nahození a znovu v ten správný čas.",
	groups = {tool = 1},
	inventory_image = "ethereal_fishing_rod.png",
	wield_image = "ethereal_fishing_rod.png^[transformFX",
	wield_scale = {x = 1.5, y = 1.5, z = 1},
	stack_max = 1,
	on_use = use_rod,
	sound = {breaks = "default_tool_breaks"}
})

minetest.register_craft({
	output = "farming:fishing_rod",
	recipe = {
		{"","","group:stick"},
		{"","group:stick","farming:string"},
		{"group:stick","","farming:string"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:fishing_rod",
	burntime = 15
})

--[[ cooked fish
minetest.register_craftitem(":ethereal:fish_cooked", {
	description = S("Cooked Fish"),
	inventory_image = "ethereal_fish_cooked.png",
	wield_image = "ethereal_fish_cooked.png",
	groups = {food_fish = 1, flammable = 3, ch_food = 5},
	on_use = minetest.item_eat(5)
})

minetest.register_craft({
	type = "cooking",
	output = "ethereal:fish_cooked",
	recipe = "group:ethereal_fish",
	cooktime = 8
})
]]

-- Worm
minetest.register_craftitem("farming:worm", {
	description = S("Worm"),
	inventory_image = "ethereal_worm.png",
	wield_image = "ethereal_worm.png"
})

-- Add worms to dirt
local dirt_drop = minetest.registered_nodes["default:dirt"].drop or {}
local dirt_drop_items = (dirt_drop and dirt_drop.items) or {{items = {"default:dirt"}}}
local orig_count = #dirt_drop_items
dirt_drop.max_items = 1
dirt_drop.items = dirt_drop_items
for i = orig_count, 1, -1 do
	dirt_drop_items[i + 1] = dirt_drop_items[i]
end
dirt_drop_items[1] = {items = {"farming:worm"}, rarity = 20}
minetest.override_item("default:dirt", {drop = dirt_drop})

--[[
minetest.register_craft({
	output = "farming:worm",
	recipe = {
		{"default:dirt","default:dirt"}
	}
})
]]
