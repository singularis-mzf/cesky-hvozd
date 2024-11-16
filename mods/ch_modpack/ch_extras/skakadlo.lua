local default_tool_sounds = {breaks = "default_tool_breaks"}

local function is_cast_result_nonwalkable(cast_result)
	if cast_result ~= nil and cast_result.above ~= nil and cast_result.under ~= nil then
		local node_name = minetest.get_node(cast_result.under).name
		local ndef = minetest.registered_nodes[node_name]
		if ndef == nil or (ndef.walkable == false and ndef.climbable ~= true) then
			return true
		end
	end
	return false
end

-- skákadlo
local function skakadlo(itemstack, player, new_speed, wear_to_add)
	if not player or not player:is_player() then
		return
	end
	local player_name = player:get_player_name()
	local pos = player:get_pos()
	local current_velocity = player:get_velocity()
	local reason

	if current_velocity.y ~= 0 then
		reason = "Current velocity = "..minetest.pos_to_string(current_velocity)
	end

	local node_at_player, node_under_player
	if reason == nil then
		local cast = Raycast(pos, vector.offset(pos, 0, -0.5, 0), false, true)
		local cast_result = cast:next()
		while is_cast_result_nonwalkable(cast_result) do
			cast_result = cast:next()
		end
		if cast_result ~= nil and cast_result.above ~= nil and cast_result.under ~= nil then
			node_at_player = minetest.get_node(cast_result.above)
			node_under_player = minetest.get_node(cast_result.under)
		else
			node_at_player = minetest.get_node(pos)
			node_under_player = minetest.get_node(vector.new(pos.x, pos.y - 0.05, pos.z))
			minetest.log("warning", "Raycast at "..minetest.pos_to_string(pos).." for skakadlo failed! result = "..dump2(cast_result))
		end
	end

	if reason == nil and node_at_player.name ~= "air" then
		local node_def = minetest.registered_nodes[node_at_player.name]
		if not node_def then
			reason = "Unknown node "..node_at_player.name
		elseif node_def.climbable then
			reason = "At climbable node "..node_at_player.name
		elseif (node_def.move_resistance or 0) > 0 then
			reason = "Node "..node_at_player.name.." has move_resistance "..(node_def.move_resistance or 0)
		elseif node_def.liquid_move_physics or (node_def.liquidtype or "none") ~= "none" then
			reason = "Player is in liquid "..node_at_player.name
		end
	end

	if reason == nil then
		local node_def = minetest.registered_nodes[node_under_player.name]
		if not node_def then
			reason = "Unknown node "..node_under_player.name
		elseif node_def.walkable == false then
			reason = "On non-walkable node "..node_under_player.name
		elseif node_def.climbable then
			reason = "On climbable node "..node_under_player.name
		elseif (node_def.move_resistance or 0) > 0 then
			reason = "Node "..node_under_player.name.." has move_resistance "..(node_def.move_resistance or 0)
		elseif node_def.liquid_move_physics or (node_def.liquidtype or "none") ~= "none"  then
			reason = "Player is on liquid "..node_under_player.name
		end
	end

	if reason ~= nil then
		minetest.log("action", player_name.." failed to jump using a jump tool at "..minetest.pos_to_string(pos).." due to the reason: "..reason)
	else
		player:add_velocity(vector.new(0, new_speed, 0))
		minetest.log("action", player_name.." jumped using a jump tool at "..minetest.pos_to_string(pos)..", nodes: "..node_at_player.name..", "..node_under_player.name)
		minetest.sound_play("toaster", {pos = pos, max_hear_distance = 32, gain = 0.2}, true)

		if not minetest.is_creative_enabled(player_name) then
			local new_wear = math.ceil(itemstack:get_wear() + wear_to_add)
			if new_wear > 65535 then
				itemstack:clear()
			else
				itemstack:set_wear(new_wear)
			end
			return itemstack
		end
	end
end

local def = {
	description = "skákadlo",
	_ch_help = "Nástroj sloužící ke skoku do velké výšky. Umožňuje vyskočit např. z jámy či na strom.\nLevým klikem vyskočíte cca o 6,5 metru, pravým o cca 3 metry.\nNefunguje pod vodou nebo pokud nestojíte na pevné zemi. Nejde opravit na kovadlině, ale v elektrické opravně ano.",
	_ch_help_group = "skakadlo",
	inventory_image = "ch_extras_skakadlo.png",
	wield_image = "blank.png",
	sound = default_tool_sounds,
	range = 0.0,
	on_use = function(itemstack, player, pointed_thing) return skakadlo(itemstack, player, 18, 300) end,
	-- on_secondary_use = function(itemstack, player, pointed_thing) return skakadlo(itemstack, player, 12, 120) end,
	on_place = function(itemstack, player, pointed_thing) return skakadlo(itemstack, player, 12, 120) end,
}
def.on_secondary_use = def.on_place

minetest.register_tool("ch_extras:jumptool", def)
for _, stick in ipairs({"default:stick", "basic_materials:steel_bar"}) do
	minetest.register_craft({
		output = "ch_extras:jumptool",
		recipe = {
			{stick, stick, stick},
			{"", "technic:rubber", ""},
			{"", "default:steel_ingot", ""},
		},
	})
end
if minetest.get_modpath("anvil") then
	anvil.make_unrepairable("ch_extras:jumptool")
end
