local beds_list = {
	"beds:bed",
	"beds:fancy_bed",
}

local look_yaw = {
	[0] = math.pi,
	[1] = math.pi / 2,
	[2] = 0,
	[3] = -math.pi / 2,
}

function emote.bed_onrightclick(pos, node, clicker, itemstack, pointed_thing)
	if clicker and clicker:is_player() then
		local player_name = clicker:get_player_name()
		local velocity = vector.length(clicker:get_velocity())
		local distance = vector.distance(pos, clicker:get_pos())

		if velocity > 0.001 or distance > 2.0 then
			minetest.log("action", "Player "..player_name.." tried to go to bed, but: velocity = "..velocity..", distance = "..distance..".")
			return nil
		end
		-- clicker:set_eye_offset(vector.new(0, -13, 0), vector.new(0, 0, 0))
		local facedir = node.param2 % 4
		local dir = minetest.facedir_to_dir(facedir)
		clicker:set_look_horizontal(look_yaw[facedir])
		clicker:set_look_vertical(-0.9 * math.pi)
		-- clicker:set_physics_override({speed = 0, jump = 0, gravity = 0})

		local ndef = minetest.registered_nodes[node.name]
		local cbox = ndef and ndef.collision_box
		local y_shift = 0.5
		if cbox and cbox.type == "fixed" and cbox.fixed then
			y_shift = cbox.fixed[5]
		end

		clicker:set_pos(vector.new(pos.x + 0.5 * dir.x, pos.y + y_shift, pos.z + 0.5 * dir.z))

		minetest.after(0.5, function()
			local player = minetest.get_player_by_name(player_name)
			if player then
				emote.start(player, "lehni")
			end
		end)
	end
	return nil
end

for _, name in ipairs(beds_list) do
	if minetest.registered_nodes[name] then
		minetest.override_item(name, {on_rightclick = emote.bed_onrightclick})
	end
end
