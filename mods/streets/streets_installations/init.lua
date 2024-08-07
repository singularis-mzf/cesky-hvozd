--[[
	## StreetsMod 2.0 ##
	Submod: installations
	Optional: true
]]

local S = minetest.get_translator("streets")
local surfaces = table.copy(streets.surfaces.surfacetypes)

local function add_surface(node_name)
	local ndef = minetest.registered_nodes[node_name]
	local tiles = table.copy(ndef.tiles)
	local tiles_count = #tiles
	local counter = 0
	for i = 1, #tiles do
		if type(tiles[i]) == "table" then
			tiles[i] = tiles[i].name
			counter = counter + 1
		end
	end
	if counter > 0 then
		ndef = table.copy(ndef)
		ndef.tiles = tiles
	end
	surfaces[node_name] = ndef
end

add_surface("building_blocks:Tar")
add_surface("default:desert_sandstone")
add_surface("default:stone")
add_surface("default:stone_block")

for surface_name, surface_data in pairs(surfaces) do
	minetest.register_node(":streets:" .. surface_name:sub(2, -1):split(":")[2] .. "_manhole", {
		description = S("průlez v: @1", surface_data.friendlyname or minetest.registered_nodes[surface_name].description),
		tiles = { surface_data["tiles"][1] .. "^streets_manhole.png", surface_data.tiles[1] },
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = { cracky = 3 },
		on_rightclick = function(pos, node, name)
			local player_name = name:get_player_name()
			if minetest.is_protected(pos, player_name) and not minetest.check_player_privs(player_name, { protection_bypass = true }) then
				minetest.record_protection_violation(pos, player_name)
				return
			end
			node.name = node.name .. "_open"
			minetest.set_node(pos, node)
		end,
		sunlight_propagates = true,
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, -0.375 }, -- F
				{ -0.5, -0.5, 0.375, 0.5, 0.5, 0.5 }, -- B
				{ -0.5, -0.5, -0.4375, -0.375, 0.5, 0.4375 }, -- Lsurface_data.friendlyname or
				{ 0.375, -0.5, -0.4375, 0.5, 0.5, 0.4375 }, -- R
				{ -0.25, 0.4375, -0.25, 0.25, 0.5, 0.25 }, -- CenterPlate
				{ -0.5, 0.4375, -0.0625, 0.5, 0.5, 0.0625 }, -- CenterLR
				{ -0.0625, 0.4375, -0.5, 0.0625, 0.5, 0.5 }, -- CenterFR
			}
		},
	})

	minetest.register_node(":streets:" .. surface_name:sub(2, -1):split(":")[2] .. "_manhole_open", {
		tiles = { surface_data["tiles"][1] .. "^streets_manhole.png", surface_data.tiles[1] },
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		climbable = true,
		drop = "streets:" .. surface_name:sub(2, -1):split(":")[2] .. "_manhole",
		groups = { cracky = 3, not_in_creative_inventory = 1 },
		on_rightclick = function(pos, node, name)
			local player_name = name:get_player_name()
			if minetest.is_protected(pos, player_name) and not minetest.check_player_privs(player_name, { protection_bypass = true }) then
				minetest.record_protection_violation(pos, player_name)
				return
			end
			node.name = string.sub(node.name, 1, -6)
			minetest.set_node(pos, node)
		end,
		sunlight_propagates = true,
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, -0.375 }, -- F
				{ -0.5, -0.5, 0.375, 0.5, 0.5, 0.5 }, -- B
				{ -0.5, -0.5, -0.4375, -0.375, 0.5, 0.4375 }, -- L
				{ 0.375, -0.5, -0.4375, 0.5, 0.5, 0.4375 }, -- R
			}
		},
	})



	minetest.register_craft({
		output = "streets:" .. surface_name:sub(2, -1):split(":")[2] .. "_manhole 4",
		recipe = {
			{ surface_name, surface_name, surface_name },
			{ surface_name, "default:steel_ingot", surface_name },
			{ surface_name, surface_name, surface_name },
		}
	})

	minetest.register_node(":streets:" .. surface_name:sub(2, -1):split(":")[2] .. "_stormdrain", {
		description = S("kanalizační vpusť v: @1", surface_data.friendlyname or minetest.registered_nodes[surface_name].description),
		tiles = { surface_data["tiles"][1] .. "^streets_stormdrain.png", surface_data.tiles[1] },
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = { cracky = 3 },
		sunlight_propagates = true,
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, -0.4375 }, -- F
				{ -0.5, -0.5, 0.4375, 0.5, 0.5, 0.5 }, -- B
				{ -0.5, -0.5, -0.4375, -0.375, 0.5, 0.4375 }, -- L
				{ 0.375, -0.5, -0.4375, 0.5, 0.5, 0.4375 }, -- R
				{ -0.4375, 0.4375, 0, 0.4375, 0.5, 0.4375 }, -- T1
				{ -0.3125, 0.4375, -0.4375, -0.25, 0.5, 0 }, -- S1
				{ 0.25, 0.4375, -0.4375, 0.3125, 0.5, 0 }, -- S2
				{ -0.1875, 0.4375, -0.4375, -0.125, 0.5, 0 }, -- S3
				{ 0.125, 0.4375, -0.4375, 0.1875, 0.5, 0 }, -- S4
				{ -0.0625, 0.4375, -0.3125, 0.0625, 0.5, 0 }, -- S5
				{ -0.125, 0.4375, -0.375, 0.125, 0.5, -0.3125 }, -- S6
			}
		},
		selection_box = {
			type = "regular"
		}
	})

	minetest.register_craft({
		output = "streets:" .. surface_name:sub(2, -1):split(":")[2] .. "_stormdrain 3",
		recipe = {
			{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
			{ surface_name, surface_name, surface_name },
		}
	})
end
