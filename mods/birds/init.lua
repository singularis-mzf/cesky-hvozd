ch_base.open_mod(minetest.get_current_modname())
local totalBirdCount = 0
local radiusRemove = 150
local radiusAdd = 100 --not used yet

local minBirds = tonumber(minetest.settings:get("birds.minBirds")) or 80
local maxSwarmSize = tonumber(minetest.settings:get("birds.maxSwarmSize")) or 9
local spawn_y_variance = 30
local spawn_y = tonumber(minetest.settings:get("birds.spawnAltitude")) or 60

local birdNames = {"black","blue","brown1","brown2","cardinal","eagle","red","robin","sparrow","white"}
local dropItem = nil

if minetest.get_modpath("mobs_animal") then
	dropItem = "mobs:chicken_raw"
elseif minetest.get_modpath("animalia") then
	dropItem = "animalia:poultry_raw"
else
	local game = minetest.get_game_info().id
	if game == "mineclone2" or game == "mineclonia" then
		dropItem = "mcl_mobitems:chicken"
	end
end

math.randomseed( os.time() )
local Bird = {
	speed = 5,
    initial_properties = {
        hp_max = 1,
        physical = true,
        collide_with_objects = false,
        collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
        visual = "mesh",
        mesh = "bird.b3d",
        visual_size = {x = 1, y = 1},		
		textures = {
			"birds_white_bottom.png",
			"birds_white_top.png",
			"birds_white_top.png",
			"birds_white_bottom.png",
		},
        static_save = false,
        automatic_face_movement_dir = false,
		--automatic_face_movement_max_rotation_per_sec = 100,
    },
    _target_rotation = nil,
	follow = nil,
	followers = {},
	time = 10,
	deletetimer = 0,
}

local function find(t, v)
	for i=1,#t do
		if t[i]==v then return i end
	end
	return nil
end

function Bird:updateObjSpeed()
	local obj = self.object
	obj:set_velocity(
		vector.rotate(
			vector.new(self.speed,0,0),
			obj:get_rotation()
		)
	)
end

local emptyTable = {}
function Bird:endRelations()
	if self.follow then
		local f = self.follow.followers
		table.remove(f,find(f,self))
	elseif #self.followers > 0 then
		local newLead = self.followers[1]
		newLead:endRelations()
		for k,v in ipairs(self.followers) do
			v.follow = newLead
		end
		newLead.followers = self.followers
	end
	
	self.follow = nil
	self.followers = emptyTable
end

function Bird:on_activate(staticdata, dtime_s)
	totalBirdCount = totalBirdCount + 1
	--~ minetest.chat_send_all("Bird added. New count: "..totalBirdCount)
	--self.object:set_rotation({0,0,math.pi/2})
	
	--fly in random direction
	local yaw = (math.random()*math.pi*2)
	self.object:set_rotation(vector.new(0,yaw,0))
	--self.object:set_animation({x=40,y=80},24,0,true)
	--self.object:set_animation({x=40,y=40})
	--local frame_range, frame_speed, frame_blend, frame_loop = self.object:get_animation()
	--minetest.chat_send_player("singleplayer",#frame_range)
	self:updateObjSpeed()
end

function Bird:on_deactivate(removal)
	if removal then
		self:endRelations()
		
		totalBirdCount = totalBirdCount - 1
		--~ minetest.chat_send_all("Bird deleted. New count: "..totalBirdCount)
	else
		if self.follow then
			self.follow:removeSwarm()
		else
			self:removeSwarm()
		end
	end
end

function Bird:on_punch(hitter)
    if dropItem then
		minetest.add_item(self.object:get_pos(),dropItem)
    end
end

--only to be called on leader
function Bird:removeSwarm()
	for _,b in ipairs(self.followers) do
		b.object:remove()
	end
	self.object:remove()
end

local rotation_speed = 2

local v_axis_x = {x=1,y=0,z=0}
local v_axis_y = {x=0,y=1,z=0}
local v_axis_z = {x=0,y=0,z=1}
function Bird:on_step(dtime, moveresult)
	local obj = self.object
	

	
	if not self.follow then --only leaders check for player distance
		self.deletetimer = self.deletetimer + dtime
		
		if self.deletetimer > 10 then
			local list = minetest.get_connected_players()
			if #list == 0 then
				self:removeSwarm()
				return
			else
				local nearPlayers = 0
				for _,p in ipairs(list) do
					if vector.distance( p:get_pos(), obj:get_pos() ) < radiusRemove then
						nearPlayers = nearPlayers + 1
					end
				end
				if nearPlayers == 0 then
					self:removeSwarm()
					return
				end
			end
			self.deletetimer = 0
		end
	end
	
	if moveresult.collides then
		self:endRelations()
		
		local c = moveresult.collisions
		
		local rot = obj:get_rotation()
		rot.y = rot.y+math.pi
		if rot.y > math.pi*2 then rot.y = rot.y - math.pi*2 end
		rot.z = 0
		obj:set_rotation(rot)
		
		self:updateObjSpeed()
	end

    self.time = self.time + dtime
	
	--~ print(dump(obj:get_rotation()))
	
	if self.follow then
		local vel = self.follow.object:get_velocity()
		if vel then --workaround to crash message "Invalid vector (expected table got no value)." from set_velocity
			obj:set_velocity(vel)
			obj:set_rotation(self.follow.object:get_rotation())
		end
	
	else
		if self._target_rotation then
			local current_rotation = obj:get_rotation()
			local target_rotation = self._target_rotation
			
			
			-- Calculate the difference between current and target rotation
			local diff = vector.subtract(target_rotation, current_rotation)

			-- Normalize the difference to avoid overshooting
			local length = vector.length(diff)
			if length < rotation_speed * dtime then
				obj:set_rotation(target_rotation)
				self._target_rotation = nil
			else
				-- Calculate the shortest path for yaw rotation
				local delta = target_rotation - current_rotation
				for i=1,3 do
					if delta[i] > math.pi then
						delta[i] = delta[i] - 2 * math.pi
					elseif delta[i] < -math.pi then
						delta[i] = delta[i] + 2 * math.pi
					end
				end
				-- Linear interpolation for each axis
				current_rotation = current_rotation + vector.multiply(delta, rotation_speed*dtime)


				obj:set_rotation(current_rotation)
			end
			self:updateObjSpeed()
		end
		
		if self.time >= rotation_speed+1 then
			self.time = 0
			local pos = obj:get_pos()
			local rotation = obj:get_rotation()
			local r = obj:get_rotation()
			
			local function raycastWithRotation(r,distance)
				return minetest.raycast(pos, vector.add(pos,vector.rotate(vector.new(distance,0,0),r)) ,false,true)
			end
			
			if raycastWithRotation(rotation,15):next() then --check if raycast hit anything, objects excluded because birds fly in swarms
				r.z = math.pi*2 -math.pi/2 + math.pi/6
				
				if not raycastWithRotation(r,25):next() then -- if it hits nothing looking upwards, rise
					self._target_rotation = r
					return
				end
				
				local r = vector.copy(rotation)
				r.y = r.y + math.pi/2
				r.y = r.y % (math.pi*2)
				
				if not raycastWithRotation(r,15):next() then -- if it hits nothing turing, turn
					self._target_rotation = r
					return
				end
				
				
				local r = vector.copy(rotation)
				r.y = r.y - math.pi/2
				r.y = r.y % (math.pi*2)
				
				if not raycastWithRotation(r,15):next() then -- if it hits nothing turing, turn
					self._target_rotation = r
					return
				end
			else
				r.z = 0
				if not raycastWithRotation(r,15):next() then -- if it hits nothing normalize
					self._target_rotation = r
					return
				end
				
				--turn randomly
				local r = vector.copy(rotation)
				r.y = r.y + (math.random()*2-1)*0.2
				r.y = r.y % (math.pi*2)
				return
			end
		end
	end
end

local function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

for _,birdName in ipairs(birdNames) do
	local b = copy(Bird)
	b.initial_properties.textures = {
			"birds_"..birdName.."_bottom.png",
			"birds_"..birdName.."_top.png",
			"birds_"..birdName.."_top.png",
			"birds_"..birdName.."_bottom.png",
		}
	minetest.register_entity("birds:"..birdName, b)

end

--[[
local groups_not_for_birds = {
	"cracky", "choppy", "crumbly", "oddly_breakable_by_hand"
}
local function is_name_for_birds(name)
	if name ~= nil then
		for _, group in ipairs(groups_not_for_birds) do
			if core.get_item_group(name, group) ~= 0 then
				return false
			end
		end
	end
	return true
end
]]

local shifts = {
	-- y = -10
	vector.new(0, -10, 0),
	vector.new(-20, -10, -20),
	vector.new(-20, -10, 0),
	vector.new(-20, -10, 20),
	vector.new(0, -10, -20),
	vector.new(0, -10, 20),
	vector.new(20, -10, -20),
	vector.new(20, -10, 0),
	vector.new(20, -10, 20),
	-- y = 0
	vector.new(-20, 0, -20),
	vector.new(-20, 0, 0),
	vector.new(-20, 0, 20),
	vector.new(0, 0, -20),
	vector.new(0, 0, 20),
	vector.new(20, 0, -20),
	vector.new(20, 0, 0),
	vector.new(20, 0, 20),
	-- y = 20
	vector.new(-20, 20, -20),
	vector.new(-20, 20, 0),
	vector.new(-20, 20, 20),
	vector.new(0, 20, -20),
	vector.new(0, 20, 0),
	vector.new(0, 20, 20),
	vector.new(20, 20, -20),
	vector.new(20, 20, 0),
	vector.new(20, 20, 20),
}

-- local vm_buffer = {}
local function is_place_for_birds(pos)
	local us = core.get_us_time()
	if core.get_node(pos).name ~= "air" then
		return false
	end
	core.load_area(vector.offset(pos, -20, -10, -20), vector.offset(pos, 20, 20, 20))
	for _, shift in ipairs(shifts) do
		local shifted_pos = vector.add(pos, shift)
		local is_free, pos2 = core.line_of_sight(pos, shifted_pos)
		if not is_free then
			-- print("DEBUG : "..core.pos_to_string(pos).." is not for birds because "..core.get_node(pos2).name.." at "..core.pos_to_string(pos2).."!")
			return false
		end
	end
	-- print("DEBUG : "..core.pos_to_string(pos).." is for birds after "..math.ceil((core.get_us_time() - us)).." us.")
	return true
end

local spawnOffsetMult = vector.new(20,4,20)
function spawnSwarm(pos)
	if not is_place_for_birds(pos) then
		pos.y = pos.y + 20
		if not is_place_for_birds(pos) then
			return false
		end
	end
	
	pos.x = pos.x + 3
	local b = "birds:"..birdNames[math.ceil(math.random()*#birdNames)]
	
	local leader = minetest.add_entity(pos,b)
	
	leader = leader:get_luaentity()
	for i=1,math.floor(math.random()*(maxSwarmSize-1)) do
		local e = minetest.add_entity(
			vector.add(
				pos,
				vector.multiply(vector.new(math.random()-0.5,math.random()-0.5,math.random()-0.5),spawnOffsetMult)
				),
			b
		)
		
		e = e:get_luaentity()
		e.follow = leader
		table.insert(leader.followers,e)
	end
	return true
end

local timeout = 0
local itable = {}

minetest.register_globalstep(function(dtime)
	timeout = timeout - dtime
	if timeout <= 0 and totalBirdCount < minBirds then
		local list = minetest.get_connected_players()
		if #list == 0 then timeout = 3 return end
		local p = list[math.ceil(math.random()*#list)]
		local pos = p:get_pos()
		
		if pos.y > spawn_y-80 and pos.y < 3000 then
			if pos.y > spawn_y then
				pos.y = pos.y + math.random()*spawn_y_variance*2 - spawn_y_variance
			else
				pos.y = math.max(pos.y,spawn_y) + math.random()*spawn_y_variance*2 -spawn_y_variance
			end
			pos.x = pos.x + (math.random()-0.5)*100
			pos.z = pos.z + (math.random()-0.5)*100
			if not spawnSwarm(pos) then timeout = 3 return end
		end
	end
end)
ch_base.close_mod(minetest.get_current_modname())
