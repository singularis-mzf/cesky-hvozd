local get_object = smartshop.api.get_object

local function check_any_priv(player, privs)
	if not player then
		return false
	end
	if type(privs) == "string" then
		return minetest.check_player_privs(player, privs)
	end
	for priv, _ in pairs(privs) do
		if minetest.check_player_privs(player, priv) then
			return true
		end
	end
	return false
end

smartshop.nodes = {
    after_place_node = function(pos, placer, itemstack)

		-- check rights
		if not minetest.check_player_privs(placer, "smartshop_admin") then
			if not check_any_priv(placer, {ch_registered_player = true, protection_bypass = true, server = true}) then
				ch_core.systemovy_kanal(placer:get_player_name(), "Děláte to správně, ale nové postavy nesmějí umístit obchodní terminál ani jeho zásobník!")
				minetest.remove_node(pos)
				return
			end
			if minetest.check_player_privs(placer, "give") then
				ch_core.systemovy_kanal(placer:get_player_name(), "VAROVÁNÍ: Kouzelnické postavy se nesmějí účastnit obchodování! Výjimky jsou možné v odůvodněných případech po dohodě s Administrací. Pokud je obchodní terminál žádoucí součástí vaší stavby, doporučuji k jeho zřízení a plnění využít dělnickou postavu nebo o jeho zřízení požádat Administraci. Kouzelnickým postavám, jako je ta vaše, nebude umožněno do obchodního terminálu doplňovat zboží.")
			end
		end

        local obj = get_object(pos)
        obj:initialize_metadata(placer)
        obj:initialize_inventory()
        obj:update_appearance()
    end,

    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local obj = get_object(pos)
        obj:on_rightclick(node, player, itemstack, pointed_thing)
    end,

    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local obj = get_object(pos)
        return obj:allow_metadata_inventory_put(listname, index, stack, player)
    end,

    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        local obj = get_object(pos)
        return obj:allow_metadata_inventory_take(listname, index, stack, player)
    end,

    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        local obj = get_object(pos)
        return obj:allow_metadata_inventory_move(from_list, from_index, to_list, to_index, count, player)
    end,

    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        local obj = get_object(pos)
        obj:on_metadata_inventory_put(listname, index, stack, player)
    end,

    on_metadata_inventory_take = function(pos, listname, index, stack, player)
        local obj = get_object(pos)
        obj:on_metadata_inventory_take(listname, index, stack, player)
    end,

    on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        local obj = get_object(pos)
        obj:on_metadata_inventory_move(from_list, from_index, to_list, to_index, count, player)
    end,

    can_dig = function(pos, player)
        local obj = get_object(pos)
        return obj:can_dig(player)
    end,

    on_destruct = function(pos)
        local obj = get_object(pos)
        return obj:on_destruct()
    end,

    make_variant_tiles = function(color)
        return {("(smartshop_face.png^[colorize:#FFFFFF77)^(smartshop_border.png^[colorize:%s)"):format(color)}
    end,
}

smartshop.dofile("nodes", "shop")
smartshop.dofile("nodes", "storage")
