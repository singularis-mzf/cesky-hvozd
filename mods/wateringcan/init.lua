local S = minetest.get_translator("wateringcan")

-- some lists make it extendable

-- group:waterable
-- call on_watered(pos)

local function wetten_node(pos, node_name)
	local ndef = minetest.registered_nodes[node_name]
	if not ndef or not ndef.groups or not ndef.groups.waterable or not ndef.on_watered then
		pos = vector.new(pos.x, pos.y - 1, pos.z)
		node_name = minetest.get_node(pos).name
		ndef = minetest.registered_nodes[node_name]
		if not ndef or not ndef.groups or not ndef.groups.waterable or not ndef.on_watered then
			return false -- no node to wet
		end
	end
	ndef.on_watered(pos)
	return true
end

minetest.register_tool("wateringcan:wateringcan_water", {
	description = S("Watering can with water"),
	_ch_help = "Slouží k zalévání ornice, před použitím nutno naplnit vodou.\nPrázdnou konev naplníte levým klikem na vodu; pravým klikem ji položíte.\nNeprázdnou konví levým klikem zalijete ornici, pravý klik nemá funkci.",
	_ch_help_group = "wcan",
	inventory_image = "wateringcan_wateringcan_water.png",
	wield_image = "wateringcan_wateringcan_wield.png",
	liquids_pointable = true,
	stack_max = 1,
	groups = { disable_repair = 1 },
	tool_capabilities = {
		full_punch_interval = 2.0,
	},
	on_use = function(itemstack, user, pointed_thing)
		if(pointed_thing.type == "node") then
			local pos = pointed_thing.under
			local node = minetest.get_node_or_nil(pos)
			if node ~= nil then
				local watered = wetten_node(pos, node.name)
				local newtool
				if watered then
					minetest.sound_play({name = "wateringcan_pour", gain = 0.25, max_hear_distance = 10}, { pos = user:get_pos() }, true)
					local wear = itemstack:get_wear()
					wear = wear + 2849	 -- 24 uses
					if(wear > 65535) then
						newtool = { name = "wateringcan:wateringcan_empty" }
					else
						newtool = { name = "wateringcan:wateringcan_water", wear = wear }
					end
				elseif minetest.get_item_group(node.name, "watering") > 0 then
					newtool = { name = "wateringcan:wateringcan_water" }
					minetest.sound_play({name = "wateringcan_fill", gain = 0.25, max_hear_distance = 10}, { pos = user:get_pos() }, true)
				else
					return nil
				end
				return newtool
			end
		end
	end,
	}
)

minetest.register_node("wateringcan:wateringcan_empty", {
	drawtype = "plantlike",
	tiles = {"wateringcan_wateringcan_empty.png"},
	description = S("Empty watering can"),
	_ch_help = "Slouží k zalévání ornice, před použitím nutno naplnit vodou.\nPrázdnou konev naplníte levým klikem na vodu; pravým klikem ji položíte.\nNeprázdnou konví levým klikem zalijete ornici, pravý klik nemá funkci.",
	_ch_help_group = "wcan",
	inventory_image = "wateringcan_wateringcan_empty.png",
	wield_image = "wateringcan_wateringcan_wield.png",
	liquids_pointable = true,
	stack_max = 1,
	groups = { oddly_breakable_by_hand = 2 },
	tool_capabilities = {
		full_punch_interval = 2.0,
	},
	on_use = function(itemstack, user, pointed_thing)
		local node = minetest.get_node_or_nil(pointed_thing.under)
		if node ~= nil then
			local name = node.name
			-- local nodedef = minetest.registered_nodes[name]
			if minetest.get_item_group(name, "watering") > 0 then
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
