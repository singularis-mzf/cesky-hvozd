-- wagon.lua
-- Holds all logic related to wagons
-- From now on, wagons are, just like trains, just entries in a table
-- All data that is static is stored in the entity prototype (self).
--   A copy of the entity prototype is always available inside wagon_prototypes
-- All dynamic data is stored in the (new) wagons table
-- An entity is ONLY spawned by update_trainpart_properties when it finds it useful.
-- Only data that are only important to the entity itself are stored in the luaentity

-- TP delay when getting off wagon
local GETOFF_TP_DELAY = 0.25

local IGNORE_WORLD = advtrains.IGNORE_WORLD
local has_wielded_light = core.get_modpath("wielded_light")

advtrains.wagons = {}
advtrains.wagon_alias = {}
advtrains.wagon_prototypes = setmetatable({}, {
	__index = function(t, k)
		local _, proto = advtrains.resolve_wagon_alias(k)
		return proto
	end
})
advtrains.wagon_objects = {}

local unload_wgn_range = advtrains.wagon_load_range + 32
function advtrains.wagon_outside_range(pos) -- returns true if the object is outside of unload_wgn_range of any player
	return not advtrains.position_in_range(pos, unload_wgn_range)
end

local setting_show_ids = minetest.settings:get_bool("advtrains_show_ids")

--
function advtrains.create_wagon(wtype, owner)
	local new_id=advtrains.random_id()
	while advtrains.wagons[new_id] do new_id=advtrains.random_id() end
	local wgn = {}
	wgn.type = wtype
	wgn.seatp = {}
	wgn.owner = owner
	wgn.id = new_id
	---wgn.train_id = train_id   --- will get this via update_trainpart_properties
	advtrains.wagons[new_id] = wgn
	--atdebug("Created new wagon:",wgn)
	return new_id
end

local function make_inv_name(uid)
	return "detached:advtrains_wgn_"..uid
end


local wagon_base_initial_properties = {
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	--physical = true,
	visual = "mesh",
	mesh = "wagon.b3d",
	visual_size = {x=1, y=1},
	textures = {"black.png"},
	static_save=false,
}

local wagon = {
	is_wagon=true,
	wagon_span=1,--how many index units of space does this wagon consume
	wagon_width=3, -- Wagon width in meters
	has_inventory=false,
}


function wagon:train()
	local data = advtrains.wagons[self.id]
	return advtrains.trains[data.train_id]
end


function wagon:on_activate(sd_uid, dtime_s)
	if sd_uid~="" then
		--destroy when loaded from static block.
		self.object:remove()
		return
	end
	self.object:set_armor_groups({immortal=1})
end

local function invcallback(id, pname, rtallow, rtfail)
	local data = advtrains.wagons[id]
	if data and advtrains.check_driving_couple_protection(pname, data.owner, data.whitelist) then
		return rtallow
	end
	return rtfail
end

function wagon:set_id(wid)
	self.id = wid
	self.initialized = true
	
	local data = advtrains.wagons[self.id]
	advtrains.wagon_objects[self.id] = self.object
	
	--atdebug("Created wagon entity:",self.name," w_id",wid," t_id",data.train_id)
	
	if self.has_inventory then
		--to be used later
		local inv=minetest.get_inventory({type="detached", name="advtrains_wgn_"..self.id})
		-- create inventory, if not yet created
		if not inv then	
			inv=minetest.create_detached_inventory("advtrains_wgn_"..self.id, {
				allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
					return invcallback(wid, player:get_player_name(), count, 0)
				end,
				allow_put = function(inv, listname, index, stack, player)
					return invcallback(wid, player:get_player_name(), stack:get_count(), 0)
				end,
				allow_take = function(inv, listname, index, stack, player)
					return invcallback(wid, player:get_player_name(), stack:get_count(), 0)
				end
			})
			if data.ser_inv then
				advtrains.deserialize_inventory(data.ser_inv, inv)
			end
			if self.inventory_list_sizes then
				for lst, siz in pairs(self.inventory_list_sizes) do
					inv:set_size(lst, siz)
				end
			end
		end
	end
	self.door_anim_timer=0
	self.door_state=0
	
	minetest.after(0.2, function() self:reattach_all() end)
	
	
	
	if self.set_textures then
		self:set_textures(data)
	end
	
	if self.custom_on_activate then
		self:custom_on_activate()
	end
end

function wagon:get_staticdata()
	return "STATIC"
end

function wagon:ensure_init()
			-- Note: A wagon entity won't exist when there's no train, because the train is
			-- the thing that actually creates the entity
			-- Train not being set just means that this will happen as soon as the train calls update_trainpart_properties.
	if self.initialized and self.id then
		local data = advtrains.wagons[self.id]
		if data and data.train_id and self:train() then
			if self.noninitticks then self.noninitticks=nil end
			return true
		end
	end
	if not self.noninitticks then
		atwarn("wagon",self.id,"uninitialized init=",self.initialized)
		self.noninitticks=0
	end
	self.noninitticks=self.noninitticks+1
	if self.noninitticks>20 then
		atwarn("wagon",self.id,"uninitialized, removing")
		self:destroy()
	else
		self.object:set_velocity({x=0,y=0,z=0})
	end
	return false
end

function wagon:train()
	local data = advtrains.wagons[self.id]
	return advtrains.trains[data.train_id]
end

-- Remove the wagon
function wagon:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
		if not self:ensure_init() then return end
		
		local data = advtrains.wagons[self.id]
	
		if not puncher or not puncher:is_player() then
			return
		end
		if data.owner and puncher:get_player_name()~=data.owner and (not minetest.check_player_privs(puncher, {train_admin = true })) then
		   minetest.chat_send_player(puncher:get_player_name(), attrans("This wagon is owned by @1, you can't destroy it.", data.owner));
		   return
		end
		
		if self.custom_may_destroy then
			if not self.custom_may_destroy(self, puncher, time_from_last_punch, tool_capabilities, direction) then
				return
			end
		end
		local itemstack = puncher:get_wielded_item()
		-- WARNING: This part of the API is guaranteed to change! DO NOT USE!
		if self.set_livery and itemstack:get_name() == "bike:painter" then
			self:set_livery(puncher, itemstack, data)
			return
		end
		-- check whether wagon has an inventory. Is is empty?
		if self.has_inventory then
			local inv=minetest.get_inventory({type="detached", name="advtrains_wgn_"..self.id})
			if not inv then -- inventory is not initialized when wagon was never loaded - should never happen
				atwarn("Destroying wagon with inventory, but inventory is not found? Shouldn't happen!")
				return
			end
			for listname, _ in pairs(inv:get_lists()) do
				if not inv:is_empty(listname) then
					minetest.chat_send_player(puncher:get_player_name(), attrans("The wagon's inventory is not empty."));
					return
				end
			end
		end
		
		if #(self:train().trainparts)>1 then
		   minetest.chat_send_player(puncher:get_player_name(), attrans("Wagon needs to be decoupled from other wagons in order to destroy it."));
		   return
		end

		local pc=puncher:get_player_control()
		if not pc.sneak then
			minetest.chat_send_player(puncher:get_player_name(), attrans("Warning: If you destroy this wagon, you only get some steel back! If you are sure, hold Sneak and left-click the wagon."))
			return
		end
		
		
		if not self:destroy() then return end

		local inv = puncher:get_inventory()
		for _,item in ipairs(self.drops or {self.name}) do
			inv:add_item("main", item)
		end
end
function wagon:destroy()
	--some rules:
	-- you get only some items back
	-- single left-click shows warning
	-- shift leftclick destroys
	-- not when a driver is inside
	if self.id then
		local data = advtrains.wagons[self.id]
		if not data then
			atwarn("wagon:destroy(): data is not set!")
			return
		end
		
		if self.custom_on_destroy then
			self.custom_on_destroy(self)
		end
		
		for seat,_ in pairs(data.seatp) do
			self:get_off(seat)
		end
		
		if data.train_id and self:train() then
			advtrains.remove_train(data.train_id)
			advtrains.wagons[self.id]=nil
			if self.discouple then self.discouple.object:remove() end--will have no effect on unloaded objects
		end
	end
	--atdebug("[wagon ", self.id, "]: destroying")
	
	self.object:remove()
	return true
end

function wagon:is_driver_stand(seat)
	if self.seat_groups then
		return (seat.driving_ctrl_access or self.seat_groups[seat.group].driving_ctrl_access)
	else
		return seat.driving_ctrl_access
	end
	
end

function wagon:on_step(dtime)
		if not self:ensure_init() then return end
		
		if advtrains.is_no_action() then
			self.object:remove()
			return
		end
		
		local t=os.clock()
		local pos = self.object:get_pos()
		local data = advtrains.wagons[self.id]
		
		if not pos then
			--atdebug("["..self.id.."][fatal] missing position (object:get_pos() returned nil)")
			return
		end
		
		if not data.seatp then
			data.seatp={}
		end
		if not self.seatpc then
			self.seatpc={}
		end
		
		local train=self:train()
		
		local is_in_loaded_area = advtrains.is_node_loaded(pos)

		--custom on_step function
		if self.custom_on_step then
			self:custom_on_step(dtime, data, train)
		end
		if has_wielded_light and self.light_level ~= nil then
			wielded_light.track_user_entity(self.object, "wagon", string.format("ch_core:light_%02d", self.light_level))
		end

		--driver control
		for seatno, seat in ipairs(self.seats) do
			local pname=data.seatp[seatno]
			local driver=pname and minetest.get_player_by_name(pname)
			local has_driverstand = pname and advtrains.check_driving_couple_protection(pname, data.owner, data.whitelist)
			has_driverstand = has_driverstand and self:is_driver_stand(seat)
			if has_driverstand and driver then
				advtrains.update_driver_hud(driver:get_player_name(), self:train(), data.wagon_flipped)
			elseif driver then
				--only show the inside text
				local inside=self:train().text_inside or ""
				advtrains.set_trainhud(driver:get_player_name(), inside)
			end
			if driver and driver:get_player_control_bits()~=self.seatpc[seatno] then
				local pc=driver:get_player_control()
				self.seatpc[seatno]=driver:get_player_control_bits()
				
				if has_driverstand then
					--regular driver stand controls
					advtrains.on_control_change(pc, self:train(), data.wagon_flipped)
					--bordcom
					if pc.sneak and pc.jump then
						self:show_bordcom(data.seatp[seatno])
					end
					--sound horn when required
					if self.horn_sound and pc.aux1 and not pc.sneak and not self.horn_handle then
						self.horn_handle = minetest.sound_play(self.horn_sound, {
							object = self.object,
							gain = 1.0, -- default
							max_hear_distance = 128, -- default, uses an euclidean metric
							loop = true,
						})
					elseif not pc.aux1 and self.horn_handle then
						minetest.sound_stop(self.horn_handle)
						self.horn_handle = nil
					end
				else
					-- If on a passenger seat and doors are open, get off when W or D pressed.
					local pass = data.seatp[seatno] and minetest.get_player_by_name(data.seatp[seatno])
					if pass and self:train().door_open~=0 then
					local pc=pass:get_player_control()
						if pc.up or pc.down then
							self:get_off(seatno)
						end
					end
				end
				if pc.aux1 and pc.sneak then
					self:get_off(seatno)
				end
			end
		end

		--check infotext
		local outside=train.text_outside or ""
		if setting_show_ids then
			outside = outside .. "\nvlak:" .. data.train_id .. " vagon:" .. self.id .. " vlastník/ice:" .. ch_core.prihlasovaci_na_zobrazovaci(data.owner)
		end

		--show off-track information in outside text instead of notifying the whole server about this
		if train.off_track then
			outside = outside .."\n!!! Vlak mimo koleje !!!"
		end
		
		-- liquid container: display liquid contents in infotext
		if self.techage_liquid_capacity then
			if data.techage_liquid and data.techage_liquid.name then
				outside = outside .."\nKapalina: "..data.techage_liquid.name..", "..data.techage_liquid.amount.." jednotek"
			else
				outside = outside .."\nKapalina: empty"
			end
		end
		
		if self.infotext_cache~=outside  then
			self.object:set_properties({infotext=outside})
			self.infotext_cache=outside
		end
		
		local fct=data.wagon_flipped and -1 or 1
		
		--door animation
		if self.doors then
			if (self.door_anim_timer or 0)<=0 then
				local dstate = (train.door_open or 0) * fct
				if dstate ~= self.door_state then
					local at
					--meaning of the train.door_open field:
					-- -1: left doors (rel. to train orientation)
					--  0: closed
					--  1: right doors
					--this code produces the following behavior:
					-- if changed from 0 to +-1, play open anim. if changed from +-1 to 0, play close.
					-- if changed from +-1 to -+1, first close and set 0, then it will detect state change again and run open.
					if self.door_state == 0 then
						if self.doors.open.sound then minetest.sound_play(self.doors.open.sound, {object = self.object}) end
						at=self.doors.open[dstate]
						self.object:set_animation(at.frames, at.speed or 15, at.blend or 0, false)
						self.door_state = dstate
					else
						if self.doors.close.sound then minetest.sound_play(self.doors.close.sound, {object = self.object}) end
						at=self.doors.close[self.door_state or 1]--in case it has not been set yet
						self.object:set_animation(at.frames, at.speed or 15, at.blend or 0, false)
						self.door_state = 0
					end
					self.door_anim_timer = at.time
				end
			else
				self.door_anim_timer = (self.door_anim_timer or 0) - dtime
			end
		end
		
		--for path to be available. if not, skip step
		if not train.path or train.no_step then
			self.object:set_velocity({x=0, y=0, z=0})
			self.object:set_acceleration({x=0, y=0, z=0})
			return
		end
		if not data.pos_in_train then
			return
		end
		
		-- Calculate new position, yaw and direction vector
		-- note: "index" is needed to be the center index, required by door code
		local index = advtrains.path_get_index_by_offset(train, train.index, -data.pos_in_train)
		local pos, yaw, npos, npos2, vdir

		-- use new position logic?
		if self.wheel_positions then
			-- request two positions, calculate difference and yaw from this
			-- depending on flipstate, need to invert wheel pos indices -> wheelpos * fct
			local index1 = advtrains.path_get_index_by_offset(train, index, self.wheel_positions[1] * fct)
			local index2 = advtrains.path_get_index_by_offset(train, index, self.wheel_positions[2] * fct)
			local pos1 = advtrains.path_get_interpolated(train, index1)
			local pos2 = advtrains.path_get_interpolated(train, index2)
			npos = advtrains.path_get(train, atfloor(index)) -- need npos just for node loaded check
			-- calculate center of 2 positions and vdir vector
			-- if wheel positions are asymmetric, needs to weight by the difference!
			local fact = self.wheel_positions[1] / (self.wheel_positions[1]-self.wheel_positions[2])
			pos = {x=pos1.x-(pos1.x-pos2.x)*fact, y=pos1.y-(pos1.y-pos2.y)*fact, z=pos1.z-(pos1.z-pos2.z)*fact}
			if data.wagon_flipped then
				vdir = vector.normalize(vector.subtract(pos2, pos1))
			else
				vdir = vector.normalize(vector.subtract(pos1, pos2))
			end
			yaw = math.atan2(-vdir.x, vdir.z)
		else
			--old position logic (for small wagons): use center index and just get position
			pos, yaw, npos, npos2 = advtrains.path_get_interpolated(train, index)
			vdir = vector.normalize(vector.subtract(npos2, npos))
		end
		
		--automatic get_on
		--needs to know index and path
		if train.velocity==0 and self.door_entry and train.door_open and train.door_open~=0 then
			--using the mapping created by the trainlogic globalstep
			for i, ino in ipairs(self.door_entry) do
				--fct is the flipstate flag from door animation above
				local aci = advtrains.path_get_index_by_offset(train, index, ino*fct)
				local ix1, ix2 = advtrains.path_get_adjacent(train, aci)
				-- the two wanted positions are ix1 and ix2 + (2nd-1st rotated by 90deg)
				-- (x z) rotated by 90deg is (-z x)  (http://stackoverflow.com/a/4780141)
				local add = { x = (ix2.z-ix1.z)*train.door_open, y = 0, z = (ix1.x-ix2.x)*train.door_open }
				local pts1=vector.round(vector.add(ix1, add))
				local pts2=vector.round(vector.add(ix2, add))
				if minetest.get_item_group(minetest.get_node(pts1).name, "platform")>0 then
					local ckpts={
						pts1,
						pts2,
						vector.add(pts1, {x=0, y=1, z=0}),
						vector.add(pts2, {x=0, y=1, z=0}),
					}
					for _,ckpos in ipairs(ckpts) do
						local cpp=minetest.pos_to_string(ckpos)
						if advtrains.playersbypts[cpp] then
							self:on_rightclick(advtrains.playersbypts[cpp])
						end
					end
				end
			end
		end
		
		--checking for environment collisions(a 3x3 cube around the center)
		if not IGNORE_WORLD and is_in_loaded_area and not train.recently_collided_with_env then
			local collides=false
			local exh = self.extent_h or 1
			local exv = self.extent_v or 2
			for x=-exh,exh do
				for y=0,exv do
					for z=-exh,exh do
						local node=minetest.get_node_or_nil(vector.add(npos, {x=x, y=y, z=z}))
						if (advtrains.train_collides(node)) then
							collides=true
						end
					end
				end
			end
			if collides then
				-- screw collision mercy
				train.recently_collided_with_env=true
				train.velocity=0
				advtrains.atc.train_reset_command(train)
			end
		end
		
		-- Spawn discouple object when train stands, in all other cases remove it.
		-- FIX: Need to do this after the yaw calculation
		if train.velocity==0 and is_in_loaded_area and data.pos_in_trainparts and data.pos_in_trainparts>1 then
			if not self.discouple or not self.discouple.object:get_yaw() then
				atprint(self.id,"trying to spawn discouple")
				local dcpl_pos = vector.add(pos, {y=0, x=-math.sin(yaw)*self.wagon_span, z=math.cos(yaw)*self.wagon_span})
				local object=minetest.add_entity(dcpl_pos, "advtrains:discouple")
				if object then
					local le=object:get_luaentity()
					le.wagon=self
					--box is hidden when attached, so unuseful.
					--object:set_attach(self.object, "", {x=0, y=0, z=self.wagon_span*10}, {x=0, y=0, z=0})
					self.discouple=le
				end
			end
		else
			if self.discouple and self.discouple.object:get_yaw() then
				self.discouple.object:remove()
				atprint(self.id," removing discouple")
			end
		end

		-- object yaw (corrected by flipstate)
		local oyaw = yaw
		if data.wagon_flipped then
			oyaw = yaw + math.pi
		end
		
		--FIX: use index of the wagon, not of the train.
		local velocity = train.velocity * advtrains.global_slowdown
		local acceleration = (train.acceleration or 0) * (advtrains.global_slowdown*advtrains.global_slowdown)
		local velocityvec = vector.multiply(vdir, velocity)
		local accelerationvec = vector.multiply(vdir, acceleration)
		
		-- this timer runs off every 2 seconds.
		self.updatepct_timer=(self.updatepct_timer or 0)-dtime
		local updatepct_timer_elapsed = self.updatepct_timer<=0
		
		if updatepct_timer_elapsed then
			--restart timer
			self.updatepct_timer=2
			-- perform checks that are not frequently needed
			
			-- unload entity if out of range (because relevant pr won't be merged in engine)
			-- This is a WORKAROUND!
			local players_in = false
			for sno,pname in pairs(data.seatp) do
				if minetest.get_player_by_name(pname) then
					-- Fix: If the RTT is too high, a wagon might be recognized out of range even if a player sits in it
					-- (client updates position not fast enough)
					players_in = true
					break
				end
			end
			if not players_in then
				if advtrains.wagon_outside_range(pos) then
					--atdebug("wagon",self.id,"unloading (too far away)")
                    -- Workaround until minetest engine deletes attached sounds
                    if self.sound_loop_handle then
                        minetest.sound_stop(self.sound_loop_handle)
                    end
					self.object:remove()
				end
			end
		end
		
		local wagon_yaw_changed = not advtrains.yaw_equals(self.old_yaw, oyaw)

		if not self.old_velocity_vector 
				or not vector.equals(velocityvec, self.old_velocity_vector)
				or not self.old_acceleration_vector 
				or not vector.equals(accelerationvec, self.old_acceleration_vector)
				or wagon_yaw_changed
				or updatepct_timer_elapsed then--only send update packet if something changed
			
			self.object:set_pos(pos)
			self.object:set_velocity(velocityvec)
			self.object:set_acceleration(accelerationvec)
			
			if #self.seats > 0 and wagon_yaw_changed then
				if not self.player_yaw then
					self.player_yaw = {}
				end
				if not self.old_yaw then
					self.old_yaw=oyaw
				end
				for _,name in pairs(data.seatp) do
					local p = minetest.get_player_by_name(name)
					if p then
						if not self.turning then
							-- save player looking direction offset
							self.player_yaw[name] = p:get_look_horizontal()-self.old_yaw
						end
						-- set player looking direction using calculated offset
						p:set_look_horizontal((self.player_yaw[name] or 0)+oyaw)
					end
				end
				self.turning = true							 
			elseif not wagon_yaw_changed then
				-- train is no longer turning
				self.turning = false
			end
			
			if self.object.set_rotation then
                local pitch = math.atan2(vdir.y, math.hypot(vdir.x, vdir.z))
                if data.wagon_flipped then
                    pitch = -pitch
                end
                self.object:set_rotation({x=pitch, y=oyaw, z=0})
            else
                self.object:set_yaw(oyaw)
            end
			
			if self.update_animation then
				self:update_animation(train.velocity, self.old_velocity)
			end
			if self.custom_on_velocity_change then
				self:custom_on_velocity_change(train.velocity, self.old_velocity or 0, dtime)
			end
			-- remove discouple object, because it will be in a wrong location
			if not updatepct_timer_elapsed and self.discouple then
				self.discouple.object:remove()
			end
		end
		
		
		self.old_velocity_vector=velocityvec
		self.old_velocity = train.velocity
		self.old_acceleration_vector=accelerationvec
		self.old_yaw=oyaw
		atprintbm("wagon step", t)
end

function wagon:on_rightclick(clicker)
		if not self:ensure_init() then return end
		if not clicker or not clicker:is_player() then
			return
		end
		
		local data = advtrains.wagons[self.id]
		
		local pname=clicker:get_player_name()
		local no=self:get_seatno(pname)
		if no then
			if self.seat_groups then
				local poss={}
				local sgr=self.seats[no].group
				for _,access in ipairs(self.seat_groups[sgr].access_to) do
					if self:check_seat_group_access(pname, access) then
						poss[#poss+1]={name=self.seat_groups[access].name, key="sgr_"..access}
					end
				end
				if self.has_inventory and self.get_inventory_formspec and advtrains.check_driving_couple_protection(pname, data.owner, data.whitelist) then
					poss[#poss+1]={name=attrans("Show Inventory"), key="inv"}
				end
				if self.seat_groups[sgr].driving_ctrl_access and advtrains.check_driving_couple_protection(pname, data.owner, data.whitelist) then
					poss[#poss+1]={name=attrans("Onboard Computer"), key="bordcom"}
				end
				if data.owner==pname then
					poss[#poss+1]={name=attrans("Wagon properties"), key="prop"}
				end
				if not self.seat_groups[sgr].require_doors_open or self:train().door_open~=0 then
					poss[#poss+1]={name=attrans("Get off"), key="off"}
				else
					if clicker:get_player_control().sneak then
						poss[#poss+1]={name=attrans("Get off (forced)"), key="off"}
					else
						poss[#poss+1]={name=attrans("(Doors closed)"), key="dcwarn"}
					end
				end
				if #poss==0 then
					--can't do anything.
				elseif #poss==1 then
					self:seating_from_key_helper(pname, {[poss[1].key]=true}, no)
				else
					local form = "size[5,"..1+(#poss).."]"
					for pos,ent in ipairs(poss) do
						form = form .. "button_exit[0.5,"..(pos-0.5)..";4,1;"..ent.key..";"..ent.name.."]"
					end
					minetest.show_formspec(pname, "advtrains_seating_"..self.id, form)
				end
			else
				self:get_off(no)
			end
		else
			--do not attach if already on a train
			if advtrains.player_to_train_mapping[pname] then return end
			if self.seat_groups then
				if #self.seats==0 then
					if self.has_inventory and self.get_inventory_formspec and advtrains.check_driving_couple_protection(pname, data.owner, data.whitelist) then
						minetest.show_formspec(pname, "advtrains_inv_"..self.id, self:get_inventory_formspec(pname, make_inv_name(self.id)))
					end
					return
				end
				
				local doors_open = self:train().door_open~=0 or clicker:get_player_control().sneak
				local allow, rsn=false, attrans("This wagon has no seats.")
				for _,sgr in ipairs(self.assign_to_seat_group) do
					allow, rsn = self:check_seat_group_access(pname, sgr)
					if allow then
						for seatid, seatdef in ipairs(self.seats) do
							if seatdef.group==sgr then
								if (not self.seat_groups[sgr].require_doors_open or doors_open) then
									if not data.seatp[seatid] then
										self:get_on(clicker, seatid)
										return
									else
										rsn=attrans("This wagon is full.")
									end
								else
									rsn=attrans("Doors are closed! (try holding sneak key!)")
								end
							end
						end
					end
				end
				minetest.chat_send_player(pname, rsn or attrans("You can't get on this wagon."))
			else
				self:show_get_on_form(pname)
			end
		end
end

function wagon:get_on(clicker, seatno)
	
	local data = advtrains.wagons[self.id]
		
	if not data.seatp then data.seatp={}end
	if not self.seatpc then self.seatpc={}end--player controls in driver stands
	
	if not self.seats[seatno] then return end
	local oldno=self:get_seatno(clicker:get_player_name())
	if oldno then
		atprint("get_on: clearing oldno",seatno)
		advtrains.player_to_train_mapping[clicker:get_player_name()]=nil
		advtrains.clear_driver_hud(clicker:get_player_name())
		data.seatp[oldno]=nil
	end
	if data.seatp[seatno] and data.seatp[seatno]~=clicker:get_player_name() then
		atprint("get_on: throwing off",data.seatp[seatno],"from seat",seatno)
		self:get_off(seatno)
	end
	atprint("get_on: attaching",clicker:get_player_name())
	data.seatp[seatno] = clicker:get_player_name()
	self.seatpc[seatno] = clicker:get_player_control_bits()
	advtrains.player_to_train_mapping[clicker:get_player_name()]=data.train_id
	clicker:set_attach(self.object, "", self.seats[seatno].attach_offset, {x=0,y=0,z=0})
	clicker:set_eye_offset(self.seats[seatno].view_offset, self.seats[seatno].view_offset)
end
function wagon:get_off_plr(pname)
	local no=self:get_seatno(pname)
	if no then
		self:get_off(no)
	end
end
function wagon:get_seatno(pname)
	
	local data = advtrains.wagons[self.id]
	
	for no, cont in pairs(data.seatp) do
		if cont==pname then
			return no
		end
	end
	return nil
end
function wagon:get_off(seatno)
	
	local data = advtrains.wagons[self.id]
	
	if not data.seatp[seatno] then return end
	local pname = data.seatp[seatno]
	local clicker = minetest.get_player_by_name(pname)
	advtrains.player_to_train_mapping[pname]=nil
	advtrains.clear_driver_hud(pname)
	data.seatp[seatno]=nil
	self.seatpc[seatno]=nil
	if clicker then
		atprint("get_off: detaching",clicker:get_player_name())
		clicker:set_detach()
		clicker:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
		local train=self:train()
		--code as in step - automatic get on
		if self.door_entry and train.door_open and train.door_open~=0 and train.velocity==0 and train.index and train.path then
			local index = advtrains.path_get_index_by_offset(train, train.index, -data.pos_in_train)
			for i, ino in ipairs(self.door_entry) do
				--atdebug("using door-based",i,ino)
				local fct=data.wagon_flipped and -1 or 1
				local aci = advtrains.path_get_index_by_offset(train, index, ino*fct)
				local ix1, ix2 = advtrains.path_get_adjacent(train, aci)
				local d = train.door_open
				if self.wagon_width then
					d = d * math.floor(self.wagon_width/2)
				end
				-- the two wanted positions are ix1 and ix2 + (2nd-1st rotated by 90deg)
				-- (x z) rotated by 90deg is (-z x)  (http://stackoverflow.com/a/4780141)
				local add = { x = (ix2.z-ix1.z)*d, y = 0, z = (ix1.x-ix2.x)*d }
				local oadd = { x = (ix2.z-ix1.z)*(d+train.door_open), y = 1, z = (ix1.x-ix2.x)*(d+train.door_open)}
				local platpos=vector.round(vector.add(ix1, add))
				local offpos=vector.round(vector.add(ix1, oadd))
				
				--atdebug("platpos:", platpos, "offpos:", offpos)
				if minetest.get_item_group(minetest.get_node(platpos).name, "platform")>0 then
					minetest.after(GETOFF_TP_DELAY, function() clicker:set_pos(offpos) end)
					--atdebug("tp",offpos)
					return
				end
				--atdebug("nope")
			end
		end
		--if not door_entry, or paths missing, fall back to old method
		--atdebug("using fallback")
		local objpos=advtrains.round_vector_floor_y(self.object:get_pos())
		local yaw=self.object:get_yaw()
		local isx=(yaw < math.pi/4) or (yaw > 3*math.pi/4 and yaw < 5*math.pi/4) or (yaw > 7*math.pi/4)
		local offp
		--abuse helper function
		for _,r in ipairs({-1, 1}) do
			--atdebug("offset",r)
			local p=vector.add({x=isx and r or 0, y=0, z=not isx and r or 0}, objpos)
			offp=vector.add({x=isx and r*2 or 0, y=1, z=not isx and r*2 or 0}, objpos)
			--atdebug("platpos:", p, "offpos:", offp)
			if minetest.get_item_group(minetest.get_node(p).name, "platform")>0 then
				minetest.after(GETOFF_TP_DELAY, function() clicker:set_pos(offp) end)
				--atdebug("tp",offp)
				return
			end
		end
		--atdebug("nope")
		
	end
end
function wagon:show_get_on_form(pname)
	if not self.initialized then return end
	
	local data = advtrains.wagons[self.id]
	if #self.seats==0 then
		if self.has_inventory and self.get_inventory_formspec and advtrains.check_driving_couple_protection(pname, data.owner, data.whitelist) then
			minetest.show_formspec(pname, "advtrains_inv_"..self.id, self:get_inventory_formspec(pname, make_inv_name(self.id)))
		end
		return
	end
	local form, comma="size[5,8]label[0.5,0.5;"..attrans("Select seat:").."]textlist[0.5,1;4,6;seat;", ""
	for seatno, seattbl in ipairs(self.seats) do
		local addtext, colorcode="", ""
		if data.seatp and data.seatp[seatno] then
			colorcode="#FF0000"
			addtext=" ("..data.seatp[seatno]..")"
		end
		form=form..comma..colorcode..seattbl.name..addtext
		comma=","
	end
	form=form..";0,false]"
	if self.has_inventory and self.get_inventory_formspec then
		form=form.."button_exit[1,7;3,1;inv;"..attrans("Show Inventory").."]"
	end
	minetest.show_formspec(pname, "advtrains_geton_"..self.id, form)
end
function wagon:show_wagon_properties(pname)
	--[[
	fields: 
	field: driving/couple whitelist
	button: save
	]]
	local data = advtrains.wagons[self.id]
	local form="size[5,5]"
	form=form.."label[0.2,0;"..attrans("This Wagon ID")..": "..self.id.."]"
	form = form .. "field[0.5,1;4.5,1;whitelist;"..attrans("Allow these players to access your wagon:")..";"..minetest.formspec_escape(data.whitelist or "").."]"
	form = form .. "field[0.5,2;4.5,1;roadnumber;"..attrans("Wagon road number:")..";"..minetest.formspec_escape(data.roadnumber or "").."]"
	local fc = ""
	if data.fc then
		fc = table.concat(data.fc, "!")
	end
	form = form .. "field[0.5,3;4.5,1;fc;" .. attrans("Freight Code:") ..";"..fc.."]"
	if data.fc then
		if not data.fcind then data.fcind = 1 end
		if data.fcind > 1 then
			form=form.."button[0.5,3.5;1,1;fcp;" .. attrans("prev FC") .."]"
		end
		form=form.."label[1.5,3.5;" .. attrans("Current FC:").."]"

		local cur = data.fc[data.fcind] or ""
		form=form.."label[1.5,3.75;"..minetest.formspec_escape(cur).."]"
		form=form.."button[3.5,3.5;1,1;fcn;" .. attrans("next FC") .. "]"
	end
	form=form.."button_exit[0.5,4.5;4,1;save;"..attrans("Save wagon properties").."]"
	minetest.show_formspec(pname, "advtrains_prop_"..self.id, form)
end

--BordCom
local function checkcouple(ent)
	if not ent or not ent:get_yaw() then
		return nil
	end
	local le = ent:get_luaentity()
	if not le or not le.is_couple then
		return nil
	end
	return le
end
local function checklock(pname, own1, own2, wl1, wl2)
	return advtrains.check_driving_couple_protection(pname, own1, wl1)
		or advtrains.check_driving_couple_protection(pname, own2, wl2)
end

local function split(str, sep)
   local fields = {}
   local pattern = string.format("([^%s]+)", sep)
   str:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

function wagon.set_fc(data, fcstr)
	data.fc = split(fcstr, "!")
	if not data.fcind then
		data.fcind = 1
	elseif data.fcind > #data.fc then
		data.fcind = #data.fc
	end	
end

function wagon.prev_fc(data)
	if data.fcind > 1 then
		data.fcind = data.fcind -1
	end
	if data.fcind == 1 and data.fcrev then
		data.fcrev = nil
	end
end

function wagon.next_fc(data)
	if not data.fc then return end
	if data.fcrev then
		wagon.prev_fc(data)
		return
	end
	if data.fcind < #data.fc then
		data.fcind = data.fcind + 1
	else
		data.fcind = 1
	end
	if data.fcind == #data.fc and data.fc[data.fcind] == "?" then
		data.fcrev = true
		wagon.prev_fc(data)
		return			
	end
end

function advtrains.get_cur_fc(data)
	if not ( data.fc and data.fcind ) then
		return ""
	end
	return data.fc[data.fcind] or ""
end

function advtrains.step_fc(data)
	wagon.next_fc(data)
end


local function limit_text(t, limit)
	local tbl = t:split("\n")
	if #tbl <= limit then
		return t
	else
		for i = #t, limit + 1, -1 do
			tbl[i] = nil
		end
		return table.concat(tbl, "\n")
	end
end


function wagon:show_bordcom(pname)
	if not self:train() then return end
	local train = self:train()
	local data = advtrains.wagons[self.id]
	local linhei
	
	local form = "size[11,9]label[0.5,0;AdvTrains Boardcom v0.1]"
	form=form.."textarea[7.5,0.05;10,1;;"..attrans("Train ID")..": "..(minetest.formspec_escape(train.id or ""))..";]"
	form=form.."textarea[0.5,1.5;7,1;text_outside;"..attrans("Text displayed outside on train")..";"..(minetest.formspec_escape(train.text_outside or "")).."]"
	form=form.."textarea[0.5,3;7,1;text_inside;"..attrans("Text displayed inside train")..";"..(minetest.formspec_escape(train.text_inside or "")).."]"
	form=form.."field[7.5,1.75;3,1;line;"..attrans("Line")..";"..(minetest.formspec_escape(train.line or "")).."]"
	form=form.."field[7.5,3.25;3,1;routingcode;"..attrans("Routingcode")..";"..(minetest.formspec_escape(train.routingcode or "")).."]"
	--row 5 : train overview and autocoupling
	if train.velocity==0 then
		form=form.."label[0.5,4;"..attrans("Train overview/coupling control:").."]"
		linhei=5
		local pre_own, pre_wl, owns_any = nil, nil, minetest.check_player_privs(pname, "train_admin")
		for i, tpid in ipairs(train.trainparts) do
			local ent = advtrains.wagons[tpid]
			if ent then
				local roadnumber = ent.roadnumber or ""
				form = form .. string.format("button[%d,%d;%d,%d;%s;%s]", i, linhei, 1, 0.2, "wgprp"..i, roadnumber)
				local ename = ent.type
				form = form .. "item_image["..i..","..(linhei+0.5)..";1,1;"..ename.."]"
				if i~=1 then
					if checklock(pname, ent.owner, pre_own, ent.whitelist, pre_wl) then
						form = form .. "image_button["..(i-0.5)..","..(linhei+1.5)..";1,1;advtrains_discouple.png;dcpl_"..i..";]"
					end
				end
				if i == data.pos_in_trainparts then
					form = form .. "box["..(i-0.1)..","..(linhei+0.4)..";1,1;green]"
				end
				pre_own = ent.owner
				pre_wl = ent.whitelist
				owns_any = owns_any or (not ent.owner or ent.owner==pname)
			end
		end
		
		if train.movedir==1 then
			form = form .. "label["..(#train.trainparts+1)..","..(linhei)..";-->]"
		else
			form = form .. "label[0.5,"..(linhei)..";<--]"
		end
		--check cpl_eid_front and _back of train
		local couple_front = checkcouple(train.cpl_front)
		local couple_back = checkcouple(train.cpl_back)
		if couple_front then
			form = form .. "image_button[0.5,"..(linhei+1)..";1,1;advtrains_couple.png;cpl_f;]"
		end
		if couple_back then
			form = form .. "image_button["..(#train.trainparts+0.5)..","..(linhei+1)..";1,1;advtrains_couple.png;cpl_b;]"
		end
		
	else
		form=form.."label[0.5,4.5;" .. attrans("Train overview / coupling control is only shown when the train stands.") .. "]"
	end
	form = form .. "button[0.5,8;3,1;save;" .. attrans("Save") .. "]"
	
	-- Interlocking functionality: If the interlocking module is loaded, you can set the signal aspect
	-- from inside the train
	if advtrains.interlocking and train.lzb and #train.lzb.checkpoints > 0 then
		local i=1
		while train.lzb.checkpoints[i] do
			local oci = train.lzb.checkpoints[i]
			if oci.udata and oci.udata.signal_pos then
				if advtrains.interlocking.db.get_sigd_for_signal(oci.udata.signal_pos) then
					form = form .. "button[4.5,8;5,1;ilrs;" .. attrans("Remote Routesetting") .. "]"
					break
				end
			end
			i=i+1
		end
		if train.ars_disable then
			form = form .. "button[4.5,7;5,1;ilarsenable;" .. attrans("Clear 'Disable ARS' flag") .. "]"
		end
	end
	
	minetest.show_formspec(pname, "advtrains_bordcom_"..self.id, form)
end
function wagon:handle_bordcom_fields(pname, formname, fields)
	local data = advtrains.wagons[self.id]
	
	local seatno=self:get_seatno(pname)
	if not seatno or not self.seat_groups[self.seats[seatno].group].driving_ctrl_access or not advtrains.check_driving_couple_protection(pname, data.owner, data.whitelist) then
		return
	end
	local train = self:train()
	if not train then return end
	if fields.text_outside then
		if fields.text_outside~="" then
			train.text_outside = limit_text(fields.text_outside, 3)
		else
			train.text_outside=nil
		end
	end
	if fields.text_inside then
		if fields.text_inside~="" then
			train.text_inside = limit_text(fields.text_inside, 5)
		else
			train.text_inside=nil
		end
	end
	if fields.line then
		if fields.line~="" then
			if fields.line ~= train.line then
				train.line=fields.line
				minetest.after(0, advtrains.invalidate_path, train.id)
			end
		else
			train.line=nil
		end
	end
	if fields.routingcode then
		if fields.routingcode~="" then
			if fields.routingcode ~= train.routingcode then
				train.routingcode=fields.routingcode
				minetest.after(0, advtrains.invalidate_path, train.id)
			end
		else
			train.routingcode=nil
		end
	end
	for i, tpid in ipairs(train.trainparts) do
		if fields["dcpl_"..i] then
			advtrains.safe_decouple_wagon(tpid, pname)
		elseif fields["wgprp"..i] and data.owner==pname then
			local wagon = advtrains.get_wagon_entity(tpid)
			if wagon then
				wagon:show_wagon_properties(pname)
				return
			end
		end
	end
	--check cpl_eid_front and _back of train
	local couple_front = checkcouple(train.cpl_front)
	local couple_back = checkcouple(train.cpl_back)
	
	if fields.cpl_f and couple_front then
		couple_front:on_rightclick(pname)
	end
	if fields.cpl_b and couple_back then
		couple_back:on_rightclick(pname)
	end
	
	-- Interlocking functionality: If the interlocking module is loaded, you can set the signal aspect
	-- from inside the train
	if advtrains.interlocking then
		if fields.ilrs and train.lzb and #train.lzb.checkpoints > 0 then
			local i=1
			while train.lzb.checkpoints[i] do
				local oci = train.lzb.checkpoints[i]
				if oci.udata and oci.udata.signal_pos then
					local sigd = advtrains.interlocking.db.get_sigd_for_signal(oci.udata.signal_pos)
					if sigd then
						advtrains.interlocking.show_signalling_form(sigd, pname)
						return
					end
				end
				i=i+1
			end
		end
		if fields.ilarsenable then
			advtrains.interlocking.ars_set_disable(train, false)
		end
	end
	
	
	if not fields.quit then
		self:show_bordcom(pname)
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
		local uid=string.match(formname, "^advtrains_geton_(.+)$")
		if uid then
			local wagon = advtrains.get_wagon_entity(uid)
			if wagon then
				local data = advtrains.wagons[wagon.id]
				if fields.inv then
					if wagon.has_inventory and wagon.get_inventory_formspec then
						minetest.show_formspec(player:get_player_name(), "advtrains_inv_"..uid, wagon:get_inventory_formspec(player:get_player_name(), make_inv_name(uid)))
					end
				elseif fields.seat then
					local val=minetest.explode_textlist_event(fields.seat)
					if val and val.type~="INV" and not data.seatp[player:get_player_name()] then
					--get on
						wagon:get_on(player, val.index)
						--will work with the new close_formspec functionality. close exactly this formspec.
						minetest.show_formspec(player:get_player_name(), formname, "")
					end
				end
			end
			return true
		end

		uid=string.match(formname, "^advtrains_seating_(.+)$")
		if uid then
			local wagon = advtrains.get_wagon_entity(uid)
			if wagon then
				local pname=player:get_player_name()
				local no=wagon:get_seatno(pname)
				if no then
					if wagon.seat_groups then
						wagon:seating_from_key_helper(pname, fields, no)
					end
				end
			end
			return true
		end

		uid=string.match(formname, "^advtrains_prop_(.+)$")
		if uid then
			local pname=player:get_player_name()
			local data = advtrains.wagons[uid]
			if not data then
				return true
			elseif pname~=data.owner and not minetest.check_player_privs(pname, {train_admin = true}) then
				return true
			end
			if fields.save or not fields.quit then
				if fields.whitelist then
					data.whitelist = fields.whitelist
				end
				if fields.roadnumber then
					data.roadnumber = fields.roadnumber
				end
				if fields.fc then
					wagon.set_fc(data, fields.fc)
				end
				if fields.fcp then
					wagon.prev_fc(data)
					wagon.show_wagon_properties({id=uid}, pname)
				end
				if fields.fcn then
					advtrains.step_fc(data)
					wagon.show_wagon_properties({id=uid}, pname)
				end
			end
			return true
		end
		uid=string.match(formname, "^advtrains_bordcom_(.+)$")
		if uid then
			local wagon = advtrains.get_wagon_entity(uid)
			if wagon then
				wagon:handle_bordcom_fields(player:get_player_name(), formname, fields)
			end
			return true
		end

		uid=string.match(formname, "^advtrains_inv_(.+)$")
		if uid then
			local pname=player:get_player_name()
			local data = advtrains.wagons[uid]
			if fields.prop and data.owner==pname then
				local wagon = advtrains.get_wagon_entity(uid)
				if wagon then
					wagon:show_wagon_properties(pname)
					--wagon:handle_bordcom_fields(player:get_player_name(), formname, fields)
				end
			end
			return true
		end
end)

function wagon:seating_from_key_helper(pname, fields, no)
	local data = advtrains.wagons[self.id]
	local sgr=self.seats[no].group
	for _,access in ipairs(self.seat_groups[sgr].access_to) do
		if fields["sgr_"..access] and self:check_seat_group_access(pname, access) then
			for seatid, seatdef in ipairs(self.seats) do
				if seatdef.group==access and not data.seatp[seatid] then
					self:get_on(minetest.get_player_by_name(pname), seatid)
					return
				end
			end
		end
	end
	if fields.inv and self.has_inventory and self.get_inventory_formspec then
		minetest.close_formspec(pname, "advtrains_seating_"..self.id)
		minetest.after(0.1, minetest.show_formspec, pname, "advtrains_inv_"..self.id, self:get_inventory_formspec(pname, make_inv_name(self.id)))
	end
	if fields.prop and data.owner==pname then
		minetest.close_formspec(pname, "advtrains_seating_"..self.id)
		minetest.after(0.1, function(pn) self:show_wagon_properties(pn) end, pname)
	end
	if fields.bordcom and self.seat_groups[sgr].driving_ctrl_access and advtrains.check_driving_couple_protection(pname, data.owner, data.whitelist) then
		minetest.close_formspec(pname, "advtrains_seating_"..self.id)
		minetest.after(0.1, function(pn) self:show_bordcom(pn) end, pname)
	end
	if fields.dcwarn then
		minetest.chat_send_player(pname, attrans("Doors are closed! Use Sneak+rightclick to ignore the closed doors and get off!"))
	end
	if fields.off then
		self:get_off(no)
	end
end
function wagon:check_seat_group_access(pname, sgr)
	local data = advtrains.wagons[self.id]
	if self.seat_groups[sgr].driving_ctrl_access and not (advtrains.check_driving_couple_protection(pname, data.owner, data.whitelist)) then
		return false, attrans("You are not allowed to access the driver stand.")
	end
	if self.seat_groups[sgr].driving_ctrl_access then
		advtrains.log("Drive", pname, self.object:get_pos(), self:train().text_outside)
	end
	return true
end
function wagon:reattach_all()
	local data = advtrains.wagons[self.id]
	if not data.seatp then data.seatp={} end
	for seatno, pname in pairs(data.seatp) do
		local p=minetest.get_player_by_name(pname)
		if p then
			self:get_on(p ,seatno)
		end
	end
end

function advtrains.safe_decouple_wagon(w_id, pname, try_run)
	if not minetest.check_player_privs(pname, "train_operator") then
		minetest.chat_send_player(pname, attrans("Missing train_operator privilege"))
		return false
	end
	local data = advtrains.wagons[w_id]
	
	local dpt = data.pos_in_trainparts
	if not dpt or dpt <= 1 then
		return false
	end
	local train = advtrains.trains[data.train_id]
	local owid = train.trainparts[dpt-1]
	local owdata = advtrains.wagons[owid]
	
	if not owdata then
		return
	end
	
	if not checklock(pname, data.owner, owdata.owner, data.whitelist, owdata.whitelist) then
		minetest.chat_send_player(pname, attrans("Not allowed to do this."))
		return false
	end
	
	if try_run then
		return true
	end
	
	advtrains.log("Discouple", pname, train.last_pos, train.text_outside)
	advtrains.split_train_at_wagon(w_id)
	return true
end



function advtrains.get_wagon_prototype(data)
	local wt = data.type
	if not wt then
		-- LEGACY: Field was called "entity_name" in previous versions
		wt = data.entity_name
		data.type = data.entity_name
		data.entity_name = nil
	end
	local rt, proto = advtrains.resolve_wagon_alias(wt)
	if not rt then
		--atwarn("Unable to load wagon type",wt,", using placeholder")
		rt = "advtrains:wagon_placeholder"
		proto = advtrains.wagon_prototypes[rt]
	end
	return rt, proto
end

function advtrains.register_wagon_alias(src, dst)
	advtrains.wagon_alias[src] = dst
end

local function recursive_resolve_alias(name, seen)
	local prototype = rawget(advtrains.wagon_prototypes, name)
	if prototype then
		return name, prototype
	end
	local resolved = advtrains.wagon_alias[name]
	if resolved and not seen[resolved] then
		seen[name] = true
		return recursive_resolve_alias(resolved, seen)
	end
end

function advtrains.resolve_wagon_alias(name)
	return recursive_resolve_alias(name, {})
end

function advtrains.standard_inventory_formspec(self, pname, invname)
	--[[minetest.chat_send_player(pname, string.format("self=%s, pname=%s, invname=%s", self, pname, invname))
	for k,v in pairs(self) do
		minetest.chat_send_player(pname, string.format("%s=%s", k,v))
	end
	minetest.chat_send_player(pname, string.format("***%s***", self.object:get_pos()))--]]
	local data = advtrains.wagons[self.id]
	local r = "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"
	if data.owner==pname then
		r = r .. "button_exit[0,9;4,1;prop;"..attrans("Wagon properties").."]"
	end
	r = r .. "list[current_player;main;0,5;8,4;]"..
			"listring[]"
	return r
end

function advtrains.register_wagon(sysname_p, prototype, desc, inv_img, nincreative)
	local sysname = sysname_p
	if not string.match(sysname, ":") then
		sysname = "advtrains:"..sysname_p
	end
	ch_core.upgrade_entity_properties(prototype, {keep_fields = false, base_properties = wagon_base_initial_properties})
	if prototype.initial_properties ~= nil then
		local ip = prototype.initial_properties
		if ip.selectionbox == nil or ip.selectionbox.rotate == nil then
			assert(prototype.wagon_span ~= nil)
			assert(type(prototype.wagon_span) == "number")
			local wagon_span = prototype.wagon_span
			ip.selectionbox = {-0.9, 0, -wagon_span + 0.25, 0.9, 2.25, wagon_span - 0.25, rotate = true}
		end
	end
	setmetatable(prototype, {__index=wagon})
	minetest.register_entity(":"..sysname,prototype)
	advtrains.wagon_prototypes[sysname] = prototype
	
	--group classification to make recipe searching easier
	local wagon_groups = {
		not_in_creative_inventory = nincreative and 1 or 0,
		at_wagon = 1,
	}
	if prototype.is_locomotive then
		wagon_groups['at_loco'] = 1
	end
	if prototype.seat_groups then
		if prototype.seat_groups.dstand then wagon_groups['at_control'] = 1 end
		if prototype.seat_groups.pass then wagon_groups['at_pax'] = 1 end
	end
	if prototype.has_inventory then wagon_groups['at_freight'] = 1 end

	local max_speed = tonumber(prototype.max_speed) or 20

	minetest.register_craftitem(":"..sysname, {
		description = desc,
		inventory_image = inv_img,
		wield_image = inv_img,
		stack_max = 1,
		_ch_help = "max. rychlost vozu: "..max_speed,
		
		groups = wagon_groups,

		on_place = function(itemstack, placer, pointed_thing)
				if pointed_thing.type ~= "node" then
					return
				end

				local pos = pointed_thing.under
				local node = minetest.get_node(pos)
				local pointed_def = minetest.registered_nodes[node.name]
				if pointed_def and pointed_def.on_rightclick then
					local controls = placer:get_player_control()
					if not controls.sneak then
						return pointed_def.on_rightclick(pos, node, placer, itemstack, pointed_thing)
					end
				end

				local pname = placer:get_player_name()

				if node.name == "ignore" then atprint("[advtrains]Ignore at placer position") return itemstack end
				local nodename=node.name
				if(not advtrains.is_track(nodename)) then
					atprint("no track here, not placing.")
					return itemstack
				end
				if not minetest.check_player_privs(placer, {train_operator = true }) then
					minetest.chat_send_player(pname, attrans("You don't have the train_operator privilege."))
					return itemstack
				end
				if not minetest.check_player_privs(placer, {train_admin = true }) and minetest.is_protected(pos, placer:get_player_name()) then
					return itemstack
				end
				local tconns=advtrains.get_track_connections(node.name, node.param2)
				local yaw = placer:get_look_horizontal()
				local plconnid = advtrains.yawToClosestConn(yaw, tconns)
				
				local prevpos = advtrains.get_adjacent_rail(pointed_thing.under, tconns, plconnid, prototype.drives_on)
				if not prevpos then
					minetest.chat_send_player(pname, attrans("The track you are trying to place the wagon on is not long enough!"))
					return
				end
				
				local wid = advtrains.create_wagon(sysname, pname)
				
				local id=advtrains.create_new_train_at(pos, plconnid, 0, {wid})
				
				if not advtrains.is_creative(pname) then
					itemstack:take_item()
				end
				return itemstack
		end,
	})
end

-- Placeholder wagon. Will be spawned whenever a mod is missing
advtrains.register_wagon("advtrains:wagon_placeholder", {
	visual="sprite",
	textures = {"advtrains_wagon_placeholder.png"},
	collisionbox = {-0.3,-0.3,-0.3, 0.3,0.3,0.3},
	visual_size = {x=0.7, y=0.7},
	initial_sprite_basepos = {x=0, y=0},
	max_speed = 5,
	seats = {
	},
	seat_groups = {
	},
	assign_to_seat_group = {},
	wagon_span=1,
	drops={},
}, "Wagon placeholder", "advtrains_wagon_placeholder.png", true)



-- Helper function to retrieve the wagon at a certain position in a train, given its train ID and the desired index within that train's path
--
-- Returns: wagon_num, wagon_id, wagon_data, offset_from_center
-- wagon_num: The n'th wagon in the train (index into "trainparts" table)
-- wagon_id: The wagon ID. Obtain wagon data from advtrains.wagons[wagon_id], and subsequently the wagon prototype via advtrains.get_wagon_prototype(data)
-- offset_from_center: The offset (an absolute distance value) from the center point of the wagon. Positive is towards the end of the train, negative towards the start. (note that this is inverse to the counting direction of the index!)
--
--[[ To get the wagon standing at a certain world position, you first need to retrieve the index via the occupation table, as follows:
	local trains = advtrains.occ.get_trains_at(pos)
	for train_id, index in pairs(trains) do
		local wagon_num, wagon_id, wagon_data, offset_from_center = advtrains.get_wagon_at_index(train_id, index)
		if wagon_num then
			...
		end
	end
]]--
function advtrains.get_wagon_at_index(train_id, w_index)
	local train = advtrains.trains[train_id]
	if not train then error("Passed train id "..train_id.." doesnt exist") end
	-- ensure init - always required
	advtrains.train_ensure_init(train_id, train)
	-- Use path dist to determine the offset from the start of the train
	local dstart = advtrains.path_get_path_dist_fractional(train, train.index)
	local dtarget = advtrains.path_get_path_dist_fractional(train, w_index)
	local dist_from_start = dstart - dtarget -- NOTE: dist_from_start is supposed to be positive, but dtarget will be smaller than dstart
	-- if dist_from_start is <0, we are outside of train
	if dist_from_start < 0 then
		return nil
	end
	-- scan over wagons to see if dist_from_start falls into its window
	local start_pos = 0
	local center_pos
	local end_pos
	local i = 1
	while train.trainparts[i] do
		local w_id = train.trainparts[i]
		-- get wagon prototype to retrieve wagon span
		local wdata = advtrains.wagons[w_id]
		if wdata then
			local wtype, wproto = advtrains.get_wagon_prototype(wdata)
			local wagon_span = wproto.wagon_span
			-- determine center and end pos
			center_pos = start_pos + wagon_span
			end_pos = center_pos + wagon_span
			if start_pos <= dist_from_start and dist_from_start < end_pos then
				-- Found the correct wagon in the train!
				local offset_from_center = dist_from_start - center_pos
				return i, w_id, wdata, offset_from_center
			end
			-- go on
			start_pos = end_pos
		else
			error("Wagon "..w_id.." from train "..train_id.." doesnt exist!")
		end
		i = i + 1
	end
	-- nothing found, dist must be further back
	return nil
end

function advtrains.get_wagon_entity(wagon_id)
	if not advtrains.wagons[wagon_id] then return end
	local object = advtrains.wagon_objects[wagon_id]
	if object then
		return object:get_luaentity()
	end
end

function advtrains.next_wagon_entity_in_train(train, i)
	local wagon_id = train.trainparts[i + 1]
	if wagon_id then
		local wagon = advtrains.get_wagon_entity(wagon_id)
		if wagon then
			return i + 1, wagon
		end
	end
end

function advtrains.wagon_entity_pairs_in_train(train_id)
	local train = advtrains.trains[train_id]
	if not train then return function() end end
	return advtrains.next_wagon_entity_in_train, train, 0
end
