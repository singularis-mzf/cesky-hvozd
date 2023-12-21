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
	local pos = mobkit.recall(self, "node_pos")
	if not pos then
		error("NPC node position not found!")
	end
	minetest.load_area(pos)
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "ch_npc_spawner") == 0 then
		minetest.log("warning", "on_rightclick expected NPC spawner under "..minetest.pos_to_string(pos).." where is the node "..node.name)
		return
	end
	local meta = minetest.get_meta(pos)
	local dialog = meta:get_string("npc_dialog")
	if dialog == "" then
		minetest.log("info", "No dialog for NPC at position "..minetest.pos_to_string(pos)..".")
		return -- no dialog for this NPC
	end
	if dialog ~= self._dialog_file then
		local file_path = minetest.get_worldpath().."/dialogs/"..dialog..".txt"
		minetest.log("info", "Will load dialog for NPC at position "..minetest.pos_to_string(pos).." from file: "..file_path)
		local file = io.open(file_path)
		local dialog_text
		if file then
			dialog_text = file:read("*a")
			file:close()
		end
		if dialog_text == nil or dialog_text == "" then
			minetest.log("warning", "No text loaded from "..file_path.."!")
			return -- no text available
		end
		minetest.log("info", file_path..": "..#dialog_text.." chars.")
		simple_dialogs.load_dialog_from_string(self, dialog_text)
		self._dialog_file = dialog
	end
	simple_dialogs.show_dialog_formspec(player:get_player_name(), self)
	-- local formspec = ch_npc.internal.get_entity_formspec(meta)
	-- ch_npc.internal.show_formspec(pos, player:get_player_name(), "ch_npc:entity_formspec", formspec)
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
		static_save = false,
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
