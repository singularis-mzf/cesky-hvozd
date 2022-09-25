-- ENTITY
local function entity_on_activate(self, staticdata, dtime_s)
	mobkit.actfunc(self, staticdata, dtime_s)
end

local function entity_logic(self)
	-- based on code from „Folks“ mod by Michele Viotto
	mobkit.vitals(self)
	local pos = self.object:get_pos()
	if mobkit.get_queue_priority(self) < 10 then
		local player = mobkit.get_nearby_player(self)
		local player_pos = player and player:get_pos()
		if player_pos and vector.distance(pos, player_pos) < 8 then
			mobkit.lq_turn2pos(self, player_pos)
		end
	end
end

local function entity_on_rightclick(self, player)
	local pos, positions, meta, formspec
	pos = self.object:get_pos()
	positions = minetest.find_nodes_in_area(vector.new(pos.x, pos.y + 0.5, pos.z), vector.new(pos.x, pos.y - 4, pos.z), {"group:ch_npc_spawner"})
	if #positions > 1 and positions[2].y < positions[1].y then
		pos = positions[2]
	elseif #positions > 0 then
		pos = positions[1]
	else
		minetest.log("warning", "on_rightclick expected NPC spawner under "..minetest.pos_to_string(pos))
		return
	end
	meta = minetest.get_meta(pos)
	formspec = ch_npc.internal.get_entity_formspec(meta)
	ch_npc.internal.show_formspec(pos, player:get_player_name(), "ch_npc:entity_formspec", formspec)
end

local function entity_on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
	entity_on_rightclick(self, puncher)
	return true
end

-- entity parameters based on parameters from „Folks“ mod by Michele Viotto
local model = ch_npc.registered_npcs["default"]
local def = {
	initial_properties = {
		hp_max = 9999,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
		visual = "mesh",
		visual_size = {x = 1, y = 1},
		mesh = model.mesh,
		textures = model.textures,
		-- nametag = "",
		-- nametag_color = "#ffffff",
	},

	-- mobkit
	timeout = 0,
	max_hp = 9999,
	buoyancy = -1,
	lung_capacity = 200,
	on_step = mobkit.stepfunc,
	on_activate = entity_on_activate,
	get_staticdata = mobkit.statfunc,
	view_range = 24,
	max_speed = 10,
	jump_height = 10,
	logic = entity_logic,
	on_rightclick = entity_on_rightclick,
	on_punch = entity_on_punch,
}

minetest.register_entity("ch_npc:npc", def)
