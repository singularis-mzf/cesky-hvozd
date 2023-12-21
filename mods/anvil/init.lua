---------------------------------------------------------------------------------------
-- simple anvil that can be used to repair tools
---------------------------------------------------------------------------------------
-- * can be used to repair tools
-- * the hammer gets damaged a bit at each repair step
---------------------------------------------------------------------------------------

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

anvil = {
	setting = {
		item_displacement = 2/16,
		min_wear_min = 3275, -- anvil cannot reduce wear below the limit that is random between these values
		min_wear_max = 6553,
	}
}

local function get_min_wear_limit()
	local s = anvil.setting
	return math.random(s.min_wear_min, s.min_wear_max)
end

minetest.register_alias("castle:anvil", "anvil:anvil")

local hammer_repairable = minetest.settings:get_bool("anvil_hammer_is_repairable", true)

anvil.make_unrepairable = function(item_name)
	local item_def = minetest.registered_items[item_name]
	if item_def then
		-- Drop table reference. Copy other values over.
		local groups = { not_repaired_by_anvil = 1 }
		for k, v in pairs(item_def.groups) do groups[k] = v end
		minetest.override_item(item_name, {groups = groups})
	end
end

if minetest.get_modpath("technic") then
	-- make rechargeable technic tools unrepairable
	anvil.make_unrepairable("technic:water_can")
	anvil.make_unrepairable("technic:lava_can")
	anvil.make_unrepairable("technic:flashlight")
	anvil.make_unrepairable("technic:battery")
	anvil.make_unrepairable("technic:vacuum")
	anvil.make_unrepairable("technic:prospector")
	anvil.make_unrepairable("technic:sonic_screwdriver")
	anvil.make_unrepairable("technic:chainsaw")
	anvil.make_unrepairable("technic:laser_mk1")
	anvil.make_unrepairable("technic:laser_mk2")
	anvil.make_unrepairable("technic:laser_mk3")
	anvil.make_unrepairable("technic:mining_drill")
	anvil.make_unrepairable("technic:mining_drill_mk2")
	anvil.make_unrepairable("technic:mining_drill_mk2_1")
	anvil.make_unrepairable("technic:mining_drill_mk2_2")
	anvil.make_unrepairable("technic:mining_drill_mk2_3")
	anvil.make_unrepairable("technic:mining_drill_mk2_4")
	anvil.make_unrepairable("technic:mining_drill_mk3")
	anvil.make_unrepairable("technic:mining_drill_mk3_1")
	anvil.make_unrepairable("technic:mining_drill_mk3_2")
	anvil.make_unrepairable("technic:mining_drill_mk3_3")
	anvil.make_unrepairable("technic:mining_drill_mk3_4")
	anvil.make_unrepairable("technic:mining_drill_mk3_5")
end

local S = minetest.get_translator(minetest.get_current_modname())

-- the hammer for the anvil

local hammer_def = {
	description = S("Steel blacksmithing hammer"),
	_doc_items_longdesc = S("A tool for repairing other tools at a blacksmith's anvil."),
	_doc_items_usagehelp = S("Use this hammer to strike blows upon an anvil bearing a damaged tool and you can repair it. It can also be used for smashing stone, but it is not well suited to this task."),
	image           = "anvil_tool_steelhammer.png",
	inventory_image = "anvil_tool_steelhammer.png",

	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={
		-- about equal to a stone pick (it's not intended as a tool)
			cracky={times={[2]=2.00, [3]=1.20}, uses=30, maxlevel=1},
		},
		damage_groups = {fleshy=6},
	}
}

if not hammer_repairable then
	hammer_def.groups = {["not_repaired_by_anvil"] = 1}
end

minetest.register_tool("anvil:hammer", hammer_def)

local tmp = {}

minetest.register_entity("anvil:item",{
	initial_properties = {
		hp_max = 1,
		visual="wielditem",
		visual_size={x=.33,y=.33},
		collisionbox = {0,0,0,0,0,0},
		physical=false,
		textures={"air"},
	},
	on_activate = function(self, staticdata)
		if tmp.nodename ~= nil and tmp.texture ~= nil then
			self.nodename = tmp.nodename
			tmp.nodename = nil
			self.texture = tmp.texture
			tmp.texture = nil
		else
			if staticdata ~= nil and staticdata ~= "" then
				local data = staticdata:split(';')
				if data and data[1] and data[2] then
					self.nodename = data[1]
					self.texture = data[2]
				end
			end
		end
		if self.texture ~= nil then
			self.object:set_properties({textures={self.texture}})
		end
	end,
	get_staticdata = function(self)
		if self.nodename ~= nil and self.texture ~= nil then
			return self.nodename .. ';' .. self.texture
		end
		return ""
	end,
})

local remove_item = function(pos, node)
	local objs = minetest.get_objects_inside_radius({x = pos.x, y = pos.y + anvil.setting.item_displacement, z = pos.z}, .5)
	if objs then
		for _, obj in ipairs(objs) do
			if obj and obj:get_luaentity() and obj:get_luaentity().name == "anvil:item" then
				obj:remove()
			end
		end
	end
end

local update_item = function(pos, node)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if not inv:is_empty("input") then
		pos.y = pos.y + anvil.setting.item_displacement
		tmp.nodename = node.name
		tmp.texture = inv:get_stack("input", 1):get_name()
		local e = minetest.add_entity(pos,"anvil:item")
		local yaw = math.pi*2 - node.param2 * math.pi/2
		if e.set_rotation == nil then
			-- This is for 0.4.16 support, remove it eventually
			e:set_yaw(yaw)
			pos.y = pos.y + 5/16
			e:set_pos(pos)
		else
			e:set_rotation({x=-1.5708, y=yaw, z=0}) -- x is pitch, 1.5708 is 90 degrees.
		end
	end
end

local metal_sounds
-- Apparently node_sound_metal_defaults is a newer thing, I ran into games using an older version of the default mod without it.
if default.node_sound_metal_defaults ~= nil then
	metal_sounds = default.node_sound_metal_defaults()
else
	metal_sounds = default.node_sound_stone_defaults()
end

local function set_anvil_infotext(meta, owner, is_shared)
	local view_name = ch_core.prihlasovaci_na_zobrazovaci(owner)
	if is_shared then
		meta:set_string("infotext", S("Shared anvil, placed by @1", view_name))
	else
		meta:set_string("infotext", S("@1's anvil", view_name))
	end
end

minetest.register_node("anvil:anvil", {
	drawtype = "nodebox",
	description = S("Anvil"),
	_doc_items_longdesc = S("A tool for repairing other tools in conjunction with a blacksmith's hammer."),
	_doc_items_usagehelp = S("Right-click on this anvil with a damaged tool to place the damaged tool upon it. You can then repair the damaged tool by striking it with a blacksmith's hammer. Repeated blows may be necessary to fully repair a badly worn tool. To retrieve the tool either punch or right-click the anvil with an empty hand."),
	_ch_help = "Kladivo slouží k opravám nářadí na kovadlině\na opravám rozbitých pneumatických rour. Používá se levým klikem.\nLevým klikem dokáže rovněž rozbít některé druhy neporušených pneumatických rour.\nOmezeně lze použít i k těžbě některých materiálů.",
	tiles = {"default_stone.png"},
	paramtype  = "light",
	paramtype2 = "facedir",
	groups = {cracky=2,padlockable=1},
	sounds = metal_sounds,
	-- the nodebox model comes from realtest
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5,-0.5,-0.3,0.5,-0.4,0.3},
			{-0.35,-0.4,-0.25,0.35,-0.3,0.25},
			{-0.3,-0.3,-0.15,0.3,-0.1,0.15},
			{-0.35,-0.1,-0.2,0.35,0.1,0.2},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5,-0.5,-0.3,0.5,-0.4,0.3},
			{-0.35,-0.4,-0.25,0.35,-0.3,0.25},
			{-0.3,-0.3,-0.15,0.3,-0.1,0.15},
			{-0.35,-0.1,-0.2,0.35,0.1,0.2},
		}
	},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
	end,

	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		local owner = placer:get_player_name() or ""
		meta:set_string("owner", owner)
		meta:set_int("shared", 1)
		set_anvil_infotext(meta, owner, true)
	end,

	can_dig = function(pos,player)
		local meta  = minetest.get_meta(pos)
		local inv   = meta:get_inventory()

		if not inv:is_empty("input") then
			return false
		end
		ch_core.dig_padlock(pos, player)
		return true
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if listname~="input" then
			return 0
		end
		if (listname=='input') then
			-- if (stack:get_wear() == 0) then
				-- minetest.chat_send_player( player:get_player_name(), S('This anvil is for damaged tools only.'))
				-- return 0
			-- end

			local stack_name = stack:get_name()
			local item_def = minetest.registered_items[stack_name]
			local item_groups = item_def.groups or {}
			if (item_groups.not_repaired_by_anvil or 0) ~= 0 or
				(item_groups.not_repairable or 0) ~= 0 or
				(item_def.wear_represents and item_def.wear_represents ~= "mechanical_wear")
			then
				minetest.chat_send_player( player:get_player_name(), S('@1 cannot be repaired with an anvil.', item_def.description))
				return 0
			end
		end

		if meta:get_inventory():room_for_item("input", stack) then
			return stack:get_count()
		end
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname~="input" then
			return 0
		end
		return stack:get_count()
	end,

	on_rightclick = function(pos, node, clicker, itemstack)
		if not clicker or not itemstack then
			return
		end
		local meta = minetest.get_meta(pos)
		local name = clicker:get_player_name()
		local owner = meta:get_string("owner")
		local shared = meta:get_int("shared") == 1

		if name ~= owner and not shared then return itemstack end
		if itemstack:get_count() == 0 then
			local inv = meta:get_inventory()
			if not inv:is_empty("input") then
				local return_stack = inv:get_stack("input", 1)
				inv:set_stack("input", 1, nil)
				local wield_index = clicker:get_wield_index()
				clicker:get_inventory():set_stack("main", wield_index, return_stack)
				set_anvil_infotext(meta, owner, shared)
				remove_item(pos, node)
				return return_stack
			end
		end
		local this_def = minetest.registered_nodes[node.name]
		if this_def.allow_metadata_inventory_put(pos, "input", 1, itemstack:peek_item(), clicker) > 0 then
			local s = itemstack:take_item()
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			inv:add_item("input", s)
			local meta_description = s:get_meta():get_string("description")
			if "" ~= meta_description then
				set_anvil_infotext(meta, owner, shared) -- "\n" .. meta_description)
			end
			meta:set_int("informed", 0)
			update_item(pos,node)
		end

		return itemstack
	end,

	on_punch = function(pos, node, puncher)
		if( not( pos ) or not( node ) or not( puncher )) then
			return
		end

		local wielded = puncher:get_wielded_item()
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()
		local owner = meta:get_string("owner")
		local shared = meta:get_int("shared") == 1
		if owner ~= puncher:get_player_name() and not shared then
			return
		end

		if wielded:get_count() == 0 then
			if not inv:is_empty("input") then
				local return_stack = inv:get_stack("input", 1)
				inv:set_stack("input", 1, nil)
				local wield_index = puncher:get_wield_index()
				puncher:get_inventory():set_stack("main", wield_index, return_stack)
				set_anvil_infotext(meta, owner, shared)
				remove_item(pos, node)
			end
		end

		-- only punching with the hammer is supposed to work
		if wielded:get_name() ~= 'anvil:hammer' then
			return
		end
		local input = inv:get_stack('input',1)

		-- only tools can be repaired
		if not input or input:is_empty() then
			return
		end

		-- 65535 is max damage
		local damage_state = 40-math.floor(input:get_wear()/1638)

		local tool_name = input:get_name()

		local hud2 = nil
		local hud3 = nil
		if( input:get_wear()>0 ) then
			hud2 = puncher:hud_add({
			hud_elem_type = "statbar",
			text = "default_cloud.png^[colorize:#ff0000:256",
			number = 40,
			direction = 0, -- left to right
			position = {x=0.5, y=0.65},
			alignment = {x = 0, y = 0},
			offset = {x = -320, y = 0},
			size = {x=32, y=32},
			})
			hud3 = puncher:hud_add({
			hud_elem_type = "statbar",
			text = "default_cloud.png^[colorize:#00ff00:256",
			number = damage_state,
			direction = 0, -- left to right
			position = {x=0.5, y=0.65},
			alignment = {x = 0, y = 0},
			offset = {x = -320, y = 0},
			size = {x=32, y=32},
			})
		end
		minetest.after(2, function()
		if( puncher ) and ( hud2 ) and ( hud3 ) then
			puncher:hud_remove(hud2)
			puncher:hud_remove(hud3)
			end
		end)

		-- tell the player when the job is done
		if(   input:get_wear() <= get_min_wear_limit() ) then
			--[[ but only once
			if 0 < meta:get_int("informed") then return end
			meta:set_int("informed", 1) ]]
			local tool_desc
			local meta_description = input:get_meta():get_string("description")
			if "" ~= meta_description then
				tool_desc = meta_description
			elseif minetest.registered_items[tool_name] and minetest.registered_items[tool_name].description then
				tool_desc = minetest.registered_items[tool_name].description
			else
				tool_desc = tool_name
			end
			minetest.chat_send_player( puncher:get_player_name(), S('Your @1 has been repaired successfully, remains damage @2 %.', tool_desc, string.format("%.3f", input:get_wear() / 655.35)))
			return
		else
			pos.y = pos.y + anvil.setting.item_displacement
			minetest.sound_play({name="anvil_clang"}, {pos=pos})
			minetest.add_particlespawner({
			amount = 10,
			time = 0.1,
			minpos = pos,
			maxpos = pos,
			minvel = {x=2, y=3, z=2},
			maxvel = {x=-2, y=1, z=-2},
			minacc = {x=0, y= -10, z=0},
			maxacc = {x=0, y= -10, z=0},
			minexptime = 0.5,
			maxexptime = 1,
			minsize = 1,
			maxsize = 1,
			collisiondetection = true,
			vertical = false,
			texture = "anvil_spark.png",
			})
		end

		-- do the actual repair
		local old_wear = input:get_wear()
		local wear_to_add = math.min(0, math.max(-5000, get_min_wear_limit() - old_wear))
		--input:add_wear( -5000 ) -- equals to what technic toolshop does in 5 seconds
		input:add_wear(wear_to_add)
		inv:set_stack("input", 1, input)

		-- damage the hammer slightly
		wielded:add_wear( 100 )
		puncher:set_wielded_item( wielded )
	end,
	is_ground_content = false,

	-- padlock
	on_padlock_place = function(player, pos, owner)
		local meta = minetest.get_meta(pos)
		if not (meta:get_int("shared") == 1) then
			return false
		end
		meta:set_int("shared", 0)
		set_anvil_infotext(meta, owner, false)
		return true
	end,
	on_padlock_remove = function(player, pos, owner)
		local meta = minetest.get_meta(pos)
		local player_name = player:get_player_name()
		if meta:get_int("shared") == 1 then
			return false -- already shared
		end
		meta:set_int("shared", "1")
		set_anvil_infotext(meta, owner, true)
		return true
	end,
})

-- automatically restore entities lost due to /clearobjects or similar
minetest.register_lbm({
	name = "anvil:anvil_item_restoration",
	nodenames = { "anvil:anvil" },
	run_at_every_load = true,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local test_pos = {x=pos.x, y=pos.y + anvil.setting.item_displacement, z=pos.z}
		if #minetest.get_objects_inside_radius(test_pos, 0.5) > 0 then return end
		update_item(pos, node)
	end
})

-- Transfer the hammer from the old hammer storage slot to the main slot, or else drop it in world
minetest.register_lbm({
	name = "anvil:hammer_ejection",
	nodenames = "anvil:anvil",
	run_at_every_load = false,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()
		if not inv:is_empty("hammer") then
			local hammer = inv:get_stack("hammer", 1)
			inv:set_stack("hammer", 1, nil)
			inv:set_size("hammer", 0)
			if inv:is_empty("input") then
				inv:set_stack("input", 1, hammer) -- the abm will ensure there's an entity showing the hammer is here
			else
				minetest.add_item({x=pos.x, y=pos.y+1, z=pos.z}, hammer)
			end
		end
	end
})

---------------------------------------------------------------------------------------
-- crafting receipes
---------------------------------------------------------------------------------------

minetest.register_craft({
	output = "anvil:anvil",
	recipe = {
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{'',                   "default:steel_ingot",''                   },
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"}
	}
})

minetest.register_craft({
	output = "anvil:hammer",
	recipe = {
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{"group:stick","",""}
	}
})

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
