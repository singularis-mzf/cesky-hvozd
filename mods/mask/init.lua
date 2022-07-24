---
---Mask
---

minetest.register_craftitem("mask:mask", {
	description = "rouška",
	inventory_image = "mask_inv_mask.png",
	uv_image = "mask_mask.png",
	groups = {clothing = 1},
})

---
---Craft
---

minetest.register_craft({
	output = "mask:mask",
	recipe = {
		{"default:paper", "clothing:yarn_spool_white"},
		{"", ""},
	},
	replacements = {
		{"clothing:yarn_spool_white", "clothing:yarn_spool_empty"},
	},
})

clothing.sewing_table:recipe_register_input("", {
	outputs = {{"mask:mask 2", "clothing:yarn_spool_empty"}},
	inputs = {
		"default:paper", "clothing:yarn_spool_white", "default:paper",
		"", "", "",
		"", "", "",
	},
	production_time = 10,
	consumption_step_size = 1,
})

clothing.sewing_table:recipe_register_input("", {
	outputs = {{"mask:mask 4", "clothing:yarn_spool_empty"}},
	inputs = {
		"default:paper", "clothing:yarn_spool_white", "default:paper",
		"default:paper", "", "default:paper",
		"", "", "",
	},
	production_time = 20,
	consumption_step_size = 1,
})

clothing.sewing_table:recipe_register_input("", {
	outputs = {{"mask:mask 7", "clothing:yarn_spool_empty"}},
	inputs = {
		"default:paper", "clothing:yarn_spool_white", "default:paper",
		"default:paper", "", "default:paper",
		"default:paper", "", "default:paper",
	},
	production_time = 30,
	consumption_step_size = 1,
})

clothing.sewing_table:recipe_register_input("", {
	outputs = {{"mask:mask 10", "clothing:yarn_spool_empty"}},
	inputs = {
		"default:paper", "clothing:yarn_spool_white", "default:paper",
		"default:paper", "default:paper", "default:paper",
		"default:paper", "default:paper", "default:paper",
	},
	production_time = 40,
	consumption_step_size = 1,
})
