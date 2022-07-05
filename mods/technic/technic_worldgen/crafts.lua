
local S = technic.worldgen.gettext

minetest.register_craftitem(":technic:uranium_lump", {
	description = S("Uranium Lump"),
	inventory_image = "technic_uranium_lump.png",
})
minetest.register_alias("technic:uranium", "technic:uranium_lump")

minetest.register_craftitem(":technic:uranium_ingot", {
	description = S("Uranium Ingot"),
	inventory_image = "technic_uranium_ingot.png",
	groups = {uranium_ingot=1},
})

minetest.register_craftitem(":technic:chromium_lump", {
	description = S("Chromium Lump"),
	inventory_image = "technic_chromium_lump.png",
})

minetest.register_craftitem(":technic:chromium_ingot", {
	description = S("Chromium Ingot"),
	inventory_image = "technic_chromium_ingot.png",
})

minetest.register_craftitem(":technic:zinc_lump", {
	description = S("Zinc Lump"),
	inventory_image = "technic_zinc_lump.png",
})

minetest.register_craftitem(":technic:zinc_ingot", {
	description = S("Zinc Ingot"),
	inventory_image = "technic_zinc_ingot.png",
})

minetest.register_craftitem(":technic:lead_lump", {
	description = S("Lead Lump"),
	inventory_image = "technic_lead_lump.png",
})

minetest.register_craftitem(":technic:lead_ingot", {
	description = S("Lead Ingot"),
	inventory_image = "technic_lead_ingot.png",
})

minetest.register_craftitem(":technic:sulfur_lump", {
	description = S("Sulfur Lump"),
	inventory_image = "technic_sulfur_lump.png",
})

minetest.register_alias("technic:wrought_iron_ingot", "default:steel_ingot")

minetest.override_item("default:steel_ingot", {
	description = S("Wrought Iron Ingot"),
	inventory_image = "technic_wrought_iron_ingot.png",
})

minetest.register_craftitem(":technic:cast_iron_ingot", {
	description = S("Cast Iron Ingot"),
	inventory_image = "technic_cast_iron_ingot.png",
})

minetest.register_craftitem(":technic:carbon_steel_ingot", {
	description = S("Carbon Steel Ingot"),
	inventory_image = "technic_carbon_steel_ingot.png",
})

minetest.register_craftitem(":technic:stainless_steel_ingot", {
	description = S("Stainless Steel Ingot"),
	inventory_image = "technic_stainless_steel_ingot.png",
})

local function register_block(block, ingot)
	minetest.register_craft({
		output = block,
		recipe = {
			{ingot, ingot, ingot},
			{ingot, ingot, ingot},
			{ingot, ingot, ingot},
		}
	})

	minetest.register_craft({
		output = ingot.." 9",
		recipe = {
			{block}
		}
	})
end

register_block("technic:uranium_block", "technic:uranium_ingot")
register_block("technic:chromium_block", "technic:chromium_ingot")
register_block("technic:zinc_block", "technic:zinc_ingot")
register_block("technic:lead_block", "technic:lead_ingot")
register_block("technic:cast_iron_block", "technic:cast_iron_ingot")
register_block("technic:carbon_steel_block", "technic:carbon_steel_ingot")
register_block("technic:stainless_steel_block", "technic:stainless_steel_ingot")

minetest.register_craft({
	type = 'cooking',
	recipe = "technic:zinc_lump",
	output = "technic:zinc_ingot",
})

minetest.register_craft({
	type = 'cooking',
	recipe = "technic:chromium_lump",
	output = "technic:chromium_ingot",
})

minetest.register_craft({
	type = 'cooking',
	recipe = "technic:uranium_lump",
	output = "technic:uranium_ingot",
})

minetest.register_craft({
	type = 'cooking',
	recipe = "technic:lead_lump",
	output = "technic:lead_ingot",
})


minetest.register_craft({
	type = 'cooking',
	recipe = minetest.registered_aliases["technic:wrought_iron_ingot"],
	output = "technic:cast_iron_ingot",
})

minetest.register_craft({
	type = 'cooking',
	recipe = "technic:cast_iron_ingot",
	cooktime = 2,
	output = "technic:wrought_iron_ingot",
})

minetest.register_craft({
	type = 'cooking',
	recipe = "technic:carbon_steel_ingot",
	cooktime = 2,
	output = "technic:wrought_iron_ingot",
})
