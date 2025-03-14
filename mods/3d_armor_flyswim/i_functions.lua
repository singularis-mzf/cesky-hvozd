------------------------------------------------------------------
-- ___________                   __  .__                        --
-- \_   _____/_ __  ____   _____/  |_|__| ____   ____   ______  --
--  |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/  --
--  |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \   --
--  \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >  --
--      \/             \/     \/                    \/     \/   --
------------------------------------------------------------------

----------------------------------------
-- Get Player model and textures

function armor_fly_swim.get_player_model()
	
	local player_mod = "character_sf.b3d"              		-- Swim, Fly
	local texture = {"character.png", 
	                 "3d_armor_trans.png"}

	if armor_fly_swim.is_3d_armor and 
	   not armor_fly_swim.add_capes and 
	   not armor_fly_swim.is_skinsdb  then
	   
		player_mod = "3d_armor_character_sf.b3d"            -- Swim Fly
		texture = {armor.default_skin..".png", 
			       "3d_armor_trans.png", 
				   "3d_armor_trans.png"}
	end

	if armor_fly_swim.is_3d_armor and 
	   armor_fly_swim.add_capes and 
	   not armor_fly_swim.is_skinsdb then
	   
		player_mod = "3d_armor_character_sfc.b3d"			-- Swim Fly Capes
		texture = {armor.default_skin..".png", 
		           "3d_armor_trans.png", 
				   "3d_armor_trans.png"}
	end

	if armor_fly_swim.is_skinsdb then 
		player_mod = "skinsdb_3d_armor_character_5.b3d"		-- Swim Fly Capes
		texture = {"blank.png", 
		           "blank.png", 
				   "blank.png", 
				   "blank.png"}
	end	

	return player_mod,texture
end

----------------------------------------
-- Get WASD, pressed = true 

function armor_fly_swim.get_wasd_state(controls)

	local rtn = false 
	
	if controls.up == true or                                 
       controls.down == true or                          
	   controls.left == true or 
	   controls.right == true then
	   
		rtn = true
	end
	
	return rtn
end

----------------------------------------
-- Check specific node fly/swim       --
-- 1=player feet, 2=one below feet,   --
--          Thanks Gundul             -- 
----------------------------------------
function node_fsable(pos,num,type)
	
	local draw_ta = {"airlike"}
	local draw_tl = {"liquid","flowingliquid"}
	local compare = draw_ta
	local node = minetest.get_node({x=pos.x,y=pos.y-(num-1),z=pos.z})
	local n_draw
	
	if minetest.registered_nodes[node.name] then
		n_draw = minetest.registered_nodes[node.name].drawtype
	else
		n_draw = "normal"
	end
	
		if type == "s" then
			compare = draw_tl
		end
		
		for k,v in ipairs(compare) do		 
			if n_draw == v then
				return true
			end
		end
	return false
end

-- hash/num/type => {}
local node_down_fsable_cache = {}
local node_down_fsable_cache_old = node_down_fsable_cache
local node_down_fsable_cache_expiration = 0

-----------------------------------------------
--  Check X number nodes down fly/Swimmable  --
-----------------------------------------------
function node_down_fsable(pos,num,type)
	pos = vector.round(pos)
	local now = minetest.get_us_time()
	-- cache rolling
	if now > node_down_fsable_cache_expiration then
		node_down_fsable_cache_old = node_down_fsable_cache
		node_down_fsable_cache = {}
		node_down_fsable_cache_expiration = now + 60000000
	end
	local cache_key = minetest.hash_node_position(pos).."/"..num.."/"..type
	local cached_result = node_down_fsable_cache[cache_key]
	if cached_result == nil then
		cached_result = node_down_fsable_cache_old[cache_key]
	end
	if cached_result ~= nil then
		return cached_result -- cache hit
	end

	-- cache miss
	local draw_ta = {"airlike"}
	local draw_tl = {"liquid","flowingliquid"}
	local i
	local nodes = {}
	local result = {}
	local compare = draw_ta

	local raycast = Raycast(vector.offset(pos, 0, 0.1, 0), vector.offset(pos, 0, -num, 0), false, true)
	local raycast_result = raycast:next()
	local raycast_cache = {}

	while raycast_result ~= nil do
		local y = raycast_result.under.y
		if raycast_result.type == "node" and raycast_cache[y] == nil then
			raycast_cache[y] = raycast_result.under
		end
		raycast_result = raycast:next()
	end

	for i = 0, num - 1 do
		local y = pos.y - i
		local lpos = raycast_cache[y] or vector.new(pos.x, y, pos.z)
		table.insert(nodes, minetest.get_node(lpos))
	end

	if type == "s" then
		compare = draw_tl
	end

	local n_draw
	for k,v in pairs(nodes) do
		local n_draw
		
		if minetest.registered_nodes[v.name] then
			n_draw = minetest.registered_nodes[v.name].drawtype
		else
			n_draw = "normal"
		end
		
			for k2,v2 in ipairs(compare) do 
				if n_draw == v2 then
				  	table.insert(result,"t")
				end
			end
	end

	if #result == num then
		result = true
	else
		result = false
	end
	node_down_fsable_cache[cache_key] = result -- save to the cache

	return result
end

------------------------------------------
--  Workaround for odd crouch behaviour --
------------------------------------------
function crouch_wa(player,pos)
	local is_slab = 0                                             -- is_slab var holder 0=not_slab, 1=slab 
	local pos_w = {}                                              -- Empty table
	local angle = (player:get_look_horizontal())*180/math.pi      -- Convert Look direction to angles
	
		if angle <= 45 or angle >= 315 then                       -- +Z North
			pos_w={x=pos.x,y=pos.y+1,z=pos.z+1}
			
		elseif angle > 45 and angle < 135 then                    -- -X West
			pos_w={x=pos.x-1,y=pos.y+1,z=pos.z}
			
		elseif angle >= 135 and angle <= 225 then                 -- -Z South
			pos_w={x=pos.x,y=pos.y+1,z=pos.z-1}
			
		elseif angle > 225 and angle < 315 then                   -- +X East
			pos_w={x=pos.x+1,y=pos.y+1,z=pos.z}			
		end

	local check = minetest.get_node(pos_w)                       -- Get the node that is in front of the players look direction
	
	if minetest.registered_nodes[check.name] then
		local check_g = minetest.registered_nodes[check.name].groups -- Get the groups assigned to node                                             
			for k,v in pairs(check_g) do
				if k == "slab" then                                  -- Any of the keys == slab then slab
					is_slab = 1                                      -- is_slab set to 1
				end
			end	
	end
	
	return is_slab                                               -- return 1 or 0
		
end






