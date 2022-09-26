local def
local empty_table = {}
local ch_help, ch_help_group

-- Sickles
local sickle_sounds = {breaks = "default_tool_breaks"}
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

-- skákadlo
local function skakadlo(itemstack, player, new_speed, wear_to_add)
	if not player or not player:is_player() then
		return
	end
	local player_name = player:get_player_name()
	local pos = player:get_pos()
	local node_at_player = minetest.get_node(pos)
	local node_under_player = minetest.get_node(vector.new(pos.x, pos.y - 0.05, pos.z))
	local current_velocity = player:get_velocity()
	local reason

	if current_velocity.y ~= 0 then
		reason = "Current velocity = "..minetest.pos_to_string(current_velocity)
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
		minetest.sound_play("toaster", {pos = pos, max_hear_distance = 5, gain = 0.2}, true)

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
	stack_max = 1,
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

local function teleporter_on_use(itemstack, player, pointed_thing)
	if not player or not player:is_player() or pointed_thing.type ~= "node" then
		return
	end
	local player_name = player:get_player_name()
	local online_charinfo = ch_core.online_charinfo[player_name] or {}
	if (online_charinfo.trest or 0) > 0 then
		ch_core.systemovy_kanal(player_name, "Chyba: jste ve výkonu trestu odnětí svobody.")
		return
	end
	local pos = minetest.get_pointed_thing_position(pointed_thing, false)
	local pos2 = minetest.get_pointed_thing_position(pointed_thing, true)
	if pos.x == pos2.x and pos.z == pos2.z and pos.y == pos2.y + 1 then
		ch_core.systemovy_kanal(player_name, "Chyba: nelze teleportovat, pokud ukazujete na spodní stranu bloku.")
		return
	end
	local node = minetest.get_node(vector.new(pos.x, pos.y + 1, pos.z))

	if is_walkable_node(node.name) then
		node = minetest.get_node(pos2)
		if is_walkable_node(node.name) then
			pos = vector.new(pos2.x, pos2.y + 0.5, pos2.z)
		else
			pos = vector.new(pos2.x, pos.y - 0.5, pos2.z)
		end
	else
		pos = vector.new(pos.x, pos.y + 0.5, pos.z)
	end
	local old_pos = player:get_pos()
	player:set_pos(pos)
	if vector.distance(pos, old_pos) > 0 then
		minetest.sound_play("mobs_spell", {pos = old_pos, max_hear_distance = 5, gain = 0.2}, true)
	end
	minetest.after(0.1, function() minetest.sound_play("mobs_spell", {pos = pos, max_hear_distance = 5, gain = 0.2}, true) end)

	if not minetest.is_creative_enabled(player_name) then
		local new_wear = tonumber(itemstack:get_wear()) + 1000
		if new_wear > 65535 then
			itemstack:clear()
		else
			itemstack:set_wear(new_wear)
		end
		return itemstack
	end
end

	-- player:add_velocity(vector.new(0, 6.5, 0))

def = {
	description = "teleportér",
	_ch_help = "Nástroj sloužící k okamžitému přesunu na malou vzdálenost.\nLevý klik na blok vás přenese přibližně na daný blok, ale nefunguje, pokud ukazujete na spodní stranu bloku.\nTento nástroj je určen především pro kouzelnické postavy.",
	_ch_help_group = "teleporter",
	inventory_image = "translocator.png",
	stack_max = 1,
	range = 128,
	liquids_pointable = true,
	on_use = teleporter_on_use,
}

minetest.register_tool("ch_extras:teleporter", def)
minetest.register_craft({
	output = "ch_extras:teleporter",
	recipe = {
		{"worldedit:wand", "technic:red_energy_crystal", "worldedit:wand"},
		{"default:mese", "moreores:mithril_block", "default:mese"},
		{"travelnet:travelnet", "technic:stainless_steel_block", "travelnet:travelnet"},
	},
})

-- žezlo usnadnění
def = {
	description = "žezlo usnadnění",
	_ch_help = "Postavám s právem privs nebo ch_switchable_creative umožňuje levým klikem\nsi zapnout či vypnout režim usnadnění hry podle potřeby.\nTento nástroj je určen výhradně pro kouzelnické postavy.",
	_ch_help_group = "creative_zezlo",
	inventory_image = "ch_extras_creative_inv.png",
	on_use = function(itemstack, user, pointed_thing)
		if user and user:is_player() then
			local player_name = user:get_player_name()
			local privs = minetest.get_player_privs(player_name)
			local message
			if privs.privs or privs.ch_switchable_creative then
				if privs.creative then
					privs.creative = nil
					message = "režim usnadnění hry vypnut"
				else
					privs.creative = true
					message = "režim usnadnění hry zapnut"
				end
				minetest.set_player_privs(player_name, privs)
				
			else
				message = "K použití žezla usnadnění nemáte dostatečná práva!"
			end
			ch_core.systemovy_kanal(player_name, message)
		end
	end,
}
minetest.register_craftitem("ch_extras:staff_of_creativity", def)
