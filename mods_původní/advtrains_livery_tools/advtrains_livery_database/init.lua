advtrains_livery_database = {}

local callback_functions = {}
local livery_templates = {}
local registered_wagons = {}
local predefined_liveries = {}

local overlays_per_template_limit = 6

-------------------------------------------------------------------------------
-- External Utilities:

function advtrains_livery_database.clone_livery_design(src_livery_design)
	if not src_livery_design then
		return nil
	end

	local livery_design = {
		wagon_type = src_livery_design.wagon_type,
		livery_template_name = src_livery_design.livery_template_name,
	}
	if src_livery_design.overlays then
		livery_design.overlays = {}
		for seq_num, overlay in pairs(src_livery_design.overlays) do
			livery_design.overlays[seq_num] = {
				id = overlay.id,
				color = overlay.color,
			}
		end
	end
	return livery_design
end

function advtrains_livery_database.clone_textures(src)
	if not src then
		return nil
	end

	local textures = {}
	for k, texture in pairs(src) do
		textures[k] = texture
	end
	return textures
end

function advtrains_livery_database.get_overlays_per_template_limit()
	return overlays_per_template_limit
end

-------------------------------------------------------------------------------
-- Internal Utilities:

local function is_valid_livery_design(livery_design)
	return livery_design and
		livery_design.wagon_type and
		livery_design.livery_template_name
end

local function get_wagon_type_prefix(wagon_type)
	local delimiter_pos, _ = string.find(wagon_type, ":")
	if not delimiter_pos or delimiter_pos < 2 then
		return
	end

	return wagon_type:sub(1, delimiter_pos - 1)
end

local function get_template(wagon_type, base_texture)
	for name, template in pairs(livery_templates[wagon_type]) do
		if template.base_textures[1] == base_texture then
			return name, template
		end
	end
end

-------------------------------------------------------------------------------

-- Every mod that needs to register one or more livery templates should call
-- this function exactly once.

function advtrains_livery_database.register_mod(mod_name, optional_callback_functions)
	assert(mod_name, "Missing required mod name")

	if not callback_functions[mod_name] then
		if optional_callback_functions then
			callback_functions[mod_name] = {
					on_custom_get_livery_design_from_textures = optional_callback_functions.on_custom_get_livery_design_from_textures,	-- Function parameters: (wagon_type, livery_textures, wagon_id)
					on_pre_get_livery_design_from_textures = optional_callback_functions.on_pre_get_livery_design_from_textures,		-- Function parameters: (wagon_type, livery_textures, wagon_id, livery_design)
					on_custom_get_livery_textures_from_design = optional_callback_functions.on_custom_get_livery_textures_from_design,	-- Function parameters: (livery_design, wagon_id)
					on_post_get_livery_textures_from_design = optional_callback_functions.on_post_get_livery_textures_from_design,		-- Function parameters: (livery_design, wagon_id, livery_textures)
				}
		else
			callback_functions[mod_name] = {}
		end
	else
		minetest.debug("WARNING: An attempt to register mod '"..mod_name.."' multiple times with the train livery database is not supported and has been blocked.")
	end
end

-------------------------------------------------------------------------------

-- This function should be called exactly once per wagon type being registered
-- for a mod, regardless of how many templates are being registered for the
-- wagon type.
--
-- Note: The mod_name parameter is optional if both wagon_type prefix is not
-- null and not equal to "advtrains".

function advtrains_livery_database.register_wagon(wagon_type, mod_name)
	assert(wagon_type, "Invalid wagon type")

	-- Determine the effective wagon_mod.  This is the mod whose callback
	-- functions will be used for the given wagon_type and livery_template_name.
	local actual_wagon_mod = nil
	local wagon_type_prefix = get_wagon_type_prefix(wagon_type)
	if wagon_type_prefix and wagon_type_prefix ~= "advtrains" then
		actual_wagon_mod = wagon_type_prefix
	elseif mod_name and mod_name ~="advtrains" then
		-- The mod_name parameter is only used if the wagon_type_prefix is nil
		-- or not "advtrains". If used, it must be neither nil nor "advtrains".
		-- Its purpose is to allow mods that define their wagons in the
		-- "advtrains" namespace to register livery templates that use callback
		-- functions that are specific to the owning mod.
		actual_wagon_mod = mod_name
	end

	assert(actual_wagon_mod, "Invalid wagon_mod parameter") -- The wagon_mod parameter must be neither nil nor equal to "advtrains" if wagon_type_prefix is nil or equal to "advtrains"
	assert(callback_functions[actual_wagon_mod], "Attempt to register a wagon_type for an unregistered mod ('"..actual_wagon_mod.."').")
	if not registered_wagons[wagon_type] then
		registered_wagons[wagon_type] = {
			mod_name = actual_wagon_mod,
		}
	end
end

-- Use this funtion to determine the mod for which a given wagon type was
-- registered.  This is need because some mods define their wagon_type using
-- the prefix "advtrains" rather than their mod name.

function advtrains_livery_database.get_wagon_mod_name(wagon_type)
	if wagon_type and registered_wagons[wagon_type] then
		return registered_wagons[wagon_type].mod_name
	end

	return
end

-- This function should be called once for each livery template that is
-- registered for a given wagon type.

function advtrains_livery_database.add_livery_template(wagon_type, livery_template_name, base_textures, livery_mod, overlay_count, designer, texture_license, texture_creator, notes)
	assert(wagon_type, "Invalid wagon type")
	assert(registered_wagons[wagon_type], "Attempt to register a livery template for an unregistered wagon type ('"..wagon_type.."').")
	assert(livery_template_name, "Invalid livery template name")
	assert(base_textures, "Invalid base textures")
	assert(base_textures[1], "Missing base texture")
	assert(livery_mod, "Missing livery mod name")
	assert(overlay_count, "Missing overlay count")
	assert(callback_functions[livery_mod], "Attempt to add a livery template for an unregistered mod ('"..livery_mod.."').")

	if not livery_templates[wagon_type] then
		livery_templates[wagon_type] = {}
	end

	if not livery_templates[wagon_type][livery_template_name] then
		-- Only add the livery template if another livery template for the
		-- given wagon type that has the same base texture has not been
		-- previously registered. In other words, for a given wagon_type, each
		-- livery template should have a unique base_textures[1]. This
		-- restriction is used so that base_texture[1] of given wagon can be
		-- used to identify its livery template. A workaround for this
		-- restriction for the template creator is to duplicate the texture
		-- file and give it a unique name.
		local existing_livery_template_name, _ = get_template(wagon_type, base_textures[1])
		assert(not existing_livery_template_name,
				"Attempt to register a livery template ('"..livery_template_name..
				"') that does not have a uniquely named base texture for wagon type ('"..wagon_type..
				"'). A previously registered livery template ('"..(existing_livery_template_name or "<nil>")..
				"') already uses the same texture file ('"..base_textures[1].."').")

		livery_templates[wagon_type][livery_template_name] = {
			base_textures = advtrains_livery_database.clone_textures(base_textures),
			designer = designer,
			texture_license = texture_license,
			texture_creator = texture_creator,
			notes = notes,
			livery_mod = livery_mod,
			expected_overlay_count = overlay_count,
			overlays = {},
		}
	end
end

-- This function is called to register an overlay for a given livery template.
-- It should be called once for each overlay in the template.

function advtrains_livery_database.add_livery_template_overlay(wagon_type, livery_template_name, overlay_id, overlay_name, overlay_slot_idx, overlay_texture, overlay_alpha)
	assert(wagon_type, "Invalid wagon type")
	assert(livery_template_name, "Invalid livery template name")
	assert(overlay_id, "Invalid overlay id")
	assert(overlay_name, "Invalid overlay name")
	assert(overlay_slot_idx and tonumber(overlay_slot_idx) > 0, "Invalid overlay slot index")
	assert(overlay_texture, "Invalid overlay texture")
	assert(livery_templates[wagon_type], "wagon type, '"..wagon_type.."' not registered")
	assert(livery_templates[wagon_type][livery_template_name], "livery template name, '"..livery_template_name.."' not registered for wagon type, '"..wagon_type.."'")

	local overlay_count = #livery_templates[wagon_type][livery_template_name].overlays
	if overlay_count >= overlays_per_template_limit then
		minetest.debug(
			"Failed to add overlay ('"..overlay_name..
			"') for livery template ('"..livery_template_name..
			"') of wagon type ('"..wagon_type..
			"') due to exceeding overlays per template limit.")
		return
	end

	if livery_templates[wagon_type][livery_template_name].overlays[overlay_id] then
		minetest.debug(
			"Failed to add overlay ('"..overlay_name..
			"') for livery template ('"..livery_template_name..
			"') of wagon type ('"..wagon_type..
			"') due to overlay id "..overlay_id.." having already been added.")
		return
	end

	if overlay_count >= livery_templates[wagon_type][livery_template_name].expected_overlay_count then
		-- This could be due to a mod not correctly specifying the number of
		-- overlays that that will be in the template when it called
		-- add_livery_template() or it could be an attempt by one mod to update
		-- the overlays of a template created by another mod.
		minetest.debug(
			"Failed to add overlay ('"..overlay_name..
			"') for livery template ('"..livery_template_name..
			"') of wagon type ('"..wagon_type..
			"') due to exceeding the expected number of overlays.")
		return
	end

	livery_templates[wagon_type][livery_template_name].overlays[overlay_id] = {
		name =overlay_name,
		slot_idx = tonumber(overlay_slot_idx),
		texture = overlay_texture,
		alpha = overlay_alpha and tonumber(overlay_alpha) or 255,
	}
end

-- This function registers a predefined livery for a wagon type. Predefined
-- liveries are optional.
-- Note that predefined livery names must be unique per wagon type.
--
-- Ideally, predefined liveries should be used to showcase examples of a few
-- designs that are possibile for a given templete. Registering too many
-- predefined liveries for a given template could be counter produtive since
-- a player could become overwhelmed with the number of options. That concern
-- could be addressed if the tool that displays predefined liveries provides a
-- filtering and/or search mechanism.

function advtrains_livery_database.add_predefined_livery(design_name, livery_design, mod_name, notes)
	assert(design_name, "Invalid design name")
	assert(is_valid_livery_design(livery_design), "Invalid livery design")
	assert(mod_name, "Invalid mod name")
	assert(callback_functions[mod_name], "Attempt to add predefined livery for an unregistered mod ('"..mod_name.."').")

	-- Don't add predefined liveries that reference a livery template that is
	-- not already registered.
	if not livery_templates[livery_design.wagon_type] or not livery_templates[livery_design.wagon_type][livery_design.livery_template_name] then
		minetest.debug("Failed to add predefined livery design ('"..design_name.."') for wagon type ('"..livery_design.wagon_type.."') due to unknown livery template ('"..livery_design.livery_template_name.."')")
		return false
	end

	if not predefined_liveries[livery_design.wagon_type] then
		predefined_liveries[livery_design.wagon_type] = {}
	end

	if not predefined_liveries[livery_design.wagon_type][design_name] then
		predefined_liveries[livery_design.wagon_type][design_name] = {
			mod_name = mod_name,
			notes = notes,
			livery_design = advtrains_livery_database.clone_livery_design(livery_design),
		}
		return true
	else
		minetest.debug("Failed to add predefined livery design due to duplicate name ('"..design_name.."') for wagon type ('"..livery_design.wagon_type.."')")
	end

	return false
end

-- Get the list of names of predefined liveries for a given wagon type.

function advtrains_livery_database.get_predefined_livery_names(wagon_type)
	local names = {}
	if wagon_type and predefined_liveries[wagon_type] then
		for name, predefined_livery in pairs(predefined_liveries[wagon_type]) do
			table.insert(names, {livery_name = name, livery_template_name = predefined_livery.livery_design.livery_template_name})
		end
	end
	return names
end

-- Get the predefined livery for a given wagon type and predefined livery name.
-- Note that predefined livery names are unique per wagon type.

function advtrains_livery_database.get_predefined_livery(wagon_type, design_name)
	if wagon_type and design_name and predefined_liveries[wagon_type] and predefined_liveries[wagon_type][design_name] then
		return advtrains_livery_database.clone_livery_design(predefined_liveries[wagon_type][design_name].livery_design)
	end
	return
end

-------------------------------------------------------------------------------

function advtrains_livery_database.get_wagon_livery_overlay_name(wagon_type, livery_template_name, overlay_seq_number)
	assert(wagon_type, "Invalid wagon type")
	assert(livery_template_name, "Invalid livery template name")
	assert(overlay_seq_number, "Invalid overlay sequence number")

	if livery_templates[wagon_type] and
	   livery_templates[wagon_type][livery_template_name] and
	   livery_templates[wagon_type][livery_template_name].overlays and
	   livery_templates[wagon_type][livery_template_name].overlays[overlay_seq_number] then
		return livery_templates[wagon_type][livery_template_name].overlays[overlay_seq_number].name
	end
end

function advtrains_livery_database.get_wagon_livery_template(wagon_type, livery_template_name)
	assert(wagon_type, "Invalid wagon type")
	assert(livery_template_name, "Invalid livery template name")

	if not livery_templates[wagon_type] or not livery_templates[wagon_type][livery_template_name] then
		return nil
	end

	-- Create a copy of the template
	local wagon_livery_template = {
		base_textures = advtrains_livery_database.clone_textures(livery_templates[wagon_type][livery_template_name].base_textures),
		designer = livery_templates[wagon_type][livery_template_name].designer,
		texture_license = livery_templates[wagon_type][livery_template_name].texture_license,
		texture_creator = livery_templates[wagon_type][livery_template_name].texture_creator,
		notes = livery_templates[wagon_type][livery_template_name].notes,
		livery_mod = livery_templates[wagon_type][livery_template_name].livery_mod,
		overlays = {},
	}
	for id, overlay in ipairs(livery_templates[wagon_type][livery_template_name].overlays) do
		wagon_livery_template.overlays[id] = {
			name = overlay.name,
			slot_idx = overlay.slot_idx,
			texture = overlay.texture,
			alpha = overlay.alpha,
		}
	end

	return wagon_livery_template
end

function advtrains_livery_database.get_livery_template_names_for_wagon(wagon_type)
	local livery_template_names = {}
	if wagon_type and livery_templates[wagon_type] then
		for name, _ in pairs(livery_templates[wagon_type]) do
			table.insert(livery_template_names, name)
		end
	end
	return livery_template_names
end

-------------------------------------------------------------------------------

-- Attempt to determine the livery_design for a given wagon_type from its
-- livery textures. Note that if livery textures were modified by the owning
-- mod due to weathering, loads, etc. then this function could fail. The mod
-- should provide an implementation of on_custom_get_livery_design_from_textures()
-- or on_pre_get_livery_design_from_textures() to handle such cases.

function advtrains_livery_database.get_livery_design_from_textures(wagon_type, textures, wagon_id)
	if not wagon_type or not textures or not textures[1] then
		return nil
	end

	local wagon_mod_name = advtrains_livery_database.get_wagon_mod_name(wagon_type)
	if not wagon_mod_name then
		return
	end

	local livery_textures = advtrains_livery_database.clone_textures(textures)

	-- Allow the mod to provide its own implementation for this function.
	if callback_functions[wagon_mod_name] and callback_functions[wagon_mod_name].on_custom_get_livery_design_from_textures then
		return callback_functions[wagon_mod_name].on_custom_get_livery_design_from_textures(wagon_type, livery_textures, wagon_id)
	end

	if not livery_templates[wagon_type] then
		return nil
	end

	if callback_functions[wagon_mod_name] and callback_functions[wagon_mod_name].on_pre_get_livery_design_from_textures then
		-- Allow mods to adjust the textures in case they have been previously
		-- modified for loads, weathering, etc.
		livery_textures = callback_functions[wagon_mod_name].on_pre_get_livery_design_from_textures(wagon_type, advtrains_livery_database.clone_textures(livery_textures), wagon_id)
	end

	-- Extract the base texture from the first texture in livery_textures.
	-- This will be used to identify the livery_template_name.
	local base_texture = livery_textures[1]
	local i, _ = string.find(livery_textures[1], "^", 1, true)
	if i and i > 1 then
		-- Trim any modifiers that were applied to the texture
		base_texture = string.sub(livery_textures[1], 1, i - 1)
	end

	-- Find the livery template for the given wagon_type and base_texture.
	local livery_template_name, livery_template = get_template(wagon_type, base_texture)

	-- Abort if no matching template was found
	if not livery_template then
		return nil
	end

	-- Create a candidate livery_design
	local livery_design = {
		wagon_type = wagon_type,
		livery_template_name = livery_template_name,
		overlays = {},
	}

	-- For each overlay clause in livery_textures, extract its texture and
	-- attempt to identify an overlay in the livery_template that has the same
	-- texture. Having a fewer number of overlays in livery_textures than the
	-- livery_template is OK. Having more is not. Thus, if livery_textures
	-- contains an overlay texture than is not present in the livery_template
	-- then the livery_template is not a match for livery_textures.
	for slot_idx, livery_texture in ipairs(livery_textures) do
		local pos = 1
		while pos do
			local _, j = string.find(livery_texture, "^(", pos, true)
			local n = j
			if j then
				local m
				m, n = string.find(livery_texture, "^[colorize:#", pos, true)
				if n then
					local overlay_texture = string.sub(livery_texture, j + 1, m - 1)
					local overlay_color = string.sub(livery_texture, n, n + 6)

					-- Seek a matching overlay in livery_template based on the
					-- found texture.
					local found = false
					for id, overlay in ipairs(livery_template.overlays) do
						if overlay.slot_idx == slot_idx and overlay.texture:upper() == overlay_texture:upper() then
							livery_design.overlays[id] = {id = id, color=overlay_color}
							found = true
						end
					end

					-- Abort if livery_texture contains an overlay that is not
					-- present in livery_template
					if not found then
						return nil
					end
				end
			end
			pos = n
		end
	end

	return livery_design
end

-- Given an instance of the livery_design table and an optional wagon id, this
-- function should return livery strings suitable for updating an advtrains
-- wagon. If specified, the wagon_id parameter is used in case the base texture
-- varies by instance of the wagon due to weathering, load, etc.

function advtrains_livery_database.get_livery_textures_from_design(livery_design, wagon_id)
	assert(livery_design, "Invalid livery design")
	assert(livery_design.wagon_type, "Missing wagon type in livery_design")
	assert(livery_design.livery_template_name, "Missing livery template name in livery_design")

	local wagon_mod_name = advtrains_livery_database.get_wagon_mod_name(livery_design.wagon_type)
	if not wagon_mod_name then
		return nil
	end

	-- Allow the mod to provide its own implementation for this function.
	if callback_functions[wagon_mod_name] and callback_functions[wagon_mod_name].on_custom_get_livery_textures_from_design then
		return callback_functions[wagon_mod_name].on_custom_get_livery_textures_from_design(livery_design, wagon_id)
	end

	if not livery_templates[livery_design.wagon_type] or
		not livery_templates[livery_design.wagon_type][livery_design.livery_template_name] or
		not livery_templates[livery_design.wagon_type][livery_design.livery_template_name].base_textures or
		not livery_templates[livery_design.wagon_type][livery_design.livery_template_name].base_textures[1] then
		return nil
	end

	local livery_template = livery_templates[livery_design.wagon_type][livery_design.livery_template_name]
	local livery_textures = advtrains_livery_database.clone_textures(livery_template.base_textures)

	-- Append a "colorize" clause for each valid overlay in livery_design
	if livery_template.overlays and livery_design.overlays then

		local ordered_overlays = {}
		for seq_num, overlay in pairs(livery_design.overlays) do
			table.insert(ordered_overlays, {seq_num = seq_num, id = overlay.id, color = overlay.color})
		end
		table.sort(ordered_overlays, function(a, b) return a.seq_num < b.seq_num end)
		for _, overlay in ipairs(ordered_overlays) do
			if livery_template.overlays and #livery_template.overlays > 0 and tonumber(overlay.id) <= #livery_template.overlays then
				local slot_idx = livery_template.overlays[overlay.id].slot_idx
				if overlay.id and overlay.color and livery_template.overlays[overlay.id] and slot_idx and livery_template.overlays[overlay.id].texture then
					local alpha = livery_template.overlays[overlay.id].alpha or 255
					if alpha < 0 then alpha = 0 end
					if alpha > 255 then alpha = 255 end
					local overlay_texture = "^("..livery_template.overlays[overlay.id].texture.."^[colorize:"..overlay.color..":"..alpha..")"
					livery_textures[slot_idx] = livery_textures[slot_idx]..overlay_texture
				end
			end
		end
	end

	if callback_functions[wagon_mod_name] and callback_functions[wagon_mod_name].on_post_get_livery_textures_from_design then
		-- Allow mods to adjust the textures in case they need to be modified
		-- for loads, weathering, etc.
		livery_textures = callback_functions[wagon_mod_name].on_post_get_livery_textures_from_design(livery_design, wagon_id, livery_textures)
	end

	return livery_textures
end


