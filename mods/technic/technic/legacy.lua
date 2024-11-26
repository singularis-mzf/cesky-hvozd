
-- Aliases to convert from legacy node/item names

technic.legacy_nodenames = {
	["technic:alloy_furnace"]        = "technic:lv_alloy_furnace",
	["technic:alloy_furnace_active"] = "technic:lv_alloy_furnace_active",
	["technic:battery_box"]  = "technic:lv_battery_box0",
	["technic:battery_box1"] = "technic:lv_battery_box1",
	["technic:battery_box2"] = "technic:lv_battery_box2",
	["technic:battery_box3"] = "technic:lv_battery_box3",
	["technic:battery_box4"] = "technic:lv_battery_box4",
	["technic:battery_box5"] = "technic:lv_battery_box5",
	["technic:battery_box6"] = "technic:lv_battery_box6",
	["technic:battery_box7"] = "technic:lv_battery_box7",
	["technic:battery_box8"] = "technic:lv_battery_box8",
	["technic:electric_furnace"]        = "technic:lv_electric_furnace",
	["technic:electric_furnace_active"] = "technic:lv_electric_furnace_active",
	["technic:grinder"]        = "technic:lv_grinder",
	["technic:grinder_active"] = "technic:lv_grinder_active",
	["technic:extractor"]        = "technic:lv_extractor",
	["technic:extractor_active"] = "technic:lv_extractor_active",
	["technic:compressor"]        = "technic:lv_compressor",
	["technic:compressor_active"] = "technic:lv_compressor_active",
	["technic:hv_battery_box"] = "technic:hv_battery_box0",
	["technic:mv_battery_box"] = "technic:mv_battery_box0",
	["technic:generator"]        = "technic:lv_generator",
	["technic:generator_active"] = "technic:lv_generator_active",
	["technic:iron_dust"] = "technic:wrought_iron_dust",
	["technic:enriched_uranium"] = "technic:uranium35_ingot",
}

for old, new in pairs(technic.legacy_nodenames) do
	minetest.register_alias(old, new)
end

for i = 0, 64 do
	minetest.register_alias("technic:hv_cable"..i, "technic:hv_cable")
	minetest.register_alias("technic:mv_cable"..i, "technic:mv_cable")
	minetest.register_alias("technic:lv_cable"..i, "technic:lv_cable")
end

local translation_table = {
["technic:lv_grinder"] = "technic:mv_grinder",
["technic:lv_extractor"] = "technic:mv_extractor",
["technic:hv_admin_generator"] = "air",
["technic:mv_admin_generator"] = "air",
["technic:lv_electric_furnace"] = "technic:mv_electric_furnace",
["technic:lv_compressor"] = "technic:mv_compressor",
["technic:lv_alloy_furnace"] = "technic:mv_alloy_furnace",
["technic:lv_admin_generator"] = "air",
["technic_hv_extend:hv_grinder"] = "technic:mv_grinder",
["technic_hv_extend:hv_electric_furnace"] = "technic:mv_electric_furnace",
["technic_hv_extend:hv_compressor"] = "technic:mv_compressor",
["technic_hv_extend:hv_alloy_furnace"] = "technic:mv_alloy_furnace",
}
local translation_nodenames = {}
for n, _ in pairs(translation_table) do
	table.insert(translation_nodenames, n)
end

minetest.register_lbm({
	label = "Change technic machines to a single tier",
	name = "technic:change_to_single_tier",
	nodenames = translation_nodenames,
	action = function(pos, node, dtime_s)
		local new_nodename = translation_table[node.name]
		if new_nodename ~= nil and minetest.registered_nodes[new_nodename] ~= nil then
			node.name = new_nodename
			minetest.swap_node(pos, node)
			print("DEBUG: "..minetest.pos_to_string(pos).." changed to "..new_nodename)
		else
			minetest.log("error", "Expected new node "..(new_nodename or "nil").." does not exist! "..minetest.pos_to_string(pos).." will not be upgraded!")
		end
	end,
})
