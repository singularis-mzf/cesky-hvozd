local max_charge = {50000, 200000, 650000}
local power_usage_per_node = {200, 200, 200}

local S = minetest.get_translator("technic")

minetest.register_craft({
	output = 'technic:mining_drill',
	recipe = {
		{'default:tin_ingot',             'technic:diamond_drill_head', 'default:tin_ingot'},
		{'technic:stainless_steel_ingot', 'basic_materials:motor',              'technic:stainless_steel_ingot'},
		{'',                              'technic:red_energy_crystal', 'default:copper_ingot'},
	}
})
minetest.register_craft({
	output = 'technic:mining_drill_mk2',
	recipe = {
		{'technic:diamond_drill_head',    'technic:diamond_drill_head',   'technic:diamond_drill_head'},
		{'technic:stainless_steel_ingot', 'technic:mining_drill',         'technic:stainless_steel_ingot'},
		{'',                              'technic:green_energy_crystal', ''},
	}
})
minetest.register_craft({
	output = 'technic:mining_drill_mk3',
	recipe = {
		{'technic:diamond_drill_head',    'technic:diamond_drill_head',  'technic:diamond_drill_head'},
		{'technic:stainless_steel_ingot', 'technic:mining_drill_mk2',    'technic:stainless_steel_ingot'},
		{'',                              'technic:blue_energy_crystal', ''},
	}
})
for i = 1, 4 do
	minetest.register_craft({
		output = 'technic:mining_drill_mk3',
		recipe = {
			{'technic:diamond_drill_head',    'technic:diamond_drill_head',   'technic:diamond_drill_head'},
			{'technic:stainless_steel_ingot', 'technic:mining_drill_mk2_'..i, 'technic:stainless_steel_ingot'},
			{'',                              'technic:blue_energy_crystal',  ''},
		}
	})
end

local mining_drill_mode_text = {
	{S("Single node.")},
	{S("3 nodes deep.")},
	{S("3 nodes wide.")},
	{S("3 nodes tall.")},
	{S("3x3 nodes.")},
}

local function drill_dig_it0 (pos,player)
	if minetest.is_protected(pos, player:get_player_name()) then
		minetest.record_protection_violation(pos, player:get_player_name())
		return
	end
	local node = minetest.get_node(pos)
	if node.name == "air" or node.name == "ignore" then return end
	if node.name == "default:lava_source" then return end
	if node.name == "default:lava_flowing" then return end
	if node.name == "default:water_source" then minetest.remove_node(pos) return end
	if node.name == "default:water_flowing" then minetest.remove_node(pos) return end
	local def = minetest.registered_nodes[node.name]
	if not def then return end
	def.on_dig(pos, node, player)
end

local function drill_dig_it1 (player)
	local dir=player:get_look_dir()
	if math.abs(dir.x)>math.abs(dir.z) then
		if dir.x>0 then return 0 end
		return 1
	end
	if dir.z>0 then return 2 end
	return 3
end

local function drill_dig_it2 (pos,player)
	pos.y=pos.y+1
	drill_dig_it0 (pos,player)
	pos.z=pos.z+1
	drill_dig_it0 (pos,player)
	pos.z=pos.z-2
	drill_dig_it0 (pos,player)
	pos.z=pos.z+1
	pos.y=pos.y-1
	drill_dig_it0 (pos,player)
	pos.z=pos.z+1
	drill_dig_it0 (pos,player)
	pos.z=pos.z-2
	drill_dig_it0 (pos,player)
	pos.z=pos.z+1
	pos.y=pos.y-1
	drill_dig_it0 (pos,player)
	pos.z=pos.z+1
	drill_dig_it0 (pos,player)
	pos.z=pos.z-2
	drill_dig_it0 (pos,player)
end

local function drill_dig_it3 (pos,player)
	pos.y=pos.y+1
	drill_dig_it0 (pos,player)
	pos.x=pos.x+1
	drill_dig_it0 (pos,player)
	pos.x=pos.x-2
	drill_dig_it0 (pos,player)
	pos.x=pos.x+1
	pos.y=pos.y-1
	drill_dig_it0 (pos,player)
	pos.x=pos.x+1
	drill_dig_it0 (pos,player)
	pos.x=pos.x-2
	drill_dig_it0 (pos,player)
	pos.x=pos.x+1
	pos.y=pos.y-1
	drill_dig_it0 (pos,player)
	pos.x=pos.x+1
	drill_dig_it0 (pos,player)
	pos.x=pos.x-2
	drill_dig_it0 (pos,player)
end

local function drill_dig_it4 (pos,player)
	drill_dig_it0 (pos,player)
	pos.x=pos.x+1
	drill_dig_it0 (pos,player)
	pos.x=pos.x-2
	drill_dig_it0 (pos,player)
	pos.x=pos.x+1
	pos.z=pos.z+1
	drill_dig_it0 (pos,player)
	pos.x=pos.x+1
	drill_dig_it0 (pos,player)
	pos.x=pos.x-2
	drill_dig_it0 (pos,player)
	pos.x=pos.x+1
	pos.z=pos.z-2
	drill_dig_it0 (pos,player)
	pos.x=pos.x+1
	drill_dig_it0 (pos,player)
	pos.x=pos.x-2
	drill_dig_it0 (pos,player)
end

local function cost_to_use(drill_type, mode)
	local mult
	if mode == 1 then
		mult = 1
	elseif mode <= 4 then
		mult = 3
	else
		mult = 9
	end
	return power_usage_per_node[drill_type] * mult
end

local function drill_dig_it(pos, player, mode)
	if mode == 1 then
		drill_dig_it0(pos, player)
	end

	if mode == 2 then -- 3 deep
		local dir = drill_dig_it1(player)
		if dir == 0 then -- x+
			drill_dig_it0(pos, player)
			pos.x = pos.x + 1
			drill_dig_it0(pos, player)
			pos.x = pos.x + 1
			drill_dig_it0(pos, player)
		end
		if dir == 1 then  -- x-
			drill_dig_it0(pos, player)
			pos.x=pos.x-1
			drill_dig_it0 (pos,player)
			pos.x=pos.x-1
			drill_dig_it0 (pos,player)
		end
		if dir==2 then  -- z+
			drill_dig_it0 (pos,player)
			pos.z=pos.z+1
			drill_dig_it0 (pos,player)
			pos.z=pos.z+1
			drill_dig_it0 (pos,player)
		end
		if dir==3 then  -- z-
			drill_dig_it0 (pos,player)
			pos.z=pos.z-1
			drill_dig_it0 (pos,player)
			pos.z=pos.z-1
			drill_dig_it0 (pos,player)
		end
	end

	if mode==3 then -- 3 wide
		local dir = drill_dig_it1(player)
		if dir==0 or dir==1 then -- x
			drill_dig_it0 (pos,player)
			pos.z=pos.z+1
			drill_dig_it0 (pos,player)
			pos.z=pos.z-2
			drill_dig_it0 (pos,player)
		end
		if dir==2 or dir==3 then  -- z
			drill_dig_it0 (pos,player)
			pos.x=pos.x+1
			drill_dig_it0 (pos,player)
			pos.x=pos.x-2
			drill_dig_it0 (pos,player)
		end
	end

	if mode==4 then -- 3 tall, selected in the middle
		drill_dig_it0 (pos,player)
		pos.y=pos.y-1
		drill_dig_it0 (pos,player)
		pos.y=pos.y-1
		drill_dig_it0 (pos,player)
	end

	if mode==5 then -- 3 x 3
		local dir=player:get_look_dir()
		if math.abs(dir.y)<0.5 then
			dir=drill_dig_it1(player)
				if dir==0 or dir==1 then -- x
					drill_dig_it2(pos,player)
				end
				if dir==2 or dir==3 then  -- z
					drill_dig_it3(pos,player)
				end
		else
		drill_dig_it4(pos,player)
		end
	end

	minetest.sound_play("mining_drill", {pos = pos, gain = 1.0, max_hear_distance = 10,})
end

local function pos_is_pointable(pos)
	local node = minetest.get_node(pos)
	local nodedef = minetest.registered_nodes[node.name]
	return nodedef and nodedef.pointable
end

local function mining_drill_mk2_setmode(user,itemstack)
	local player_name=user:get_player_name()
	local item=itemstack:to_table()
	local mode = nil
	local meta=minetest.deserialize(item["metadata"])
	if meta==nil then
		meta={}
		mode=0
	end
	if meta["mode"]==nil then
		minetest.chat_send_player(player_name, S("Use while sneaking to change Mining Drill Mk@1 modes.", 2))
		meta["mode"]=0
		mode=0
	end
	mode=(meta["mode"])
	mode=mode+1
	if mode>=5 then mode=1 end
	minetest.chat_send_player(player_name, S("Mining Drill Mk@1 Mode @2", 2, mode)..": "..mining_drill_mode_text[mode][1])
    itemstack:set_name("technic:mining_drill_mk2_"..mode);
	meta["mode"]=mode
    itemstack:get_meta():set_string("", minetest.serialize(meta))
	return itemstack
end

local function mining_drill_mk3_setmode(user,itemstack)
	local player_name=user:get_player_name()
	local item=itemstack:to_table()
	local mode = nil
	local meta=minetest.deserialize(item["metadata"])
	if meta==nil then
		meta={}
		mode=0
	end
	if meta["mode"]==nil then
		minetest.chat_send_player(player_name, S("Use while sneaking to change Mining Drill Mk@1 modes.", 3))
		meta["mode"]=0
		mode=0
	end
	mode=(meta["mode"])
	mode=mode+1
	if mode>=6 then mode=1 end
	minetest.chat_send_player(player_name, S("Mining Drill Mk@1 Mode @2", 3, mode)..": "..mining_drill_mode_text[mode][1])
    itemstack:set_name("technic:mining_drill_mk3_"..mode);
	meta["mode"]=mode
    itemstack:get_meta():set_string("", minetest.serialize(meta))
	return itemstack
end


local function mining_drill_mk2_handler(itemstack, user, pointed_thing)
	local keys = user:get_player_control()
	local meta = minetest.deserialize(itemstack:get_meta():get_string(""))
	if not meta or not meta.mode or keys.aux1 then
		return mining_drill_mk2_setmode(user, itemstack)
	end
	if pointed_thing.type ~= "node" or not pos_is_pointable(pointed_thing.under) or not meta.charge then
		return
	end
	local charge_to_take = cost_to_use(2, meta.mode)
	if meta.charge >= charge_to_take then
		local pos = minetest.get_pointed_thing_position(pointed_thing, false)
		drill_dig_it(pos, user, meta.mode)
		if not minetest.is_creative_enabled(user:get_player_name()) then
			meta.charge = meta.charge - charge_to_take
			itemstack:get_meta():set_string("", minetest.serialize(meta))
			technic.set_RE_wear(itemstack, meta.charge, max_charge[2])
		end
	end
	return itemstack
end

local function mining_drill_mk3_handler(itemstack, user, pointed_thing)
	local keys = user:get_player_control()
	local meta = minetest.deserialize(itemstack:get_meta():get_string(""))
	if not meta or not meta.mode or keys.aux1 then
		return mining_drill_mk3_setmode(user, itemstack)
	end
	if pointed_thing.type ~= "node" or not pos_is_pointable(pointed_thing.under) or not meta.charge then
		return
	end
	local charge_to_take = cost_to_use(3, meta.mode)
	if meta.charge >= charge_to_take then
		local pos = minetest.get_pointed_thing_position(pointed_thing, false)
		drill_dig_it(pos, user, meta.mode)
		if not minetest.is_creative_enabled(user:get_player_name()) then
			meta.charge = meta.charge - charge_to_take
			itemstack:get_meta():set_string("", minetest.serialize(meta))
			technic.set_RE_wear(itemstack, meta.charge, max_charge[3])
		end
	end
	return itemstack
end

local ch_help = "Slouží k rychlé těžbě bloků.\nLevý klik na jakýkoliv těžitelný blok ho okamžitě vyvrtá.\nElektrický nástroj — před použitím nutno nabít."
local ch_help_group = "mdrill1"

technic.register_power_tool("technic:mining_drill", max_charge[1])

minetest.register_tool("technic:mining_drill", {
	description = S("Mining Drill Mk@1", 1),
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "technic_mining_drill.png",
	stack_max = 1,
	wear_represents = "technic_RE_charge",
	on_refill = technic.refill_RE_charge,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" or not pos_is_pointable(pointed_thing.under) then
			return itemstack
		end
		local meta = minetest.deserialize(itemstack:get_meta():get_string(""))
		if not meta or not meta.charge then
			return
		end
		local charge_to_take = cost_to_use(1, 1)
		if meta.charge >= charge_to_take then
			local pos = minetest.get_pointed_thing_position(pointed_thing, false)
			drill_dig_it(pos, user, 1)
			if not minetest.is_creative_enabled(user:get_player_name()) then
				meta.charge = meta.charge - charge_to_take
				itemstack:get_meta():set_string("", minetest.serialize(meta))
				technic.set_RE_wear(itemstack, meta.charge, max_charge[1])
			end
		end
		return itemstack
	end,
})

local function on_place_mk2(itemstack, user, pointed_thing)
	return mining_drill_mk2_setmode(user, itemstack)
end

local function on_use_mk2(itemstack, user, pointed_thing)
	mining_drill_mk2_handler(itemstack, user, pointed_thing)
	return itemstack
end

ch_help = "Slouží k rychlé těžbě bloků, podle nastaveného režimu těží jeden nebo tři bloky.\nLevý klik na těžitelný blok ho okamžitě vyvrtá; pravý klik přepne režim.\nElektrický nástroj — před použitím nutno nabít."
ch_help_group = "mdrill2"

minetest.register_tool("technic:mining_drill_mk2", {
	description = S("Mining Drill Mk@1", 2),
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "technic_mining_drill_mk2.png",
	wear_represents = "technic_RE_charge",
	on_refill = technic.refill_RE_charge,
	on_use = on_use_mk2,
	on_secondary_use = on_place_mk2,
	on_place_mk2 = on_place_mk2,
})

technic.register_power_tool("technic:mining_drill_mk2", max_charge[2])

for i = 1, 4 do
	technic.register_power_tool("technic:mining_drill_mk2_"..i, max_charge[2])
	minetest.register_tool("technic:mining_drill_mk2_"..i, {
		description = S("Mining Drill Mk@1 Mode @2", 2, i),
		_ch_help = ch_help,
		_ch_help_group = ch_help_group,
		inventory_image = "technic_mining_drill_mk2.png^technic_tool_mode"..i..".png",
		wield_image = "technic_mining_drill_mk2.png",
		wear_represents = "technic_RE_charge",
		on_refill = technic.refill_RE_charge,
		groups = {not_in_creative_inventory=1},
		on_use = on_use_mk2,
		on_secondary_use = on_place_mk2,
		on_place = on_place_mk2,
	})
end

local function on_place_mk3(itemstack, user, pointed_thing)
	return mining_drill_mk3_setmode(user, itemstack)
end

local function on_use_mk3(itemstack, user, pointed_thing)
	mining_drill_mk3_handler(itemstack,user,pointed_thing)
	return itemstack
end

ch_help = "Slouží k rychlé těžbě bloků, podle nastaveného režimu těží jeden, tři nebo devět bloků.\nLevý klik na těžitelný blok ho okamžitě vyvrtá; pravý klik přepne režim.\nElektrický nástroj — před použitím nutno nabít."
ch_help_group = "mdrill3"

minetest.register_tool("technic:mining_drill_mk3", {
	description = S("Mining Drill Mk@1", 3),
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "technic_mining_drill_mk3.png",
	wear_represents = "technic_RE_charge",
	on_refill = technic.refill_RE_charge,
	on_use = on_use_mk3,
	on_secondary_use = on_place_mk3,
	on_place = on_place_mk3,
})

technic.register_power_tool("technic:mining_drill_mk3", max_charge[3])

for i=1,5,1 do
	technic.register_power_tool("technic:mining_drill_mk3_"..i, max_charge[3])
	minetest.register_tool("technic:mining_drill_mk3_"..i, {
		description = S("Mining Drill Mk@1 Mode @2", 3, i),
		_ch_help = ch_help,
		_ch_help_group = ch_help_group,
		inventory_image = "technic_mining_drill_mk3.png^technic_tool_mode"..i..".png",
		wield_image = "technic_mining_drill_mk3.png",
		wear_represents = "technic_RE_charge",
		on_refill = technic.refill_RE_charge,
		groups = {not_in_creative_inventory=1},
		on_use = on_use_mk3,
		on_secondary_use = on_place_mk3,
		on_place = on_place_mk3,
	})
end
