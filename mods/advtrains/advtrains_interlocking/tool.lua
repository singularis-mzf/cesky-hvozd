-- tool.lua
-- Interlocking tool

local ilrs = advtrains.interlocking.route

minetest.register_craftitem("advtrains_interlocking:tool",{
	description = attrans("Interlocking tool\nright-click turnouts to inspect route locks"),
	groups = {cracky=1}, -- key=name, value=rating; rating=1..3.
	inventory_image = "at_il_tool.png",
	wield_image = "at_il_tool.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		local pname = placer:get_player_name()
		if not pname then
			return
		end
		if not minetest.check_player_privs(pname, {interlocking=true}) then
			minetest.chat_send_player(pname, attrans("Insufficient privileges to use this!"))
			return
		end
		if pointed_thing.type=="node" then
			local pos=pointed_thing.under
			if advtrains.is_passive(pos) then
				local form = "size[7,5]label[0.5,0.5;" .. attrans("Route lock inspector") .. "]"
				local pts = minetest.pos_to_string(pos)
				
				local rtl = ilrs.has_route_lock(pts)
				
				if rtl then
					form = form.."label[0.5,1;" .. attrans("Route locks currently put:") .. "\n"..rtl.."]"
					form = form.."button_exit[0.5,3.5;  5,1;clear;" .. attrans("Clear") .. "]"
				else
					form = form.."label[0.5,1;" .. attrans("No route locks set") .. "]"
					form = form.."button_exit[0.5,3.5;  5,1;emplace;" .. attrans("Emplace manual lock") .. "]"
				end
				
				minetest.show_formspec(pname, "at_il_rtool_"..pts, form)
			else
				minetest.chat_send_player(pname, attrans("Cannot use this here."))
				return
			end
		end
	end,
})

minetest.register_craft({
	output = "advtrains_interlocking:tool",
	recipe = {
		{"default:diamond", "", ""},
		{"ch_extras:lupa", "", ""},
		{"default:steel_ingot", "", ""},
	},
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	if not minetest.check_player_privs(pname, "interlocking") then
		return
	end
	local pos
	local pts = string.match(formname, "^at_il_rtool_(.+)$")
	if pts then
		pos = minetest.string_to_pos(pts)
	end
	if pos then
		if advtrains.is_passive(pos) then
			if fields.clear then
				ilrs.remove_route_locks(pts)
			end
			if fields.emplace then
				ilrs.add_manual_route_lock(pts, attrans("Manual lock (@1)", pname))
			end
		end
	end
end)
