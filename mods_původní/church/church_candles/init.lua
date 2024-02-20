--[[
--==========================================
-- Candles mod by darkrose
-- Copyright (C) Lisa Milne 2013 <lisa@ltmnet.com>
-- Code: GPL version 2
-- http://www.gnu.org/licenses/>
--==========================================
--]]

dofile(minetest.get_modpath("church_candles").."/hive.lua")

screwdriver = screwdriver or {}

local church_candles = {}

local torches = {["default:torch"]=true}

local items = {
		steel_ingot = "default:steel_ingot",
		copper_ingot = "default:copper_ingot",
		silver_ingot = "moreores:silver_ingot",
		gold_ingot = "default:gold_ingot",
		bronze_ingot = "default:bronze_ingot",
		jungle_leaves = "default:jungleleaves",
		cotton = "farming:cotton",
	}

if minetest.get_modpath("hades_core") then
	items.steel_ingot = "hades_core:steel_ingot"
	items.copper_ingot = "hades_core:copper_ingot"
	items.silver_ingot = "hades_extraores:silver_ingot"
	items.gold_ingot = "hades_core:gold_ingot"
	items.bronze_ingot = "hades_core:bronze_ingot"
	items.jungle_leaves = "hades_trees:jungleleaves"
	items.cotton = "hades_farming:cotton"

	torches = {
			["hades_torches:torch"]=true,
			["hades_torches:torch_low"]=true
		}
end

church_candles.types = {
	{
		unlit = "church_candles:candle",
		lit = "church_candles:candle_lit",
		name = "Candle",
		ingot = nil,
		image = "church_candles_candle"
	},
		{
		unlit = "church_candles:candle_floor_steel",
		lit = "church_candles:candle_floor_steel_lit",
		name = "Steel Candle Stick",
		ingot = items.steel_ingot,
		image = "church_candles_candle_steel"
	},
	{
		unlit = "church_candles:candle_floor_copper",
		lit = "church_candles:candle_floor_copper_lit",
		name = "Copper Candle Stick",
		ingot = items.copper_ingot,
		image = "church_candles_candle_copper"
	},
	{
		unlit = "church_candles:candle_floor_silver",
		lit = "church_candles:candle_floor_silver_lit",
		name = "Silver Candle Stick",
		ingot = items.silver_ingot,
		image = "church_candles_candle_silver"
	},
	{
		unlit = "church_candles:candle_floor_gold",
		lit = "church_candles:candle_floor_gold_lit",
		name = "Gold Candle Stick",
		ingot = items.gold_ingot,
		image = "church_candles_candle_gold"
	},
	{
		unlit = "church_candles:candle_floor_bronze",
		lit = "church_candles:candle_floor_bronze_lit",
		name = "Bronze Candle Stick",
		ingot = items.bronze_ingot,
		image = "church_candles_candle_bronze"
	},
	{
		unlit = "church_candles:candle_wall_steel",
		lit = "church_candles:candle_wall_steel_lit",
		name = "Steel Wall-Mount Candle",
		ingot = items.steel_ingot,
		image = "church_candles_candle_steel"
	},
	{
		unlit = "church_candles:candle_wall_copper",
		lit = "church_candles:candle_wall_copper_lit",
		name = "Copper Wall-Mount Candle",
		ingot = items.copper_ingot,
		image = "church_candles_candle_copper"
	},
	{
		unlit = "church_candles:candle_wall_silver",
		lit = "church_candles:candle_wall_silver_lit",
		name = "Silver Wall-Mount Candle",
		ingot = items.silver_ingot,
		image = "church_candles_candle_silver"
	},
	{
		unlit = "church_candles:candle_wall_gold",
		lit = "church_candles:candle_wall_gold_lit",
		name = "Gold Wall-Mount Candle",
		ingot = items.gold_ingot,
		image = "church_candles_candle_gold"
	},
	{
		unlit = "church_candles:candle_wall_bronze",
		lit = "church_candles:candle_wall_bronze_lit",
		name = "Bronze Wall-Mount Candle",
		ingot = items.bronze_ingot,
		image = "church_candles_candle_bronze"
	},
	{
		unlit = "church_candles:candelabra_steel",
		lit = "church_candles:candelabra_steel_lit",
		name = "Steel Candelebra",
		ingot = items.steel_ingot,
		image = "church_candles_candelabra_steel"
	},
	{
		unlit = "church_candles:candelabra_copper",
		lit = "church_candles:candelabra_copper_lit",
		name = "Copper Candelebra",
		ingot = items.copper_ingot,
		image = "church_candles_candelabra_copper"
	},
	{
		unlit = "church_candles:candelabra_silver",
		lit = "church_candles:candelabra_silver_lit",
		name = "Silver Candelebra",
		ingot = items.silver_ingot,
		image = "church_candles_candelabra_silver"
	},
	{
		unlit = "church_candles:candelabra_gold",
		lit = "church_candles:candelabra_gold_lit",
		name = "Gold Candelebra",
		ingot = items.gold_ingot,
		image = "church_candles_candelabra_gold"
	},
	{
		unlit = "church_candles:candelabra_bronze",
		lit = "church_candles:candelabra_bronze_lit",
		name = "Bronze Candelebra",
		ingot = items.bronze_ingot,
		image = "church_candles_candelabra_bronze"
	},
}

church_candles.find_lit = function(name)
	for i,n in pairs(church_candles.types) do
		if n.unlit == name then
			return n.lit
		end
	end
	return nil
end

church_candles.find_unlit = function(name)
	for i,n in pairs(church_candles.types) do
		if n.lit == name then
			return n.unlit
		end
	end
	return nil
end

church_candles.light1 = function(pos, node, puncher)
	if not puncher or not node then
		return
	end
	local wield = puncher:get_wielded_item()
	if not wield then
		return
	end
	wield = wield:get_name()
	if wield and torches[wield] then
		local litname = church_candles.find_lit(node.name)
		minetest.add_node(pos,{name=litname, param1=node.param1, param2=node.param2})
	local p1 = {x=pos.x, y=pos.y+1, z=pos.z}
	local n1 = minetest.get_node(p1)
	if n1.name == "air" then
			minetest.add_node(p1, {name="church_candles:candle_flame"})
		end
		end
	end

church_candles.light2 = function(pos, node, puncher)
	if not puncher or not node then
		return
	end
	local wield = puncher:get_wielded_item()
	if not wield then
		return
	end
	wield = wield:get_name()
	if wield and torches[wield] then
		local litname = church_candles.find_lit(node.name)
		minetest.add_node(pos,{name=litname, param1=node.param1, param2=node.param2})
		end
	end

church_candles.light3 = function(pos, node, puncher)
	if not puncher or not node then
		return
	end
	local wield = puncher:get_wielded_item()
	if not wield then
		return
	end
	wield = wield:get_name()
	if wield and torches[wield] then
		local litname = church_candles.find_lit(node.name)
		minetest.add_node(pos,{name=litname, param1=node.param1, param2=node.param2})
	local p1 = {x=pos.x, y=pos.y+1, z=pos.z}
	local n1 = minetest.get_node(p1)
	if n1.name == "air" then
			minetest.add_node(p1, {name="church_candles:candelabra_flame", param2 = 1})
		end
		end
	end

	church_candles.snuff1 = function(pos, node, puncher)
	if not puncher or not node then
		return
	end
	local wield = puncher:get_wielded_item()
	if not wield then
		return
	end
	wield = wield:get_name()
	if not wield or (not torches[wield]) then
		local unlitname = church_candles.find_unlit(node.name)
		minetest.add_node(pos,{name=unlitname, param1=node.param1, param2=node.param2})

	local p1 = {x=pos.x, y=pos.y+1, z=pos.z}
	local n1 = minetest.get_node(p1)
	if n1.name == "church_candles:candle_flame"then
			minetest.remove_node(p1, {name="church_candles:candle_flame"})
		end
	end
	end

	church_candles.snuff2 = function(pos, node, puncher)
	if not puncher or not node then
		return
	end
	local wield = puncher:get_wielded_item()
	if not wield then
		return
	end
	wield = wield:get_name()
	if not wield or (not torches[wield]) then
		local unlitname = church_candles.find_unlit(node.name)
		minetest.add_node(pos,{name=unlitname, param1=node.param1, param2=node.param2})
		end
		end

	church_candles.snuff3 = function(pos, node, puncher)
	if not puncher or not node then
		return
	end
	local wield = puncher:get_wielded_item()
	if not wield then
		return
	end
	wield = wield:get_name()
	if not wield or (not torches[wield]) then
		local unlitname = church_candles.find_unlit(node.name)
		minetest.add_node(pos,{name=unlitname, param1=node.param1, param2=node.param2})

	local p1 = {x=pos.x, y=pos.y+1, z=pos.z}
	local n1 = minetest.get_node(p1)
	if n1.name == "church_candles:candelabra_flame"then
			minetest.remove_node(p1, {name="church_candles:candelabra_flame"})
		end
	end
	end

local candle_sounds = nil
if minetest.get_modpath("sounds") then
	candle_sounds = sounds.node_metal({
			dug = {name = "default_dig_crumbly", gain = 1.0}, 
			dig = {name = "default_dig_crumbly", gain = 0.1},
		})
elseif minetest.get_modpath("default") then
	candle_sounds = default.node_sound_metal_defaults({
			dug = {name = "default_dig_crumbly", gain = 1.0}, 
			dig = {name = "default_dig_crumbly", gain = 0.1},
		})
elseif minetest.get_modpath("hades_sounds") then
	candle_sounds = hades_sounds.node_sound_metal_defaults({
			dug = {name = "default_dig_crumbly", gain = 1.0}, 
			dig = {name = "default_dig_crumbly", gain = 0.1},
		})
end

church_candles.create_wall = function(ctype)
	minetest.register_node(ctype.unlit, {
		description = ctype.name,
		tiles = {ctype.image.."_top.png",ctype.image.."_bottom.png",ctype.image..".png"},
		use_texture_alpha = "clip",
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {crumbly=3,oddly_breakable_by_hand=1},
		on_punch = church_candles.light1,
		sunlight_propagates = true,
		walkable = false,
		sounds = candle_sounds,
		on_rotate = screwdriver.rotate_simple,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.125, 0.0625, -0.125, 0.125, 0.125, 0.125},
				{-0.0625, -0.1875, -0.0625, 0.0625, 0.0625, 0.0625},
				{-0.125, -0.25, -0.125, 0.125, -0.125, 0.125},
				{-0.0625, -0.3125, -0.0625, 0.375, -0.25, 0.0625},
				{0.4375, -0.4375, -0.1875, 0.5, -0.125, 0.1875},
				{0.3125, -0.375, -0.125, 0.5, -0.1875, 0.125},
				{-0.0625, 0.125, -0.0625, 0.0625, 0.5, 0.0625},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.1875, -0.5, -0.25, 0.5, 0.5, 0.25},
		},
		on_place = function(itemstack, placer, pointed_thing)
			local above = pointed_thing.above
			local under = pointed_thing.under
			local dir = {x = under.x - above.x,
				     y = under.y - above.y,
				     z = under.z - above.z}

			local wdir = minetest.dir_to_wallmounted(dir)
			local fdir = minetest.dir_to_facedir(dir)

			if wdir == 0 or wdir == 1 then
				return itemstack
			else
				fdir = fdir-1
				if fdir < 0 then
					fdir = 3
				end
				minetest.add_node(above, {name = itemstack:get_name(), param2 = fdir})
				itemstack:take_item()
				return itemstack
			end
		end
	})

	minetest.register_node(ctype.lit, {
		description = ctype.name,
		tiles = {ctype.image.."_top.png",ctype.image.."_bottom.png",ctype.image.."_lit.png"},
		use_texture_alpha = "clip",
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {crumbly=3,oddly_breakable_by_hand=1, not_in_creative_inventory = 1},
		on_punch = church_candles.snuff1,
		sunlight_propagates = true,
		walkable = false,
		sounds = candle_sounds,
		on_rotate = screwdriver.rotate_simple,
		drop = ctype.unlit,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.125, 0.0625, -0.125, 0.125, 0.125, 0.125},
				{-0.0625, -0.1875, -0.0625, 0.0625, 0.0625, 0.0625},
				{-0.125, -0.25, -0.125, 0.125, -0.125, 0.125},
				{-0.0625, -0.3125, -0.0625, 0.375, -0.25, 0.0625},
				{0.4375, -0.4375, -0.1875, 0.5, -0.125, 0.1875},
				{0.3125, -0.375, -0.125, 0.5, -0.1875, 0.125},
				{-0.0625, 0.125, -0.0625, 0.0625, 0.5, 0.0625},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.1875, -0.5, -0.25, 0.5, 0.5, 0.25},
		},
		can_dig = function(pos,player)
			return false
		end,
	})
	minetest.register_craft({
		output = ctype.unlit,
		recipe = {
			{"","church_candles:candle",""},
			{"",ctype.ingot,ctype.ingot},
		}
	})
end

church_candles.create_floor= function(ctype)
	minetest.register_node(ctype.unlit, {
		description = ctype.name,
		tiles = {ctype.image.."_top.png",ctype.image.."_bottom.png",ctype.image..".png"},
		use_texture_alpha = "clip",
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {crumbly=3,oddly_breakable_by_hand=1},
		on_punch = church_candles.light1,
		sunlight_propagates = true,
		walkable = false,
		sounds = candle_sounds,
		on_rotate = screwdriver.rotate_simple,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.0625, -0.375, -0.0625, 0.0625, 0.5, 0.0625},
				{-0.125, 0.0625, -0.125, 0.125, 0.125, 0.125},
				{-0.1875, -0.5, -0.1875, 0.1875, -0.4375, 0.1875},
				{-0.125, -0.4375, -0.125, 0.125, -0.375, 0.125},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875},
			},
		},
				on_place = function(itemstack, placer, pointed_thing)
			local above = pointed_thing.above
			local under = pointed_thing.under
			local dir = {x = under.x - above.x,
				     y = under.y - above.y,
				     z = under.z - above.z}

			local wdir = minetest.dir_to_wallmounted(dir)
			local fdir = minetest.dir_to_facedir(dir)

			if wdir == 1 then
				minetest.add_node(above, {name = itemstack:get_name(), param2 = fdir})
				itemstack:take_item()
			end
			return itemstack
		end
	})

	minetest.register_node(ctype.lit, {
		description = ctype.name,
		tiles = {ctype.image.."_top.png",ctype.image.."_bottom.png",ctype.image.."_lit.png"},
		use_texture_alpha = "clip",
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {crumbly=3,oddly_breakable_by_hand=1, not_in_creative_inventory = 1},
		on_punch = church_candles.snuff1,
		sunlight_propagates = true,
		walkable = false,
		sounds = candle_sounds,
		on_rotate = screwdriver.rotate_simple,
		drop = ctype.unlit,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.0625, -0.375, -0.0625, 0.0625, 0.5, 0.0625},
				{-0.125, 0.0625, -0.125, 0.125, 0.125, 0.125},
				{-0.1875, -0.5, -0.1875, 0.1875, -0.4375, 0.1875},
				{-0.125, -0.4375, -0.125, 0.125, -0.375, 0.125},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875},
			},
		},
		can_dig = function(pos,player)
			return false
		end,
	})
	minetest.register_craft({
		output = ctype.unlit,
		recipe = {
			{"church_candles:candle"},
			{ctype.ingot},
		}
	})
end

church_candles.create_candelabra = function(ctype)
	minetest.register_node(ctype.unlit, {
		description = ctype.name,
		tiles = {ctype.image.."_top.png",ctype.image.."_bottom.png",ctype.image..".png"},
		use_texture_alpha = "clip",
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {crumbly=3,oddly_breakable_by_hand=1},
		on_punch = church_candles.light3,
		sunlight_propagates = true,
		walkable = false,
		sounds = candle_sounds,
		on_rotate = screwdriver.rotate_simple,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.0625, -0.375, -0.0625, 0.0625, 0.5, 0.0625},
				{-0.0625, 0.0625, -0.4375, 0.0625, 0.125, 0.4375},
				{-0.1875, -0.5, -0.1875, 0.1875, -0.4375, 0.1875},
				{-0.125, -0.4375, -0.125, 0.125, -0.375, 0.125},
				{-0.125, 0.125, 0.25, 0.125, 0.1875, 0.5},
				{-0.125, 0.125, -0.5, 0.125, 0.1875, -0.25},
				{-0.125, 0.125, -0.125, 0.125, 0.1875, 0.125},
				{-0.0625, 0.1875, 0.3125, 0.0625, 0.5, 0.4375},
				{-0.0625, 0.125, -0.4375, 0.0625, 0.5, -0.3125},
				{-0.4375, 0.0625, -0.0625, 0.4375, 0.125, 0.0625},
				{0.25, 0.125, -0.125, 0.5, 0.1875, 0.125},
				{0.3125, 0.1875, -0.0625, 0.4375, 0.5, 0.0625},
				{-0.5, 0.125, -0.125, -0.25, 0.1875, 0.125},
				{-0.4375, 0.1875, -0.0625, -0.3125, 0.5, 0.0625},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.45, -0.45, -0.45, 0.45, 0.45, 0.45},
		},
		on_place = function(itemstack, placer, pointed_thing)
			local above = pointed_thing.above
			local under = pointed_thing.under
			local dir = {x = under.x - above.x,
				     y = under.y - above.y,
				     z = under.z - above.z}

			local wdir = minetest.dir_to_wallmounted(dir)
			local fdir = minetest.dir_to_facedir(dir)

			if wdir == 1 then
				minetest.add_node(above, {name = itemstack:get_name(), param2 = fdir})
				itemstack:take_item()
			end
			return itemstack
		end
	})

	minetest.register_node(ctype.lit, {
		description = ctype.name,
		tiles = {ctype.image.."_top.png",ctype.image.."_bottom.png",ctype.image.."_lit.png"},
		use_texture_alpha = "clip",
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {crumbly=3,oddly_breakable_by_hand=1, not_in_creative_inventory = 1},
		on_punch = church_candles.snuff3,
		sunlight_propagates = true,
		walkable = false,
		sounds = candle_sounds,
		on_rotate = screwdriver.rotate_simple,
		drop = ctype.unlit,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.0625, -0.375, -0.0625, 0.0625, 0.5, 0.0625},
				{-0.0625, 0.0625, -0.4375, 0.0625, 0.125, 0.4375},
				{-0.1875, -0.5, -0.1875, 0.1875, -0.4375, 0.1875},
				{-0.125, -0.4375, -0.125, 0.125, -0.375, 0.125},
				{-0.125, 0.125, 0.25, 0.125, 0.1875, 0.5},
				{-0.125, 0.125, -0.5, 0.125, 0.1875, -0.25},
				{-0.125, 0.125, -0.125, 0.125, 0.1875, 0.125},
				{-0.0625, 0.1875, 0.3125, 0.0625, 0.5, 0.4375},
				{-0.0625, 0.125, -0.4375, 0.0625, 0.5, -0.3125},
				{-0.4375, 0.0625, -0.0625, 0.4375, 0.125, 0.0625},
				{0.25, 0.125, -0.125, 0.5, 0.1875, 0.125},
				{0.3125, 0.1875, -0.0625, 0.4375, 0.5, 0.0625},
				{-0.5, 0.125, -0.125, -0.25, 0.1875, 0.125},
				{-0.4375, 0.1875, -0.0625, -0.3125, 0.5, 0.0625},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.45, -0.45, -0.45, 0.45, 0.45, 0.45},
		},
		can_dig = function(pos,player)
			return false
		end,
	})
	minetest.register_craft({
		output = ctype.unlit,
		recipe = {
			{"church_candles:candle","church_candles:candle","church_candles:candle"},
			{ctype.ingot,ctype.ingot,ctype.ingot},
		}
	})
end

minetest.register_node("church_candles:candle", {
	description = "Candle",
	drawtype = "plantlike",
	tiles = {"church_candles_candle.png"},
	paramtype = "light",
	groups = {crumbly=3,oddly_breakable_by_hand=1},
	on_punch = church_candles.light2,
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.1875, -0.5, -0.1875, 0.1875, 0.125, 0.1875},
	},
	on_place = function(itemstack, placer, pointed_thing)
		local above = pointed_thing.above
		local under = pointed_thing.under
		local dir = {x = under.x - above.x,
			     y = under.y - above.y,
			     z = under.z - above.z}

		local wdir = minetest.dir_to_wallmounted(dir)

		if wdir == 1 then
			minetest.add_node(above, {name = "church_candles:candle"})
			itemstack:take_item()
		end
		return itemstack
	end
})

minetest.register_node("church_candles:candle_lit", {
	description = "Candle",
	drawtype = "plantlike",
	tiles = {
		{name="church_candles_candle_lit.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1}},
	},
	paramtype = "light",
	groups = {crumbly=3,oddly_breakable_by_hand=1, not_in_creative_inventory = 1},
	on_punch = church_candles.snuff2,
	sunlight_propagates = true,
	walkable = false,
	light_source = 10,
	drop = "church_candles:candle",
	selection_box = {
		type = "fixed",
		fixed = {-0.1875, -0.5, -0.1875, 0.1875, 0.125, 0.1875},
	},
	can_dig = function(pos,player)
		return false
	end,
})

minetest.register_node("church_candles:candle_flame", {
	drawtype = "plantlike",
	tiles = {
		{
			name = "church_candles_candle_flame.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	paramtype = "light",
	light_source = 12,
	walkable = false,
	buildable_to = false,
	pointable = false,
	sunlight_propagates = true,
	damage_per_second = 1,
	groups = {torch = 1, dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "",
	can_dig = function(pos,player)
			return false
		end,
})

minetest.register_node("church_candles:candelabra_flame", {
	drawtype = "plantlike",
		tiles = {
		{
			name = "church_candles_candelabra_flame.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 1,
	light_source = 14,
	walkable = false,
	buildable_to = false,
	pointable = false,
	sunlight_propagates = true,
	damage_per_second = 1,
	groups = {torch = 1, dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "",
	can_dig = function(pos,player)
		return false
	end,
	})


for i,n in pairs(church_candles.types) do
   if n.ingot then
		if string.find(n.unlit,"candle_wall") then
		church_candles.create_wall(n)
		end
		if string.find(n.unlit,"candelabra") then
		church_candles.create_candelabra(n)
		end
		if string.find(n.unlit,"candle_floor") then
		church_candles.create_floor(n)
		end
	end
end

----------------
-- Craft Items
----------------
minetest.register_craftitem("church_candles:wax", {
	description = "Wax Material",
	inventory_image = "church_candles_wax.png",
})

------------------
-- Craft Recipes
------------------
--[[
minetest.register_craft({
	output = "church_candles:wax 2", --Palm Wax???   :)
	recipe = {
		{items.jungle_leaves, items.jungle_leaves, items.jungle_leaves},
		{items.jungle_leaves, items.jungle_leaves, items.jungle_leaves},
		{items.jungle_leaves, items.jungle_leaves, items.jungle_leaves},
	}
})
--]]

minetest.register_craft({
	output = "church_candles:candle",
	recipe = {
		{"church_candles:wax", items.cotton, "church_candles:wax"},
	}
})
