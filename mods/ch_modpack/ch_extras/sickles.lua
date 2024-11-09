-- Sickles
local sickle_sounds = {breaks = "default_tool_breaks"}
local sickle_groups = {sickle = 1}

local ch_help = "Slouží ke sklizni měkkých zemědělských plodin, listů, květin a podobně."
local ch_help_group = "sickle"

local def = {
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
