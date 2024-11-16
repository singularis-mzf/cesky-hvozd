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

local function get_name_base(name)
	local parts = name:gsub("^:", ""):split(":")
	local result = parts[2]
	if result == "marble" or result == "granite" then
		result = parts[1].."_"..parts[2]
	end
	return result
end

--[[
add_surface("building_blocks:Tar")
add_surface("default:desert_sandstone")
add_surface("default:stone")
add_surface("default:stone_block")
]]
for _, name in ipairs(ch_core.get_materials_from_shapes_db("streets")) do
	if minetest.registered_nodes[name] then
		add_surface(name)
	end
end

for surface_name, surface_data in pairs(surfaces) do
	local allow_manhole = ch_core.is_shape_allowed(surface_name, "streets", "manhole")
	local allow_stormdrain = ch_core.is_shape_allowed(surface_name, "streets", "stormdrain")

	if allow_manhole then
		local name = "streets:"..get_name_base(surface_name).."_manhole"
		if minetest.registered_nodes[name] ~= nil then
			error("Node already exists: "..name.." (surface_name == "..surface_name..")!")
		end
		local tiles = { surface_data.tiles[1] .. "^streets_manhole.png", surface_data.tiles[1] }
		if surface_name == "ch_extras:zdlazba" then
			for i = 3, 6 do
				tiles[i] = "default_stone_brick.png"
			end
		elseif surface_name == "ch_extras:cervzdlazba" then
			for i = 3, 6 do
				tiles[i] = "default_desert_stone_brick.png"
			end
		end

	minetest.register_node(name, {
		description = S("průlez v: @1", surface_data.friendlyname or minetest.registered_nodes[surface_name].description),
		tiles = tiles,
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = { cracky = 3, streets_manhole = 1 },
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

	minetest.register_node(name.."_open", {
		tiles = tiles,
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		climbable = true,
		drop = name,
		groups = { cracky = 3, not_in_creative_inventory = 1, streets_manhole = 2 },
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
		output = name.." 4",
		recipe = {
			{ surface_name, surface_name, surface_name },
			{ surface_name, "default:steel_ingot", surface_name },
			{ surface_name, surface_name, surface_name },
		}
	})
	end

	if allow_stormdrain then
		local name = "streets:"..get_name_base(surface_name).."_stormdrain"
		if minetest.registered_nodes[name] ~= nil then
			error("Node already exists: "..name.." (surface_name == "..surface_name..")!")
		end
		local tiles = { surface_data["tiles"][1] .. "^streets_stormdrain.png", surface_data.tiles[1] }
		if surface_name == "ch_extras:zdlazba" then
			for i = 3, 6 do
				tiles[i] = "default_stone_brick.png"
			end
		elseif surface_name == "ch_extras:cervzdlazba" then
			for i = 3, 6 do
				tiles[i] = "default_desert_stone_brick.png"
			end
		end

	minetest.register_node(name, {
		description = S("kanalizační vpusť v: @1", surface_data.friendlyname or minetest.registered_nodes[surface_name].description),
		tiles = tiles,
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = { cracky = 3, streets_stormdrain = 1 },
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
		output = name.." 3",
		recipe = {
			{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
			{ surface_name, surface_name, surface_name },
		}
	})
	end
end
