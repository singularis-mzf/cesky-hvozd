local function magic_wand_on_use(itemstack, user, pointed_thing)
	local player_info = ch_core.normalize_player(user)
	if player_info == nil or player_info.player == nil then
		return
	end
	if player_info.role ~= "admin" and player_info.role ~= "creative" then
		return
	end
	local was_creative = minetest.is_creative_enabled(player_info.player_name)
	local player_controls = player_info.player:get_player_control()
	if player_controls.aux1 then
		-- disable
		if not player_info.privs.creative then
			ch_core.systemovy_kanal(player_info.player_name, "Režim usnadnění byl už vypnutý")
			return
		end
		player_info.privs.creative = nil
		minetest.set_player_privs(player_info.player_name, player_info.privs)
		ch_core.systemovy_kanal(player_info.player_name, "Režim usnadnění vypnut")
	else
		-- enable
		if player_info.privs.creative then
			ch_core.systemovy_kanal(player_info.player_name, "Režim usnadnění byl už zapnutý")
			return
		end
		player_info.privs.creative = true
		minetest.set_player_privs(player_info.player_name, player_info.privs)
		ch_core.systemovy_kanal(player_info.player_name, "Režim usnadnění zapnut")
	end
	local offline_charinfo = ch_core.offline_charinfo[player_info.player_name]
	if offline_charinfo ~= nil then
		ch_core.ap_add(player_info.player_name, offline_charinfo) -- update AP HUD
	end
	if not was_creative then
		itemstack:add_wear_by_uses(64)
		return itemstack
	end
end

local def = {
	description = "kouzelnická hůlka",
	_ch_help = "Kouzelnické postavy si mohou touto hůlkou snadno zapnout (levý klik)\n"..
				"či vypnout (Aux1+levý klik) režim usnadnění. Pro dělnické postavy není ničím užitečná.",
	inventory_image = "ch_core_kouzhul.png",
	wield_image = "ch_core_kouzhul.png",
	on_use = magic_wand_on_use,
}
minetest.register_tool("ch_extras:magic_wand", def)
