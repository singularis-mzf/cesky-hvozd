ch_base.open_mod(minetest.get_current_modname())
--------------------------------------------------------------------------------------
--            ________      .___    _____                                           --
--            \_____  \   __| _/   /  _  \_______  _____   ___________              --
--              _(__  <  / __ |   /  /_\  \_  __ \/     \ /  _ \_  __ \             --
--             /       \/ /_/ |  /    |    \  | \/  Y Y  (  <_> )  | \/             -- 
--            /______  /\____ |  \____|__  /__|  |__|_|  /\____/|__|                --
--                   \/      \/          \/            \/                           --
--  ___________.__                             .___   _________       .__           --
--  \_   _____/|  | ___.__. _____    ____    __| _/  /   _____/_  _  _|__| _____    --
--   |    __)  |  |<   |  | \__  \  /    \  / __ |   \_____  \\ \/ \/ /  |/     \   --
--   |     \   |  |_\___  |  / __ \|   |  \/ /_/ |   /        \\     /|  |  Y Y  \  --
--   \___  /   |____/ ____| (____  /___|  /\____ |  /_______  / \/\_/ |__|__|_|  /  --
--       \/         \/           \/     \/      \/          \/                 \/   --
--                                                                                  --
--                       Also makes Capes a 3d Armor, armor item                    --
--------------------------------------------------------------------------------------
--                                 by Sirrobzeroone                                 --
--                              Licence code LGPL v2.1                              --
--                                Cape Textures - CC0                               --
--                     Blender Model/B3Ds as per base MTG - CC BY-SA 3.0            --
--                       except "3d_armor_trans.png" CC-BY-SA 3.0                   --
--------------------------------------------------------------------------------------

----------------------------
--        Settings        --
----------------------------
armor_fly_swim = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

armor_fly_swim.add_capes = minetest.settings:get_bool("capes_add_to_3darmor" ,false)
armor_fly_swim.example_cape = minetest.settings:get_bool("example_cape" ,false)

local fly_anim = minetest.settings:get_bool("fly_anim" ,true)
local fall_anim = minetest.settings:get_bool("fall_anim" ,true)
local fall_tv = tonumber(minetest.settings:get("fall_tv" ,true)) or 100
	  fall_tv = -1*(fall_tv/3.7)                             -- Convert kp/h back to number of -y blocks per 0.05 of a second.
local swim_anim = minetest.settings:get_bool("swim_anim" ,true)
local swim_sneak = minetest.settings:get_bool("swim_sneak" ,true)
local climb_anim = minetest.settings:get_bool("climb_anim" ,true)
local crouch_anim = minetest.settings:get_bool("crouch_anim" ,true)
local crouch_sneak = minetest.settings:get_bool("crouch_sneak" ,true)
 
-----------------------															
-- Conditional mods --
-----------------------															
armor_fly_swim.is_3d_armor = minetest.get_modpath("3d_armor")
armor_fly_swim.is_skinsdb  = minetest.get_modpath("skinsdb")
															
-------------------------------------
-- Adding new armor item for Capes --
-------------------------------------
if armor_fly_swim.add_capes == true then
	if minetest.global_exists("armor") and armor.elements then
		table.insert(armor.elements, "capes")
	end
end

----------------------------
--   Initiate files       --
----------------------------
dofile(modpath .. "/i_functions.lua")                        -- Functions

--[[
if armor_fly_swim.example_cape and 
   armor_fly_swim.add_capes and 
   armor_fly_swim.is_3d_armor then
   
	dofile(modpath .. "/i_example_cape.lua")                 -- Example Cape
end
]]
-------------------------------------
--     Get Player model to use     --
-------------------------------------
local player_mod, texture = armor_fly_swim.get_player_model()

--------------------------------------
-- Player model with Swim/Fly/Capes --
--------------------------------------
player_api.register_model(player_mod, {
	animation_speed = 30,
	textures = texture,	
	animations = {
		stand =     {x=0,   y=79},
		lay =       {x=162, y=166},
		walk =      {x=168, y=187},
		mine =      {x=189, y=198},
		walk_mine = {x=200, y=219},
		sit =       {x=81,  y=160},
		swim =      {x=246, y=279}, 
		swim_atk =  {x=285, y=318},
		fly =       {x=325, y=334},
		fly_atk =   {x=340, y=349},
		fall =      {x=355, y=364},
		fall_atk =  {x=365, y=374},
		duck_std =  {x=380, y=380},
		duck =      {x=381, y=399},
		climb =     {x=410, y=429},   
	},
})
----------------------------------------
-- Setting model on join and clearing --
--          local_animations          --  
----------------------------------------
minetest.register_on_joinplayer(function(player)
	player_api.set_model(player,player_mod)	
	player_api.player_attached[player:get_player_name()] = false
	player:set_local_animation({},{},{},{},30)
	
end)

------------------------------------------------
--    Global step to check if player meets    --
-- Conditions for Swimming, Flying(falling)   --
--          Crouching or Climbing             --
------------------------------------------------
minetest.register_globalstep(function()
	for _, player in pairs(minetest.get_connected_players()) do
		local controls      = player:get_player_control()
		local controls_wasd = armor_fly_swim.get_wasd_state(controls)
		local attached_to   = player:get_attach()
		local privs         = minetest.get_player_privs(player:get_player_name())
		local pos           = player:get_pos()
		local pmeta         = player:get_meta()
		local cur_anim      = player_api.get_animation(player)		
		local ladder        = {}
		      ladder.n      = {is = false, pos = pos}
		      ladder.n_a    = {is = false, pos = {x=pos.x,y=pos.y +1,z=pos.z}}		
		      ladder.n_b    = {is = false, pos = {x=pos.x,y=pos.y -1,z=pos.z}}
		local is_slab       = crouch_wa(player,pos)
		local attack        = ""
		local ani_spd       = 30		
		local offset        = 0
		local tdebug        = false
		local empty_list    = {}
		local player_name   = player:get_player_name()
		local online_charinfo = ch_data.online_charinfo[player_name] or empty_list
		local offline_charinfo = ch_data.offline_charinfo[player_name] or empty_list
		local sneak_allowed = offline_charinfo.neshybat == 0

		-- reset player collisionbox, eye height, speed override 
		player:set_properties({collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3}})
		player:set_properties({eye_height = 1.47})
		
		-- used to store and reset the players physics.speed settings 
		-- back to what they were before fly_swim adjusted them
		if pmeta:get_int("flyswim_std_under_slab") == 1 then                       		
		   player:set_physics_override({speed = pmeta:get_float("flyswim_org_phy_or")})
		   pmeta:set_int("flyswim_std_under_slab", 0)		   
		end

		local vel = player:get_velocity()

		-- basically 3D Pythagorean Theorem km/h
		local play_s = (math.sqrt(math.pow(math.abs(vel.x),2) + 
		                math.pow(math.abs(vel.y),2) + 
		                math.pow(math.abs(vel.z),2) ))*3.6

		-- Sets terminal velocity to about 100Km/hr beyond   --
        -- this speed chunk load issues become more noticable --		
		if vel.y < fall_tv  and controls.sneak ~= true then			
			local tv_offset_y = -1*((-1*(vel.y+1)) + vel.y)               --(-1*(vel.y+1)) - catch those holding shift and over acceleratering when falling so dynamic end point so we dont bounce back up		
				player:add_velocity({x=0, y=tv_offset_y, z=0})	
		end
		
		-- Check for Swinging/attacking and set string
		if controls.LMB or controls.RMB then
			attack = "_atk"
		end
		
		-- get ladder nodes
		for k,def in pairs(ladder) do
			local node = minetest.registered_nodes[minetest.get_node(def.pos).name] 
			if node and node.climbable then
				def.is = true
			end		
		end

        ---------------------------------------------------------
		--            Start of Animation Cases                 --
        ---------------------------------------------------------
	-------------------------------------
	-- Crouch Slab/Node Exception Case --
	-------------------------------------	             		
		local node_check = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z})
		local nc_draw    = "normal"
		local nc_slab    = 0
		local nc_node    = 0
		
		if minetest.registered_nodes[node_check.name] then
			
			nc_slab = minetest.get_item_group(node_check.name, "slab")
			nc_draw = minetest.registered_nodes[node_check.name].drawtype
			
			if nc_draw ~= "liquid" and 
			   nc_draw ~= "flowingliquid" and 
			   nc_draw ~= "airlike" then
				
				nc_node = 1
			end
		end
		
		--[[if crouch_sneak and
		   nc_slab == 1 and
		   not attached_to and
		   not controls.sneak and 
		   not node_fsable(pos,2,"a") then
		   
			local animation = "duck_std"
			
			-- when player moving
			if controls_wasd then                              
				local play_or_2 =player:get_physics_override()
				pmeta:set_int("flyswim_std_under_slab", 1)
				pmeta:set_float("flyswim_org_phy_or", play_or_2.speed)
				player:set_physics_override({speed = play_or_2.speed*0.2})
				
				animation = "duck" 
			end
			
			if crouch_anim == true then
				player_api.set_animation(player, animation ,ani_spd/2)
			end
			
			player:set_properties({collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.45, 0.3}})
			player:set_properties({eye_height = 1.27})
			if tdebug then minetest.debug("crouch catch") end				

		else]]if sneak_allowed and
		       swim_sneak and
		       nc_node == 1 and
		       node_down_fsable(pos,1,"s") and
		       not attached_to and			   
		       not controls.sneak then

				player_api.set_animation(player, "swim",ani_spd)
				player:set_properties({collisionbox = {-0.4, 0, -0.4, 0.4, 0.5, 0.4}})
				player:set_properties({eye_height = 0.7}) 
				offset = 90
				if tdebug then minetest.debug("swim through catch") end

	-----------------------------
	--      Climb Cases        --
	-----------------------------
		elseif climb_anim    and                                    -- Climb animation setting must be true 
		      ladder.n.is    and 								    -- Player standing in node that is climable and	
		     (controls.jump or controls.sneak) then					-- Moving up or Moving down
						
				if (controls.sneak and ladder.n_b.is) or
				   (controls.jump  and ladder.n_a.is) then
					 
					 if tdebug then minetest.debug(dump(ladder.n_b.is)) end
					 player_api.set_animation(player, "climb",ani_spd)           -- Do climbing animation
					if tdebug then minetest.debug("climb") end
				end   

	-----------------------------
	--       Swim Cases        --
	-----------------------------	
		elseif swim_anim == true and
			   node_down_fsable(pos,2,"s") and								--Node player standing in and 1 below must be swimmable
			   not attached_to then
			   
				player_api.set_animation(player,"swim"..attack ,ani_spd)			 -- Set to swimming attack animation
				offset = 90                                                  -- Offset for Headanim  
				if tdebug then minetest.debug("swim") end
			
		elseif sneak_allowed and swim_sneak == true and
			   swim_anim == true and
			   controls.sneak and									      
			   node_down_fsable(pos,1,"s") and                    	 		 -- Node player standing in swimmable
			   not attached_to then
			   
				player_api.set_animation(player, "swim",ani_spd)
				player:set_properties({collisionbox = {-0.4, 0, -0.4, 0.4, 0.5, 0.4}})
				player:set_properties({eye_height = 0.7}) 
				offset = 90                                             	  -- Offset for Headanim
				if tdebug then minetest.debug("swim through") end
	-----------------------------
	--      Sneak Cases        --
	-----------------------------
    ----------------------------------------------------------
    -- Crouch-walk workaround Start
	-- First slab player enters counts as a true slab and has an edge.
	-- As such the shift edge detection kicks in and player can't move forwards
	-- This case sets the player collision box to 1 high for that first slab 
		elseif 	sneak_allowed	and
				crouch_anim 	and
				controls.sneak 	and 
				controls.up    	and 
				not node_fsable(pos,2,"a") and                        	 -- No air node below feet
				not attached_to and
				play_s <= 1 and is_slab == 1 then                        -- Speed < 1 kph and node infront and up 1 must be slab see functions                      

					if crouch_anim == true then
						player_api.set_animation(player, "duck",ani_spd/2)
						player:set_properties({eye_height = 1.27})				
					end 
					
					if crouch_sneak == true then
						 -- Workaround set collision box to 1 high
						player:set_properties({collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.0, 0.3}})
					end
					if tdebug then minetest.debug("crouch_1") end
		elseif 	sneak_allowed	and
				crouch_anim    and
				controls.sneak and
				not node_fsable(pos,2,"a") and
				not attached_to then			                    
					
					local animation = "duck_std"
					if controls_wasd then animation = "duck" end
					
					player_api.set_animation(player, animation, ani_spd/2)
					player:set_properties({eye_height = 1.27})

					if crouch_sneak == true then
						player:set_properties({collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.45, 0.3}})
					end
					if tdebug then minetest.debug("crouch_2") end

	-----------------------------
	--      Flying Cases       --
	-----------------------------						
		elseif fly_anim == true and
			   privs.fly == true and
			   node_down_fsable(pos,3,"a") and
			   not attached_to then

				-- Vel.y value is a compromise for code simplicity,
				-- Flyers wont get fall animation until below -18m/s
				if controls_wasd then					
					player_api.set_animation(player, "fly"..attack, ani_spd)
					offset = 90
					if tdebug then minetest.debug("fly") end

				elseif fall_anim == true and
					   vel.y < -18.0 then	  
						player_api.set_animation(player, "fall"..attack, ani_spd)
						offset = 90
						if tdebug then minetest.debug("fly_fall") end
				end	
			
	-----------------------------
	--      Falling Cases      --
	-----------------------------			
		elseif 	fall_anim == true and
				node_down_fsable(pos,5,"a") and
				vel.y < -0.5 and
				not attached_to then
			
					player_api.set_animation(player, "fall"..attack, ani_spd)
					offset = 90
					if tdebug then minetest.debug("fall") end
		end

		online_charinfo.head_offset = offset
	end
end)
ch_base.close_mod(minetest.get_current_modname())
