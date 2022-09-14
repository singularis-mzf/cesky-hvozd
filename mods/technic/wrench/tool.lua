
local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_tool("wrench:wrench", {
	description = S("Wrench"),
	_ch_help = "Klíč na zvedání vybraných předmětů s inventářem, především truhel a obchodních terminálů.\nPoužijte levým tlačítkem.",
	inventory_image = "technic_wrench.png",
	on_use = function(itemstack, player, pointed_thing)
		if not player or not pointed_thing then
			return
		end
		local name = player:get_player_name()
		local pos = pointed_thing.under
		if not pos or minetest.is_protected(pos, name) then
			return
		end
		local picked_up, err_msg = wrench.pickup_node(pos, player)
		if not picked_up then
			if err_msg then
				minetest.chat_send_player(name, err_msg)
			end
			return
		end
		if not minetest.is_creative_enabled(name) then
			itemstack:add_wear(65535 / 20)
		end
		return itemstack
	end,
})

-- if minetest.get_modpath("technic") and technic.config:get_bool("enable_wrench_crafting") then
	minetest.register_craft({
		output = "wrench:wrench",
		recipe = {
			{"technic:carbon_steel_ingot", "", "technic:carbon_steel_ingot"},
			{"", "technic:carbon_steel_ingot", ""},
			{"", "technic:carbon_steel_ingot", ""}
		}
	})
-- end
