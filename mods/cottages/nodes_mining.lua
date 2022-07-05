---------------------------------------------------------------------------------------
-- a rope that is of use to the mines
---------------------------------------------------------------------------------------
-- the rope can only be digged if there is no further rope above it;
-- Note: This rope also counts as a rail node; thus, carts can move through it
minetest.register_node("cottages:rope", {
        description = "Provaz",
        tiles = {"cottages_rope.png"},
	groups = {snappy=3,choppy=3,oddly_breakable_by_hand=3,rail=1,connect_to_raillike=1},--connect_to_raillike=minetest.raillike_group("rail")},
        walkable = false,
        climbable = true,
        paramtype = "light",
        sunlight_propagates = true,
        drawtype = "plantlike",
	is_ground_content = false,
	--[[ can_dig = function(pos, player)
			local below = minetest.get_node( {x=pos.x, y=pos.y-1, z=pos.z});
			if( below and below.name and below.name == "cottages:rope" ) then
				if( player ) then
					minetest.chat_send_player( player:get_player_name(),
						'The entire rope would be too heavy. Start digging at its lowest end!');
				end
				return false;
			end
			return true;
		end ]]
})

minetest.register_craft({
	output = "cottages:rope",
	recipe = {
		{"farming:cotton","farming:cotton","farming:cotton"}
        }
})
