ch_base.open_mod(minetest.get_current_modname())
local S = attrans

function round_down(pos)
   return {x=math.floor(pos.x), y=math.floor(pos.y), z=math.floor(pos.z)}
end

function round_new(vec)
	return {x=math.floor(vec.x+0.5), y=math.floor(vec.y+0.3), z=math.floor(vec.z+0.5)}
end

function parse_attributes(s)
	local result = {}
	if s then
		for _, full_part in ipairs(string.split(s, " ", false)) do
			local part = string.trim(full_part)
			result[string.lower(ch_core.odstranit_diakritiku(part))] = part
		end
	end
	return result
end

advtrains.register_wagon("construction_train", {
	mesh="advtrains_subway_wagon.b3d",
	textures = {"advtrains_subway_wagon.png"},
	drives_on={default=true},
	max_speed=2,
	seats = {
		{
			name=S("Driver stand"),
			attach_offset={x=0, y=10, z=0},
			view_offset={x=0, y=0, z=0},
			group="dstand",
		},
		{
			name="1",
			attach_offset={x=-4, y=8, z=8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=8, z=8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=8, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=8, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
	},
	seat_groups = {
		dstand={
			name = S("Driver Stand"),
			access_to = {"pass"},
			require_doors_open=true,
			driving_ctrl_access=true,
		},
		pass={
			name = S("Passenger area"),
			access_to = {"dstand"},
			require_doors_open=true,
		},
	},
	assign_to_seat_group = {"pass", "dstand"},
	doors={
		open={
			[-1]={frames={x=0, y=20}, time=1},
			[1]={frames={x=40, y=60}, time=1},
			sound = "advtrains_subway_dopen",
		},
		close={
			[-1]={frames={x=20, y=40}, time=1},
			[1]={frames={x=60, y=80}, time=1},
			sound = "advtrains_subway_dclose",
		}
	},
	door_entry={-1, 1},
	visual_size = {x=1, y=1},
	wagon_span=2,
	--collisionbox = {-1.0,-0.5,-1.8, 1.0,2.5,1.8},
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	is_locomotive=true,
	-- drops={"default:steelblock 4"},
	drops={"advtrains:construction_train"},
	horn_sound = "advtrains_subway_horn",
	custom_on_step = function (self, dtime)
		local train = self:train()
		if train.velocity == 0 then
			return
		end
		local command = train.text_inside or ""
		local command_cache = train.ch_command_cache
		local attributes
		if command_cache and command_cache.input == command then
			attributes = command_cache.output
		else
			attributes = parse_attributes(command)
			train.ch_command_cache = {input = command, output = attributes}
		end

		if attributes.vyp then -- "vyp" => disabled
			return
		end
		local rpos = round_new(self.object:get_pos())
		rpos.y = rpos.y -1
		-- Find train tracks, if we find train tracks, we will only replace blocking nodes
		local tracks_below = #(minetest.find_nodes_in_area(vector.offset(rpos, -1, -2, -2), vector.offset(rpos, 0, 2, 2), {"group:advtrains_track"})) > 0
		--[[ for y =-1,0 do
			for x = -2,2 do
				for z = -2,2 do
					local ps = {x=rpos.x+x, y=rpos.y+y, z=rpos.z+z}
					if minetest.get_item_group(minetest.get_node(ps).name, "advtrains_track") > 0 then
						tracks_below = true
						break
					end
				end
			end
		end ]]
		local gravel_node -- "železniční" => use railway_gravel
		if attributes.zeleznicni and minetest.registered_nodes["ch_core:railway_gravel"] then
			gravel_node = {name = "ch_core:railway_gravel"}
		else
			gravel_node = {name = "default:gravel"}
		end
		local cobble_node = {name = "default:cobble"}
		for x = -1,1 do
			for z = -1,1 do
				local ps = vector.offset(rpos, x, 0, z)
				local name = minetest.get_node(ps).name
				if (not tracks_below) or (minetest.get_item_group(name, "not_blocking_trains") ==  0 and minetest.registered_nodes[name].walkable) then
					minetest.set_node(ps, gravel_node)
					ps.y = ps.y-1
					if not minetest.registered_nodes[minetest.get_node(ps).name].walkable then
						minetest.set_node(ps, cobble_node)
					end
				end
			end
		end

		if not attributes.nechattravu then
			for x = -1,1 do
				for z = -1,1 do
					for y = 0,2 do
						local ps = vector.offset(rpos, x, y, z)
						local node = minetest.get_node_or_nil(ps)
						if node ~= nil and node.name ~= "air" then
							local ndef = minetest.registered_nodes[node.name]
							if ndef ~= nil and ndef.buildable_to then
								minetest.remove_node(ps)
								minetest.check_for_falling(ps)
							end
						end
					end
				end
			end
		end
	end,
	custom_on_velocity_change = function(self, velocity, old_velocity, dtime)
		if not velocity or not old_velocity then return end
		if old_velocity == 0 and velocity > 0 then
			minetest.sound_play("advtrains_subway_depart", {object = self.object})
		end
		if velocity < 2 and (old_velocity >= 2 or old_velocity == velocity) and not self.sound_arrive_handle then
			self.sound_arrive_handle = minetest.sound_play("advtrains_subway_arrive", {object = self.object})
		elseif (velocity > old_velocity) and self.sound_arrive_handle then
			minetest.sound_stop(self.sound_arrive_handle)
			self.sound_arrive_handle = nil
		end
		if velocity > 0 and (self.sound_loop_tmr or 0)<=0 then
			self.sound_loop_handle = minetest.sound_play({name="advtrains_subway_loop", gain=0.3}, {object = self.object})
			self.sound_loop_tmr=3
		elseif velocity>0 then
			self.sound_loop_tmr = self.sound_loop_tmr - dtime
		elseif velocity==0 then
			if self.sound_loop_handle then
				minetest.sound_stop(self.sound_loop_handle)
				self.sound_loop_handle = nil
			end
			self.sound_loop_tmr=0
		end
	end,
}, S("Construction train"), "advtrains_subway_wagon_inv.png")

minetest.register_craft({
	output = "advtrains:construction_train",
	recipe = {
		{"default:steelblock", "default:steelblock", "default:steelblock"},
		{"default:steelblock", "", "default:steelblock"},
		{"", "default:gravel", ""},
	},
})

ch_base.close_mod(minetest.get_current_modname())
