--[[
	## StreetsMod 2.0 ##
	Submod: installations
	Optional: true
]]

local S = minetest.get_translator("streets")
--[[
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
]]

local function get_name_base(name)
	local parts = name:gsub("^:", ""):split(":")
	local result = parts[2]
	if result == "marble" or result == "granite" then
		result = parts[1].."_"..parts[2]
	end
	return result
end

local function closed_manhole_on_rightclick(pos, node, clicker)
	local player_name = clicker:get_player_name()
	if core.is_protected(pos, player_name) then
		core.record_protection_violation(pos, player_name)
		return
	end
	local meta = core.get_meta(pos)
	if clicker:get_player_control().aux1 then
		if meta:get_int("is_manhole") == 0 then
			meta:set_int("is_manhole", 1)
			meta:set_string("infotext", "průlez")
		else
			meta:set_int("is_manhole", 0)
			meta:set_int("infotext", "")
		end
	elseif meta:get_int("is_manhole") ~= 0 then
		node.name = assert(core.registered_nodes[node.name].manhole_alt)
		core.swap_node(pos, node)
	end
end

local function open_manhole_on_rightclick(pos, node, clicker)
	local player_name = clicker:get_player_name()
	if core.is_protected(pos, player_name) then
		core.record_protection_violation(pos, player_name)
		return
	end
	node.name = assert(core.registered_nodes[node.name].manhole_alt)
	core.swap_node(pos, node)
end

local closed_manhole_node_box = {
	type = "fixed",
	fixed = {
		{ -0.5, -0.5, -0.5, 0.5, 0.5, -0.375 }, -- F
		{ -0.5, -0.5, 0.375, 0.5, 0.5, 0.5 }, -- B
		{ -0.5, -0.5, -0.4375, -0.375, 0.5, 0.4375 }, -- L
		{ 0.375, -0.5, -0.4375, 0.5, 0.5, 0.4375 }, -- R
		{ -0.25, 0.4375, -0.25, 0.25, 0.5, 0.25 }, -- CenterPlate
		{ -0.5, 0.4375, -0.0625, 0.5, 0.5, 0.0625 }, -- CenterLR
		{ -0.0625, 0.4375, -0.5, 0.0625, 0.5, 0.5 }, -- CenterFR
	}
}

local open_manhole_node_box = {
	type = "fixed",
	fixed = {
		{ -0.5, -0.5, -0.5, 0.5, 0.5, -0.375 }, -- F
		{ -0.5, -0.5, 0.375, 0.5, 0.5, 0.5 }, -- B
		{ -0.5, -0.5, -0.4375, -0.375, 0.5, 0.4375 }, -- L
		{ 0.375, -0.5, -0.4375, 0.5, 0.5, 0.4375 }, -- R
	}
}

local stormdrain_node_box = {
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
}

function streets.register_manholes(material, allow_manhole, allow_stormdrain, manhole_node_to_override)
--[[{
	material = "darkage:gneiss",
	manhole = true,
	stormdrain = true,
	override_manhole = "darkage:stair_gniess_wchimney",
}
	- streets:gneiss_manhole
	- streets:gneiss_manhole_open
	- darkage:stair_gniess_wchimney
]]
	assert(material)
	local ndef = assert(core.registered_nodes[material])
	local tile_name = ndef.tiles[1]
	if type(tile_name) == "table" then
		tile_name = tile_name.name
	end
	if type(tile_name) ~= "string" then
		error("Unsupported format of tiles for '"..material.."': "..dump2(ndef.tiles))
	end

	local tiles = { "", tile_name }
	if material == "ch_extras:zdlazba" then
		for i = 3, 6 do
			tiles[i] = "default_stone_brick.png"
		end
	elseif material == "ch_extras:cervzdlazba" then
		for i = 3, 6 do
			tiles[i] = "default_desert_stone_brick.png"
		end
	end

	if allow_manhole then
		error("not supported in this version")
		local name_closed = "streets:"..get_name_base(material).."_manhole"
		local name_open
		if manhole_node_to_override == nil then
			name_open = name_closed.."_open"
			if core.registered_nodes[name_open] ~= nil then
				error("Node already exists: "..name_open.."!")
			end
		else
			name_open = manhole_node_to_override
		end
		if core.registered_nodes[name_closed] ~= nil then
			error("Node already exists: "..name_closed.."!")
		end
		tiles[1] = tile_name .. "^streets_manhole.png"

		-- register/override the closed manhole
		local def = {
			tiles = table.copy(tiles),
			drawtype = "nodebox",
			paramtype = "light",
			paramtype2 = "facedir",
			on_rightclick = closed_manhole_on_rightclick,
			sunlight_propagates = true,
			node_box = closed_manhole_node_box,
			manhole_alt = name_open,
			climbable = true,
			_ch_help = "Průlez po umístění aktivujete pomocí Aux1+pravý klik,\npak ho můžete otevírat/zavírat pravým kliknutím.\n"..
				"Průlez lze otáčet do všech 24 orientací.",
			_ch_help_group = "manhole",
		}
		if manhole_node_to_override ~= nil then
			local mndef = core.registered_nodes[manhole_node_to_override]
			if mndef == nil then
				error("manhole_node_to_override specified as '"..manhole_node_to_override.."', but it is not a registered node!")
			end
			def.groups = ch_core.override_groups(mndef.groups, {streets_manhole = 1})
			core.override_item(manhole_node_to_override, def)
		else
			def.description = S("průlez v: @1", ndef.description)
			def.groups = { cracky = 3, streets_manhole = 1 }
			if ndef.sounds ~= nil then
				def.sounds = ndef.sounds
			end
			core.register_node(":"..name_closed, def)
		end

		-- register the open manhole
		def = {
			tiles = table.copy(tiles),
			drawtype = "nodebox",
			paramtype = "light",
			paramtype2 = "facedir",
			climbable = true,
			drop = name_closed,
			groups = { cracky = 3, not_in_creative_inventory = 1, streets_manhole = 2 },
			on_rightclick = open_manhole_on_rightclick,
			sunlight_propagates = true,
			node_box = open_manhole_node_box,
			manhole_alt = name_closed,
		}
		core.register_node(":"..name_open, def)

		--[[
		minetest.register_craft({
			output = name_closed.." 4",
			recipe = {
				{ material, material, material },
				{ material, "default:steel_ingot", material },
				{ material, material, material },
			}
		})
		]]
	end

	if allow_stormdrain then
		local name = "streets:"..get_name_base(material).."_stormdrain"
		if minetest.registered_nodes[name] ~= nil then
			error("Node already exists: "..name.." (material == "..material..")!")
		end
		tiles[1] = tile_name .. "^streets_stormdrain.png"

		core.register_node(":"..name, {
			description = S("kanalizační vpusť v: @1", ndef.description),
			tiles = tiles,
			drawtype = "nodebox",
			paramtype = "light",
			paramtype2 = "facedir",
			groups = { cracky = 3, streets_stormdrain = 1 },
			sunlight_propagates = true,
			node_box = stormdrain_node_box,
			selection_box = {type = "regular"}
		})
		core.register_craft({
			output = name.." 3",
			recipe = {
				{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
				{ material, material, material },
			}
		})
	end
end

--[[
add_surface("building_blocks:Tar")
add_surface("default:desert_sandstone")
add_surface("default:stone")
add_surface("default:stone_block")
] ]
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
]]
