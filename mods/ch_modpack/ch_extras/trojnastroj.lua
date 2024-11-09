-- trojnástroj
local ch_help = "Trojnástroj v sobě kombinuje schopnosti lopaty, sekery a krumpáče (a také srpu).\nDokáže snadno těžit stejné druhy materiálu jako kterýkoliv z těchto nástrojů,\njeho životnost však není vyšší než životnost jednotlivého samostatného nástroje."
local ch_help_group = "ch_multitool"
local default_tool_sounds = {breaks = "default_tool_breaks"}

local def = {
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
