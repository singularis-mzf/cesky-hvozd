-- Configuration
local vacuum1_max_charge        = 10000
local vacuum2_max_charge        = 25000
local vacuum3_max_charge        = 100000
local vacuum1_charge_per_object = 100
local vacuum2_charge_per_object = 100
local vacuum3_charge_per_object = 100
local vacuum1_range             = 8
local vacuum2_range             = 16
local vacuum3_range             = 25
local ch_help = "Levý klik vysaje do inventáře všechny předměty volně se povalující po zemi v dané oblasti.\nElektrický nástroj — před použitím nutno nabít."
local ch_help_group = "vacuum"

local S = technic.getter

technic.register_power_tool("technic:vacuum_mk1", vacuum1_max_charge)
technic.register_power_tool("technic:vacuum_mk2", vacuum2_max_charge)
technic.register_power_tool("technic:vacuum_mk3", vacuum3_max_charge)

local function vacuum_onuse(itemstack, user, pointed_thing, max_charge, charge_per_object, range)
	local meta = minetest.deserialize(itemstack:get_meta():get_string(""))
	if not meta or not meta.charge then
		return
	end
	if meta.charge > charge_per_object then
		minetest.sound_play("vacuumcleaner", {
			to_player = user:get_player_name(),
			gain = 0.4,
		})
	end
	local pos = user:get_pos()
	local inv = user:get_inventory()
	for _, object in ipairs(minetest.get_objects_inside_radius(pos, range)) do
		local luaentity = object:get_luaentity()
		if not object:is_player() and luaentity and luaentity.name == "__builtin:item" and luaentity.itemstring ~= "" then
			if inv and inv:room_for_item("main", ItemStack(luaentity.itemstring)) then
				meta.charge = meta.charge - charge_per_object
				if meta.charge < charge_per_object then
					return
				end
				inv:add_item("main", ItemStack(luaentity.itemstring))
				minetest.sound_play("item_drop_pickup", {
					to_player = user:get_player_name(),
					gain = 0.4,
				})
				luaentity.itemstring = ""
				object:remove()
			end
		end
	end

	if not minetest.is_creative_enabled(user:get_player_name()) then
		technic.set_RE_wear(itemstack, meta.charge, max_charge)
		itemstack:get_meta():set_string("", minetest.serialize(meta))
	end
	return itemstack
end

minetest.register_tool("technic:vacuum_mk1", {
	description = S("Vacuum Cleaner Mk1"),
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "technic_vacuum_mk1.png",
	stack_max = 1,
	wear_represents = "technic_RE_charge",
	on_refill = technic.refill_RE_charge,
	on_use = function(itemstack, user, pointed_thing)
		return vacuum_onuse(itemstack, user, pointed_thing, vacuum1_max_charge, vacuum1_charge_per_object, vacuum1_range)
	end,
})
minetest.register_tool("technic:vacuum_mk2", {
	description = S("Vacuum Cleaner Mk2"),
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "technic_vacuum_mk2.png",
	stack_max = 1,
	wear_represents = "technic_RE_charge",
	on_refill = technic.refill_RE_charge,
	on_use = function(itemstack, user, pointed_thing)
		return vacuum_onuse(itemstack, user, pointed_thing, vacuum2_max_charge, vacuum2_charge_per_object, vacuum2_range)
	end,
})
minetest.register_tool("technic:vacuum_mk3", {
	description = S("Vacuum Cleaner Mk3"),
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "technic_vacuum_mk3.png",
	stack_max = 1,
	wear_represents = "technic_RE_charge",
	on_refill = technic.refill_RE_charge,
	on_use = function(itemstack, user, pointed_thing)
		return vacuum_onuse(itemstack, user, pointed_thing, vacuum3_max_charge, vacuum3_charge_per_object, vacuum3_range)
	end,
})

minetest.register_craft({
	output = 'technic:vacuum_mk1',
	recipe = {
		{'pipeworks:tube_1',              'pipeworks:filter', 'technic:battery'},
		{'pipeworks:tube_1',              'basic_materials:motor',    'technic:battery'},
		{'technic:stainless_steel_ingot', '',                 ''},
	}
})
minetest.register_craft({
	output = 'technic:vacuum_mk2',
	recipe = {
		{"technic:battery", "technic:stainless_steel_ingot", "technic:battery"},
		{"technic:stainless_steel_ingot", "technic:vacuum_mk1", "technic:battery"},
		{"", "technic:green_energy_crystal", ""},
	}
})
minetest.register_craft({
	output = 'technic:vacuum_mk3',
	recipe = {
		{"technic:battery", "technic:stainless_steel_ingot", "technic:battery"},
		{"technic:stainless_steel_ingot", "technic:vacuum_mk2", "technic:battery"},
		{"", "technic:blue_energy_crystal", ""},
	}
})
