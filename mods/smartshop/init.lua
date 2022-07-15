print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
smartshop={
	user={},
	tmp={},
	add_storage={},
	mesecon=minetest.get_modpath("mesecons")~=nil,
	dir={{x=0,y=0,z=-1},{x=-1,y=0,z=0},{x=0,y=0,z=1},{x=1,y=0,z=0}},
	dpos={
	{{x=0.2,y=0.2,z=0},{x=-0.2,y=0.2,z=0},{x=0.2,y=-0.2,z=0},{x=-0.2,y=-0.2,z=0}},
	{{x=0,y=0.2,z=0.2},{x=0,y=0.2,z=-0.2},{x=0,y=-0.2,z=0.2},{x=0,y=-0.2,z=-0.2}},
	{{x=-0.2,y=0.2,z=0},{x=0.2,y=0.2,z=0},{x=-0.2,y=-0.2,z=0},{x=0.2,y=-0.2,z=0}},
	{{x=0,y=0.2,z=-0.2},{x=0,y=0.2,z=0.2},{x=0,y=-0.2,z=-0.2},{x=0,y=-0.2,z=0.2}}
	},
}

local S = minetest.get_translator("smartshop")
local smartshop_capacity = 90

minetest.register_craft({
	output = "smartshop:shop",
	recipe = {
		{"default:chest_locked", "default:chest_locked", "default:chest_locked"},
		{"default:sign_wall_wood", "default:chest_locked", "default:sign_wall_wood"},
		{"default:sign_wall_wood", "", "default:sign_wall_wood"},
	}
})

smartshop.strpos=function(str,spl)
	if str==nil then return "" end
	if spl then
		local c=","
		if string.find(str," ") then c=" " end
		local s=str.split(str,c)
			if s[3]==nil then
				return nil
			else
				local p={x=tonumber(s[1]),y=tonumber(s[2]),z=tonumber(s[3])}
				if not (p and p.x and p.y and p.z) then return nil end
				return p
			end
	else	if str and str.x and str.y and str.z then
			return str.x .."," .. str.y .."," .. str.z
		else
			return nil
		end
	end
end

smartshop.send_mesecon=function(pos)
	if smartshop.mesecon then
		mesecon.receptor_on(pos)
		minetest.get_node_timer(pos):start(1)
	end
end

smartshop.use_offer=function(pos,player,n)
	local pressed={}
	pressed["buy" .. n]=true
	smartshop.user[player:get_player_name()]=pos
	smartshop.receive_fields(player,pressed)
	smartshop.user[player:get_player_name()]=nil
	smartshop.update(pos)
end

smartshop.get_offer=function(pos)
	if not pos or not minetest.get_node(pos) then return end
	if minetest.get_node(pos).name~="smartshop:shop" then return end
	local meta=minetest.get_meta(pos)
	local inv=meta:get_inventory()
	local offer={}
	for i=1,4,1 do
		offer[i]={
		give=inv:get_stack("give" .. i,1):get_name(),
		give_count=inv:get_stack("give" .. i,1):get_count(),
		pay=inv:get_stack("pay" .. i,1):get_name(),
		pay_count=inv:get_stack("pay" .. i,1):get_count(),
		}
	end
	return offer
end

smartshop.receive_fields=function(player,pressed)
		local pname=player:get_player_name()
		local pos=smartshop.user[pname]
		if not pos then
			return
		elseif pressed.customer then
			return smartshop.showform(pos,player,true)
		elseif pressed.sellall then
			local meta=minetest.get_meta(pos)
			local pname=player:get_player_name()
			if meta:get_int("sellall")==0 then
				meta:set_int("sellall",1)
				minetest.chat_send_player(pname, S("Sell your stock and give line"))
			else
				meta:set_int("sellall",0)
				minetest.chat_send_player(pname, S("Sell your stock only"))
			end
		elseif pressed.toogleee then
			local meta=minetest.get_meta(pos)
			local pname=player:get_player_name()
			if meta:get_int("type")==0 then
				meta:set_int("type",1)
				minetest.chat_send_player(pname, S("Your stock is limited"))
			else
				meta:set_int("type",0)
				minetest.chat_send_player(pname, S("Your stock is unlimited"))
			end
		elseif not pressed.quit then
			local n=1
			for i=1,4,1 do
				n=i
				if pressed["buy" .. i] then break end
			end
			local meta=minetest.get_meta(pos)
			local type=meta:get_int("type")
			local sellall=meta:get_int("sellall")
			local inv=meta:get_inventory()
			local pinv=player:get_inventory()
			local pname=player:get_player_name()
			local check_storage
			if pressed["buy" .. n] then
				local name=inv:get_stack("give" .. n,1):get_name()
				local stack=name .." ".. inv:get_stack("give" .. n,1):get_count()
				local pay=inv:get_stack("pay" .. n,1):get_name() .." ".. inv:get_stack("pay" .. n,1):get_count()
				local stack_to_use="main"
				if name~="" then
--fast checks
					if not pinv:room_for_item("main", stack) then
						minetest.chat_send_player(pname, S("Error: Your inventory is full, exchange aborted."))
						return
					elseif not pinv:contains_item("main", pay) then
						minetest.chat_send_player(pname, S("Error: You dont have enough in your inventory to buy this, exchange aborted."))
						return
					elseif type==1 and inv:room_for_item("main", pay)==false then
						minetest.chat_send_player(pname, S("Error: The owners stock is full, cant receive, exchange aborted."))
					else
						if inv:contains_item("main", stack) then
						elseif sellall==1 and inv:contains_item("give" .. n, stack) then
							stack_to_use="give" .. n
						else
							minetest.chat_send_player(pname, S("Error: The owners stock is end."))
							check_storage=1
						end
						if not check_storage then
							for i=0,smartshop_capacity,1 do
								if pinv:get_stack("main", i):get_name()==inv:get_stack("pay" .. n,1):get_name() and pinv:get_stack("main",i):get_wear()>0 then
									minetest.chat_send_player(pname, S("Error: your item is used"))
									return
								end
							end
							local rastack=inv:remove_item(stack_to_use, stack)
							pinv:remove_item("main", pay)
							pinv:add_item("main",rastack)
							if type==1 then inv:add_item("main",pay) end
							if type==0 then inv:add_item("main", rastack) end
						end
					end
					smartshop.send_mesecon(pos)
				end
			end
		else
			smartshop.update_info(pos)
			smartshop.update(pos,"update")
			smartshop.user[player:get_player_name()]=nil
		end
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="smartshop.showform" then
		smartshop.receive_fields(player,pressed)
	end
end)

smartshop.update_info=function(pos)
	local meta=minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local owner=meta:get_string("owner")
	local gve=0
	if meta:get_int("sellall")==1 then gve=1 end
	if meta:get_int("type")==0 then
		meta:set_string("infotext", S("(Smartshop by @1 Stock is unlimited)", owner))
		return false
	end
	local name=""
	local count=0
	local stuff={}
	for i=1,4,1 do
		local stuff_count = inv:get_stack("give" .. i,1):get_count()
		local stuff_name = inv:get_stack("give" .. i,1):get_name()
		local stuff_stock = gve * stuff_count
		for ii = 1, smartshop_capacity, 1 do
			name = inv:get_stack("main",ii):get_name()
			count = inv:get_stack("main",ii):get_count()
			if name == stuff_name then
				stuff_stock = stuff_stock + count
			end
		end
		local stuff_buy  = tonumber((""..(stuff_stock / stuff_count)):split(".")[1])

		if stuff_name == "" or stuff_buy == 0 then
			stuff["buy" ..i]=""
			stuff["name" ..i]=""
		else
			local def = minetest.registered_items[stuff_name] or minetest.registered_nodes[stuff_name] or minetest.registered_tools[stuff_name] or minetest.register_craftitems[stuff_name]
			if def and def.description then
				stuff["name"..i] = def.description
			elseif string.find(stuff["name" ..i],":")~=nil then
				stuff["name" ..i] = stuff["name" ..i].split(stuff["name" ..i],":")[2]
			end
			stuff["buy" ..i]="("..stuff_buy..") "
			stuff["name" ..i]=stuff["name" ..i] .."\n"
		end
	end
		meta:set_string("infotext", S("(Smartshop by @1) Purchases left:@n@2",
            owner, stuff.buy1 ..  stuff.name1
		.. stuff.buy2 ..  stuff.name2
		.. stuff.buy3 ..  stuff.name3
		.. stuff.buy4 ..  stuff.name4
		))
end

smartshop.update=function(pos,stat)
--clear
	local spos=minetest.pos_to_string(pos)
	for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
		if ob and ob:get_luaentity() and ob:get_luaentity().smartshop and ob:get_luaentity().pos==spos then
			ob:remove()	
		end
	end
	if stat=="clear" then return end
--update
	local meta=minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local node=minetest.get_node(pos)
	local dp = smartshop.dir[node.param2+1]
	if not dp then return end
	pos.x = pos.x + dp.x*0.01
	pos.y = pos.y + dp.y*6.5/16
	pos.z = pos.z + dp.z*0.01
	for i=1,4,1 do
		local item=inv:get_stack("give" .. i,1):get_name()
		local pos2=smartshop.dpos[node.param2+1][i]
		if item~="" then
			smartshop.tmp.item=item
			smartshop.tmp.pos=spos
			local e = minetest.add_entity({x=pos.x+pos2.x,y=pos.y+pos2.y,z=pos.z+pos2.z},"smartshop:item")
			e:set_yaw(math.pi*2 - node.param2 * math.pi/2)
		end
	end
end


minetest.register_entity("smartshop:item",{
	hp_max = 1,
	visual="wielditem",
	visual_size={x=.20,y=.20},
	collisionbox = {0,0,0,0,0,0},
	physical=false,
	textures={"air"},
	smartshop=true,
	type="",
	on_activate = function(self, staticdata)
		if smartshop.tmp.item ~= nil then
			self.item=smartshop.tmp.item
			self.pos=smartshop.tmp.pos
			smartshop.tmp={}
		else
			if staticdata ~= nil and staticdata ~= "" then
				local data = staticdata:split(';')
				if data and data[1] and data[2] then
					self.item = data[1]
					self.pos = data[2]
				end
			end
		end
		if self.item ~= nil then
			self.object:set_properties({textures={self.item}})
		else
			self.object:remove()
		end
	end,
	get_staticdata = function(self)
		if self.item ~= nil and self.pos ~= nil then
			return self.item .. ';' ..  self.pos
		end
		return ""
	end,
})


smartshop.showform=function(pos,player,re)
	local meta=minetest.get_meta(pos)
	local creative=meta:get_int("creative")
	local inv = meta:get_inventory()
	local gui=""
	local spos=pos.x .. "," .. pos.y .. "," .. pos.z
	local uname=player:get_player_name()
	local owner=meta:get_string("owner")==uname
	if minetest.check_player_privs(uname, {protection_bypass=true}) then owner=true end
	if re then owner=false end
	smartshop.user[uname]=pos
	if owner then
		if meta:get_int("type")==0 and not (minetest.check_player_privs(uname, {creative=true}) or minetest.check_player_privs(uname, {give=true})) then
			meta:set_int("creative",0)
			meta:set_int("type",1)
			creative=0
		end

		gui=""
		.."size[15,12]"

		.."button_exit[9,0;1.5,1;customer;" .. S("Customer") .. "]"
		-- .."button[10.2,0;1,1;sellall;" .. S("All") .. "]"
		.."label[3,0.2;" .. S("Item:") .. "]"
		.."label[3,1.2;" .. S("Price:") .. "]"
		.."list[nodemeta:" .. spos .. ";give1;4,0;1,1;]"
		.."list[nodemeta:" .. spos .. ";pay1;4,1;1,1;]"
		.."list[nodemeta:" .. spos .. ";give2;5,0;1,1;]"
		.."list[nodemeta:" .. spos .. ";pay2;5,1;1,1;]"
		.."list[nodemeta:" .. spos .. ";give3;6,0;1,1;]"
		.."list[nodemeta:" .. spos .. ";pay3;6,1;1,1;]"
		.."list[nodemeta:" .. spos .. ";give4;7,0;1,1;]"
		.."list[nodemeta:" .. spos .. ";pay4;7,1;1,1;]"

		if creative==1 then
			gui=gui .."label[3.5,-0.4;" .. S("Your stock is unlimited because you have creative or give") .. "]"
			.."button[9,1;2.2,1;toogleee;" .. S("Toogle limit") .."]"
		end
		gui=gui
		.."list[nodemeta:" .. spos .. ";main;0,2;15,6;]"
		.."list[current_player;main;3,8.2;8,4;]"
		.."listring[nodemeta:" .. spos .. ";main]"
		.."listring[current_player;main]"
	else
		gui=""
		.."size[8,6]"
		.."list[current_player;main;0,2.2;8,4;]"
		.."label[0,0.2;" .. S("Item:") .. "]"
		.."label[0,1.2;" .. S("Price:") .. "]"
		.."list[nodemeta:" .. spos .. ";give1;2,0;1,1;]"
		.."item_image_button[2,1;1,1;".. inv:get_stack("pay1",1):get_name() ..";buy1;\n\n\b\b\b\b\b" .. inv:get_stack("pay1",1):get_count() .."]"
		.."list[nodemeta:" .. spos .. ";give2;3,0;1,1;]"
		.."item_image_button[3,1;1,1;".. inv:get_stack("pay2",1):get_name() ..";buy2;\n\n\b\b\b\b\b" .. inv:get_stack("pay2",1):get_count() .."]"
		.."list[nodemeta:" .. spos .. ";give3;4,0;1,1;]"
		.."item_image_button[4,1;1,1;".. inv:get_stack("pay3",1):get_name() ..";buy3;\n\n\b\b\b\b\b" .. inv:get_stack("pay3",1):get_count() .."]"
		.."list[nodemeta:" .. spos .. ";give4;5,0;1,1;]"
		.."item_image_button[5,1;1,1;".. inv:get_stack("pay4",1):get_name() ..";buy4;\n\n\b\b\b\b\b" .. inv:get_stack("pay4",1):get_count() .."]"
	end
	minetest.after((0.1), function(gui)
		return minetest.show_formspec(player:get_player_name(), "smartshop.showform",gui)
	end, gui)
end

local inv_types = {
	pay1 = "pay", pay2 = "pay", pay3 = "pay", pay4 = "pay",
	give1 = "give", give2 = "give", give3 = "give", give4 = "give",
	main = "main"
}

local fake_take = function(inv, from_list, from_index, count_to_take)
	local fake_stack = inv:get_stack(from_list, from_index)
	fake_stack:take_item(count_to_take)
	inv:set_stack(from_list, from_index, fake_stack)
	return 0
end

local fake_put = function(inv, to_list, to_index, stack_to_put)
	inv:set_stack(to_list, to_index, stack_to_put)
	return 0
end

minetest.register_node("smartshop:shop", {
	description = S("Smartshop"),
	tiles = {"default_coral_skeleton.png^default_obsidian_glass.png"},
	use_texture_alpha = "opaque",
	groups = {choppy = 2, oddly_breakable_by_hand = 1,tubedevice = 1, tubedevice_receiver = 1,mesecon=2},
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.0,0.5,0.5,0.5}},
	paramtype2="facedir",
	paramtype = "light",
	sunlight_propagates = true,
	on_timer = function (pos, elapsed)
		if smartshop.mesecon then
			mesecon.receptor_off(pos)
		end
		return false
	end,
	tube = {insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local added = inv:add_item("main", stack)
			return added
		end,
		can_insert = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:room_for_item("main", stack)
		end,
		input_inventory = "main",
		connect_sides = {left = 1, right = 1, front = 1, back = 1, top = 1, bottom = 1}},
after_place_node = function(pos, placer)
		local meta=minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name())
		meta:set_string("infotext", S("Shop by: @1", placer:get_player_name()))
		meta:set_int("type",1)
		meta:set_int("sellall",1)
		if minetest.check_player_privs(placer:get_player_name(), {creative=true}) or minetest.check_player_privs(placer:get_player_name(), {give=true}) then
			meta:set_int("creative",1)
			meta:set_int("type",0)
			meta:set_int("sellall",0)
		end
	end,
on_construct = function(pos)
		local meta=minetest.get_meta(pos)
		meta:set_int("state", 0)
		local inv = meta:get_inventory()
		inv:set_size("main", smartshop_capacity)
		inv:set_size("give1", 1)
		inv:set_size("pay1", 1)
		inv:set_size("give2", 1)
		inv:set_size("pay2", 1)
		inv:set_size("give3", 1)
		inv:set_size("pay3", 1)
		inv:set_size("give4", 1)
		inv:set_size("pay4", 1)
	end,
on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		smartshop.showform(pos,player)
	end,

allow_metadata_inventory_put = function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local player_name = player:get_player_name()

	minetest.log("action", "SmartShop("..pos.x..","..pos.y..","..pos.z..") player "..player_name.." inventory put: "..stack:get_count().." of "..stack:get_name().." to list "..listname)
	if inv_types[listname] == "pay" then
		-- fake put to 'pay' slots
		return fake_put(meta:get_inventory(), listname, index, stack)
	elseif stack:get_wear() == 0 and (meta:get_string("owner") == player_name or minetest.check_player_privs(player_name, {protection_bypass=true})) then
		return stack:get_count()
	else
		return 0
	end
end,

allow_metadata_inventory_take = function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local player_name = player:get_player_name()

	minetest.log("action", "SmartShop("..pos.x..","..pos.y..","..pos.z..") player "..player_name.." inventory take: "..stack:get_count().." of "..stack:get_name().." from list "..listname)
	if inv_types[listname] == "pay" then
		-- fake take from 'pay' slots
		return fake_take(meta:get_inventory(), listname, index, stack:get_count())
	elseif stack:get_wear() == 0 and (meta:get_string("owner") == player_name or minetest.check_player_privs(player_name, {protection_bypass=true})) then
		return stack:get_count()
	else
		return 0
	end
end,

allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local player_name = player:get_player_name()
	minetest.log("action", "SmartShop("..pos.x..","..pos.y..","..pos.z..") player "..player_name.." inventory move: "..count.." of items from list "..from_list.." to list "..to_list)
	if meta:get_string("owner") == player_name or minetest.check_player_privs(player_name, {protection_bypass=true}) then
		if (inv_types[from_list] == "pay") == (inv_types[to_list] == "pay") then
			return count
		else
			minetest.chat_send_player(player_name, S("Price slots accept items only from the player's inventory or from other price slots!"))
		end
	end
	return 0
end,

can_dig = function(pos, player)
		local meta=minetest.get_meta(pos)
		local inv=meta:get_inventory()
		if ((meta:get_string("owner")==player:get_player_name() or minetest.check_player_privs(player:get_player_name(), {protection_bypass=true})) and inv:is_empty("main") and inv:is_empty("pay1") and inv:is_empty("pay2") and inv:is_empty("pay3") and inv:is_empty("pay4") and inv:is_empty("give1") and inv:is_empty("give2") and inv:is_empty("give3") and inv:is_empty("give4")) or meta:get_string("owner")=="" then
			smartshop.update(pos,"clear")
			return true
		end
	end,
})

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
