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

-- Teleportér
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
	player:set_pos(pos)

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
