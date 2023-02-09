

    
    local Asciugamano_list = {
	{ "Red Asciugamano", "red"},
	{ "Orange Asciugamano", "orange"},
    { "Black Asciugamano", "black"},
	{ "Yellow Asciugamano", "yellow"},
	{ "Green Asciugamano", "green"},
	{ "Blue Asciugamano", "blue"},
	{ "Violet Asciugamano", "violet"},
}

for i in ipairs(Asciugamano_list) do
	local asciugamanodesc = Asciugamano_list[i][1]
	local colour = Asciugamano_list[i][2]
 


    
   minetest.register_node("summer:asciugamano_"..colour.."", {
	    description = asciugamanodesc.."",
	    drawtype = "mesh",
		mesh = "asciugamano.obj",
	    tiles = {"asciugsmano_"..colour..".png",
	    },	    
        inventory_image = "asciugsmano_a_"..colour..".png",
	    
        wield_image  = {"asciugsmano_a_"..colour..".png",
	    },
	    paramtype = "light",
	    paramtype2 = "facedir",
	    sunlight_propagates = true,
	    walkable = false,
	    selection_box = {
	        type = "fixed",
	        fixed = { -1.0, -0.5,-0.5, 1.0,-0.49, 0.5 },
	    },
		groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,not_in_creative_inventory=0},
		--sounds = default.node_sound_wood_defaults(),
        drop = "summer:asciugamano_"..colour.."",        
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
				return minetest.sleep_in_asciugamano( pos, node, clicker, itemstack, pointed_thing );
			end
        
 
   })
   

minetest.allow_sit = function( player )
	-- no check possible
	if( not( player.get_player_velocity )) then
		return true;
	end
	local velo = player:get_player_velocity();
	if( not( velo )) then
		return false;
	end
	local max_velo = 0.0010;
	if(   math.abs(velo.x) < max_velo
	  and math.abs(velo.y) < max_velo
	  and math.abs(velo.z) < max_velo ) then
		return true;
	end
	return false;
end



minetest.sleep_in_asciugamano = function( pos, node, clicker, itemstack, pointed_thing )
	if( not( clicker ) or not( node ) or not( node.name ) or not( pos ) or not( minetest.allow_sit( clicker))) then
		return;
	end

	local animation = default.player_get_animation( clicker );
	local pname = clicker:get_player_name();

	local place_name = 'place';
	-- if only one node is present, the player can only sit;
	-- sleeping requires a asciugamano head+foot or two sleeping mats
	local allow_sleep = false;
	local new_animation = 'lay';

	-- let players get back up
	if( animation and animation.animation=="lay" ) then
		default.player_attached[pname] = false
		clicker:setpos({x=pos.x,y=pos.y-0.5,z=pos.z})
		clicker:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
		clicker:set_physics_override(1, 1, 1)
		default.player_set_animation(clicker, "stand", 30)
		minetest.chat_send_player( pname, 'That was enough sleep for now. You stand up again.');
		return;
	end

	local second_node_pos = {x=pos.x, y=pos.y, z=pos.z};
	-- the node that will contain the head of the player
	local p = {x=pos.x, y=pos.y, z=pos.z};
	-- the player's head is pointing in this direction
	local dir = node.param2;
	-- it would be odd to sleep in half a asciugamano
	if(     node.name=="summer:asciugamano_"..colour.."" ) then
		if(     node.param2==0 ) then
			second_node_pos.z = pos.z-1;
		elseif( node.param2==1) then
			second_node_pos.x = pos.x-1;
		elseif( node.param2==2) then
			second_node_pos.z = pos.z+1;
		elseif( node.param2==3) then
			second_node_pos.x = pos.x+1;
		end
		local node2 = minetest.get_node( second_node_pos );
		if( not( node2 ) or not( node2.param2 ) or not( node.param2 )
		   or node2.name   ~= "summer:asciugamano_"..colour..""
		   or node2.param2 ~= node.param2 ) then
			allow_sleep = false;
		else
			allow_sleep = true;
		end
		place_name = "asciugamano_"..colour.."";

	-- if the player clicked on the foot of the asciugamano, locate the head
	elseif( node.name=='summer:asciugamano' ) then
		if(     node.param2==2 ) then
			second_node_pos.z = pos.z-1;
		elseif( node.param2==3) then
			second_node_pos.x = pos.x-1;
		elseif( node.param2==0) then
			second_node_pos.z = pos.z+1;
		elseif( node.param2==1) then
			second_node_pos.x = pos.x+1;
		end
		local node2 = minetest.get_node( second_node_pos );
		if( not( node2 ) or not( node2.param2 ) or not( node.param2 )
		   or node2.name   ~= 'summer:asciugamano'
		   or node2.param2 ~= node.param2 ) then
			allow_sleep = false;
		else
			allow_sleep = true;
		end
		if( allow_sleep==true ) then
			p = {x=second_node_pos.x, y=second_node_pos.y, z=second_node_pos.z};
		end
		place_name = 'asciugamano';

	elseif( node.name=='summer:sleeping_mat' or node.name=='summer:straw_mat') then
		place_name = 'mat';
		dir = node.param2;
		allow_sleep = false;
		-- search for a second mat right next to this one
		local offset = {{x=0,z=-1}, {x=-1,z=0}, {x=0,z=1}, {x=1,z=0}};
		for i,off in ipairs( offset ) do
			node2 = minetest.get_node( {x=pos.x+off.x, y=pos.y, z=pos.z+off.z} );
			if( node2.name == 'summer:sleeping_mat' or node2.name=='summer:straw_mat' ) then
				-- if a second mat is found, sleeping is possible
				allow_sleep = true;
				dir = i-1;
			end
		end
	end

	-- set the right height for the asciugamano
	if( place_name=='asciugamano' ) then
		p.y = p.y-0.4;
	end
	if( allow_sleep==true ) then
		-- set the right position (middle of the asciugamano)
		if(     dir==0 ) then
			p.z = p.z-0.5;
		elseif( dir==1 ) then
			p.x = p.x-0.5;
		elseif( dir==2 ) then
			p.z = p.z+0.5;
		elseif( dir==3 ) then
			p.x = p.x+0.5;
		end
	end
	
	if( default.player_attached[pname] and animation.animation=="sit") then
		-- just changing the animation...
		if( allow_sleep==true ) then
			default.player_set_animation(clicker, "lay", 30)
			clicker:set_eye_offset({x=0,y=-14,z=2}, {x=0,y=0,z=0})
			minetest.chat_send_player( pname, 'You lie down and take a nap. A right-click will wake you up.');
			return;
		-- no sleeping on this place
		else
			default.player_attached[pname] = false
			clicker:setpos({x=pos.x,y=pos.y-0.5,z=pos.z})
			clicker:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
			clicker:set_physics_override(1, 1, 1)
			default.player_set_animation(clicker, "stand", 30)
			minetest.chat_send_player( pname, 'That was enough sitting around for now. You stand up again.');
			return;
		end
	end


	clicker:set_eye_offset({x=0,y=-7,z=2}, {x=0,y=0,z=0})
	clicker:setpos( p );
	default.player_set_animation(clicker, new_animation, 30)
	clicker:set_physics_override(0, 0, 0)
	default.player_attached[pname] = true

	if( allow_sleep==true) then
		minetest.chat_send_player( pname, 'Aaah! What a comftable '..place_name..'. A second right-click will let you sleep.');
	else
		minetest.chat_send_player( pname, 'Comftable, but not good enough for a nap. Right-click again if you want to get back up.');
	end
end

	
	
end
    --state=true: lay, state=false: stand up
    
