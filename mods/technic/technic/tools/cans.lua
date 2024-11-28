local S = technic.getter

local function set_can_wear(itemstack, level, max_level)
	local temp
	if level == 0 then
		temp = 0
	else
		temp = 65536 - math.floor(level / max_level * 65535)
		if temp > 65535 then temp = 65535 end
		if temp < 1 then temp = 1 end
	end
	itemstack:set_wear(temp)
end

local function get_can_level(itemstack)
	if itemstack:get_meta():get_string("") == "" then
		return 0
	else
		return tonumber(itemstack:get_meta():get_string(""))
	end
end

function technic.register_can(d)
	local data = {}
	for k, v in pairs(d) do data[k] = v end
	minetest.register_tool(data.can_name, {
		description = data.can_description,
		inventory_image = data.can_inventory_image,
		stack_max = 1,
		wear_represents = "content_level",
		liquids_pointable = true,
		on_use = function(itemstack, user, pointed_thing)
			if pointed_thing.type ~= "node" then return end
			local node = minetest.get_node(pointed_thing.under)
			local charge = get_can_level(itemstack)
			if node.name == data.liquid_source_name then
				if charge == data.can_capacity then return end
				if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
					minetest.log("action", user:get_player_name().." tried to take "..node.name.." at protected position "..minetest.pos_to_string(pointed_thing.under).." with a "..data.can_name)
					return
				end
				minetest.remove_node(pointed_thing.under)
				charge = charge + 1
			else
				if charge == 0 or (data.liquid_source_name ~= "default:water_source" and data.liquid_source_name ~= "default:river_water_source") then return end
				if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
					minetest.log("action", user:get_player_name().." tried to water "..node.name.." at protected position "..minetest.pos_to_string(pointed_thing.under).." with a "..data.can_name)
					return
				end
				charge = math.floor(bucket.water_land(pointed_thing.under, 8 * charge) / 8)
			end
			itemstack:get_meta():set_string("", tostring(charge))
			set_can_wear(itemstack, charge, data.can_capacity)
			return itemstack
		end,
		on_place = function(itemstack, user, pointed_thing)
			if pointed_thing.type ~= "node" then return end
			local pos = pointed_thing.under
			local node_name = minetest.get_node(pos).name
			local def = minetest.registered_nodes[node_name] or {}
			if def.on_rightclick and user and not user:get_player_control().sneak then
				return def.on_rightclick(pos, minetest.get_node(pos), user, itemstack, pointed_thing)
			end
			if not def.buildable_to or node_name == data.liquid_source_name then
				pos = pointed_thing.above
				node_name = minetest.get_node(pos).name
				def = minetest.registered_nodes[node_name] or {}
				-- Try to place node above the pointed source, or abort.
				if not def.buildable_to or node_name == data.liquid_source_name then return end
			end
			local charge = get_can_level(itemstack)
			if charge == 0 then return end
			if minetest.is_protected(pos, user:get_player_name()) then
				minetest.log("action", user:get_player_name().." tried to place "..data.liquid_source_name.." at protected position "..minetest.pos_to_string(pos).." with a "..data.can_name)
				return
			end
			minetest.set_node(pos, {name=data.liquid_source_name})
			charge = charge - 1
			itemstack:get_meta():set_string("", tostring(charge))
			set_can_wear(itemstack, charge, data.can_capacity)
			return itemstack
		end,
		on_refill = function(stack)
			stack:get_meta():set_string("", tostring(data.can_capacity))
			set_can_wear(stack, data.can_capacity, data.can_capacity)
			return stack
		end,
		get_can_capacity = function()
			return data.can_capacity
		end,
		get_can_level = get_can_level, -- function(itemstack)
		set_can_level = function(itemstack, new_level)
			local capacity = data.can_capacity
			if new_level < 0 then
				new_level = 0
			elseif new_level > capacity then
				new_level = capacity
			end
			itemstack:get_meta():set_string("", tostring(new_level))
			set_can_wear(itemstack, new_level, capacity)
			return itemstack
		end
	})
end

technic.register_can({
	can_name = "technic:water_can",
	can_description = S("Water Can"),
	can_inventory_image = "technic_water_can.png",
	can_capacity = 64,
	liquid_source_name = "default:water_source",
	liquid_flowing_name = "default:water_flowing",
})

minetest.register_craft({
	output = 'technic:water_can 1',
	recipe = {
		{'technic:zinc_ingot', 'technic:rubber','technic:zinc_ingot'},
		{'technic:carbon_steel_ingot', '', 'technic:carbon_steel_ingot'},
		{'technic:zinc_ingot', 'technic:carbon_steel_ingot', 'technic:zinc_ingot'},
	}
})

technic.register_can({
	can_name = "technic:lava_can",
	can_description = S("Lava Can"),
	can_inventory_image = "technic_lava_can.png",
	can_capacity = 64,
	liquid_source_name = "default:lava_source",
	liquid_flowing_name = "default:lava_flowing",
})

minetest.register_craft({
	output = 'technic:lava_can 1',
	recipe = {
		{'technic:zinc_ingot', 'technic:stainless_steel_ingot','technic:zinc_ingot'},
		{'technic:stainless_steel_ingot', '', 'technic:stainless_steel_ingot'},
		{'technic:zinc_ingot', 'technic:stainless_steel_ingot', 'technic:zinc_ingot'},
	}
})

technic.register_can({
	can_name = 'technic:river_water_can',
	can_description = S("River Water Can"),
	can_inventory_image = "technic_river_water_can.png",
	can_capacity = 64,
	liquid_source_name = "default:river_water_source",
	liquid_flowing_name = "default:river_water_flowing",
})

minetest.register_craft({
	output = 'technic:river_water_can 1',
	recipe = {
		{'technic:zinc_ingot', 'technic:rubber', 'technic:zinc_ingot'},
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'technic:zinc_ingot', 'default:steel_ingot', 'technic:zinc_ingot'},
	}
})
