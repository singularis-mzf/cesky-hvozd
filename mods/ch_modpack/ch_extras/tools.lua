local ifthenelse = ch_core.ifthenelse
local F = minetest.formspec_escape

-- local def
local empty_table = {}
local ch_help, ch_help_group
local default_tool_sounds = {breaks = "default_tool_breaks"}

-- Sickles
local sickle_sounds = default_tool_sounds
local sickle_groups = {sickle = 1}

ch_help = "Slouží ke sklizni měkkých zemědělských plodin, listů, květin a podobně."
ch_help_group = "sickle"

def = {
	description = "dřevěný srp",
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "ch_extras_sickle_wood.png",
	tool_capabilities = {
		full_punch_interval = 1.4,
		max_drop_level = 1,
		groupcaps = {
			snappy = {times = {2.5, 1.2, 0.5}, uses = 10, maxlevel = 1},
		},
	},
	sound = sickle_sounds,
	groups = sickle_groups,
}
minetest.register_tool("ch_extras:sickle_wood", def)
minetest.register_craft({
	output = "ch_extras:sickle_wood",
	recipe = {
		{"group:wood", ""},
		{"", "group:wood"},
		{"group:stick", ""}
	}
})
minetest.register_alias("ch_core:sickle_wood", "ch_extras:sickle_wood")

def = table.copy(def)
def.description = "kamenný srp"
def.inventory_image = "ch_extras_sickle_stone.png"
def.tool_capabilities  = {
	full_punch_interval = 1.3,
	max_drop_level = 1,
	groupcaps = {
		snappy = {times = {2.5, 1.1, 0.4}, uses = 10, maxlevel = 3},
	},
}
minetest.register_tool("ch_extras:sickle_stone", def)
minetest.register_craft({
	output = "ch_extras:sickle_stone",
	recipe = {
		{"group:stone", ""},
		{"", "group:stone"},
		{"group:stick", ""}
	}
})
minetest.register_alias("ch_core:sickle_stone", "ch_extras:sickle_stone")

def = table.copy(def)
def.description = "železný srp"
def.inventory_image = "ch_extras_sickle_steel.png"
def.tool_capabilities = {
	full_punch_interval = 1.2,
	max_drop_level = 1,
	groupcaps = {
		snappy = {times = {2.0, 1.0, 0.3}, uses = 40, maxlevel = 3},
	},
}
minetest.register_tool("ch_extras:sickle_steel", def)
minetest.register_craft({
	output = "ch_extras:sickle_steel",
	recipe = {
		{"default:steel_ingot", ""},
		{"", "default:steel_ingot"},
		{"group:stick", ""}
	}
})
minetest.register_alias("ch_core:sickle_steel", "ch_extras:sickle_steel")

def = table.copy(def)
def.description = "meseový srp"
def.inventory_image = "ch_extras_sickle_mese.png"
def.tool_capabilities = {
	full_punch_interval = 1.0,
	max_drop_level = 1,
	groupcaps = {
		snappy = {times = {1.0, 0.4, 0.2}, uses = 60, maxlevel = 3},
	},
}
minetest.register_tool("ch_extras:sickle_mese", def)
minetest.register_craft({
	output = "ch_extras:sickle_mese",
	recipe = {
		{"default:mese_crystal", ""},
		{"", "default:mese_crystal"},
		{"group:stick", ""}
	}
})
minetest.register_alias("ch_core:sickle_mese", "ch_extras:sickle_mese")

local function is_cast_result_nonwalkable(cast_result)
	if cast_result ~= nil and cast_result.above ~= nil and cast_result.under ~= nil then
		local node_name = minetest.get_node(cast_result.under).name
		local ndef = minetest.registered_nodes[node_name]
		if ndef == nil or (ndef.walkable == false and ndef.climbable ~= true) then
			return true
		end
	end
	return false
end

-- skákadlo
local function skakadlo(itemstack, player, new_speed, wear_to_add)
	if not player or not player:is_player() then
		return
	end
	local player_name = player:get_player_name()
	local pos = player:get_pos()
	local current_velocity = player:get_velocity()
	local reason

	if current_velocity.y ~= 0 then
		reason = "Current velocity = "..minetest.pos_to_string(current_velocity)
	end

	local node_at_player, node_under_player
	if reason == nil then
		local cast = Raycast(pos, vector.offset(pos, 0, -0.5, 0), false, true)
		local cast_result = cast:next()
		while is_cast_result_nonwalkable(cast_result) do
			cast_result = cast:next()
		end
		if cast_result ~= nil and cast_result.above ~= nil and cast_result.under ~= nil then
			node_at_player = minetest.get_node(cast_result.above)
			node_under_player = minetest.get_node(cast_result.under)
		else
			node_at_player = minetest.get_node(pos)
			node_under_player = minetest.get_node(vector.new(pos.x, pos.y - 0.05, pos.z))
			minetest.log("warning", "Raycast at "..minetest.pos_to_string(pos).." for skakadlo failed! result = "..dump2(cast_result))
		end
	end

	if reason == nil and node_at_player.name ~= "air" then
		local node_def = minetest.registered_nodes[node_at_player.name]
		if not node_def then
			reason = "Unknown node "..node_at_player.name
		elseif node_def.climbable then
			reason = "At climbable node "..node_at_player.name
		elseif (node_def.move_resistance or 0) > 0 then
			reason = "Node "..node_at_player.name.." has move_resistance "..(node_def.move_resistance or 0)
		elseif node_def.liquid_move_physics or (node_def.liquidtype or "none") ~= "none" then
			reason = "Player is in liquid "..node_at_player.name
		end
	end

	if reason == nil then
		local node_def = minetest.registered_nodes[node_under_player.name]
		if not node_def then
			reason = "Unknown node "..node_under_player.name
		elseif node_def.walkable == false then
			reason = "On non-walkable node "..node_under_player.name
		elseif node_def.climbable then
			reason = "On climbable node "..node_under_player.name
		elseif (node_def.move_resistance or 0) > 0 then
			reason = "Node "..node_under_player.name.." has move_resistance "..(node_def.move_resistance or 0)
		elseif node_def.liquid_move_physics or (node_def.liquidtype or "none") ~= "none"  then
			reason = "Player is on liquid "..node_under_player.name
		end
	end

	if reason ~= nil then
		minetest.log("action", player_name.." failed to jump using a jump tool at "..minetest.pos_to_string(pos).." due to the reason: "..reason)
	else
		player:add_velocity(vector.new(0, new_speed, 0))
		minetest.log("action", player_name.." jumped using a jump tool at "..minetest.pos_to_string(pos)..", nodes: "..node_at_player.name..", "..node_under_player.name)
		minetest.sound_play("toaster", {pos = pos, max_hear_distance = 32, gain = 0.2}, true)

		if not minetest.is_creative_enabled(player_name) then
			local new_wear = math.ceil(itemstack:get_wear() + wear_to_add)
			if new_wear > 65535 then
				itemstack:clear()
			else
				itemstack:set_wear(new_wear)
			end
			return itemstack
		end
	end
end

def = {
	description = "skákadlo",
	_ch_help = "Nástroj sloužící ke skoku do velké výšky. Umožňuje vyskočit např. z jámy či na strom.\nLevým klikem vyskočíte cca o 6,5 metru, pravým o cca 3 metry.\nNefunguje pod vodou nebo pokud nestojíte na pevné zemi. Nejde opravit na kovadlině, ale v elektrické opravně ano.",
	_ch_help_group = "skakadlo",
	inventory_image = "ch_extras_skakadlo.png",
	wield_image = "ch_extras_skakadlo.png^[transformR180",
	sound = default_tool_sounds,
	-- stack_max = 1,
	on_use = function(itemstack, player, pointed_thing) return skakadlo(itemstack, player, 18, 300) end,
	-- on_secondary_use = function(itemstack, player, pointed_thing) return skakadlo(itemstack, player, 12, 120) end,
	on_place = function(itemstack, player, pointed_thing) return skakadlo(itemstack, player, 12, 120) end,
}
def.on_secondary_use = def.on_place

minetest.register_tool("ch_extras:jumptool", def)
for _, stick in ipairs({"default:stick", "basic_materials:steel_bar"}) do
	minetest.register_craft({
		output = "ch_extras:jumptool",
		recipe = {
			{stick, stick, stick},
			{"", "technic:rubber", ""},
			{"", "default:steel_ingot", ""},
		},
	})
end
if minetest.get_modpath("anvil") then
	anvil.make_unrepairable("ch_extras:jumptool")
end

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
	local online_charinfo = ch_core.online_charinfo[player_name] or {}
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

def = {
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

-- žezlo usnadnění
--[[
local function switch_creative(player, target_state)
	if not player or not player:is_player() then
		return
	end
	local player_name = player:get_player_name()
	local player_privs = minetest.get_player_privs(player_name)
	local was_creative = player_privs.creative
	local message
	if not player_privs.privs and not player_privs.ch_switchable_creative then
		message = "K použití žezla usnadnění nemáte dostatečná práva!"
	else
		if target_state then
			player_privs.creative = true
			message = "režim usnadnění hry zapnut"
		else
			player_privs.creative = nil
			message = "režim usnadnění hry vypnut"
		end
		minetest.set_player_privs(player_name, player_privs)
	end
	ch_core.systemovy_kanal(player_name, message)
end
]]

local function magic_wand_on_use(itemstack, user, pointed_thing)
	local player_info = ch_core.normalize_player(user)
	if player_info == nil or player_info.player == nil then
		return
	end
	if player_info.role ~= "admin" and player_info.role ~= "creative" then
		return
	end
	local was_creative = minetest.is_creative_enabled(player_info.player_name)
	local player_controls = player_info.player:get_player_control()
	if player_controls.aux1 then
		-- disable
		if not player_info.privs.creative then
			ch_core.systemovy_kanal(player_info.player_name, "Režim usnadnění byl už vypnutý")
			return
		end
		player_info.privs.creative = nil
		minetest.set_player_privs(player_info.player_name, player_info.privs)
		ch_core.systemovy_kanal(player_info.player_name, "Režim usnadnění vypnut")
	else
		-- enable
		if player_info.privs.creative then
			ch_core.systemovy_kanal(player_info.player_name, "Režim usnadnění byl už zapnutý")
			return
		end
		player_info.privs.creative = true
		minetest.set_player_privs(player_info.player_name, player_info.privs)
		ch_core.systemovy_kanal(player_info.player_name, "Režim usnadnění zapnut")
	end
	local offline_charinfo = ch_core.offline_charinfo[player_info.player_name]
	if offline_charinfo ~= nil then
		ch_core.ap_add(player_info.player_name, offline_charinfo) -- update AP HUD
	end
	if not was_creative then
		itemstack:add_wear_by_uses(64)
		return itemstack
	end
end

def = {
	description = "kouzelnická hůlka",
	_ch_help = "Kouzelnické postavy si mohou touto hůlkou snadno zapnout (levý klik)\n"..
				"či vypnout (Aux1+levý klik) režim usnadnění. Pro dělnické postavy není ničím užitečná.",
	inventory_image = "ch_core_kouzhul.png",
	wield_image = "ch_core_kouzhul.png",
	on_use = magic_wand_on_use,
}
minetest.register_tool("ch_extras:magic_wand", def)

-- trojnástroj
ch_help = "Trojnástroj v sobě kombinuje schopnosti lopaty, sekery a krumpáče (a také srpu).\nDokáže snadno těžit stejné druhy materiálu jako kterýkoliv z těchto nástrojů,\njeho životnost však není vyšší než životnost jednotlivého samostatného nástroje."
ch_help_group = "ch_multitool"

def = {
	description = "dřevěný trojnástroj",
	inventory_image = "default_tool_woodaxe.png^default_tool_woodpick.png^default_tool_woodshovel.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level = 0,
		groupcaps = {
			cracky = minetest.registered_tools["default:pick_wood"].tool_capabilities.groupcaps.cracky,
			crumbly = minetest.registered_tools["default:shovel_wood"].tool_capabilities.groupcaps.crumbly,
			choppy = minetest.registered_tools["default:axe_wood"].tool_capabilities.groupcaps.choppy,
			snappy = minetest.registered_tools["ch_extras:sickle_wood"].tool_capabilities.groupcaps.snappy,
		},
		damage_groups = { fleshy = 2 },
	},
	sound = default_tool_sounds,
	groups = {flammable = 2, multitool = 1},
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
}
minetest.register_tool("ch_extras:multitool_wooden", def)
minetest.register_craft({
	output = "ch_extras:multitool_wooden",
	recipe = {
		{"default:axe_wood", "default:pick_wood", "default:shovel_wood"},
		{"group:wood", "group:wood", "group:wood"},
		{"", "", ""},
	},
})

def = {
	description = "kamenný trojnástroj",
	inventory_image = "default_tool_stoneaxe.png^default_tool_stonepick.png^default_tool_stoneshovel.png",
	tool_capabilities = {
		full_punch_interval = 1.3,
		max_drop_level = 0,
		groupcaps = {
			cracky = minetest.registered_tools["default:pick_stone"].tool_capabilities.groupcaps.cracky,
			crumbly = minetest.registered_tools["default:shovel_stone"].tool_capabilities.groupcaps.crumbly,
			choppy = minetest.registered_tools["default:axe_stone"].tool_capabilities.groupcaps.choppy,
			snappy = minetest.registered_tools["ch_extras:sickle_stone"].tool_capabilities.groupcaps.snappy,
		},
		damage_groups = { fleshy = 3 },
	},
	sound = default_tool_sounds,
	groups = {multitool = 2},
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
}
minetest.register_tool("ch_extras:multitool_stone", def)
minetest.register_craft({
	output = "ch_extras:multitool_stone",
	recipe = {
		{"default:axe_stone", "default:pick_stone", "default:shovel_stone"},
		{"group:stone", "group:stone", "group:stone"},
		{"", "", ""},
	},
})


def = {
	description = "bronzový trojnástroj",
	inventory_image = "default_tool_bronzeaxe.png^default_tool_bronzepick.png^default_tool_bronzeshovel.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 1,
		groupcaps = {
			cracky = minetest.registered_tools["default:pick_bronze"].tool_capabilities.groupcaps.cracky,
			crumbly = minetest.registered_tools["default:shovel_bronze"].tool_capabilities.groupcaps.crumbly,
			choppy = minetest.registered_tools["default:axe_bronze"].tool_capabilities.groupcaps.choppy,
			snappy = minetest.registered_tools["ch_extras:sickle_steel"].tool_capabilities.groupcaps.snappy,
		},
		damage_groups = { fleshy = 4 },
	},
	sound = default_tool_sounds,
	groups = {multitool = 3},
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
}
minetest.register_tool("ch_extras:multitool_bronze", def)
minetest.register_craft({
	output = "ch_extras:multitool_bronze",
	recipe = {
		{"default:axe_bronze", "default:pick_bronze", "default:shovel_bronze"},
		{"default:bronze_ingot", "default:bronze_ingot", "default:bronze_ingot"},
		{"", "", ""},
	},
})

def = {
	description = "železný trojnástroj",
	inventory_image = "default_tool_steelaxe.png^default_tool_steelpick.png^default_tool_steelshovel.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 1,
		groupcaps = {
			cracky = minetest.registered_tools["default:pick_steel"].tool_capabilities.groupcaps.cracky,
			crumbly = minetest.registered_tools["default:shovel_steel"].tool_capabilities.groupcaps.crumbly,
			choppy = minetest.registered_tools["default:axe_steel"].tool_capabilities.groupcaps.choppy,
			snappy = minetest.registered_tools["ch_extras:sickle_steel"].tool_capabilities.groupcaps.snappy,
		},
		damage_groups = { fleshy = 4 },
	},
	sound = default_tool_sounds,
	groups = {multitool = 4},
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
}
minetest.register_tool("ch_extras:multitool_steel", def)
minetest.register_craft({
	output = "ch_extras:multitool_steel",
	recipe = {
		{"default:axe_steel", "default:pick_steel", "default:shovel_steel"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"", "", ""},
	},
})

def = {
	description = "meseový trojnástroj",
	inventory_image = "default_tool_meseaxe.png^default_tool_mesepick.png^default_tool_meseshovel.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 3,
		groupcaps = {
			cracky = minetest.registered_tools["default:pick_mese"].tool_capabilities.groupcaps.cracky,
			crumbly = minetest.registered_tools["default:shovel_mese"].tool_capabilities.groupcaps.crumbly,
			choppy = minetest.registered_tools["default:axe_mese"].tool_capabilities.groupcaps.choppy,
			snappy = minetest.registered_tools["ch_extras:sickle_mese"].tool_capabilities.groupcaps.snappy,
		},
		damage_groups = { fleshy = 5 },
	},
	sound = default_tool_sounds,
	groups = {multitool = 5},
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
}
minetest.register_tool("ch_extras:multitool_mese", def)
minetest.register_craft({
	output = "ch_extras:multitool_mese",
	recipe = {
		{"default:axe_mese", "default:pick_mese", "default:shovel_mese"},
		{"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"},
		{"", "", ""},
	},
})

def = {
	description = "diamantový trojnástroj",
	inventory_image = "default_tool_diamondaxe.png^default_tool_diamondpick.png^default_tool_diamondshovel.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 3,
		groupcaps = {
			cracky = minetest.registered_tools["default:pick_diamond"].tool_capabilities.groupcaps.cracky,
			crumbly = minetest.registered_tools["default:shovel_diamond"].tool_capabilities.groupcaps.crumbly,
			choppy = minetest.registered_tools["default:axe_diamond"].tool_capabilities.groupcaps.choppy,
			snappy = minetest.registered_tools["ch_extras:sickle_mese"].tool_capabilities.groupcaps.snappy,
		},
		damage_groups = { fleshy = 5 },
	},
	sound = default_tool_sounds,
	groups = {multitool = 6},
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
}
minetest.register_tool("ch_extras:multitool_diamond", def)
minetest.register_craft({
	output = "ch_extras:multitool_diamond",
	recipe = {
		{"default:axe_diamond", "default:pick_diamond", "default:shovel_diamond"},
		{"default:diamond", "default:diamond", "default:diamond"},
		{"", "", ""},
	},
})

if minetest.get_modpath("moreores") then

def = {
	description = "stříbrný trojnástroj",
	inventory_image = "moreores_tool_silveraxe.png^moreores_tool_silverpick.png^moreores_tool_silvershovel.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 3,
		groupcaps = {
			cracky = minetest.registered_tools["moreores:pick_silver"].tool_capabilities.groupcaps.cracky,
			crumbly = minetest.registered_tools["moreores:shovel_silver"].tool_capabilities.groupcaps.crumbly,
			choppy = minetest.registered_tools["moreores:axe_silver"].tool_capabilities.groupcaps.choppy,
			snappy = minetest.registered_tools["ch_extras:sickle_steel"].tool_capabilities.groupcaps.snappy,
		},
		damage_groups = { fleshy = 5 },
	},
	sound = default_tool_sounds,
	groups = {multitool = 7},
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
}
minetest.register_tool("ch_extras:multitool_silver", def)
minetest.register_craft({
	output = "ch_extras:multitool_silver",
	recipe = {
		{"moreores:axe_silver", "moreores:pick_silver", "moreores:shovel_silver"},
		{"moreores:silver_ingot", "moreores:silver_ingot", "moreores:silver_ingot"},
		{"", "", ""},
	},
})

def = {
	description = "mitrilový trojnástroj",
	inventory_image = "moreores_tool_mithrilaxe.png^moreores_tool_mithrilpick.png^moreores_tool_mithrilshovel.png",
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level = 3,
		groupcaps = {
			cracky = minetest.registered_tools["moreores:pick_mithril"].tool_capabilities.groupcaps.cracky,
			crumbly = minetest.registered_tools["moreores:shovel_mithril"].tool_capabilities.groupcaps.crumbly,
			choppy = minetest.registered_tools["moreores:axe_mithril"].tool_capabilities.groupcaps.choppy,
			snappy = minetest.registered_tools["ch_extras:sickle_mese"].tool_capabilities.groupcaps.snappy,
		},
		damage_groups = { fleshy = 6 },
	},
	sound = default_tool_sounds,
	groups = {multitool = 8},
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
}
minetest.register_tool("ch_extras:multitool_mithril", def)
minetest.register_craft({
	output = "ch_extras:multitool_mithril",
	recipe = {
		{"moreores:axe_mithril", "moreores:pick_mithril", "moreores:shovel_mithril"},
		{"moreores:mithril_ingot", "moreores:mithril_ingot", "moreores:mithril_ingot"},
		{"", "", ""},
	},
})

end

-- LUPA

def = {
	description = "lupa",
	inventory_image = "ch_extras_lupa.png",
	groups = {tool = 1},
	_ch_help = "Když držíte lupu v ruce, ukáže vám, co jsou zač věci,\nna které ukazujete.",
}
minetest.register_tool("ch_extras:lupa", def)
minetest.register_craft({
	output = "ch_extras:lupa",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "moreblocks:clean_glass", "default:steel_ingot"},
		{"", "", "default:steel_ingot"},
	},
})

if minetest.get_modpath("what_is_this_uwu") then
	local function playerstep(player, player_name, online_charinfo, offline_charinfo, us_time)
		local wielded_item = player:get_wielded_item()
		local item_name
		if not wielded_item:is_empty() then
			item_name = wielded_item:get_name()
		end
		if item_name == "ch_extras:lupa" then
			if not what_is_this_uwu.players_set[player_name] then
				what_is_this_uwu.register_player(player, player_name)
			end
		elseif what_is_this_uwu.players_set[player_name] then
			what_is_this_uwu.remove_player(player_name)
			what_is_this_uwu.unshow(player, player:get_meta())
		end
	end
	ch_core.register_player_globalstep(playerstep)
end

-- PERISKOP

local periskop_step, periskop_max = 25, 250

local function periskop_cancel(player, online_charinfo)
	if online_charinfo.periskop ~= nil then
		local oeo = online_charinfo.periskop.orig_eye_offset
		player:set_eye_offset(oeo[1], oeo[2], oeo[3])
		online_charinfo.periskop = nil
	end
end

local function periskop_use(player, button)
	local player_name = player:get_player_name() or ""
	if player_name == "" then return end
	local online_charinfo = ch_core.online_charinfo[player_name]
	if online_charinfo == nil then
		return
	end
	if online_charinfo.periskop == nil then
		-- první použití
		local a, b, c = player:get_eye_offset()
		online_charinfo.periskop = {
			orig_eye_offset = {a, b, c},
			cancel = function() return periskop_cancel(player, online_charinfo) end,
		}
		player:set_eye_offset(vector.new(0, periskop_step, 0), b, c)
		ch_core.systemovy_kanal(player_name, "periskop: +5 metrů")
	else
		local a, b, c = player:get_eye_offset()
		if button ~= "left" then
			a.y = math.max(a.y - periskop_step, periskop_step)
		else
			a.y = math.min(a.y + periskop_step, periskop_max)
		end
		player:set_eye_offset(a, b, c)
		ch_core.systemovy_kanal(player_name, "periskop: +"..((a.y - 25) * 0.1 + 5).." metrů")
	end
end

def = {
	description = "periskop",
	inventory_image = "ch_extras_periskop.png",
	wield_image = "ch_core_white_pixel.png^[opacity:0",
	groups = {tool = 1},
	_ch_help = "když periskop držíte v ruce, umožní vám shlížet na svět z výšky,\n"..
"ačkoliv se ve skutečnosti pohybujete stále po zemi;\n"..
"levý klik = +2,5 metru, pravý klik = -2,5 metru, přepnout na jiný předmět = vypnout",
	on_use = function(itemstack, user, pointed_thing)
		periskop_use(user, "left")
	end,
	on_place = function(itemstack, placer, pointed_thing)
		periskop_use(placer, "right")
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		periskop_use(user, "right")
	end,
}
minetest.register_tool("ch_extras:periskop", def)
minetest.register_craft{
	output = "ch_extras:periskop",
	recipe = {
		{"", "default:copper_ingot", "default:copper_ingot"},
		{"", "default:copper_ingot", ""},
		{"default:copper_ingot", "default:copper_ingot", ""},
	},
}

-- SADA NA ROZBOR OTISKŮ PRSTŮ

local function otisky(player, pos, range, seconds, limit)
	local node = minetest.get_node(pos)
	local records = {}

	for _, record in ipairs(minetest.rollback_get_node_actions(pos, range, seconds, limit)) do
		if record.newnode.name ~= record.oldnode.name or record.newnode.param2 ~= record.newnode.param2 then
			local actor = record.actor
			if actor:sub(1,7) == "player:" then
				actor = ch_core.prihlasovaci_na_zobrazovaci(actor:sub(8,-1))
			end
			local cas = ch_core.cas_na_strukturu(record.time)
			local oldnode, newnode = record.oldnode, record.newnode
			table.insert(records, string.format("#aaaaaa,%04d-%02d-%02d,#ffff00,%02d:%02d:%02d,%s,#00ff00,%s,#ffffff,%s/%s => %s/%s,%s",
				cas.rok, cas.mesic, cas.den, cas.hodina, cas.minuta, cas.sekunda, cas.posun_text,
				F(actor), F(oldnode.name), oldnode.param2, F(newnode.name), newnode.param2, F(minetest.pos_to_string(pos))))
		end
	end
	local formspec = {
		"formspec_version[4]"..
		"size[20,11]"..
		"label[0.5,0.75;Otisky prstů na pozici ",
		F(minetest.pos_to_string(pos).." ("..node.name.."/"..node.param2..")"),
		"]"..
		"button_exit[19,0.25;0.75,0.75;zavrit;x]"..
		"label[0.5,10;Poznámka: Administrace má k dispozici výkonnější nástroje pro sledování zásahů do herního světa, než je tento.]",
		"tablecolumns[color;text,tooltip=datum;color,span=1;text,tooltip=čas;text;color,span=1;text,tooltip=postava;color,span=1;text,tooltip=původní blok => nový blok;text,tooltip=pozice]"..
		"table[0.5,1.25;19,8;tabulka;",
		table.concat(records, ","),
		";]",
	}
	minetest.show_formspec(player:get_player_name(), "ch_extras:otisky", table.concat(formspec))
end

local function otisky_finished(pos, player_name)
	local player = minetest.get_player_by_name(player_name)
	if player == nil then return end
	local stack = player:get_wielded_item()
	if stack:get_name() ~= "ch_extras:otisky" then return end
	if not minetest.is_creative_enabled(player_name) then
		stack:take_item()
		player:set_wielded_item(stack)
	end
	otisky(player, pos, 0, 31557600, 64)
end

local function otisky_on_use(pos, player)
	local pinfo = ch_core.normalize_player(player)
	local player_name = pinfo.player_name
	if pinfo.role == "none" or pinfo.role == "new" then
		ch_core.systemovy_kanal(player_name, "Jen přijaté postavy mohou používat sadu na rozbor otisků prstů!")
		return
	end
	local online_charinfo = ch_core.online_charinfo[player_name or ""]
	if online_charinfo ~= nil then
		ch_core.start_ch_timer(online_charinfo, "ch_extras_otisky", 8, {
			label = "rozbor otisků prstů",
			func = function() otisky_finished(pos, player_name) end,
			hudbar_icon = "ch_extras_otisky.png^[resize:20x20",
			hudbar_bar = "hudbars_bar_timer.png^[multiply:#b31536",
		})
	end
end

def = {
	description = "sada na rozbor otisků prstů",
	inventory_image = "ch_extras_otisky.png",
	wield_image = "ch_extras_otisky.png",
	groups = {tool = 1},
	_ch_help = "Sada na jedno použití. Levý klik prozkoumá otisky na bloku, na který jste klikl/a;\npravý klik prozkoumá otisky \"nad\" kliknutým povrchem.",
	on_use = function(itemstack, user, pointed_thing)
		if minetest.is_player(user) and pointed_thing.type == "node" then
			otisky_on_use(pointed_thing.under, user)
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if minetest.is_player(placer) and pointed_thing.type == "node" then
			otisky_on_use(pointed_thing.above, placer)
		end
	end,
}
minetest.register_craftitem("ch_extras:otisky", def)

minetest.register_craft{
	output = "ch_extras:otisky 3",
	recipe = {
		{"", "ch_extras:lupa", ""},
		{"darkage:chalk_powder", "darkage:chalk_powder", "darkage:chalk_powder"},
		{"darkage:chalk_powder", "darkage:chalk_powder", "darkage:chalk_powder"},
	},
}
