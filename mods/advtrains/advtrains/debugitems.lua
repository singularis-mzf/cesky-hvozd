minetest.register_tool("advtrains:tunnelborer",
{
	description = "tunnelborer",
	groups = {cracky=1}, -- key=name, value=rating; rating=1..3.
	inventory_image = "drwho_screwdriver.png",
	wield_image = "drwho_screwdriver.png",
	stack_max = 1,
	range = 7.0,
		
	on_place = function(itemstack, placer, pointed_thing)
	
	end,
	--[[
	^ Shall place item and return the leftover itemstack
	^ default: minetest.item_place ]]
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" then
			for x=-1,1 do
				for y=-1,1 do
					for z=-1,1 do
						minetest.remove_node(vector.add(pointed_thing.under, {x=x, y=y, z=z}))
					end
				end
			end
		end
	end,
}
)

minetest.register_chatcommand("atyaw",
	{
        params = "angledeg conn1 conn2", 
        description = "", 
        func = function(name, param)
			local angledegs, conn1s, conn2s = string.match(param, "^(%S+)%s(%S+)%s(%S+)$")
			if angledegs and conn1s and conn2s then
				local angledeg, conn1, conn2 = angledegs+0,conn1s+0,conn2s+0
				local yaw = angledeg*math.pi/180
				local yaw1 = advtrains.dir_to_angle(conn1)
				local yaw2 = advtrains.dir_to_angle(conn2)
				local adiff1 = advtrains.minAngleDiffRad(yaw, yaw1)
				local adiff2 = advtrains.minAngleDiffRad(yaw, yaw2)
				
				atdebug("yaw1",atfloor(yaw1*180/math.pi))
				atdebug("yaw2",atfloor(yaw2*180/math.pi))
				atdebug("dif1",atfloor(adiff1*180/math.pi))
				atdebug("dif2",atfloor(adiff2*180/math.pi))
				
				minetest.chat_send_all(advtrains.yawToAnyDir(yaw))
				return true, advtrains.yawToDirection(yaw, conn1, conn2)
			end
        end,
})
	
minetest.register_tool("advtrains:wagonpos_tester",
{
	description = "Wagon position tester",
	groups = {cracky=1}, -- key=name, value=rating; rating=1..3.
	inventory_image = "drwho_screwdriver.png",
	wield_image = "drwho_screwdriver.png",
	stack_max = 1,
	range = 7.0,
		
	on_place = function(itemstack, placer, pointed_thing)
	
	end,
	--[[
	^ Shall place item and return the leftover itemstack
	^ default: minetest.item_place ]]
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" then
			local pos = pointed_thing.under
			local trains = advtrains.occ.get_trains_at(pos)
			for train_id, index in pairs(trains) do
				local wagon_num, wagon_id, wagon_data, offset_from_center = advtrains.get_wagon_at_index(train_id, index)
				if wagon_num then
					atdebug(wagon_num, wagon_id, offset_from_center)
				end
			end
		end
	end,
}
)


local function trackitest(initial_pos, initial_connid)
	local ti, pos, connid, ok
	ti = advtrains.get_track_iterator(initial_pos, initial_connid, 500, true)
	atdebug("Starting at pos:",initial_pos,initial_connid)
	while ti:has_next_branch() do
		pos, connid = ti:next_branch() -- in first iteration, this will be the node at initial_pos. In subsequent iterations this will be the switch node from which we are branching off
		atdebug("Next Branch:",pos, connid)
		ok = true
		while ok do
			ok, pos, connid = ti:next_track()
			atdebug("Next Track:", ok, pos, connid)
		end
	end
	atdebug("End of traverse. Visited: ",table.concat(ti.visited, ","))
end

minetest.register_tool("advtrains:trackitest",
{
	description = "Track Iterator Tester (leftclick conn 1, rightclick conn 2)",
	groups = {cracky=1}, -- key=name, value=rating; rating=1..3.
	inventory_image = "advtrains_track_swlcr_45.png",
	wield_image = "advtrains_track_swlcr_45.png",
	stack_max = 1,
	range = 7.0,
		
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then return end
		trackitest(pointed_thing.under, 2)
	end,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then return end
		trackitest(pointed_thing.under, 1)
	end,
}
)

minetest.register_chatcommand("at_trackdef_audit",
	{
        params = "", 
        description = "Performs an audit of all track definitions currently loaded and checks for potential problems", 
        func = function(name, param)
			for name, ndef in pairs(minetest.registered_nodes) do
				--TODO finish this!
				if ndef.at_conns then
					-- check if conn_map is there and if it has enough entries
					if #ndef.at_conns > 2 then
						if #ndef.at_conn_map < #ndef.at_conns then
							atwarn("AUDIT: Node",name,"- Not enough connmap entries! Check ndef:",ndef)
						end
					end
				end
			end
        end,
})
