-- teleportér
local teleporter_node_category_builtin = {
	air = 0,
	ignore = 2,
}
local teleporter_node_category_by_drawtype = {
	normal = 2,
	airlike = 0,
	liquid = 2, -- liquids are considered as full nodes
	flowingliquid = 2,
	glasslike = 2,
	glasslike_framed = 2,
	glasslike_framed_optional = 2,
	allfaces = 2,
	allfaces_optional = 2,
	torchlike = 1,
	signlike = 1,
	plantlike = 1,
	firelike = 1,
	fencelike = 1,
	raillike = 1,
	nodebox = 1,
	mesh = 1,
	plantlike_rooted = 1,
}

local function teleporter_node_category(node_name)
	-- 0 = empty/non-walkable (like air)
	-- 1 = partially empty (like stairs or slabs)
	-- 2 = full node
	local result = teleporter_node_category_builtin[node_name]
	if result == nil then
		local ndef = minetest.registered_nodes[node_name]
		if ndef == nil then
			result = 2  -- unknown node
		elseif ndef.walkable == false or ndef.climbable == true then
			result = 0 -- non-walkable node
		else
			local drawtype = ndef.drawtype or "normal"
			result = teleporter_node_category_by_drawtype[drawtype] or 1
		end
	end
	return result
end

local function teleporter_raycast_test(pos)
	if Raycast(vector.offset(pos, -0.25, -0.25, -0.25), vector.offset(pos, -0.25, 1.25, -0.25), false, true):next() then
		-- print("Raycast 1 failed: "..minetest.pos_to_string(vector.offset(pos, -0.25, -0.25, -0.25)).." to "..minetest.pos_to_string(vector.offset(pos, -0.25, 1.25, -0.25)))
		return 1
	end
	if Raycast(vector.offset(pos, 0.25, -0.25, -0.25), vector.offset(pos, 0.25, 1.25, -0.25), false, true):next() then
		-- print("Raycast 2 failed")
		return 2
	end
	if Raycast(vector.offset(pos, -0.25, -0.25, 0.25), vector.offset(pos, -0.25, 1.25, 0.25), false, true):next() then
		-- print("Raycast 3 failed")
		return 3
	end
	if Raycast(vector.offset(pos, 0.25, -0.25, 0.25), vector.offset(pos, 0.25, 1.25, 0.25), false, true):next() then
		-- print("Raycast 4 failed")
		return 4
	end
	if Raycast(vector.offset(pos, 0, -0.25, 0), vector.offset(pos, 0, 1.25, 0), false, true):next() then
		-- print("Raycast 5 failed")
		return 5
	end
	return 0
end

--[[
local function teleporter_is_pos_suitable(pos)
	local node_1 = minetest.get_node(pos)
	local node_2 = minetest.get_node(vector.offset(pos, 0, 1, 0))

	local ncat_1 = teleporter_node_category(node_1.name)
	local ncat_2 = teleporter_node_category(node_2.name)
	-- print("DEBUG: "..node_1.name.." "..minetest.pos_to_string(pos).." = "..ncat_1)
	-- print("DEBUG: "..node_2.name.." "..minetest.pos_to_string(pos).." = "..ncat_2)

	if ncat_1 == 0 and ncat_2 == 0 then
		return true -- OK, both nodes are non-walkable
	end
	if ncat_1 == 2 or ncat_2 == 2 then
		return false -- no, at least one node is full
	end
	return teleporter_raycast_test(pos) == 0
end ]]

local function teleporter_candidate_to_destination(pos)
	local node_1 = minetest.get_node(pos)
	local node_2 = minetest.get_node(vector.offset(pos, 0, 1, 0))

	local ncat_1 = teleporter_node_category(node_1.name)
	local ncat_2 = teleporter_node_category(node_2.name)
	-- print("DEBUG: "..node_1.name.." "..minetest.pos_to_string(pos).." = "..ncat_1)
	-- print("DEBUG: "..node_2.name.." "..minetest.pos_to_string(pos).." = "..ncat_2)

	if (ncat_1 == 0 and ncat_2 == 0) or (ncat_1 ~= 2 and ncat_2 ~= 2 and teleporter_raycast_test(pos) == 0) then
		if ncat_1 == 0 then
			return vector.offset(pos, 0, -0.5, 0)
		else
			return vector.copy(pos)
		end
	else
		return nil
	end
end

--[[
local function is_walkable_node(node_name)
	if node_name == "air" or node_name == "ignore" then
		return false
	end
	local def = minetest.registered_nodes[node_name]
	if not def or not def.walkable or def.climbable == true then
		return false
	end
	return true
end
]]

local function teleporter_on_use(itemstack, player, pointed_thing)
	if not player or not player:is_player() or pointed_thing.type ~= "node" then
		return
	end
	local player_name = player:get_player_name()
	local old_pos = player:get_pos()

	-- check for trest
	local online_charinfo = ch_data.online_charinfo[player_name] or {}
	local trest = online_charinfo.trest or 0
	if trest > 0 then
		ch_core.systemovy_kanal(player_name, "Chyba: jste ve výkonu trestu odnětí svobody.")
		minetest.log("action", "Teleporter failed for "..player_name.." at "..minetest.pos_to_string(old_pos).." due to trest "..trest)
		return
	end

	-- play the sound and add wear
	minetest.sound_play("mobs_spell", {pos = old_pos, max_hear_distance = 5, gain = 0.2}, true)
	if not minetest.is_creative_enabled(player_name) then
		itemstack:set_count(itemstack:get_count() - 1)
	end

	local entity_root = player
	local entity_attach = entity_root:get_attach()
	while entity_attach do
		entity_root = entity_attach
		entity_attach = entity_root:get_attach()
	end

	-- check velocity
	local old_velocity = entity_root:get_velocity()
	if vector.length(old_velocity) > 3 then
		ch_core.systemovy_kanal(player_name, "Přemístění selhalo, protože se pohybujete příliš rychle.")
		minetest.log("action", "Teleporter failed for "..player_name.." at "..minetest.pos_to_string(old_pos).." due to velocity "..minetest.pos_to_string(old_velocity))
	else
		-- compute the destination
		local destination, destination_kind
		local pointed_pos = pointed_thing.under
		local surface_pos = pointed_thing.above
		local d = vector.subtract(surface_pos, pointed_pos)
		if d.y ~= -1 then
			destination = teleporter_candidate_to_destination(pointed_pos)
			if destination then
				destination_kind = "pointed_pos"
			else
				destination = teleporter_candidate_to_destination(vector.offset(pointed_pos, 0, 1, 0))
				if destination then
					destination_kind = "pointed_pos+1"
				end
			end
		end
		if not destination then
			destination = teleporter_candidate_to_destination(surface_pos)
			if destination then
				destination_kind = "surface_pos"
			end
		end
		if not destination then
			destination = teleporter_candidate_to_destination(vector.offset(surface_pos, 0, -1, 0))
			if destination then
				destination_kind = "under_surface_pos"
			end
		end
		if not destination and d.y ~= 1 then
			destination = teleporter_candidate_to_destination(vector.offset(pointed_pos, 0, -2, 0))
			if destination then
				destination_kind = "under_pointed_pos"
			end
		end

		if destination then
			local distance = vector.distance(destination, old_pos)
			minetest.log("action", "Teleporter will teleport player "..player_name.." from "..minetest.pos_to_string(old_pos).." to "..destination_kind.." "..minetest.pos_to_string(destination).." (distance="..distance..")")

			-- teleport the player
			local teleport_def = {
				type = "normal",
				player = player,
				target_pos = destination,
			}
			if distance > 1 then
				teleport_def.sound_after = {name = "mobs_spell", gain = 0.2}
			end

			local success, error_message = ch_core.teleport_player(teleport_def)
			if not success then
				ch_core.systemovy_kanal(player_name, "Chyba: přemístění selhalo: "..(error_message or "neznámý důvod"))
			end
		else
			ch_core.systemovy_kanal(player_name, "Chyba: přemístění selhalo z prostorových důvodů.")
			minetest.log("action", "Teleporter failed for "..player_name.." at "..minetest.pos_to_string(old_pos)..", because no valid destination was found for pointed_pos = "..minetest.pos_to_string(pointed_pos)..", surface_pos = "..minetest.pos_to_string(surface_pos))
		end
	end

	if not minetest.is_creative_enabled(player_name) then
		return itemstack
	end
end

local def = {
	description = "teleportér / přemísťovač",
	_ch_help = "Nástroj sloužící k okamžitému přemístění na malou vzdálenost.\nLevý klik na blok vás přemístí přibližně na daný blok. Přemístění může selhat v těsných prostorách nebo když se rychle pohybujete.\nTento nástroj je určen především pro kouzelnické postavy.\nTeleportér je jednorázový, ledaže máte právo usnadnění hry.",
	_ch_help_group = "teleporter2",
	inventory_image = "translocator.png",
	range = 128,
	liquids_pointable = true,
	on_use = teleporter_on_use,
}

minetest.register_craftitem("ch_extras:teleporter", table.copy(def))
def.description = "teleportér / přemísťovač (neprodejný v OSA)"
minetest.register_craftitem("ch_extras:teleporter_unsellable", def)
minetest.register_craft({
	output = "ch_extras:teleporter",
	recipe = {
		{"worldedit:wand", "technic:blue_energy_crystal", "worldedit:wand"},
		{"default:mese", "moreores:mithril_block", "default:mese"},
		{"travelnet:travelnet", "technic:blue_energy_crystal", "travelnet:travelnet"},
	},
})

local function rn_after(player_name)
	local player = core.get_player_by_name(player_name)
	if player ~= nil then
		local success, message = ch_core.bn_zpet(player)
		if message ~= nil then
			ch_core.systemovy_kanal(player_name, message)
		end
	end
end

local function rn_left(itemstack, user, pointed_thing)
	if user ~= nil and core.is_player(user) then
		core.after(0.1, rn_after, assert(user:get_player_name()))
	end
end

local function rn_right(itemstack, user, pointed_thing)
	if user ~= nil and core.is_player(user) then
		local success, message = ch_core.bn_nastavit(user)
		if message ~= nil then
			ch_core.systemovy_kanal(user:get_player_name(), message)
		end
	end
end

def = {
	description = "runa návratu",
	_ch_help = "levý klik = /zpět (přenese vás na poslední nastavený bod návratu)\npravý klik = /bodnávratu (nastaví místo, kde jste, jako váš bod návratu)",
	_ch_help_group = "rnvrt",
	inventory_image = "ch_extras_zpet.png",
	wield_image = "ch_extras_zpet.png",
	range = 0.1,
	on_use = rn_left,
	on_place = rn_right,
	on_secondary_use = rn_right,
}
minetest.register_tool("ch_extras:runa_navratu", def)
minetest.register_craft({
	output = "ch_extras:runa_navratu",
	recipe = {
		{"", "default:mese_crystal_fragment", ""},
		{"default:mese_crystal_fragment", "cavestuff:pebble_1", ""},
		{"", "default:mese_crystal_fragment", ""},
	},
})
minetest.register_craft({
	output = "cavestuff:pebble_1",
	type = "shapeless",
	recipe = {"ch_extras:runa_navratu", "moreblocks:sweeper"},
})
