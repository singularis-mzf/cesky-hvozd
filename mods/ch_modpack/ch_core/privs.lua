-- právo značící registrovanou postavu
minetest.register_privilege("ch_registered_player", "Odlišuje registrované postavy od čerstvě založených.")

-- kouzelníci/ce nesmí vkládat do cizích inventářů
minetest.override_chatcommand("give", {privs = {give = true, protection_bypass = true, interact = true}})

local def = {
	description = "žezlo usnadnění",
	inventory_image = "ch_core_creative_inv.png",
	on_use = function(itemstack, user, pointed_thing)
		if user and user:is_player() and minetest.check_player_privs(user, "privs") then
			local player_name = user:get_player_name()
			local privs = minetest.get_player_privs(player_name)
			local message
			if privs.creative then
				privs.creative = nil
				message = "režim usnadnění hry vypnut"
			else
				privs.creative = true
				message = "režim usnadnění hry zapnut"
			end
			minetest.set_player_privs(player_name, privs)
			minetest.chat_send_player(player_name, "*** "..message)
		end
	end,
}
minetest.register_craftitem("ch_core:staff_of_creativity", def)

ch_core.submod_loaded("privs")
