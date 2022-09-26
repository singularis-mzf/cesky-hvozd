-- SITTING

if not minetest.get_modpath("ts_furniture") then
	return
end

local function sednout(sedadlo_offset, zidle_pos, zidle_node, player)
	if not player or not player:is_player() or not zidle_pos or not zidle_node or not default.player_get_animation then
		return false
	end
	local player_name = player:get_player_name()
	local anim = default.player_get_animation(player) or ""
	local zero_vector = vector.zero()

	if anim == "sit" or anim == "sedni" then
		-- postava již sedí => zvednout se
		default.player_attached[player_name] = false
		emote.stop(player)
		player:set_eye_offset(zero_vector, zero_vector)
		return nil
	end

	local look_yaw = {
		[0] = math.pi,
		[1] = math.pi / 2,
		[2] = 0,
		[3] = -math.pi / 2,
	}
	local node_facedir = zidle_node.param2 % 4
	if node_facedir == 1 then
		sedadlo_offset = vector.new(sedadlo_offset.z, sedadlo_offset.y, -sedadlo_offset.x)
	elseif node_facedir == 2 then
		sedadlo_offset = vector.new(-sedadlo_offset.x, sedadlo_offset.y, -sedadlo_offset.z)
	elseif node_facedir == 3 then
		sedadlo_offset = vector.new(-sedadlo_offset.z, sedadlo_offset.y, sedadlo_offset.x)
	end

	local sit_pos = vector.new(zidle_pos.x + sedadlo_offset.x, zidle_pos.y + sedadlo_offset.y, zidle_pos.z + sedadlo_offset.z)

	-- verify position and velocity
	if vector.distance(player:get_pos(), sit_pos) > 2.0 then
		minetest.log("action", "Sit attempt failed for "..player_name.." because the distance is too large.")
		return false
	end
	local velocity = player:get_velocity()
	if vector.length(velocity) > 0.5 then
		minetest.log("action", "Sit attempt failed for "..player_name.." because the velocity is too large.")
		return false
	end
	ts_furniture.sit(sit_pos, zidle_node, player)
	player:set_look_horizontal(look_yaw[node_facedir])
	player:set_look_vertical(0)
	--[[ if minetest.get_modpath("emote") then
		minetest.after(0.5, function(p) emote.start(p, "sedni") end, player)
	end ]]
	--[[
	player:set_pos(sit_pos)
	player:add_velocity(vector.multiply(velocity, -1))
	player:set_look_horizontal(look_yaw[node_facedir])
	player:set_look_vertical(0)
	player:set_eye_offset(vector.new(0, -7, 2), vector.zero())
	default.player_attached[player_name] = true
	minetest.after(0.5, function(p) emote.start(p, "sedni") end, player)
	]]
	return true
end

if minetest.registered_nodes["cottages:bench"] then
	minetest.override_item("cottages:bench", {
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			sednout(vector.new(0, 0, 0.3), pos, node, clicker)
		end,
	})
end

for _, itemname in ipairs({"homedecor:kitchen_chair_wood", "homedecor:kitchen_chair_padded",
"homedecor:bench_large_1", "homedecor:bench_large_2", "homedecor:armchair", "lrfurn:armchair"}) do
	if minetest.registered_nodes[itemname] then
		minetest.override_item(itemname, {
			on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
				sednout(vector.zero(), pos, node, clicker)
			end,
		})
	end
end

for _, itemname in ipairs({"homedecor:office_chair_basic", "homedecor:office_chair_upscale"}) do
	if minetest.registered_nodes[itemname] then
		minetest.override_item(itemname, {
			on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
				sednout(vector.new(0, 0.15, 0), pos, node, clicker)
			end,
		})
	end
end

for _, itemname in ipairs({"lrfurn:longsofa", "lrfurn:sofa"}) do
	if minetest.registered_nodes[itemname] then
		minetest.override_item(itemname, {
			on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
				node.param2 = node.param2 % 4
				if node.param2 == 2 then
					node.param2 = 1
				elseif node.param2 == 1 then
					node.param2 = 2
				end
				sednout(vector.new(0, 0.15, 0), pos, node, clicker)
			end,
		})
	end
end
