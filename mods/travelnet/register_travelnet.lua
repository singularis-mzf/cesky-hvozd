-- contains the node definition for a general travelnet that can be used by anyone
--   further travelnets can only be installed by the owner or by people with the travelnet_attach priv
--   digging of such a travelnet is limited to the owner and to people with the
--   travelnet_remove priv (useful for admins to clean up)
-- (this can be overrided in config.lua)
-- Author: Sokomine

local S = minetest.get_translator("travelnet")

local travelnet_nodenames = {}
local travelnet_dyes = {}

local function on_interact(pos, _, player)
	local meta = minetest.get_meta(pos)
	local legacy_formspec = meta:get_string("formspec")
	if not travelnet.is_falsey_string(legacy_formspec) then
		meta:set_string("formspec", "")
	end

	local player_name = player:get_player_name()
	travelnet.show_current_formspec(pos, meta, player_name)
end

-- travelnet box register function
function travelnet.register_travelnet_box(cfg)
    local desc = S("Travelnet-Box")
    travelnet_nodenames[cfg.nodename] = 1
	if cfg.colorname then
        desc = desc .. " (" .. cfg.colorname .. ")"
    end
	minetest.register_node(cfg.nodename, {
		description = desc,
		drawtype = "mesh",
		mesh = "travelnet.obj",
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "facedir",
		wield_scale = { x=0.6, y=0.6, z=0.6 },
		selection_box = {
			type = "fixed",
			fixed = { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 }
		},

		collision_box = {
			type = "fixed",
			fixed = {
				{ 0.45,  -0.5, -0.5,   0.5, 1.45, 0.5 },
				{ -0.5 , -0.5, 0.45,  0.45, 1.45, 0.5 },
				{ -0.5,  -0.5, -0.5, -0.45, 1.45, 0.5 },
				--groundplate to stand on
				{ -0.5,  -0.5, -0.5,  0.5, -0.45, 0.5 },
				--roof
				{ -0.5,  1.45, -0.5,  0.5,   1.5, 0.5 },
			},
		},

		tiles = {
			"(travelnet_travelnet_front_color.png^[multiply:" .. cfg.color .. ")^travelnet_travelnet_front.png", -- backward view
			"(travelnet_travelnet_back_color.png^[multiply:"  .. cfg.color .. ")^travelnet_travelnet_back.png",  -- front view
			"(travelnet_travelnet_side_color.png^[multiply:"  .. cfg.color .. ")^travelnet_travelnet_side.png",  -- sides :)
			"travelnet_top.png", -- view from top
			"travelnet_bottom.png", -- view from bottom
		},

		use_texture_alpha = "clip",
		inventory_image = "travelnet_inv_base.png^(travelnet_inv_colorable.png^[multiply:" .. cfg.color .. ")",
		groups = {
			travelnet = 1
		},
		light_source = cfg.light_source or 10,
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext",       S("Travelnet-box (unconfigured)"))
			meta:set_string("station_name",   "")
			meta:set_string("station_network","")
			meta:set_string("owner", placer:get_player_name())
			minetest.set_node(vector.add(pos, { x=0, y=1, z=0 }), { name="travelnet:hidden_top" })
		end,

		on_receive_fields = travelnet.on_receive_fields,
		on_rightclick = on_interact,
		on_punch = function(pos, node, puncher)
			local item = puncher:get_wielded_item()
			local item_name = item:get_name()
			local player_name = puncher:get_player_name()
			if	    travelnet_dyes[item_name]
				and puncher:get_player_control().sneak
				and not minetest.is_protected(pos, player_name)
			then
				-- in-place travelnet coloring
				node.name = travelnet_dyes[item_name]
				minetest.swap_node(pos, node)
				item:take_item()
				puncher:set_wielded_item(item)
				return
			end
			on_interact(pos, nil, puncher)
		end,

		can_dig = function(pos, player)
			return travelnet.can_dig(pos, player, "travelnet box")
		end,

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			travelnet.remove_box(pos, oldnode, oldmetadata, digger)
		end,

		-- TNT and overenthusiastic DMs do not destroy travelnets
		on_blast = function() end,

		-- taken from VanessaEs homedecor fridge
		on_place = function(itemstack, placer, pointed_thing)
			local node = minetest.get_node(vector.add(pointed_thing.above, { x=0, y=1, z=0 }))
			local def = minetest.registered_nodes[node.name]
			-- leftover top nodes can be removed by placing a new travelnet underneath
			if (not def or not def.buildable_to) and node.name ~= "travelnet:hidden_top" then
				minetest.chat_send_player(
					placer:get_player_name(),
					S("Not enough vertical space to place the travelnet box!")
				)
				return
			end
			return minetest.item_place(itemstack, placer, pointed_thing)
		end,

		on_destruct = function(pos)
			minetest.remove_node(vector.add(pos, { x=0, y=1, z=0 }))
		end,

		_ch_help_group = "travelnet",
		_ch_help = "postavenou budku je možné přebarvit na jinou barvu\nShift+levým klikem dávkou příslušného barviva",
	})

	if cfg.recipe then
		-- normal recipe
		minetest.register_craft({
			output = cfg.nodename,
			recipe = cfg.recipe,
		})
	end
	if cfg.dye then
		travelnet_dyes[cfg.dye] = cfg.nodename
		-- dye recipe
		minetest.register_craft({
			output = cfg.nodename,
			type = "shapeless",
			recipe = { "group:travelnet", cfg.dye },
		})
	end
	if minetest.get_modpath("mesecons_mvps") then
		mesecon.register_mvps_stopper(cfg.nodename:gsub("^:", ""))
	end
end

local on_chatcommand = function(name)
	local player = minetest.get_player_by_name(name);
	local pos = player and player:get_pos()
	local node = pos and minetest.get_node(pos)
	if node and travelnet_nodenames[node.name] then
		return on_interact(pos, nil, player)
	else
		return false, S("You are not in a Travelnet-Box!")
	end
end

minetest.register_chatcommand("cestovat", {
	description = "Opens an interface of the Travelnet Box you are standing in",
	privs = {},
	func = on_chatcommand,
})

on_chatcommand = function(name, param)
	local b, hash1, hash2 = param:match("^([^ ]+) (%d+) (%d+)$")
	if b == nil then
		return false, "Chybné zadání!"
	end
	local n
	if b == "ano" then
		n = 1
	elseif b == "ne" then
		n = 0
	else
		return false, "Chybné zádání!"
	end
	if tonumber(hash1) == tonumber(hash2) then
		return false, "Chybné zadání, kódy nemohou být stejné!"
	end
	if tonumber(hash1) > tonumber(hash2) then
		hash1, hash2 = hash2, hash1
	end
	travelnet.storage:set_int(string.format("%d_%d", hash1, hash2), n)
	return true, "Úspěšně nastaveno."
end

minetest.register_chatcommand("cestovat_zdarma", {
	description = "Nastaví cestování zdarma mezi vybranými budkami.",
	params = "<ano|ne> <kód1> <kód2>",
	privs = {server = true},
	func = on_chatcommand,
})
