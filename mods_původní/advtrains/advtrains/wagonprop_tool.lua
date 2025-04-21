minetest.register_craftitem("advtrains:wagon_prop_tool",{ --craftitem because it does nothing on its own
	description = attrans("Wagon Properties Tool\nPunch a wagon to view and edit the Wagon Properties"),
	short_description = attrans("Wagon Properties Tool"),
	groups = {},
	inventory_image = "advtrains_wagon_prop_tool.png",
	wield_image = "advtrains_wagon_prop_tool.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		local pname = user:get_player_name()
		if not pname or pname == "" then
			return
		end

		--sanity checks in case of clicking the wrong entity/node/nothing
		if pointed_thing.type ~= "object" then return end --not an entity
		local object = pointed_thing.ref:get_luaentity()
		if not object.id then return end --entity doesn't have an id field

		local wagon = advtrains.wagons[object.id] --check if wagon exists in advtrains
		if not wagon then --not a wagon
			return
		end --end sanity checks

		--whitelist protection check
		if not advtrains.check_driving_couple_protection(pname,wagon.owner,wagon.whitelist) then
			minetest.chat_send_player(pname, attrans("Insufficient privileges to use this!"))
			return
		end
		object:show_wagon_properties(pname)
		return itemstack
	end,
})

if minetest.get_modpath("default") then --register recipe
	minetest.register_craft({
		output = "advtrains:wagon_prop_tool",
		recipe = {
			{"advtrains:dtrack_placer","dye:black","default:paper"},
			{"screwdriver:screwdriver","default:paper","default:paper"},
			{"","","group:wood"},
		}
	})
end