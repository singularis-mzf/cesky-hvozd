local internal = ...

local common_def = {
	drawtype = "normal",
	tiles = {{name = "area_containers_wall.png"}},
	use_texture_alpha = "opaque",
	paramtype = "light",
	paramtype2 = "none",
	diggable = false,
	is_ground_content = false,
	sunlight_propagates = true,
	sounds = default.node_sound_stone_defaults(),
	drop = "",
	node_dig_prediction = "",
	on_blast = function() end,
	on_destruct = function(pos)
		local node = core.get_node(pos)
		if node.name ~= "ch_containers:access_point" then
			core.log("warning", node.name.."/"..tostring(node.param2).." at "..core.pos_to_string(pos).." is being destroyed!")
		end
	end,
	on_dig = function(pos, node, digger)
		if digger ~= nil and core.is_player(digger) and ch_core.get_player_role(digger) == "admin" then
			return core.node_dig(pos, node, digger)
		else
			return false
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if placer ~= nil and core.is_player(placer) then
			if ch_core.get_player_role(placer) == "admin" then
				return core.item_place(itemstack, placer, pointed_thing)
			else
				ch_core.systemovy_kanal(placer:get_player_name(), "Tento předmět může umísťovat jen Administrace!")
				return
			end
		end
	end,
}

local wall_thickness = 1/16
local ap_width = 2
local ap_height = 2 + 1/16
local ap_depth = 1
local ap_depth2 = 0.5

ch_core.register_nodes(common_def, {
	["ch_containers:ceiling"] = {
		description = "strop kontejneru",
		tiles = {{name = "area_containers_wall.png^[makealpha:204,204,204", backface_culling = true}},
		use_texture_alpha = "clip",
		light_source = 3,
		groups = {ch_container = 1, not_in_creative_inventory = 1},
	},
	["ch_containers:wall"] = {
		description = "stěna kontejneru",
		paramtype2 = "color",
		palette = "unifieddyes_palette_extended.png",
		light_source = 3,
		groups = {ch_container = 1, not_in_creative_inventory = 1, ud_param2_colorable = 1},
	},
	["ch_containers:transparent_wall"] = {
		description = "stěna kontejneru (průhledná)",
		tiles = {{name = "area_containers_wall.png^[makealpha:204,204,204", backface_culling = false}},
		use_texture_alpha = "clip",
		paramtype2 = "none",
		-- palette = "unifieddyes_palette_extended.png",
		light_source = 3,
		groups = {ch_container = 1, not_in_creative_inventory = 1},
	},
	["ch_containers:floor"] = {
		description = "podlaha kontejneru",
		paramtype2 = "color",
		palette = "unifieddyes_palette_extended.png",
		groups = {ch_container = 1, not_in_creative_inventory = 1, ud_param2_colorable = 1, fall_damage_add_percent = -100},
		light_source = 3,
	},
	["ch_containers:control_panel"] = {
		description = "ovládací panel kontejneru",
		tiles = {{name = "ch_core_white_pixel.png", backface_culling = true}},
		overlay_tiles = {
			"",
			"",
			{name = "ch_containers_piepad.png", backface_culling = true, color = "white"},
		},
		paramtype2 = "color",
		palette = "unifieddyes_palette_extended.png",
		light_source = 3,
		groups = {ch_container = 1, not_in_creative_inventory = 1, ud_param2_colorable = 1},
		on_rightclick = internal.cp_on_rightclick,
	},
	["ch_containers:access_point"] = {
		drawtype = "nodebox",
		description = "brána do osobních herních kontejnerů (může umístit jen Administrace)",
		tiles = {
			{name = "ch_core_white_pixel.png^[multiply:#008080"},
			{name = "ch_core_white_pixel.png^[multiply:#008080"},
			{name = "ch_core_white_pixel.png"},
			{name = "ch_core_white_pixel.png"},
			{name = "ch_core_white_pixel.png^[multiply:#000000"},
			{name = "[combine:32x32"..
				":0,0=ch_core_white_pixel.png\\^[multiply\\:#808080\\^[resize\\:32x32"..
				":0,30=ch_core_white_pixel.png\\^[multiply\\:#008080\\^[resize\\:32x2"..
				":0,0=ch_containers_piepad.png",
			},
		},
		paramtype2 = "4dir",
		node_box = {
			type = "fixed",
			fixed = {
				-- spodní stěna:
				{
					-0.5, -0.5, 0.5 - ap_depth,
					ap_width - 0.5, wall_thickness - 0.5, 0.5,
				},
				-- horní stěna:
				{
					-0.5, ap_height - 0.5 - wall_thickness, 0.5 - ap_depth,
					ap_width - 0.5, ap_height - 0.5, 0.5,
				},
				-- zadní stěna:
				{
					-0.5, wall_thickness - 0.5, 0.5 - wall_thickness,
					ap_width - 0.5, ap_height - 0.5 - wall_thickness, 0.5,
				},
				-- levá stěna:
				{
					-0.5, wall_thickness - 0.5, 0.5 - ap_depth2 - wall_thickness,
					wall_thickness - 0.5, ap_height - 0.5 - wall_thickness, 0.5 - wall_thickness,
				},
				-- pravá stěna:
				{
					ap_width - 0.5 - wall_thickness, wall_thickness - 0.5, 0.5 - ap_depth2 - wall_thickness,
					ap_width - 0.5, ap_height - 0.5 - wall_thickness, 0.5 - wall_thickness,
				},
			},
		},
		groups = {ch_container = 1},
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			pos = vector.round(pos)
			local storage = assert(internal.storage)
			storage:set_int("ap_x", pos.x)
			storage:set_int("ap_y", pos.y)
			storage:set_int("ap_z", pos.z)
			core.log("action", "ch_containers:access_point placed at ("..pos.x..", "..pos.y..", "..pos.z..")")
		end,
		can_dig = function(pos, player)
			return core.is_player(player) and ch_core.get_player_role(player) == "admin"
		end,
		on_construct = function(pos)
			core.get_meta(pos):set_string("infotext", "brána do osobních herních kontejnerů")
		end,
		on_rightclick = internal.ap_on_rightclick,
	}
})

if core.get_modpath("mesecons_mvps") then
	mesecon.register_mvps_stopper("ch_containers:ceiling")
	mesecon.register_mvps_stopper("ch_containers:wall")
	mesecon.register_mvps_stopper("ch_containers:floor")
	mesecon.register_mvps_stopper("ch_containers:control_panel")
end
