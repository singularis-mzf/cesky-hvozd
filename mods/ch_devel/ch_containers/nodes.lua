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
	["ch_containers:floor"] = {
		description = "podlaha kontejneru",
		paramtype2 = "color",
		palette = "unifieddyes_palette_extended.png",
		groups = {ch_container = 1, not_in_creative_inventory = 1, ud_param2_colorable = 1},
		light_source = 3,
	},
	["ch_containers:control_panel"] = {
		description = "ovládací panel kontejneru",
		tiles = {{name = "ch_core_white_pixel.png"}}, -- TODO
		paramtype2 = "none",
		light_source = 3,
		groups = {ch_container = 1, not_in_creative_inventory = 1},
		on_rightclick = internal.cp_on_rightclick,
	},
	["ch_containers:access_point"] = {
		description = "brána do osobních herních kontejnerů (může umístit jen Administrace)",
		tiles = {{name = "ch_core_white_pixel.png^[multiply:#009900"}}, -- TODO
		paramtype2 = "4dir",
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
