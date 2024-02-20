--[[
--==========================================
-- Candles mod by darkrose
-- Copyright (C) Lisa Milne 2013 <lisa@ltmnet.com>
-- Code: GPL version 2
-- http://www.gnu.org/licenses/>
--==========================================
--Artificial Hive node functions and formspec from xdecor mod
--Copyright (c) 2015-2016 kilbith <jeanpatrick.guerrero@gmail.com>
--Code: GPL version 3
--==========================================
--]]

local hive = {}

local honey_max = 16

function hive.construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	local formspec = [[ size[8,5;]
	label[0.5,0.03;Bees are busy making honey...]
	image[7,0;1,1;church_candles_hive_bee.png]
	image[6,0;1,1;church_candles_hive_dandelion.png]
	image[5,0;1,1;church_candles_hive_layout.png]
	list[context;honey;5,0;1,1;]
	list[current_player;main;0,1.35;8,4;] ]]
	..default.gui_bg
	..default.gui_bg_img
	..default.gui_slots
	..default.get_hotbar_bg(0,1.35)

	meta:set_string("formspec", formspec)
	meta:set_string("infotext", "Artificial Hive")
	inv:set_size("honey", 1)

	local timer = minetest.get_node_timer(pos)
	timer:start(math.random(64, 128))
end

function hive.timer(pos)
	local time = (minetest.get_timeofday() or 0) * 24000
	if time < 5500 or time > 18500 then return true end

	local inv = minetest.get_meta(pos):get_inventory()
	local honeystack = inv:get_stack("honey", 1)
	local honey = honeystack:get_count()

	local radius = 4
	local minp = vector.add(pos, -radius)
	local maxp = vector.add(pos, radius)
	local flowers = minetest.find_nodes_in_area_under_air(minp, maxp, "group:flower")

	if #flowers > 2 and honey < honey_max then
		inv:add_item("honey", "church_candles:honey")
	elseif honey == honey_max then
		local timer = minetest.get_node_timer(pos)
		timer:stop() return true
	end
	return true
end

--------------------
-- Nodes
--------------------

local add_bee = function(pos, rand)
	end
if minetest.get_modpath("mobs_animal") then
	add_bee = function(pos, rand)
			if math.random(1, rand) == 1 then
				minetest.add_entity(pos, "mobs_animal:bee")
			end
		end
elseif minetest.get_modpath("hades_animals") then
	add_bee = function(pos, rand)
			if math.random(1, rand) == 1 then
				minetest.add_entity(pos, "hades_animals:bee")
			end
		end
end

local leaves_sounds = nil
local wood_sounds = nil
local dirt_sounds = nil
local glass_sounds = nil
if minetest.get_modpath("sounds") then
	leaves_sounds = sounds.node_leaves()
	wood_sounds = sounds.node_wood()
	dirt_sounds = sounds.node_dirt()
	glass_sounds = sounds.node_glass()
elseif minetest.get_modpath("default") then
	leaves_sounds = default.node_sound_leaves_defaults()
	wood_sounds = default.node_sound_wood_defaults()
	dirt_sounds = default.node_sound_dirt_defaults()
	glass_sounds = default.node_sound_glass_defaults()
elseif minetest.get_modpath("hades_sounds") then
	leaves_sounds = hades_sounds.node_sound_leaves_defaults()
	wood_sounds = hades_sounds.node_sound_wood_defaults()
	dirt_sounds = hades_sounds.node_sound_dirt_defaults()
	glass_sounds = hades_sounds.node_sound_glass_defaults()
end

--Natural Beehive
minetest.register_node("church_candles:hive_wild", {
	description = "Beehive",
	drawtype = "plantlike",
	--visual_scale = 0.5,
	tiles = {"church_candles_hive_wild.png"},
	inventory_image = "church_candles_hive_wild.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = true,
	groups = {snappy = 3, oddly_breakable_by_hand = 2, flammable = 1, not_in_creative_inventory = 1},
	sounds = leaves_sounds,
	drop = {
		max_items = 1,
		items = {
			{items = {"church_candles:comb"}, rarity = 5},
			{items = {"church_candles:honey 2"}}
		}
	},
    after_place_node = function(pos, placer, itemstack)
			add_bee(pos, 6)
	end,
	on_punch = function(_, _, puncher, _)
		local health = puncher:get_hp()
		puncher:set_hp(health - 1)
	end,
	on_rightclick = function(_, _, clicker)
		local health = clicker:get_hp()
		clicker:set_hp(health - 1)
	end,
})
--Artificial Hive
minetest.register_node("church_candles:hive", {
	description = "Artificial Hive",
	tiles = {"church_candles_hive_top.png","church_candles_hive_bottom.png",
		"church_candles_hive.png","church_candles_hive.png",
		"church_candles_hive.png","church_candles_hive.png"},
	drawtype = "nodebox",
	use_texture_alpha = "clip",
	paramtype = "light",
	paramtype2 = "facedir",
	place_param2 = 0,
	on_rotate = screwdriver.rotate_simple,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 3, not_in_creative_inventory = 1},
	sounds = wood_sounds,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, 0.4375, 0, 0.4375},
			{-0.375, -0.0625, -0.375, 0.375, 0.5, 0.375},
			{-0.4375, 0.375, -0.4375, 0.4375, 0.4375, 0.4375},
			{0.375, 0, -0.4375, 0.4375, 0.4375, -0.375},
			{-0.4375, 0, -0.4375, -0.375, 0.4375, -0.375},
			{-0.4375, 0, 0.375, -0.375, 0.4375, 0.4375},
			{0.375, 0, 0.375, 0.4375, 0.4375, 0.4375},
		},
    },
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	},
    after_place_node = function(pos, placer, itemstack)
			add_bee(pos, 12)
	end,
	on_construct = hive.construct,
	on_timer = hive.timer,
	can_dig = function(pos)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("honey")
	end,
	on_punch = function(_, _, puncher)
		puncher:set_hp(puncher:get_hp() - 1)
	end,
	allow_metadata_inventory_put = function() return 0 end,
	on_metadata_inventory_take = function(pos, _, _, stack)
		if stack:get_count() == honey_max then
			local timer = minetest.get_node_timer(pos)
			timer:start(math.random(64, 128))
		end
	end
})

minetest.register_node("church_candles:hive_empty", {
	description = "Artificial Hive (empty)",
	tiles = {"church_candles_hive_empty_top.png","church_candles_hive_empty_bottom.png",
		"church_candles_hive_empty.png","church_candles_hive_empty.png",
		"church_candles_hive_empty.png","church_candles_hive_empty.png"},
	drawtype = "nodebox",
	use_texture_alpha = "clip",
	paramtype = "light",
	paramtype2 = "facedir",
	place_param2 = 0,
	on_rotate = screwdriver.rotate_simple,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = wood_sounds,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, 0.4375, 0, 0.4375},
			{-0.375, -0.0625, -0.375, 0.375, 0.5, 0.375},
			{-0.4375, 0.375, -0.4375, 0.4375, 0.4375, 0.4375},
			{0.375, 0, -0.4375, 0.4375, 0.4375, -0.375},
			{-0.4375, 0, -0.4375, -0.375, 0.4375, -0.375},
			{-0.4375, 0, 0.375, -0.375, 0.4375, 0.4375},
			{0.375, 0, 0.375, 0.4375, 0.4375, 0.4375},
		},
    },
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	},
    after_place_node = function(pos, placer, itemstack)
			add_bee(pos, 18)
	end,
	on_timer = function(pos,elapsed)
		minetest.add_node(pos,{name="church_candles:hive"})
		return false
	end,
	on_construct = function(pos)
		local tmr = minetest.get_node_timer(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext","Bee Hive: Empty");
		tmr:start(300)
	end
})
--Busy Bees (adapted from glow mod by bdjnk)
minetest.register_node("church_candles:busybees", {
	description = "Busy Bees",
	inventory_image ="church_candles_hive_bee.png",
	drawtype = "glasslike",
	tiles = {
		{
			name = "church_candles_hive_busybees.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			},
		},
	},
	alpha = 155,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	climbable = false,
	buildable_to = true,
	groups = {not_in_creative_inventory =1},
	on_punch = function(_, _, puncher, _)
		local health = puncher:get_hp()
		puncher:set_hp(health - 1)
	end,
	on_rightclick = function(_, _, clicker)
		local health = clicker:get_hp()
		clicker:set_hp(health - 1)
	end,
	on_construct = function(pos)
		minetest.sound_play("church_candles_bee", {pos = pos, gain = 0.009, max_hear_distance = 1.0})
	end,
})
--Honeycomb Block
minetest.register_node("church_candles:honeycomb_block", {
	description = "Honeycomb Block",
	inventory_image = "church_candles_honey_comb_block.png",
	tiles = {"church_candles_honey_comb_block.png"},
	groups = {oddly_breakable_by_hand = 3, dig_immediate = 1},
	sounds = dirt_sounds,
})
--Jar of Honey
minetest.register_node("church_candles:honey_jar", {
	description = "Jar of Honey",
	inventory_image = "church_candles_honey_jar_inv.png",
	drawtype = "nodebox",
	use_texture_alpha = true,
	tiles = {"church_candles_honey_jar_top.png","church_candles_honey_jar_bottom.png","church_candles_honey_jar.png"},
	wield_image = "church_candles_honey_jar_inv.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.1875, 0.1875, 0.0625, 0.1875},
			{-0.125, 0.0625, -0.125, 0.125, 0.125, 0.125},
			{-0.25, -0.4375, -0.1875, 0.25, 0, 0.1875},
			{-0.1875, -0.4375, -0.25, 0.1875, 0, 0.25},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.3125, 0.3125, 0.1875, 0.3125},
			--{-0.25, -0.5, -0.25, 0.25, 0.4, 0.25}
		},
	},
	groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
	sounds = glass_sounds,
	on_use = minetest.item_eat(10),
})
--Bottle of Honey
minetest.register_node("church_candles:honey_bottled", {
	description = "Bottled Honey",
	inventory_image = "church_candles_honey_bottled.png",
	drawtype = "plantlike",
	tiles = {"church_candles_honey_bottled.png"},
	wield_image = "church_candles_honey_bottled.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.4, 0.25}
	},
	groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
	sounds = glass_sounds,
	on_use = minetest.item_eat(6, "vessels:glass_bottle"),
})
------------
-- ABMs
------------
--particle ABM adapted from Bees Mod by bas080
  minetest.register_abm({ --particles
    nodenames = {"church_candles:hive", "church_candles:hive_empty"},
    interval  = 10,
    chance    = 4,
    action = function(pos)
    if minetest.get_timeofday() >= 0.25 and minetest.get_timeofday() < 0.75 then
      minetest.add_particle({
        pos = {x=pos.x, y=pos.y, z=pos.z},
        velocity = {x=(math.random()-0.5)*5,y=(math.random()-0.5)*5,z=(math.random()-0.5)*5},
        accceleration = {x=math.random()-0.5,y=math.random()-0.5,z=math.random()-0.5},
        expirationtime = math.random(3.5),
        minsize = 0.1,
        maxsize = 0.2,
        collisiondetection = true,
        texture = "church_candles_hive_bee.png",
      })
      end
    end,
  })
--bee spawning adapted from glow mod by bdjnk
minetest.register_abm({
	nodenames = { "air" },
	neighbors = {"group:flower"},
	interval = 1200,
	chance = 100,
	action = function(pos, node, active_object_count, active_object_count_wider)
if minetest.get_timeofday() >= 0.25 and minetest.get_timeofday() < 0.75 then
			if minetest.find_node_near(pos, 4, "church_candles:busybees") == nil then
				minetest.set_node(pos, {name = "church_candles:busybees"})
				minetest.sound_play("church_candles_bee", {pos = pos, gain = 0.1, max_hear_distance = 1.0})
			end
		end
	end,
})

minetest.register_abm({
	nodenames = { "air" },
	neighbors = {"church_candles:hive_wild"},
	interval = 60,
	chance = 10,
	action = function(pos, node, active_object_count, active_object_count_wider)
if minetest.get_timeofday() >= 0.25 and minetest.get_timeofday() < 0.75 then
			if minetest.find_node_near(pos, 4, "church_candles:busybees") == nil then
				minetest.set_node(pos, {name = "church_candles:busybees"})
				minetest.sound_play("church_candles_bee", {pos = pos, gain = 0.1, max_hear_distance = 1.0})
			end
		end
	end,
})

minetest.register_abm({
	nodenames = {"church_candles:busybees"},
	interval = 100,
	chance = 3,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.remove_node(pos)
	end,
})

local hive_wild_spawn_interval = tonumber(minetest.settings:get("church_candles_wild_hive_spawn_interval") or "207")
local hive_wild_spawn_chance = tonumber(minetest.settings:get("church_candles_wild_hive_spawn_chance") or "6001")

if not minetest.get_modpath("hades_core") then
  if hive_wild_spawn_chance>0 then
    minetest.register_abm({
      nodenames = "default:apple",
      neighbors = "default:leaves",
      interval = hive_wild_spawn_interval,
      chance = hive_wild_spawn_chance,
      action = function(pos, node, active_object_count, active_object_count_wider)
        local abv = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z})
        if not abv or abv.name ~= "default:leaves" then
          return nil
        end
        if minetest.find_node_near(pos, 10, {"church_candles:hive_wild","church_candles:busybees"}) ~= nil then
          return nil
        end
        minetest.add_node(pos,{name="church_candles:hive_wild", param2 = 0})
      end
    })
  end
else
  if hive_wild_spawn_chance>0 then
    -- special callback version for Hades Revisited
    minetest.register_abm({
      nodenames = "group:fruit_regrow",
      neighbors = "group:leaves",
      interval = hive_wild_spawn_interval,
      chance = hive_wild_spawn_chance,
      action = function(pos, node, active_object_count, active_object_count_wider)
        if minetest.get_item_group(node.name, "fruit_regrow")~=2 then
          return nil
        end
        local abv = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z})
        if not abv or minetest.get_item_group(abv.name, "leaves")==0 then
          return nil
        end
        local objs = minetest.get_objects_inside_radius(pos, 10)
        for _,obj in pairs(objs) do
          local luaentity = object:get_luaentity()
          if luaentity and (luaentity.name=="hades_animals:bee") then
            minetest.add_node(pos,{name="church_candles:hive_wild", param2 = 0})
            return nil
          end
        end
      end
    })
  end
end
----------------
-- Craft Items
----------------
minetest.register_craftitem("church_candles:honey", {
	description = "Honey",
	inventory_image = "church_candles_honey.png",
	wield_image = "church_candles_honey.png",
	on_use = minetest.item_eat(2)
})

minetest.register_craftitem("church_candles:comb", {
	description = "Honey Comb",
	inventory_image = "church_candles_honey_comb.png",
	on_use = minetest.item_eat(4),
})
------------------
-- Craft Recipes
------------------
local items = {
		glass = "default:glass",
		wood = "default:wood",
		glass_bottle = "vessels:glass_bottle",
	}

if minetest.get_modpath("hades_core") then
	items.glass = "hades_core:glass"
	items.wood = "hades_trees:wood"
	items.glass_bottle = "hades_vessels:glass_bottle"
end

minetest.register_craft({
	output = "church_candles:hive_empty",
	recipe = {
		{"group:stick", "group:stick", "group:stick"},
		{"group:stick",  items.glass , "group:stick"},
		{items.wood ,    items.wood  ,  items.wood},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "church_candles:wax 2",
	recipe = "church_candles:comb"
})

minetest.register_craft({
	output = "church_candles:honey 2",
	recipe = {
		{"church_candles:comb"},
	}
})

minetest.register_craft({
	output = "church_candles:honey_jar",
	recipe = {
		{"church_candles:honey", "church_candles:honey"},
		{"church_candles:comb", "church_candles:comb"},
		{items.glass_bottle, items.glass_bottle},
	}
})

minetest.register_craft({
	output = "church_candles:honey_bottled 1",
	recipe = {
        {"church_candles:honey"},
		{"church_candles:honey"},
		{items.glass_bottle},
	}
})

minetest.register_craft({
	output = "church_candles:comb 9",
	recipe = {
		{"church_candles:honeycomb_block"},
	}
})

minetest.register_craft({
	output = "church_candles:honeycomb_block",
	recipe = {
		{"church_candles:comb", "church_candles:comb", "church_candles:comb"},
		{"church_candles:comb", "church_candles:comb", "church_candles:comb"},
		{"church_candles:comb", "church_candles:comb", "church_candles:comb"},
	}
})
