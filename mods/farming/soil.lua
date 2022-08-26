local S = farming.intllib

-- default dry soil node
local dry_soil = "farming:soil"

-- add soil types to existing dirt blocks
minetest.override_item("default:dirt", {
	soil = {
		base = "default:dirt",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})

minetest.override_item("default:dirt_with_grass", {
	soil = {
		base = "default:dirt_with_grass",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})

minetest.override_item("default:dirt_with_dry_grass", {
	soil = {
		base = "default:dirt_with_dry_grass",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})

minetest.override_item("default:dirt_with_rainforest_litter", {
	soil = {
		base = "default:dirt_with_rainforest_litter",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})

if minetest.registered_nodes["default:dirt_with_coniferous_litter"] then

	minetest.override_item("default:dirt_with_coniferous_litter", {
		soil = {
			base = "default:dirt_with_coniferous_litter",
			dry = "farming:soil",
			wet = "farming:soil_wet"
		}
	})
end

-- add watering property to the default water sources
local g = minetest.registered_nodes["default:water_source"].groups or {}
g.watering = 3
minetest.override_item("default:water_source", {groups = g})
g = minetest.registered_nodes["default:river_water_source"].groups or {}
g.watering = 3
minetest.override_item("default:river_water_source", {groups = g})

-- watering
local function on_watered(pos)
	local node = minetest.get_node_or_nil(pos)
	if node then
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.soil then
			local wet_soil = ndef.soil.wet
			if wet_soil then
				minetest.swap_node(pos, {name = wet_soil})
			end
		end
	end
	return true
end

-- savanna soil
if minetest.registered_nodes["default:dry_dirt"] then

	minetest.override_item("default:dry_dirt", {
		soil = {
			base = "default:dry_dirt",
			dry = "farming:dry_soil",
			wet = "farming:dry_soil_wet"
		}
	})

	minetest.override_item("default:dry_dirt_with_dry_grass", {
		soil = {
			base = "default:dry_dirt_with_dry_grass",
			dry = "farming:dry_soil",
			wet = "farming:dry_soil_wet"
		}
	})

	minetest.register_node("farming:dry_soil", {
		description = S("Savanna Soil"),
		tiles = {
			"default_dry_dirt.png^farming_soil.png",
			"default_dry_dirt.png"
		},
		drop = "default:dry_dirt",
		groups = {crumbly = 3, not_in_creative_inventory = 1, soil = 2, field = 1, waterable = 1},
		sounds = default.node_sound_dirt_defaults(),
		soil = {
			base = "default:dry_dirt",
			dry = "farming:dry_soil",
			wet = "farming:dry_soil_wet"
		},
		on_watered = on_watered,
	})

	minetest.register_node("farming:dry_soil_wet", {
		description = S("Wet Savanna Soil"),
		tiles = {
			"default_dry_dirt.png^farming_soil_wet.png",
			"default_dry_dirt.png^farming_soil_wet_side.png"
		},
		drop = "default:dry_dirt",
		groups = {crumbly = 3, not_in_creative_inventory = 1, soil = 3, field = 1},
		sounds = default.node_sound_dirt_defaults(),
		soil = {
			base = "default:dry_dirt",
			dry = "farming:dry_soil",
			wet = "farming:dry_soil_wet"
		}
	})

	dry_soil = "farming:dry_soil"
end

-- normal soil
minetest.register_node("farming:soil", {
	description = S("Soil"),
	tiles = {"default_dirt.png^farming_soil.png", "default_dirt.png"},
	drop = "default:dirt",
	groups = {crumbly = 3, not_in_creative_inventory = 1, soil = 2, field = 1, waterable = 1},
	sounds = default.node_sound_dirt_defaults(),
	soil = {
		base = "default:dirt",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	},
	on_watered = on_watered,
})

-- wet soil
minetest.register_node("farming:soil_wet", {
	description = S("Wet Soil"),
	tiles = {
		"default_dirt.png^farming_soil_wet.png",
		"default_dirt.png^farming_soil_wet_side.png"
	},
	drop = "default:dirt",
	groups = {crumbly = 3, not_in_creative_inventory = 1, soil = 3, field = 1},
	sounds = default.node_sound_dirt_defaults(),
	soil = {
		base = "default:dirt",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})


-- sand is not soil, change existing sand-soil to use dry soil
minetest.register_alias("farming:desert_sand_soil", dry_soil)
minetest.register_alias("farming:desert_sand_soil_wet", dry_soil .. "_wet")

local random_gen = PcgRandom(os.clock())

function farming.has_watering(pos)
	local watering_nodes = minetest.find_nodes_in_area(
		vector.new(pos.x - 5, pos.y - 1, pos.z - 5),
		vector.new(pos.x + 5, pos.y + 3, pos.z + 5),
		"group:watering")
	if #watering_nodes == 0 then
		return false
	end
	for _, wpos in pairs(watering_nodes) do
		local max_distance = minetest.get_item_group(minetest.get_node(wpos).name, "watering") or 0
		if math.abs(pos.x - wpos.x) <= max_distance and math.abs(pos.z - wpos.z) <= max_distance and math.abs(pos.y - wpos.y) <= max_distance then
			return true
		end
	end
	return false
end

function farming.trigger_drying_soil(pos, randomly)
	-- temporarily disable drying randomization
	--[[ if randomly then
		local random_value = random_gen:next(0, 4)
		if random_value ~= 0 then
			return true
		end
	end ]]
	local node = minetest.get_node_or_nil(pos)
	if not node or minetest.get_item_group(node.name, "soil") ~= 3 or farming.has_watering(pos) then
		return false
	else
		minetest.swap_node(pos, { name = minetest.registered_nodes[node.name].soil.dry })
		return true
	end
end

-- if watering node is near waterable node then water it
minetest.register_abm({
	label = "Soil watering",
	nodenames = {"group:waterable"},
	interval = 15,
	chance = 4,
	catch_up = false,

	action = function(pos, node, active_object_count, active_object_count_wider)
		-- minetest.chat_send_all("DEBUG: ABM called at pos "..pos.x..", "..pos.y..","..pos.z.."!")
		if farming.has_watering(pos) then
			local ndef = minetest.registered_nodes[node.name]
			if ndef and ndef.soil and ndef.soil.wet then
				minetest.swap_node(pos, { name = ndef.soil.wet })
			else
				minetest.log("warning", "Waterable node "..node.name.." does not have wet soil definition!")
			end
		end
	end,
})
