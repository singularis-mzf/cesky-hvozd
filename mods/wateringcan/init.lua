local S = minetest.get_translator("wateringcan")

-- some lists make it extendable
wateringcan = {
	wettable_nodes = {},
	wettable_groups = {},
}

if minetest.get_modpath("farming") then
	wateringcan.wettable_nodes["farming:soil"] = function(pos)
		minetest.set_node(pos, { name = "farming:soil_wet" })
	end
	wateringcan.wettable_nodes["farming:dry_soil"] = function(pos)
		minetest.set_node(pos, { name = "farming:dry_soil_wet" })
	end
	wateringcan.wettable_nodes["farming:desert_sand_soil"] = function(pos)
		minetest.set_node(pos, { name = "farming:desert_sand_soil_wet" })
	end
end
if minetest.get_modpath("hades_farming") then
	wateringcan.wettable_nodes["hades_farming:soil"] = function(pos)
		minetest.set_node(pos, { name = "hades_farming:soil_wet" })
	end
end
if minetest.get_modpath("pedology") then
	wateringcan.wettable_groups["sucky"] = function(pos, node_name)
		if (minetest.get_item_group(node_name, "wet")<2) then
			pedology.wetten(pos)
		end
	end
end

local function wetten_node(pos, node_name)
	local wettable_callback = wateringcan.wettable_nodes[node_name];
	if wettable_callback then
		wettable_callback(pos, node_name);
	else
		for group_name,group_callback in pairs(wateringcan.wettable_groups) do
			if (minetest.get_item_group(node_name, group_name)>0) then
				group_callback(pos, node_name);
			end
		end
	end
end

minetest.register_tool("wateringcan:wateringcan_water", {
	description = S("Watering can with water"),
  _tt_help = S("Use watering can by placing it to node or flora."),
	_doc_items_create_entry = false,
	inventory_image = "wateringcan_wateringcan_water.png",
	wield_image = "wateringcan_wateringcan_wield.png",
	liquids_pointable = true,
	stack_max = 1,
	groups = { disable_repair = 1 },
	tool_capabilities = {
		full_punch_interval = 2.0,
	},
	on_place = function(itemstack, user, pointed_thing)
		if(pointed_thing.type == "node") then
			local pos = pointed_thing.under
			local node = minetest.get_node_or_nil(pos)
			if node ~= nil then
				local name, nodedef
				local watered = true
				local wear, newtool
				local underunder
				if minetest.get_item_group(node.name, "plant") > 0 or minetest.get_item_group(node.name, "flora") > 0 or minetest.get_item_group(node.name, "seed") > 0 then
					pos = {x=pos.x, y=pos.y-1, z=pos.z}
					underunder = minetest.get_node_or_nil(pos)
					if(underunder ~= nil) then
						name = underunder.name
						nodedef = minetest.registered_nodes[name]
					else
						return itemstack
					end
				else
					name = node.name
					nodedef = minetest.registered_nodes[name]
				end
				if minetest.get_item_group(name, "water") > 0 then
					newtool = { name = "wateringcan:wateringcan_water" }
					watered = false
					minetest.sound_play({name = "wateringcan_fill", gain = 0.25, max_hear_distance = 10}, { pos = user:get_pos() }, true)
				else
					wetten_node(pos, name);
				end

				if watered then
					minetest.sound_play({name = "wateringcan_pour", gain = 0.25, max_hear_distance = 10}, { pos = user:get_pos() }, true)
					wear = itemstack:get_wear()
					wear = wear + 2849	 -- 24 uses
					if(wear > 65535) then
						newtool = { name = "wateringcan:wateringcan_empty" }
					else
						newtool = { name = "wateringcan:wateringcan_water", wear = wear }
					end
				end
				return newtool
			end
		end
	end,
	}
)

local usagehelp, longdesc, entry_name
local entry_name
if minetest.get_modpath("doc_items") then
	usagehelp = S("Rightclick on water (or any other block belonging to the “@1” group) to fill or refill the watering can. Rightclick with the filled can on an appropriate block (or a plant above it) to wetten it. Soil, desert sand soil, and other blocks capable of becoming wet can be wettened. The tool wear indicator of the watering can indicates the amount of water left.", doc.sub.items.get_group_name("water"))
	entry_name = S("Watering can")
	longdesc = S("Watering cans are used to collect a small amount of water in order to pour it on dry blocks. One filled watering can can be used 24 times, after which it has to be refilled. Watering cans don't wear out.")
end

minetest.register_tool("wateringcan:wateringcan_empty", {
	description = S("Empty watering can"),
	_doc_items_entry_name = entry_name,
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usagehelp,
	inventory_image = "wateringcan_wateringcan_empty.png",
	wield_image = "wateringcan_wateringcan_wield.png",
	liquids_pointable = true,
	stack_max = 1,
	groups = { disable_repair = 1 },
	tool_capabilities = {
		full_punch_interval = 2.0,
	},
	on_place = function(itemstack, user, pointed_thing)
		local node = minetest.get_node_or_nil(pointed_thing.under)
		if node ~= nil then
			local name = node.name
			local nodedef = minetest.registered_nodes[name]
			if minetest.get_item_group(name, "water") > 0 then
				minetest.sound_play({name = "wateringcan_fill", gain = 0.25, max_hear_distance = 10}, { pos = user:get_pos() }, true)
				return { name = "wateringcan:wateringcan_water" }
			end
		end
	end
})

if minetest.get_modpath("bucket") ~= nil then
	if minetest.get_modpath("default") ~= nil then
		minetest.register_craft({
			output = "wateringcan:wateringcan_empty",
			recipe = {
				{"", "", "default:steel_ingot"},
				{"group:stick", "default:steel_ingot", ""},
				{"default:steel_ingot", "bucket:bucket_empty", ""},
			}
		})
		minetest.register_craft({
			output = "wateringcan:wateringcan_water",
			recipe = {
				{"", "", "default:steel_ingot"},
				{"group:stick", "default:steel_ingot", ""},
				{"default:steel_ingot", "group:water_bucket", ""},
			}
		})
	end
	minetest.register_craft({
		output = "wateringcan:wateringcan_water",
		type = "shapeless",
		recipe = {"wateringcan:wateringcan_empty", "group:water_bucket"},
		replacements = {{"group:water_bucket", "bucket:bucket_empty"}}
	})
end
if minetest.get_modpath("hades_bucket") ~= nil then
	if minetest.get_modpath("hades_core") ~= nil then
		minetest.register_craft({
			output = "wateringcan:wateringcan_empty",
			recipe = {
				{"", "", "hades_core:steel_ingot"},
				{"group:stick", "hades_core:steel_ingot", ""},
				{"hades_core:steel_ingot", "hades_bucket:bucket_empty", ""},
			}
		})
		minetest.register_craft({
			output = "wateringcan:wateringcan_water",
			recipe = {
				{"", "", "hades_core:steel_ingot"},
				{"group:stick", "hades_core:steel_ingot", ""},
				{"hades_core:steel_ingot", "group:water_bucket", ""},
			}
		})
	end
	minetest.register_craft({
		output = "wateringcan:wateringcan_water",
		type = "shapeless",
		recipe = {"wateringcan:wateringcan_empty", "group:water_bucket"},
		replacements = {{"group:water_bucket", "hades_bucket:bucket_empty"}}
	})
end

if minetest.get_modpath("doc") ~= nil and minetest.get_modpath("doc_items") ~= nil then
	doc.add_entry_alias("tools", "wateringcan:wateringcan_empty", "tools", "wateringcan:wateringcan_water")
end
