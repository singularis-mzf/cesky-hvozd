ch_core.open_submod("plaster", {})
local colors = {
	-- black = {
--		color = "222222",
--		description = "černá omítka",
--	},
	blue = {
		color = "476092",
		description = "modrá omítka",
	},
	cyan = {
		color = "77B39A",
		description = "tyrkysová omítka",
	},
	dark_green = {
		color = "367342",
		description = "tmavozelená omítka",
	},
	dark_grey = {
		color = "59534E",
		description = "tmavě šedá omítka",
	},
	grey = {
		color = "ADACAA",
		description = "šedá omítka",
	},
	medium_amber_s50 = {
		color = "BAA882",
		description = "okrová omítka",
	},
	orange = {
		color = "FED2A3",
		description = "oranžová omítka",
	},
	pink = {
		color = "FAC4B5",
		description = "růžová omítka",
	},
	red = {
		color = "DD7156",
		description = "červená omítka",
	},
	green = {
		-- color = "83E783",
		color = "8FCE8D",
		description = "zelená omítka",
	},
	white = {
		color = "FFFFFF",
		description = "bílá omítka",
	},
	yellow = {
		color = "D9CD82",
		description = "žlutá omítka",
	},
}

for dye, data in pairs(colors) do
	local def = {
		description = data.description,
        tiles = {"ch_core_clay.png^[multiply:#"..data.color},
		is_ground_content = false,
		paramtype2 = "facedir",
		groups = {cracky = 1, plaster = 1},
		sounds = default.node_sound_stone_defaults(),
	}
    core.register_node("ch_core:plaster_"..dye, def)
	core.register_craft({output = "ch_core:plaster_"..dye, type = "shapeless", recipe = {"group:plaster", "dye:"..dye}})
end
core.register_craft({
    output = "ch_core:plaster_grey 4",
    type = "shapeless",
    recipe = {"group:sand", "basic_materials:wet_cement", "default:clay", "default:clay"}})
ch_core.close_submod("plaster", {})
