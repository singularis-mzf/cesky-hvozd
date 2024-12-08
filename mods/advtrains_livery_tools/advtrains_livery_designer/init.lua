local S = minetest.get_translator("advtrains_livery_designer")

----------------------------------------------------------------------------------------

local function get_materials_minetest_game()
	return {
		base_game	= "Minetest Game",

		bronze_ingot	= "default:bronze_ingot",
		diamond			= "default:diamond",
		dye_blue		= "dye:blue",
		dye_green		= "dye:green",
		dye_red			= "dye:red",
		glass			= "default:glass",
		gold_ingot		= "default:gold_ingot",
		mese			= "default:mese",
		obsidian_glass	= "default:obsidian_glass",
	}
end

local function get_materials_mineclonia()
	return {
		base_game	= "Mineclonia",

		bronze_ingot	= "mcl_core:gold_ingot",	-- bronze is not available
		diamond			= "mcl_core:diamond",
		dye_blue		= "mcl_dyes:blue",
		dye_green		= "mcl_dyes:green",
		dye_red			= "mcl_dyes:red",
		glass			= "mcl_core:glass",
		gold_ingot		= "mcl_core:gold_ingot",
		mese			= minetest.get_modpath("mesecons_torch") and "mesecons_torch:redstoneblock" or "mcl_core:lapisblock",
		obsidian_glass	= "mcl_core:glass_black",	-- obsidian glass is not available
	}
end

local function get_materials_voxelibre()
	return {
		base_game	= "VoxeLibre/MineClone2",

		bronze_ingot	= "mcl_core:gold_ingot",	-- bronze is not available
		diamond			= "mcl_core:diamond",
		dye_blue		= "mcl_dye:blue",
		dye_green		= "mcl_dye:green",
		dye_red			= "mcl_dye:red",
		glass			= "mcl_core:glass",
		gold_ingot		= "mcl_core:gold_ingot",
		mese			= minetest.get_modpath("mesecons_torch") and "mesecons_torch:redstoneblock" or "mcl_core:lapisblock",
		obsidian_glass	= "mcl_core:glass_black",	-- obsidian glass is not available
	}
end

local function get_materials_farlands_reloaded()
	return {
		base_game	= "Farlands Reloaded",

		bronze_ingot	= "fl_ores:bronze_ingot",
		diamond			= "fl_ores:diamond_ore",
		dye_blue		= "fl_dyes:blue_dye",
		dye_green		= "fl_dyes:green_dye",
		dye_red			= "fl_dyes:red_dye",
		glass			= "fl_glass:framed_glass",
		gold_ingot		= "fl_ores:gold_ingot",
		mese			= "fl_ores:bronze_ingot",
		obsidian_glass	= "fl_ores:bronze_ingot",	-- obsidian is not yet available, use an alternate for now.
	}
end

local function get_materials_hades_revisited()
	return {
		base_game	= "Hades Revisited",

		bronze_ingot	= "hades_core:bronze_ingot",
		diamond			= "hades_core:diamond",
		dye_blue		= "hades_dye:blue",
		dye_green		= "hades_dye:green",
		dye_red			= "hades_dye:red",
		glass			= "hades_core:glass",
		gold_ingot		= "hades_core:gold_ingot",
		mese			= "hades_core:mese",
		obsidian_glass	= "hades_core:obsidian_glass",
	}
end

local function get_materials()
	if minetest.get_modpath("default") and minetest.get_modpath("dye") then
		return get_materials_minetest_game()
	end

	if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_dyes") then
		return get_materials_mineclonia()
	end

	if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_dye") then
		return get_materials_voxelibre()
	end

	if minetest.get_modpath("fl_dyes") and minetest.get_modpath("fl_glass") and minetest.get_modpath("fl_ores") then
		return get_materials_farlands_reloaded()
	end

	if minetest.get_modpath("hades_core") and minetest.get_modpath("hades_dye") then
		return get_materials_hades_revisited()
	end

	return nil
end

local materials = get_materials()

----------------------------------------------------------------------------------------

local callback_functions = {}
local livery_designer_tool = "advtrains_livery_designer:livery_designer"
local livery_designer_form = "advtrains_livery_designer:livery_designer_form"
local max_visible_overlay_controls = 5
local overlay_row_height = 0.8
local overlay_list_scroll_height = overlay_row_height * max_visible_overlay_controls
local overlay_list_height = 0.1 + overlay_list_scroll_height
local overlay_control_height = overlay_row_height - 0.2
local edit_livery_design_tooltip = "tooltip[11.25,7.0;2.0,0.8;"..S("Copies the livery design into the editor and then activates the editor.").."\n\n"..S("The existing design in the editor will be overwritten.").."]"
local apply_livery_design_tooltip = "tooltip[13.375,7.0;2.0,0.8;"..S("Applies the livery design to the wagon.").."]"
local undefined_str = "<"..S("Undefined")..">"
local unknown_str = "<"..S("Unknown")..">"

minetest.register_tool(livery_designer_tool, {
	description = S("Livery Designer Tool"),
	inventory_image = "advtrains_livery_designer_tool.png",
	wield_image = "advtrains_livery_designer_tool.png",
	stack_max = 1,
})

-- Only register the crafting recipe if the needed mods and their materials are available.
if materials then
	minetest.register_craft({
		output = livery_designer_tool,
		recipe = {
			{materials.dye_red, materials.obsidian_glass, materials.diamond},
			{materials.dye_green, materials.mese, materials.gold_ingot},
			{materials.dye_blue, materials.glass, materials.bronze_ingot},
		}
	})
end

advtrains_livery_designer = {
	contexts = {},
	tool_name = livery_designer_tool,
}

--------------------------------------------------------------------------------------------------------

function advtrains_livery_designer.get_mod_version()
	return {major = 0, minor = 8, patch = 5}
end

-- This utility function is intended to allow dependent mods to check if the
-- needed version of advtrains_livery_designer is in use. It returns true if
-- the current version of advtrains_livery_designer is equal to or greater
-- than the given version info. The given version info can have nil values for
-- patch or patch and minor numbers in which case those values will be
-- ignored.
function advtrains_livery_designer.is_compatible_mod_version(version_info)
	local current_mod_info = advtrains_livery_designer.get_mod_version()

	local major = tonumber(version_info.major)
	if not major or major > current_mod_info.major then
		return false
	end

	if major < current_mod_info.major then
		return true
	end

	local minor = tonumber(version_info.minor)
	local patch = tonumber(version_info.patch)
	if not minor then
		return not patch
	end

	if minor > current_mod_info.minor then
		return false
	end

	if minor < current_mod_info.minor then
		return true
	end

	if patch and patch > current_mod_info.patch then
		return false
	end

	return true
end

--------------------------------------------------------------------------------------------------------

local color_definitions = {
	{value = "#FA8072", name = S("Salmon")},
	{value = "#DC143C", name = S("Crimson")},
	{value = "#FF0000", name = S("Red")},
	{value = "#800000", name = S("Maroon")},
	{value = "#FFC0CB", name = S("Pink")},
	{value = "#FF1493", name = S("Deep Pink")},
	{value = "#FF7F50", name = S("Coral")},
	{value = "#FF4500", name = S("Orange Red")},
	{value = "#FF8C00", name = S("Dark Orange")},
	{value = "#FFA500", name = S("Orange")},
	{value = "#FFD700", name = S("Gold")},
	{value = "#FFFF00", name = S("Yellow")},
	{value = "#F0E68C", name = S("Khaki")},
	{value = "#DDA0DD", name = S("Plumb")},
	{value = "#DA70D6", name = S("Orchid")},
	{value = "#FF00FF", name = S("Magenta")},
	{value = "#8A2BE2", name = S("Blue Violet")},
	{value = "#800080", name = S("Purple")},
	{value = "#6A5ACD", name = S("Slate Blue")},
	{value = "#ADFF2F", name = S("Green Yellow")},
	{value = "#00FF00", name = S("Lime")},
	{value = "#2E8B57", name = S("Sea Green")},
	{value = "#008000", name = S("Green")},
	{value = "#006400", name = S("Dark Green")},
	{value = "#808000", name = S("Olive")},
	{value = "#008080", name = S("Teal")},
	{value = "#00FFFF", name = S("Cyan")},
	{value = "#40E0D0", name = S("Turquoise")},
	{value = "#ADD8E6", name = S("Light Blue")},
	{value = "#87CEEB", name = S("Sky Blue")},
	{value = "#4682B4", name = S("Steel Blue")},
	{value = "#4169E1", name = S("Royal Blue")},
	{value = "#0000FF", name = S("Blue")},
	{value = "#000080", name = S("Navy")},
	{value = "#F5DEB3", name = S("Wheat")},
	{value = "#D2B48C", name = S("Tan")},
	{value = "#DAA520", name = S("Goldenrod")},
	{value = "#D2691E", name = S("Chocolate")},
	{value = "#A0522D", name = S("Sienna")},
	{value = "#8B4513", name = S("Saddle Brown")},
	{value = "#A52A2A", name = S("Brown")},
	{value = "#FFFFFF", name = S("White")},
	{value = "#FFFAFA", name = S("Snow")},
	{value = "#F0FFFF", name = S("Azure")},
	{value = "#FFFFF0", name = S("Ivory")},
	{value = "#FAF0E6", name = S("Linen")},
	{value = "#F5F5DC", name = S("Beige")},
	{value = "#C0C0C0", name = S("Silver")},
	{value = "#808080", name = S("Grey")},
	{value = "#708090", name = S("Slate Grey")},
	{value = "#696969", name = S("Dim Grey")},
	{value = "#2F4F4F", name = S("Dark Slate Grey")},
	{value = "#000000", name = S("Black")},
}

-- Build a table for lookup of a color value by name
local color_definitions_name_lookup = {}
for _, color_definition in ipairs(color_definitions) do
	color_definitions_name_lookup[color_definition.name] = color_definition.value
end

local function get_color_by_name(color_name)
	return color_definitions_name_lookup[color_name]
end

-- Build a table for lookup of a color name by value
local color_definitions_value_lookup = {}
for _, color_definition in ipairs(color_definitions) do
	color_definitions_value_lookup[color_definition.value] = color_definition.name
end

local function get_color_name_by_value(color)
	return color_definitions_value_lookup[color]
end

-- Build a table of color override options
local color_overrides = {
	S("None"),
	S("Custom"),
}
for _, color_definition in ipairs(color_definitions) do
	table.insert(color_overrides, color_definition.name)
end
local color_override_options = table.concat(color_overrides, ",")

-- Build a table of predefined color options (for use by the color selector)
local predefined_colors = {
	S("Custom"),
}
for _, color_definition in ipairs(color_definitions) do
	table.insert(predefined_colors, color_definition.name)
end
local predefined_color_options = table.concat(predefined_colors, ",")

--------------------------------------------------------------------------------------------------------

local function get_index(array, value)
	for idx, val in ipairs(array) do
		if val == value then
			return idx
		end
	end
	return nil
end

local function get_livery_name_index(array, value)
	for idx, val in ipairs(array) do
		if val.livery_name == value then
			return idx
		end
	end
	return nil
end

local function is_valid_wagon(wagon)
	return wagon and wagon.id and advtrains.wagons[wagon.id] and advtrains.wagons[wagon.id].type
end

--------------------------------------------------------------------------------------------------------

local function get_color_from_color_components(r, g, b)
	return string.format("#%02X%02X%02X", r, g, b)
end

local function get_color_components_from_color(color)
	-- Skip leading "#" in color
	local color_components = {
		r = tonumber("0x"..color:sub(2, 3)),
		g = tonumber("0x"..color:sub(4, 5)),
		b = tonumber("0x"..color:sub(6, 7)),
	}
	return color_components
end

local function is_valid_color(color)
	return #color == 7 and color:match("#%x%x%x%x%x%x")
end

--------------------------------------------------------------------------------------------------------

local function get_or_create_context(player)
	local name = player:get_player_name()
	local context = advtrains_livery_designer.contexts[name]
	if not context then
		advtrains_livery_designer.contexts[name] = {}
	end
	return context
end

local function set_context(player, context)
	advtrains_livery_designer.contexts[player:get_player_name()] = context
end

local function remove_context(player)
	advtrains_livery_designer.contexts[player:get_player_name()] = nil
end

minetest.register_on_joinplayer(function(player)
	get_or_create_context(player)
end)

minetest.register_on_leaveplayer(function(player)
	remove_context(player)
end)

local function play_apply_sound(wagon)
	minetest.sound_play("advtrains_livery_designerr_tool", {object = wagon.object, gain = 0.06, max_hear_distance = 11})
end

--------------------------------------------------------------------------------------------------------

function advtrains_livery_designer.register_mod(mod_name, apply_wagon_livery_textures, optional_callback_functions)
	assert(mod_name, "Missing required mod name")
	assert(apply_wagon_livery_textures, "Missing required callback function")

	advtrains_livery_database.register_mod(mod_name, optional_callback_functions)

	if not callback_functions[mod_name] then
		callback_functions[mod_name] = {
				apply_wagon_livery_textures = apply_wagon_livery_textures,
			}
	end
end

local function update_overlay_controls(wagon_livery_template, livery_design, overlay_controls)
	if not wagon_livery_template or not livery_design then
		return
	end

	-- Clear the overlay control values but keep the control entries since they determine what is visible in the UI.
	for key, _ in pairs(overlay_controls) do
		overlay_controls[key] = nil
	end

	for id, overlay in ipairs(wagon_livery_template.overlays) do	-- This will need to change if supporting resequenced overlays.
		local overlay_color = livery_design.overlays and livery_design.overlays[id] and livery_design.overlays[id].color or nil	-- A template overlay is not required to be present in a livery_design
		local override_selection_idx = overlay_color and 2 or 1

		-- Update override_selection_idx if the overlay color matches one of the named colors
		if override_selection_idx == 2 then
			local predefined_color_name = get_color_name_by_value(overlay_color)
			override_selection_idx = get_index(color_overrides, predefined_color_name) or 2
		end

		overlay_controls[id] = {
			name = overlay.name or undefined_str,
			override_selection_idx = override_selection_idx,
			override_selection_name = color_overrides[override_selection_idx],
			color = livery_design.overlays[id] and livery_design.overlays[id].color,
		}
	end
end

local function update_color_selector_controls(color_selector_dialog)
	local color = color_selector_dialog.current_color
	local color_name = get_color_name_by_value(color)

	-- Update the quick select control
	color_selector_dialog.controls.predefined_color_selection_idx = get_index(predefined_colors, color_name) or 1

	-- Update the color component scrollbars
	local color_components = get_color_components_from_color(color)
	color_selector_dialog.controls.component_scrollbar_pos = {
		r = color_components.r,
		g = color_components.g,
		b = color_components.b,
	}
end

local function clone_control_settings(src_controls)
	local controls = {
		livery_template_name_selection = src_controls.livery_template_name_selection,
		overlays = {},
	}
	for id, overlay in ipairs(src_controls.overlays) do
		controls.overlays[id] = {
			name = overlay.name,
			override_selection_idx = overlay.override_selection_idx,
			override_selection_name = overlay.override_selection_name,
			color = overlay.color,
		}
	end
	return controls
end

local function clone_tab(src_tab)
	local tab = {
		textures = advtrains_livery_database.clone_textures(src_tab.textures),
		livery_design = advtrains_livery_database.clone_livery_design(src_tab.livery_design),
		controls = clone_control_settings(src_tab.controls),
	}
	return tab
end

-- This function is similar to clone_tab() but is used when copying a livery design from
-- the predefined_liveries_tab which doesn't have the same controls as the other tabs.  Thus,
-- the target tab must be updated from the selected livery rather than have values copied
-- from the source tab.
local function update_tab_from_predefined_livery_design(context, target_tab)
		target_tab.textures = advtrains_livery_database.clone_textures(context.predefined_liveries_tab.textures)
		target_tab.livery_design = advtrains_livery_database.clone_livery_design(context.predefined_liveries_tab.livery_design)
		local wagon_livery_template = advtrains_livery_database.get_wagon_livery_template(context.wagon_type, target_tab.livery_design.livery_template_name)
		target_tab.controls.livery_template_name_selection = get_index(context.wagon_valid_livery_template_names, target_tab.livery_design.livery_template_name)
		update_overlay_controls(wagon_livery_template, target_tab.livery_design, target_tab.controls.overlays)
end

-- Record the current state of the override values. These values are restored to the override
-- controls later when switching to a different livery template in order to view the newly
-- selected template with the overrides that had been displayed.
local function save_override_values(context)
	context.override_values = {}
	for seq_num, overlay in ipairs(context.livery_editor_tab.controls.overlays) do
		if overlay.color then
			context.override_values[seq_num] = overlay.color
		end
	end
end

local function save_override_value(context, idx, color)
	context.override_values[idx] = color
end

local function restore_override_values(context)
	-- Update the color overlays in the livery design
	if context.override_values then
		for idx, override_value in pairs(context.override_values) do
			-- Update the livery design with the specified color
			if not context.livery_editor_tab.livery_design.overlays[idx] then
				-- Only add an overlay to the livery design if the template supports it.
				local wagon_livery_template = advtrains_livery_database.get_wagon_livery_template(context.wagon_type, context.livery_editor_tab.livery_design.livery_template_name)
				if wagon_livery_template and wagon_livery_template.overlays and idx <= #wagon_livery_template.overlays then
					-- A color override did not previously exist in the livery design so create one
					context.livery_editor_tab.livery_design.overlays[idx] = {
						id = idx,
						color = override_value,
					}
				end
			else
				-- Update the existing color override value in the livery design
				context.livery_editor_tab.livery_design.overlays[idx].color = override_value
			end
		end
	end
end

local function update_predefined_liveries_tab_selection(context, selection_idx)
	context.predefined_liveries_tab.controls.livery_name_selection_idx = selection_idx
	context.predefined_liveries_tab.selected_livery_name = context.wagon_predefined_livery_names[selection_idx].livery_name
	context.predefined_liveries_tab.livery_design = advtrains_livery_database.get_predefined_livery(context.wagon_type, context.predefined_liveries_tab.selected_livery_name)
	context.predefined_liveries_tab.textures = advtrains_livery_database.get_livery_textures_from_design(context.predefined_liveries_tab.livery_design, context.wagon.id)
end

local function are_livery_templates_equivalent(livery_template_1, livery_template_2)
	if not livery_template_1 or
	   not livery_template_2 or
	   livery_template_1.overlays and not livery_template_2.overlays or
	   not livery_template_1.overlays and livery_template_2.overlays then
		return false
	end

	-- Every overlay in livery template 1 should be in livery template 2 and...
	for id, overlay in pairs(livery_template_1.overlays) do
		if not livery_template_2.overlays[id] or
		   overlay.name ~= livery_template_2.overlays[id].name then
			return false
		end
	end

	-- ...every overlay in livery template 2 should also be in livery template 1
	for id, overlay in pairs(livery_template_2.overlays) do
		if not livery_template_1.overlays[id] or
		   overlay.name ~= livery_template_1.overlays[id].name then
			return false
		end
	end
	return true
end

local function are_livery_designs_equivalent(livery_design_1, livery_design_2)
	if not livery_design_1 or
	   not livery_design_2 or
	   livery_design_1.wagon_type ~= livery_design_2.wagon_type or
	   livery_design_1.livery_template_name ~= livery_design_2.livery_template_name or
	   livery_design_1.overlays and not livery_design_2.overlays or
	   not livery_design_1.overlays and livery_design_2.overlays then
		return false
	end

	-- Every overlay in livery design 1 should be in livery design 2 and...
	for seq_number, overlay in pairs(livery_design_1.overlays) do
		if not livery_design_2.overlays[seq_number] or
		   overlay.id ~= livery_design_2.overlays[seq_number].id or
		   overlay.color ~= livery_design_2.overlays[seq_number].color then
			return false
		end
	end

	-- ...every overlay in livery design 2 should also be in livery design 1
	for seq_number, overlay in pairs(livery_design_2.overlays) do
		if not livery_design_1.overlays[seq_number] or
		   overlay.id ~= livery_design_1.overlays[seq_number].id or
		   overlay.color ~= livery_design_1.overlays[seq_number].color then
			return false
		end
	end
	return true
end

local function get_livery_designer_context(player, wagon)
	-- Validate the given wagon
	if not is_valid_wagon(wagon) then
		return
	end

	local wagon_type = advtrains.wagons[wagon.id].type
	local wagon_mod_name = advtrains_livery_database.get_wagon_mod_name(wagon_type)
	if not wagon_mod_name then
		return
	end

	-- Validate that livery options have been registered for the given wagon.
	local livery_template_names = advtrains_livery_database.get_livery_template_names_for_wagon(wagon_type)
	if #livery_template_names < 1 then
		-- There is no reason to continue if there are no valid options to present to the player.
		return
	end
	table.sort(livery_template_names, function(a, b) return a < b end)

	local actual_textures = advtrains_livery_database.clone_textures(advtrains.wagon_objects[wagon.id]:get_properties().textures)
	local livery_design = advtrains_livery_database.get_livery_design_from_textures(wagon_type, actual_textures, wagon.id)
	local current_textures = livery_design and advtrains_livery_database.get_livery_textures_from_design(livery_design, wagon.id)
	local editor_livery_design = livery_design
	local editor_textures = advtrains_livery_database.clone_textures(current_textures)
	if not editor_livery_design then
		-- The current livery texture cannot be mapped to a known livery design.  Initialize the editor
		-- with a default design for for given wagon type so that the user can optionally replace the
		-- unknown livery with a known one.
		editor_livery_design = {
			wagon_type = wagon_type,
			livery_template_name = livery_template_names[1],
			overlays = {},
		}
		editor_textures = advtrains_livery_database.get_livery_textures_from_design(editor_livery_design, wagon.id)
	end

	-- Initialize predefined livery name options
	local predefined_livery_names = advtrains_livery_database.get_predefined_livery_names(wagon_type)
	table.sort(predefined_livery_names, function(a, b) return a.livery_name < b.livery_name end)
	local predefined_livery_options = {}
	for _, predefined_livery_name in ipairs(predefined_livery_names) do
		table.insert(predefined_livery_options, minetest.formspec_escape(predefined_livery_name.livery_name))
	end

	local context = {
		current_tab = 2,

		-- This is information about the selected wagon. It does not change while the livery tool is active.
		wagon = wagon,
		wagon_type = wagon_type,
		wagon_model = wagon.mesh,
		wagon_mod_name = wagon_mod_name,
		wagon_valid_livery_template_names = livery_template_names,
		wagon_livery_options = table.concat(livery_template_names, ","),
		wagon_predefined_livery_names = predefined_livery_names,
		wagon_predefined_livery_options = table.concat(predefined_livery_options, ","),

		-- These controls on the current/edit/saved livery tabs share a common state.
		common_controls = {
			overlay_scrollbar_pos = 0,
			rotate_checkbox = true,
		},

		-- The following is a cache of override values that is used to preserve them when
		-- switching between liveries. They are sequence based, not related to overlay names.
		-- The cache is not part of livery_editor_tab since it is not to be included when
		-- cloning tabs.
		override_values = {},

		-- This a a snapshot of the selected wagon's design. It is only updated when the user applies
		-- a livery design to the wagon. It should otherwise not be updated or edited.
		current_livery_tab = {
			textures = current_textures,
			livery_design = advtrains_livery_database.clone_livery_design(livery_design),
			controls = {
				livery_template_name_selection = livery_design and get_index(livery_template_names, livery_design.livery_template_name) or 1,
				overlays = {},
			},
		},
		-- This is the livery design currently being edited. It can be updated by the user making edits
		-- or when the user copies a livry design to the editer from a different tab.
		livery_editor_tab = {
			textures = editor_textures,
			livery_design = advtrains_livery_database.clone_livery_design(editor_livery_design),
			controls = {
				livery_template_name_selection = editor_livery_design and get_index(livery_template_names, editor_livery_design.livery_template_name) or 1,
				overlays = {},
			},
		},
		predefined_liveries_tab = {
			livery_names = advtrains_livery_database.get_predefined_livery_names(wagon_type),
			controls = {
				livery_name_selection_idx = 1,
			}
		},
		-- This is the color picker control. It needs to be initialized with a color and the id of the
		-- button that initiated it. It will then update the color override for the applicable override
		-- when the user selects the "OK" button.
		color_selector_dialog = {
			is_active = false,
			color_button_idx = 0,		-- 0 is an invalid id. A value of 0 indicates that the dialog has not been initialized.
			current_color = "#404040",
			controls = {
				predefined_color_selection_idx = 1,
				component_scrollbar_pos = {r = 500, g = 500, b = 500},
			},
		},
		-- This is the model preview control which is used to display an enlarged preview of the model.
		model_preview_dialog = {
			is_active = false,
			textures = {},
		},
		-- This is the livery template info dialog which is used to display some additional info about a template.
		livery_template_info_dialog = {
			is_active = false,
			livery_template_name = nil,
			textures = {},
		},

		applied = true,	-- The current livery is is prepopulated into the livery editor so consider it to be "applied".
	}

	-- Update context.current_livery_tab.controls and context.livery_editor_tab.controls with overlay information.
	local wagon_livery_template = livery_design and advtrains_livery_database.get_wagon_livery_template(wagon_type, livery_design.livery_template_name)
	update_overlay_controls(wagon_livery_template, livery_design, context.current_livery_tab.controls.overlays)

	local editor_livery_template = editor_livery_design and advtrains_livery_database.get_wagon_livery_template(wagon_type, editor_livery_design.livery_template_name)
	update_overlay_controls(editor_livery_template, editor_livery_design, context.livery_editor_tab.controls.overlays)

	-- Initialize override_values
	save_override_values(context)

	-- Restore the relevant values from the previous invocation of the tool, if they exist.
	local previous_context = get_or_create_context(player)
	if previous_context.common_controls then
		-- Get the rotation checkbox from the previous session
		context.common_controls.rotate_checkbox = previous_context.common_controls.rotate_checkbox
	end
	if previous_context.current_tab then
		-- Get the tab that was last active
		context.current_tab = previous_context.current_tab
	end
	if previous_context.saved_livery_tab and previous_context.saved_livery_tab.textures and previous_context.saved_livery_tab.livery_design then
		if context.wagon_type == previous_context.wagon_type then
			-- Get the saved livery
			context.saved_livery_tab = clone_tab(previous_context.saved_livery_tab)
		else
			--	If the previous_context's save livery tab is not empty and its livery design's
			--	template name exists for the current wagon type and the templates for the
			--	previous and curent wagon types are equivalent then convert the previous
			--	context's save tab into one that is valid for the new context.
			local previous_livery_template_name = previous_context.saved_livery_tab.livery_design.livery_template_name
			if previous_livery_template_name then
				local previous_livery_template = advtrains_livery_database.get_wagon_livery_template(previous_context.wagon_type, previous_livery_template_name)
				if previous_livery_template then
					-- Determine if the template name is valid for the current wagon type
					local current_livery_template = advtrains_livery_database.get_wagon_livery_template(context.wagon_type, previous_livery_template_name)
					if current_livery_template and are_livery_templates_equivalent(current_livery_template, previous_livery_template) then
						-- Now that equivalent livery templates are confirmed to exist
						-- for both the current and previous wagon types, copy the
						-- previously saved livery design tab to the current context
						-- and adjust it as needed for the current wagon type.
						context.saved_livery_tab = clone_tab(previous_context.saved_livery_tab)
						context.saved_livery_tab.livery_design.wagon_type = context.wagon_type
						context.saved_livery_tab.textures = advtrains_livery_database.get_livery_textures_from_design(context.saved_livery_tab.livery_design, context.wagon.id)
						context.saved_livery_tab.controls.livery_template_name_selection = get_index(context.wagon_valid_livery_template_names, context.saved_livery_tab.livery_design.livery_template_name) or 1
					end
				end
			end
		end
	end
	if previous_context.predefined_liveries_tab then
		if context.wagon_type == previous_context.wagon_type then
			-- Get the selected predefined livery selection from the previous session
			context.predefined_liveries_tab.controls.livery_name_selection_idx = previous_context.predefined_liveries_tab.controls.livery_name_selection_idx
		elseif previous_context.predefined_liveries_tab.selected_livery_name then
			-- Since the wagon types are different, try to find the same predefined livery
			-- name for the current wagon type that was selected for the previous wagon type.
			-- They could be at different index postions for their respective wagon types
			-- since each wagon type can have a different set of predefined liveries.
			local livery_name_selection_idx = get_livery_name_index(context.wagon_predefined_livery_names, previous_context.predefined_liveries_tab.selected_livery_name)
			if livery_name_selection_idx then
				context.predefined_liveries_tab.controls.livery_name_selection_idx = livery_name_selection_idx
			end
		end
	end
	if previous_context.color_selector_dialog and previous_context.color_selector_dialog.saved_color then
		-- Get saved color from previous session of the color selector dialog
		context.color_selector_dialog.saved_color = previous_context.color_selector_dialog.saved_color
	end

	if context.wagon_predefined_livery_names and #context.wagon_predefined_livery_names > 0 then
		update_predefined_liveries_tab_selection(context, context.predefined_liveries_tab.controls.livery_name_selection_idx)
	else
		-- There are no predefined liveries for the wagon type
		context.predefined_liveries_tab.selected_livery_name = nil
		context.predefined_liveries_tab.textures = nil
		context.predefined_liveries_tab.livery_design = nil
		context.predefined_liveries_tab.controls.livery_name_selection_idx = 0
	end

	return context
end

local function get_model_preview_formspec(context, wagon_textures, show_rotate_checkbox)
	local formspec = ""
	if context.wagon_model and wagon_textures and #wagon_textures > 0 then
		local textures = table.concat(wagon_textures, ",")

		local rotate_model = false
		if show_rotate_checkbox then
			rotate_model = context.common_controls.rotate_checkbox
		end
		formspec = formspec..
			"container[11.25,1.5]"..
			"box[0,0;6.25,5;#ffffff09]"..
			"model[0,0;6.25,5;WagonModelPreview;"..context.wagon_model..";"..textures..";-15,45;"..tostring(rotate_model)..";true;0,0]"
		if show_rotate_checkbox then
			formspec = formspec..
				"checkbox[0.1,4.75;RotationCheckbox;"..S("Rotate")..";"..tostring(rotate_model).."]"
		end
		formspec = formspec..
			"button[5.75,4.5;0.4,0.4;ExpandPreviewButton;<>]"..
			"tooltip[5.75,4.5;0.4,0.4;"..S("Expands the livery preview.").."]"..
			"container_end[]"
	end
	return formspec
end

local function get_model_preview_formspec_section(context)
	local formspec = ""
	if context.wagon_model and context.model_preview_dialog.textures and context.model_preview_dialog.textures[1] then
		local rotate_model = context.common_controls.rotate_checkbox
		local textures = table.concat(context.model_preview_dialog.textures, ",")
		formspec = formspec..
			"container[0.25,0.25]"..
			"box[0,0;19.5,15.5;#ffffff09]"..
			"model[0,0;19.5,15.5;WagonModelPreview;"..context.wagon_model..";"..textures..";-15,45;"..tostring(rotate_model)..";true;0,0]"..
			"checkbox[0.1,15.25;RotationCheckbox;"..S("Rotate")..";"..tostring(rotate_model).."]"..
			"button[19.0,15.0;0.4,0.4;CollapsePreviewButton;><]"..
			"tooltip[19.0,15.0;0.4,0.4;"..S("Collapses the livery preview.").."]"..
			"container_end[]"
	end
	return formspec
end

local function get_livery_template_info_formspec_section(context)
	local formspec = ""
	if context.wagon_type and context.wagon_model and context.livery_template_info_dialog.livery_template_name then
		local livery_template = advtrains_livery_database.get_wagon_livery_template(context.wagon_type, context.livery_template_info_dialog.livery_template_name)

		formspec = formspec..
			"container[0.1,0.1]"..
			"box[0,0;13.8,0.5;#555555ff]"..
			"label[5.0,0.275;"..S("Livery Template Information").."]"..
			"container_end[]"..
			"container[0.25,1.00]"..
			"container[0.0,0.25]"..
			"label[0.00,0.000;"..S("Livery Template")..":]"..
			"label[0.30,0.575;"..context.livery_template_info_dialog.livery_template_name.."]"..
			"container_end[]"..

			"container[0.0,1.5]"..
			"label[0.00,0.000;"..S("Source Mod")..":]"..
			"label[0.30,0.575;"..(livery_template.livery_mod or "").."]"..
			"container_end[]"..

			"container[0.0,2.75]"..
			"label[0.00,0.000;"..S("Template Designer")..":]"..
			"label[0.30,0.575;"..(livery_template.designer or "").."]"..
			"container_end[]"..

			"container[0.0,4.00]"..
			"label[0.00,0.000;"..S("Base Texture Filename")..":]"..
			"label[0.30,0.575;"..(livery_template.base_textures[1] or "").."]"..
			"container_end[]"..

			"container[0.0,5.25]"..
			"label[0.00,0.000;"..S("Texture Creator")..":]"..
			"label[0.30,0.575;"..(livery_template.texture_creator or "").."]"..
			"container_end[]"..

			"container[0.0,6.5]"..
			"label[0.00,0.000;"..S("Texture License")..":]"..
			"label[0.30,0.575;"..(livery_template.texture_license or "").."]"..
			"container_end[]"..

			"container[0.0,7.75]"..
			"label[0.00,0.000;"..S("Notes")..":]"..
			"textarea[0.30,0.275;13.0,1.0;;;"..(livery_template.notes or "").."]"..
			"container_end[]"..

			"button[11.4,9.25;2.0,0.8;CloseLiveryTemplateInfoDialogButton;OK]"..
			"container_end[]"
	end
	return formspec
end

local function get_current_livery_formspec_section(context)
	local current_livery_design = context.current_livery_tab.livery_design
	local current_livery_template_name = current_livery_design and current_livery_design.livery_template_name or unknown_str

	local formspec =
		"container[0.25,1.0]"..
		"label[0,0.25;"..S("Livery Template")..":]"..
		"label[0.30,0.825;"..current_livery_template_name.."]"

	if current_livery_design then
		formspec = formspec..
			"label[0,1.45;"..S("Color Overrides")..":]"..
			"container[0.25,1.65]"..
			"box[0,0;10.5,"..overlay_list_height..";#ffffff09]"

		local overlay_count = #context.current_livery_tab.controls.overlays
		local scroll_pos = context.common_controls.overlay_scrollbar_pos
		local overlay_box_width = 10.4
		local use_overlay_scrollbar = overlay_count > max_visible_overlay_controls
		if use_overlay_scrollbar then
			overlay_box_width = overlay_box_width - .25

			local max_step = overlay_count - max_visible_overlay_controls
			formspec = formspec..
				"scrollbaroptions[arrows=default;thumbsize=1;max="..max_step..";min=0;smallstep=1;largestep=1]"..
				"scroll_container[0,0;10.5,"..overlay_list_scroll_height..";OverlayScrollbar;vertical;"..overlay_row_height.."]"
		end

		for id, overlay in ipairs(context.current_livery_tab.controls.overlays) do
			local overlay_name = overlay.name or undefined_str
			local overlay_color_override = overlay.override_selection_name or "None"
			local overlay_color = overlay.color
			formspec = formspec..
				"container[0,"..(0.1 + (id - 1) * overlay_row_height).."]"..
				"box[0.05,0.0;"..overlay_box_width..","..(overlay_row_height - 0.1)..";#ffffff09]"..
				"label[0.1,0.35;"..id..".]"..
				"label[0.6,0.35;"..overlay_name.."]"..
				"label[4.15,0.35;"..overlay_color_override.."]"
			if overlay_color then
				formspec = formspec..
				"box[8.75,0.05;"..overlay_control_height..","..overlay_control_height..";#252525ff]"..
				"box[8.80,0.09;"..(overlay_control_height - 0.08)..","..(overlay_control_height - 0.08)..";"..overlay_color.."]"..
				"tooltip[8.80,0.09;"..(overlay_control_height - 0.08)..","..(overlay_control_height - 0.08)..";"..overlay_color.."]"
			end
			formspec = formspec..
				"container_end[]"
		end

		if use_overlay_scrollbar then
			formspec = formspec..
				"scroll_container_end[]"..
				"scrollbar[10.25,0.0;.25,"..overlay_list_height..";vertical;OverlayScrollbar;"..scroll_pos.."]"
		end

		formspec = formspec..
			"container_end[]"
	end

	formspec = formspec..
		"container_end[]"..
		get_model_preview_formspec(context, context.current_livery_tab.textures, true)

	if current_livery_design then
		if not are_livery_designs_equivalent(current_livery_design, context.livery_editor_tab.livery_design) then
			formspec = formspec..
				"button[11.25,7.0;2.0,0.8;CurrentLiveryEditButton;"..S("Edit").."]"..
				edit_livery_design_tooltip
		end
	end

	return formspec
end

local function get_livery_editor_formspec_section(context)
	local livery_design = context.livery_editor_tab.livery_design
	local livery_template_name = livery_design and livery_design.livery_template_name or unknown_str

	local formspec =
		"container[0.25,1.0]"..
		"label[0,0.25;"..S("Livery Template")..":]"

	if livery_design then
		local wagon_livery_options = context.wagon_livery_options or undefined_str
		local livery_template_name_selection = context.livery_editor_tab.controls.livery_template_name_selection or 1

		formspec = formspec..
			"dropdown[0.27,0.52;10.5,0.6;EditorLiveryTemplateName;"..wagon_livery_options..";"..livery_template_name_selection.."]"..

			"label[0,1.45;"..S("Color Overrides")..":]"..
			"container[0.25,1.65]"..
			"box[0,0;10.5,"..overlay_list_height..";#ffffff09]"

		local overlay_count = #context.livery_editor_tab.controls.overlays
		local scroll_pos = context.common_controls.overlay_scrollbar_pos
		local overlay_box_width = 10.4
		local use_overlay_scrollbar = overlay_count > max_visible_overlay_controls
		if use_overlay_scrollbar then
			overlay_box_width = overlay_box_width - .25

			local max_step = overlay_count - max_visible_overlay_controls
			formspec = formspec..
				"scrollbaroptions[arrows=default;thumbsize=1;max="..max_step..";min=0;smallstep=1;largestep=1]"..
				"scroll_container[0,0;10.5,"..overlay_list_scroll_height..";OverlayScrollbar;vertical;"..overlay_row_height.."]"
		end
		local override_count = 0

		for id, overlay in ipairs(context.livery_editor_tab.controls.overlays) do
			local overlay_name = overlay.name or undefined_str
			local overlay_color_override = context.livery_editor_tab.controls.overlays and context.livery_editor_tab.controls.overlays[id] and context.livery_editor_tab.controls.overlays[id].override_selection_idx or 1
			local overlay_color = overlay.color

			formspec = formspec..
				"container[0,"..(0.1 + (id - 1) * overlay_row_height).."]"..
				"box[0.05,0.0;"..overlay_box_width..","..(overlay_row_height - 0.1)..";#ffffff09]"..
				"label[0.1,0.35;"..id..".]"..
				"label[0.6,0.35;"..overlay_name.."]"..
				"dropdown[4.12,0.05;4.5,"..overlay_control_height..";ColorOverride"..id..";"..color_override_options..";"..(overlay_color_override or 1).."]"
			if overlay.override_selection_idx > 1 then
				override_count = override_count + 1
				formspec = formspec..
				"box[8.75,0.05;"..overlay_control_height..","..overlay_control_height..";#252525ff]"..
				"box[8.80,0.09;"..(overlay_control_height - 0.08)..","..(overlay_control_height - 0.08)..";"..(overlay_color or "#00000000").."]"..
				"tooltip[8.80,0.09;"..(overlay_control_height - 0.08)..","..(overlay_control_height - 0.08)..";"..(overlay_color or "#00000000").."]"
				if overlay.override_selection_idx > 1 then
					formspec = formspec..
					"button[9.45,0.05;"..overlay_control_height..","..overlay_control_height..";EditColorButton"..(id)..";...]"..
					"tooltip[9.45,0.05;"..overlay_control_height..","..overlay_control_height..";"..S("Edit Color").."]"
				end
			end
			formspec = formspec..
				"container_end[]"
		end

		if use_overlay_scrollbar then
			formspec = formspec..
				"scroll_container_end[]"..
				"scrollbar[10.25,0.0;.25,"..overlay_list_height..";vertical;OverlayScrollbar;"..scroll_pos.."]"
		end

		formspec = formspec..
			"container_end[]"..
			"container_end[]"..
			get_model_preview_formspec(context, context.livery_editor_tab.textures, false)..
			"button[0.5,7.0;0.8,0.8;InfoButton;i]"..
			"tooltip[0.5,7.0;0.8,0.8;"..S("Displays information about the current livery template.").."]"

		if override_count > 0 then
			formspec = formspec..
				"button[1.425,7.0;2.0,0.8;EditorResetButton;"..S("Reset").."]"..
				"tooltip[1.425,7.0;2.0,0.8;"..S("Resets all color overrides to 'None'.").."]"
		end

		if not context.saved_livery_tab or not are_livery_designs_equivalent(context.saved_livery_tab.livery_design, context.livery_editor_tab.livery_design) then
			formspec = formspec..
				"button[11.25,7.0;2.0,0.8;EditorSaveButton;"..S("Save").."]"..
				"tooltip[11.25,7.0;2.0,0.8;"..S("Copies the livery design to the saved livery tab and then activates the saved livery tab.").."\n\n"..S("The currently saved livery design will be overwritten.").."]"
		end

		if not context.applied then
			formspec = formspec..
				"button[13.375,7.0;2.0,0.8;ApplyButton;"..S("Apply").."]"..
				apply_livery_design_tooltip
		end
	else
		formspec = formspec..
			"label[0.30,0.825;"..livery_template_name.."]"..
			"container_end[]"..
			get_model_preview_formspec(context, context.livery_editor_tab.textures, false)
	end

	return formspec
end

local function get_saved_livery_formspec_section(context)
	local formspec = "textarea[0.5,2.5;13.5,2;;;"..S("A livery for this wagon type has not been recently saved.").."]"

	if context.saved_livery_tab and context.saved_livery_tab.livery_design then
		local livery_template_name = context.saved_livery_tab.livery_design.livery_template_name or unknown_str

		formspec =
			"container[0.25,1.0]"..
			"label[0,0.25;"..S("Livery Template")..":]"..
			"label[0.30,0.825;"..livery_template_name.."]"..
			"label[0,1.45;"..S("Color Overrides")..":]"..
			"container[0.25,1.65]"..
			"box[0,0;10.5,"..overlay_list_height..";#ffffff09]"

		local overlay_count = #context.saved_livery_tab.controls.overlays
		local scroll_pos = context.common_controls.overlay_scrollbar_pos
		local overlay_box_width = 10.4
		local use_overlay_scrollbar = overlay_count > max_visible_overlay_controls
		if use_overlay_scrollbar then
			overlay_box_width = overlay_box_width - .25

			local max_step = overlay_count - max_visible_overlay_controls
			formspec = formspec..
				"scrollbaroptions[arrows=default;thumbsize=1;max="..max_step..";min=0;smallstep=1;largestep=1]"..
				"scroll_container[0,0;10.5,"..overlay_list_scroll_height..";OverlayScrollbar;vertical;"..overlay_row_height.."]"
		end

		for id, overlay in ipairs(context.saved_livery_tab.controls.overlays) do
			local overlay_name = overlay.name or undefined_str
			local overlay_color_override = overlay.override_selection_name or "None"
			local overlay_color = overlay.color
			formspec = formspec..
				"container[0,"..(0.1 + (id - 1) * overlay_row_height).."]"..
				"box[0.05,0.0;"..overlay_box_width..","..(overlay_row_height - 0.1)..";#ffffff09]"..
				"label[0.1,0.35;"..id..".]"..
				"label[0.6,0.35;"..overlay_name.."]"..
				"label[4.15,0.35;"..overlay_color_override.."]"
			if overlay_color then
				formspec = formspec..
				"box[8.75,0.05;"..overlay_control_height..","..overlay_control_height..";#252525ff]"..
				"box[8.80,0.09;"..(overlay_control_height - 0.08)..","..(overlay_control_height - 0.08)..";"..overlay_color.."]"..
				"tooltip[8.80,0.09;"..(overlay_control_height - 0.08)..","..(overlay_control_height - 0.08)..";"..overlay_color.."]"
			end
			formspec = formspec..
				"container_end[]"
		end

		if use_overlay_scrollbar then
			formspec = formspec..
				"scroll_container_end[]"..
				"scrollbar[10.25,0.0;.25,"..overlay_list_height..";vertical;OverlayScrollbar;"..scroll_pos.."]"
		end

		formspec = formspec..
			"container_end[]"..
			"container_end[]"..
			get_model_preview_formspec(context, context.saved_livery_tab.textures, true)

		if not are_livery_designs_equivalent(context.saved_livery_tab.livery_design, context.livery_editor_tab.livery_design) then
			formspec = formspec..
				"button[11.25,7.0;2.0,0.8;SavedLiveryEditButton;"..S("Edit").."]"..
				edit_livery_design_tooltip
		end
		if not are_livery_designs_equivalent(context.saved_livery_tab.livery_design, context.current_livery_tab.livery_design) then
			formspec = formspec..
				"button[13.375,7.0;2.0,0.8;SavedLiveryApplyButton;"..S("Apply").."]"..
				apply_livery_design_tooltip
		end
	end

	return formspec
end

local function get_predefined_liveries_formspec_section(context)
	local predefined_livery_count = #context.wagon_predefined_livery_names

	local formspec = "textarea[0.5,2.5;13.5,2;;;"..S("No predefined liveries are available for this wagon type.").."]"
	if predefined_livery_count > 0 then
		local selection_idx = context.predefined_liveries_tab.controls.livery_name_selection_idx
		formspec =
			"container[0.25,1]"..
			"textlist[0,0.5;10.5,5;PredefinedLiveriesTextList;"..context.wagon_predefined_livery_options..";"..selection_idx..";false]"..
			"container_end[]"..
			get_model_preview_formspec(context, context.predefined_liveries_tab.textures, false)

		if not are_livery_designs_equivalent(context.predefined_liveries_tab.livery_design, context.livery_editor_tab.livery_design) then
			formspec = formspec..
				"button[11.25,7.0;2.0,0.8;PredefinedLiveriesEditButton;"..S("Edit").."]"..
				edit_livery_design_tooltip
		end
		if not are_livery_designs_equivalent(context.predefined_liveries_tab.livery_design, context.current_livery_tab.livery_design) then
			formspec = formspec..
				"button[13.375,7.0;2.0,0.8;PredefinedLiveriesApplyButton;"..S("Apply").."]"..
				apply_livery_design_tooltip
		end
	end

	return formspec
end

local function get_color_selector_formspec_section(context)
	local color = context.color_selector_dialog.current_color or "#000000"
	local saved_color = context.color_selector_dialog.saved_color or "#000000"

	local formspec =
		"container[0,0]"..
		"box[0,0;14,7;#333333ff]"..

		"container[0.1,0.1]"..
		"box[0,0;13.8,0.5;#555555ff]"..
		"label[6.0,0.275;"..S("Color Selector").."]"..
		"container_end[]"..

		"container[0.4,1.0]"..
		"label[0.1,0.1;"..S("Preview")..":]"..
		"box[0.0,0.5;3.7,3.7;#0a0a0aff]"..
		"box[0.1,0.6;3.5,3.5;"..color.."ff]"..
		"tooltip[0.1,0.6;3.5,3.5;"..color.."]"..
		"container_end[]"..

		"container[4.5,0.75]"..
		"box[0,0;4.35,1.3;#ffffff09]"..
		"label[0.1,0.28;"..S("Color")..":]"..
		"dropdown[0.1,0.5;4.15,0.7;ColorSelectorQuickSelectDropdown;"..predefined_color_options..";"..context.color_selector_dialog.controls.predefined_color_selection_idx..";true]"..
		"container_end[]"..

		"container[9.25,0.75]"..
		"box[0,0;4.6,1.3;#ffffff09]"..
		"label[0.1,0.28;"..S("Hex Value")..":]"..
		"field[0.1,0.5;2.25,0.7;ColorSelectorInputColor;;"..color.."]"..
		"field_close_on_enter[ColorSelectorInputColor;false]"..
		"button[2.5,0.5;2.0,0.7;ColorSelectorUpdateButton;"..S("Update").."]"..
		"tooltip[2.5,0.5;2.0,0.7;"..S("Updates the current color based on the entered hex value.").."]"..
		"container_end[]"..

		"container[4.5,2.0]"..

		"scrollbaroptions[arrows=default;thumbsize=8;max=255;min=0;smallstep=1;largestep=32]"..

		"container[0,0.5]"..
		"label[0,0;"..S("Red")..":]"..
		"scrollbar[0,0.25;8.2,0.4;horizontal;ColorSelectorScrollBarR;"..context.color_selector_dialog.controls.component_scrollbar_pos.r.."]"..
		"label[8.3,0.47;"..context.color_selector_dialog.controls.component_scrollbar_pos.r.."]"..
		"container_end[]"..

		"container[0,1.5]"..
		"label[0,0;"..S("Green")..":]"..
		"scrollbar[0,0.25;8.2,0.4;horizontal;ColorSelectorScrollBarG;"..context.color_selector_dialog.controls.component_scrollbar_pos.g.."]"..
		"label[8.3,0.47;"..context.color_selector_dialog.controls.component_scrollbar_pos.g.."]"..
		"container_end[]"..

		"container[0,2.5]"..
		"label[0,0;"..S("Blue")..":]"..
		"scrollbar[0,0.25;8.2,0.4;horizontal;ColorSelectorScrollBarB;"..context.color_selector_dialog.controls.component_scrollbar_pos.b.."]"..
		"label[8.3,0.47;"..context.color_selector_dialog.controls.component_scrollbar_pos.b.."]"..
		"container_end[]"..

		"container_end[]"..

		"container[0.3,5.5]"..
		"box[0,0;5.1,1.3;#ffffff09]"..
		"label[0.1,0.25;"..S("Saved Color")..":]"..
		"box[0.1,0.5;0.7,0.7;#0a0a0aff]"..
		"box[0.2,0.6;0.5,0.5;"..saved_color.."ff]"..
		"tooltip[0.2,0.6;0.5,0.5;"..saved_color.."]"..
		"button[0.9,0.5;2.0,0.7;ColorSelectorSaveColorButton;"..S("Update").."]"..
		"tooltip[0.9,0.5;2.0,0.7;"..S("Updates the saved color to match the current color.").."]"..
		"button[3.0,0.5;2.0,0.7;ColorSelectorRecallButton;"..S("Recall").."]"..
		"tooltip[3.0,0.5;2.0,0.7;"..S("Updates the current color to match the saved color.").."]"..
		"container_end[]"..

		"button[8.25,6;2.5,0.8;ColorSelectorOkButton;"..S("OK").."]"..
		"button[11.0,6;2.5,0.8;ColorSelectorCancelButton;"..S("Cancel").."]"..
		"container_end[]"

	return formspec
end

local function get_formspec(player, context)
	local tab_names = S("Current Livery")..", "..S("Editor")..", "..S("Saved Livery")..", "..S("Predefined Liveries")
	local wagon_type = context.wagon_type and context.wagon_type or undefined_str

	local formspec =
		"formspec_version[4]"

	if context.model_preview_dialog.is_active then
		formspec = formspec..
			"size[20,16]"..
			"position[0.5,0.5]"..
			get_model_preview_formspec_section(context)
	elseif context.livery_template_info_dialog.is_active then
		formspec = formspec..
			"size[14,11.25]"..
			"position[0.5,0.5]"..
			get_livery_template_info_formspec_section(context)
	elseif context.color_selector_dialog.is_active then
		formspec = formspec..
			"size[14,7]"..
			"position[0.5,0.5]"..
			get_color_selector_formspec_section(context)
	else
		formspec = formspec..
			"size[18,8]"..
			"position[0.5,0.5]"..
			"tabheader[0,0;CurrentTab;"..tab_names..";"..context.current_tab.."]"..

			"container[0.1,0.1]"..
			"box[0.00,0.00;17.80,0.80;#ffffff09]"..
			"label[0.15,0.38;"..(minetest.registered_items[wagon_type].description or wagon_type or "<"..S("Unknown Wagon")..">").."]"..
			"container_end[]"

		if context.current_tab == 1 then
			formspec = formspec..get_current_livery_formspec_section(context)
		elseif context.current_tab == 2 then
			formspec = formspec..get_livery_editor_formspec_section(context)
		elseif context.current_tab == 3 then
			formspec = formspec..get_saved_livery_formspec_section(context)
		elseif context.current_tab == 4 then
			formspec = formspec..get_predefined_liveries_formspec_section(context)
		end

		formspec = formspec..
			"button_exit[15.5,7.0;2.0,0.8;exit_button;"..S("Exit").."]"
	end

	return formspec
end

local function show_livery_designer_form(player, wagon)
	local context = get_livery_designer_context(player, wagon)
	if context then
		set_context(player, context)
		minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
	else
		-- This is an unsupported wagon type or no livery templates have been registered for the wagon type.
		minetest.chat_send_player(player:get_player_name(), S("No livery templates are defined for the wagon."))
	end
end

local function get_indexed_selection(base_name, max_idx, fields)
	if not base_name or not max_idx or max_idx < 1 or not fields then
		return
	end

	local len = #base_name
	for key, val in pairs(fields) do
		if key:sub(1, len) == base_name then
			for i = 1, max_idx do
				if key == base_name..i then
					return i, val
				end
			end
		end
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == livery_designer_form then
		local itemstack = player:get_wielded_item()
		if itemstack:get_name() ~= livery_designer_tool then
			minetest.debug("ERROR: Not wielding the correct livery tool.")
			return
		end

		local context = get_or_create_context(player)

		if fields.quit then
			set_context(player, context)
			return
		end

		if context.model_preview_dialog.is_active then
			if fields.RotationCheckbox then
				context.common_controls.rotate_checkbox = fields.RotationCheckbox == "true"
				set_context(player, context)
				minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
				return
			end

			if fields.CollapsePreviewButton then
				context.model_preview_dialog.is_active = false
				context.model_preview_dialog.textures = {}
				set_context(player, context)
				minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
				return
			end
		end

		if context.livery_template_info_dialog.is_active then
			if fields.CloseLiveryTemplateInfoDialogButton then
				context.livery_template_info_dialog.is_active = false
				context.livery_template_info_dialog.livery_template_name = nil
				context.livery_template_info_dialog.textures = {}
				set_context(player, context)
				minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
				return
			end
		end

		if context.color_selector_dialog.is_active then
			if fields.ColorSelectorCancelButton or fields.ColorSelectorOkButton then
				if context.color_selector_dialog.color_button_idx and fields.ColorSelectorOkButton then
					local override_idx = context.color_selector_dialog.color_button_idx

					-- Update the livery design
					context.livery_editor_tab.livery_design.overlays[override_idx].color = context.color_selector_dialog.current_color

					-- Update context.livery_editor_tab.textures
					context.livery_editor_tab.textures = advtrains_livery_database.get_livery_textures_from_design(context.livery_editor_tab.livery_design, context.wagon.id)

					-- Update context.livery_editor_tab.controls to match the updated livery design
					local wagon_livery_template = advtrains_livery_database.get_wagon_livery_template(context.wagon_type, context.livery_editor_tab.livery_design.livery_template_name)
					update_overlay_controls(wagon_livery_template, context.livery_editor_tab.livery_design, context.livery_editor_tab.controls.overlays)

					-- Update the applicable context.override_values[] to the updated value
					save_override_value(context, override_idx, context.livery_editor_tab.livery_design.overlays[override_idx].color)

					context.applied = are_livery_designs_equivalent(context.current_livery_tab.livery_design, context.livery_editor_tab.livery_design)
				end
				context.color_selector_dialog.is_active = false
				set_context(player, context)
				minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
				return
			end

			if fields.ColorSelectorSaveColorButton and context.color_selector_dialog.saved_color ~= context.color_selector_dialog.current_color then
				context.color_selector_dialog.saved_color = context.color_selector_dialog.current_color
				update_color_selector_controls(context.color_selector_dialog)
				set_context(player, context)
				minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
				return
			end

			if fields.ColorSelectorRecallButton and context.color_selector_dialog.current_color ~= context.color_selector_dialog.saved_color then
				context.color_selector_dialog.current_color = context.color_selector_dialog.saved_color
				update_color_selector_controls(context.color_selector_dialog)
				set_context(player, context)
				minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
				return
			end

			if fields.ColorSelectorUpdateButton and is_valid_color(fields.ColorSelectorInputColor) then
				context.color_selector_dialog.current_color = fields.ColorSelectorInputColor
				update_color_selector_controls(context.color_selector_dialog)
				set_context(player, context)
				minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
				return
			end

			local scrollbar_changed = false
			if fields.ColorSelectorScrollBarR and fields.ColorSelectorScrollBarR:sub(1, 3) == "CHG" then
				context.color_selector_dialog.controls.component_scrollbar_pos.r = tonumber(fields.ColorSelectorScrollBarR:sub(5, 8))
				scrollbar_changed = true
			elseif fields.ColorSelectorScrollBarG and fields.ColorSelectorScrollBarG:sub(1, 3) == "CHG" then
				context.color_selector_dialog.controls.component_scrollbar_pos.g = tonumber(fields.ColorSelectorScrollBarG:sub(5, 8))
				scrollbar_changed = true
			elseif fields.ColorSelectorScrollBarB and fields.ColorSelectorScrollBarB:sub(1, 3) == "CHG" then
				context.color_selector_dialog.controls.component_scrollbar_pos.b = tonumber(fields.ColorSelectorScrollBarB:sub(5, 8))
				scrollbar_changed = true
			end
			if scrollbar_changed then
				context.color_selector_dialog.current_color = get_color_from_color_components(
					context.color_selector_dialog.controls.component_scrollbar_pos.r,
					context.color_selector_dialog.controls.component_scrollbar_pos.g,
					context.color_selector_dialog.controls.component_scrollbar_pos.b)
				context.color_selector_dialog.controls.predefined_color_selection_idx = get_index(predefined_colors, get_color_name_by_value(context.color_selector_dialog.current_color)) or 1
			elseif fields.ColorSelectorQuickSelectDropdown ~= context.color_selector_dialog.controls.predefined_color_selection_idx then
				local selection_idx = tonumber(fields.ColorSelectorQuickSelectDropdown)
				if selection_idx > 1 then
					context.color_selector_dialog.current_color = get_color_by_name(predefined_colors[selection_idx])
					update_color_selector_controls(context.color_selector_dialog)
				end
			end

			set_context(player, context)
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
			return
		end

		if fields.OverlayScrollbar and fields.OverlayScrollbar:sub(1, 3) == "CHG" then
			context.common_controls.overlay_scrollbar_pos = tonumber(fields.OverlayScrollbar:sub(5, 8))
			return
		end

		if fields.ExpandPreviewButton then
			context.model_preview_dialog.is_active = true
			if context.current_tab == 1 then
				context.model_preview_dialog.textures = context.current_livery_tab.textures
			elseif context.current_tab == 2 then
				context.model_preview_dialog.textures = context.livery_editor_tab.textures
			elseif context.current_tab == 3 then
				context.model_preview_dialog.textures = context.saved_livery_tab.textures
			elseif context.current_tab == 4 then
				context.model_preview_dialog.textures = context.predefined_liveries_tab.textures
			end
			set_context(player, context)
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
			return
		end

		if fields.InfoButton then
			context.livery_template_info_dialog.is_active = true
			local livery_design = context.livery_editor_tab.livery_design
			local livery_template_name = livery_design and livery_design.livery_template_name
			if livery_template_name then
				context.livery_template_info_dialog.livery_template_name = livery_template_name
				set_context(player, context)
				minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
			end
			return
		end

		local color_button_idx = get_indexed_selection("EditColorButton", advtrains_livery_database.get_overlays_per_template_limit(), fields)
		if color_button_idx then
			context.color_selector_dialog.is_active = true
			context.color_selector_dialog.color_button_idx = color_button_idx
			context.color_selector_dialog.current_color = context.livery_editor_tab.controls.overlays[color_button_idx].color or "#808080"
			if not context.color_selector_dialog.saved_color then
				context.color_selector_dialog.saved_color = context.color_selector_dialog.current_color
			end
			update_color_selector_controls(context.color_selector_dialog)
			set_context(player, context)
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
			return
		end

		if fields.CurrentLiveryEditButton then
			context.livery_editor_tab = clone_tab(context.current_livery_tab)

			-- Update override_values in order to keep them in sync with the new livery design loaded into the editor.
			save_override_values(context)

			context.current_tab = 2		-- Switch to the editor tab
			context.applied = are_livery_designs_equivalent(context.current_livery_tab.livery_design, context.livery_editor_tab.livery_design) -- should always be true
			set_context(player, context)
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
			return
		end

		if fields.SavedLiveryEditButton then
			context.livery_editor_tab = clone_tab(context.saved_livery_tab)

			-- Update override_values in order to keep them in sync with the new livery design loaded into the editor.
			save_override_values(context)

			context.current_tab = 2		-- Switch to the editor tab
			context.applied = are_livery_designs_equivalent(context.current_livery_tab.livery_design, context.livery_editor_tab.livery_design)
			set_context(player, context)
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
			return
		end

		if fields.SavedLiveryApplyButton then
			callback_functions[context.wagon_mod_name].apply_wagon_livery_textures(player, context.wagon, context.saved_livery_tab.textures)
			play_apply_sound(context.wagon)

			context.current_livery_tab = clone_tab(context.saved_livery_tab)

			context.applied = are_livery_designs_equivalent(context.saved_livery_tab.livery_design, context.livery_editor_tab.livery_design)
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context))
			return
		end

		if fields.ApplyButton then
			callback_functions[context.wagon_mod_name].apply_wagon_livery_textures(player, context.wagon, context.livery_editor_tab.textures)
			play_apply_sound(context.wagon)

			context.current_livery_tab = clone_tab(context.livery_editor_tab)

			context.applied = true
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context))
			return
		end

		if fields.EditorSaveButton then
			context.saved_livery_tab = clone_tab(context.livery_editor_tab)
			context.current_tab = 3		-- Switch to the save livery tab
			set_context(player, context)
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
			return
		end

		if fields.CurrentTab then
			local tab = tonumber(fields.CurrentTab)
			if tab ~= context.current_tab then
				context.current_tab = tab
				set_context(player, context)
				return minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
			end
		end

		if fields.RotationCheckbox then
			context.common_controls.rotate_checkbox = fields.RotationCheckbox == "true"
			set_context(player, context)
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
		end

		if fields.EditorResetButton then
			context.livery_editor_tab.livery_design.overlays = {}
			context.override_values = {}

			-- Update context.livery_editor_tab.textures
			context.livery_editor_tab.textures = advtrains_livery_database.get_livery_textures_from_design(context.livery_editor_tab.livery_design, context.wagon.id)

			context.applied = are_livery_designs_equivalent(context.current_livery_tab.livery_design, context.livery_editor_tab.livery_design)
			set_context(player, context)
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
		end

		if fields.EditorLiveryTemplateName then
			-- Update context.livery_editor_tab.livery_design
			context.livery_editor_tab.livery_design.livery_template_name = fields.EditorLiveryTemplateName
			context.livery_editor_tab.livery_design.overlays = {}

			-- Update all color overlays in the livery design based on recent edits/changes
			-- (Without this, all color override values would be lost whenever a different livery template is selected.)
			restore_override_values(context)

			-- Update context.livery_editor_tab.textures
			context.livery_editor_tab.textures = advtrains_livery_database.get_livery_textures_from_design(context.livery_editor_tab.livery_design, context.wagon.id)

			-- Update context.livery_editor_tab.controls
			context.livery_editor_tab.controls.livery_template_name_selection = get_index(context.wagon_valid_livery_template_names, fields.EditorLiveryTemplateName) or 1
			local wagon_livery_template = advtrains_livery_database.get_wagon_livery_template(context.wagon_type, context.livery_editor_tab.livery_design.livery_template_name)
			update_overlay_controls(wagon_livery_template, context.livery_editor_tab.livery_design, context.livery_editor_tab.controls.overlays)

			context.applied = are_livery_designs_equivalent(context.current_livery_tab.livery_design, context.livery_editor_tab.livery_design)
			set_context(player, context)
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
			return
		end

		if fields.PredefinedLiveriesTextList and fields.PredefinedLiveriesTextList:sub(1, 3) == "CHG" then
			update_predefined_liveries_tab_selection(context, tonumber(fields.PredefinedLiveriesTextList:sub(5, 8)))

			set_context(player, context)
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
			return
		end

		if fields.PredefinedLiveriesEditButton then
			update_tab_from_predefined_livery_design(context, context.livery_editor_tab)

			-- Update override_values in order to keep them in sync with the new livery design loaded into the editor.
			-- (Without this, all color override values would be lost whenever a different livery template is selected.)
			save_override_values(context)

			context.current_tab = 2		-- Switch to the editor tab
			context.applied = are_livery_designs_equivalent(context.current_livery_tab.livery_design, context.livery_editor_tab.livery_design)
			set_context(player, context)
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
			return
		end

		if fields.PredefinedLiveriesApplyButton then
			callback_functions[context.wagon_mod_name].apply_wagon_livery_textures(player, context.wagon, context.predefined_liveries_tab.textures)
			play_apply_sound(context.wagon)

			update_tab_from_predefined_livery_design(context, context.current_livery_tab)

			context.applied = false
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context))
			return
		end

		local override_idx, selection_value = get_indexed_selection("ColorOverride", advtrains_livery_database.get_overlays_per_template_limit(), fields)
		if override_idx then
			local selection_idx = get_index(color_overrides, selection_value)
			if not selection_idx then
				return
			end

			-- Update the applicable color overlay in the livery design based on the color override field that was changed.
			if context.livery_editor_tab.livery_design.overlays then
				if selection_idx > 1 then
					-- A color override was specified, make note of it in the livery design
					local color = get_color_by_name(color_overrides[selection_idx])
					if selection_idx == 2 then	-- "Custom"
						if context.livery_editor_tab.livery_design.overlays[override_idx] and
						   context.livery_editor_tab.livery_design.overlays[override_idx].color then
							-- Keep color if switching from an existing override.
							color = context.livery_editor_tab.livery_design.overlays[override_idx].color
						else
							color = "#7F7F7F"	-- An unnamed color
						end
					end
					context.livery_editor_tab.livery_design.overlays[override_idx] = {
						id = override_idx,		-- This should be an index to an overlay in livery_templates.  Currently, it will likely a cause a problem if a template's overlays are not registered with contiguous numbers starting with 1.
						color = color
				}
				elseif context.livery_editor_tab.livery_design.overlays[override_idx] then
					-- The color override was removed so remove if from the livery design.
					context.livery_editor_tab.livery_design.overlays[override_idx] = nil
				end
			end

			-- Update context.livery_editor_tab.textures
			context.livery_editor_tab.textures = advtrains_livery_database.get_livery_textures_from_design(context.livery_editor_tab.livery_design, context.wagon.id)

			-- Update context.livery_editor_tab.controls to match the updated livery design
			context.livery_editor_tab.controls.overlays[override_idx].override_selection_idx = selection_idx
			context.livery_editor_tab.controls.overlays[override_idx].override_selection_name = selection_value
			context.livery_editor_tab.controls.overlays[override_idx].color =
				context.livery_editor_tab.livery_design.overlays and
				context.livery_editor_tab.livery_design.overlays[override_idx] and
				context.livery_editor_tab.livery_design.overlays[override_idx].color or nil

			-- Update the applicable context.override_values[] to the updated value
			save_override_value(context, override_idx, override_idx and context.livery_editor_tab.livery_design.overlays and
				context.livery_editor_tab.livery_design.overlays[override_idx] and
				context.livery_editor_tab.livery_design.overlays[override_idx].color or nil)

			context.applied = are_livery_designs_equivalent(context.current_livery_tab.livery_design, context.livery_editor_tab.livery_design)
			set_context(player, context)
			minetest.show_formspec(player:get_player_name(), livery_designer_form, get_formspec(player, context) )
			return
		end
	end
end)

function advtrains_livery_designer.activate_tool(player, wagon, mod_name)
	assert(mod_name, "Invalid mod name")
	assert(callback_functions[mod_name], "Attempted use of unregistered mod '"..mod_name.."'")
	assert(callback_functions[mod_name].apply_wagon_livery_textures, "Missing registration of apply_wagon_livery_textures() for '"..mod_name.."' mod.")
	show_livery_designer_form(player, wagon)
end