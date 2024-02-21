local display_entity_name = "tombs:text"

display_api.register_display_entity(display_entity_name)

local shapes = { --mesh identifier, shape, col
	{
		id = 10,
		name = "_10",
		description  = "kulatý",
		center_box = tombs.colbox_0_0,
		offset_box = tombs.colbox_0_1,
		text = true,
		text_top = 1/32,
		text_maxlines = 4,
	},
	{
		id = 2,
		name = "_2",
		description = "špičatý",
		center_box = tombs.colbox_0_0,
		offset_box = tombs.colbox_0_1,
		text = true,
		text_top = 1/32,
		text_maxlines = 4,
	},
	{
		id = 20,
		name ="_0",
		description = "kvádr",
		center_box = tombs.colbox_0_0,
		offset_box = tombs.colbox_0_1,
		text = true,
		text_top = 0/32,
		text_maxlines = 4,
	},
	{
		id = 8,
		name = "_8",
		description = "obelisk",
		center_box = tombs.colbox_8_0,
		offset_box = tombs.colbox_8_1,
		text = true,
		text_top = -1/32,
		text_maxlines = 5,
		text_size = {x = 8/16, y = 12/16},
		text_pitch = -0.085,
		text_depth_shift = 0.023,
	},
	{
		id = 9,
		name = "_9",
		description = "hromada",
		center_box = tombs.colbox_9_0,
		offset_box = tombs.colbox_9_0,
		text = false,
	},
	{
		id = 1,
		name = "_1",
		description = "kříž",
		center_box = tombs.colbox_1_0,
		offset_box = tombs.colbox_1_1,
		text = true,
		text_top = -7/32,
		text_size = {x = 8/16, y = 3/16},
	},
	-- {'_3', 'Short Slanted', tombs.colbox_3_0, tombs.colbox_3_1},
	-- {'_4', 'Short Flat', tombs.colbox_4_0, tombs.colbox_4_1},
	{
		id = 5,
		name = "_5",
		description = "kříž s podstavcem",
		center_box = tombs.colbox_5_0,
		offset_box = tombs.colbox_5_1,
		text = true,
		text_top = 10/32,
		text_size = {x = 8/16, y = 3/16},
	},
	-- {'_6', 'Staggered', tombs.colbox_6_0, tombs.colbox_6_1},
	{
		id = 7,
		name = "_7",
		description = "keltský kříž",
		center_box = tombs.colbox_7_0,
		offset_box = tombs.colbox_7_1,
		text = true,
		text_top = -4/32,
		text_size = {x = 8/16, y = 3/16},
	},
	-- {'_11', 'Sam', tombs.colbox_11_0, tombs.colbox_11_1},
	{
		id = 12,
		name = "_12",
		description = "pěticípá hvězda",
		center_box = tombs.colbox_12_0,
		offset_box = tombs.colbox_12_1,
		text = true,
		text_top = 1/16,
		text_maxlines = 2,
		text_size = {x = 8/16, y = 4/16},
	},
	{
		id = 13,
		name = "_13",
		description = "šesticípá hvězda",
		center_box = tombs.colbox_12_0,
		offset_box = tombs.colbox_12_1,
		text = true,
		text_top = 0,
		text_maxlines = 3,
		text_size = {x = 8/16, y = 6/16},
	},
	{
		id = 14,
		name = "_14",
		description = "mříž",
		center_box = tombs.colbox_14_0,
		offset_box = tombs.colbox_14_1,
	},
}

local tombstone_common_def = {
	drawtype = 'mesh',
	paramtype = 'light',
	paramtype2 = 'facedir',
	on_construct = function(pos)
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]
		if not ndef then
			minetest.log("error", "[tombs] on_construct called on unknown node "..node.name.."!")
			return
		end
		local meta = minetest.get_meta(pos)
		local formspec = {
			"formspec_version[4]", -- [1]
			"size[6,4]", -- [2]
			default.gui_bg, -- [3]
			default.gui_bg_img, -- [4]
			default.gui_slots, -- [5]
			"textarea[0.5,0.7;5,2;display_text;", -- [6]
			"Text", -- [7]
			";${display_text}]",
			"button[0.5,3;2.25,0.75;font;Písmo]",
			"button_exit[3.25,3;2.25,0.75;ok;Napsat]",
		}
		local maxlines
		if ndef.display_entities ~= nil then
			maxlines = ndef.display_entities[display_entity_name].maxlines or 1
		end
		if maxlines == nil then
			formspec[7] = "Text (jen infotext):"
		elseif maxlines == 1 then
			formspec[7] = "Text (jen 1 řádek):"
		elseif 2 <= maxlines and maxlines <= 4 then
			formspec[7] = "Text (max. "..maxlines.." řádky):"
		else
			formspec[7] = "Text (max. "..maxlines.." řádek):"
		end
		meta:set_string("formspec", table.concat(formspec))
	end,
	on_destruct = display_api.on_destruct,
	on_rotate = display_api.on_rotate,
	on_place = function(itemstack, placer, pointed_thing)
		minetest.rotate_node(itemstack, placer, pointed_thing)
		return display_api.on_place(itemstack, placer, pointed_thing)
	end,

	after_place_node = function(pos, placer)
		minetest.get_meta(pos):set_string('owner',placer:get_player_name())
	end,
	on_punch = display_api.update_entities,
	on_receive_fields = function(pos, formname, fields, sender)
		local player_name = sender and sender:get_player_name()
		if not player_name then
			return
		end
		if minetest.is_protected(pos, player_name) then
			minetest.record_protection_violation(pos, player_name)
			return
		end
		local node = minetest.get_node(pos)
		if minetest.get_item_group(node.name, "gravestone") == 0 then
			minetest.log("error", "Fields received for player "..player_name.." and "..node.name.." that is not a gravestone!")
			return
		end
		local meta = minetest.get_meta(pos)
		if fields.ok or fields.font then
			meta:set_string("display_text", fields.display_text)
			meta:set_string("infotext", fields.display_text)
			minetest.log("action", "Player "..player_name.." wrote this on a grave stone "..node.name.." at "..minetest.pos_to_string(pos).." owned by '"..meta:get_string("owner").."': >>>"..fields.display_text.."<<<")
			display_api.update_entities(pos)
		end
		if fields.font then
			font_api.show_font_list(sender, pos)
		end
	end,
}

function tombs.register_stones(recipe, name, desc, textures, material_def)

	if minetest.registered_nodes[recipe] == nil then
		return false
	end

	if material_def == nil then
		material_def = {}
	end

-- local group = {oddly_breakable_by_hand=2, not_in_creative_inventory=1}
-- if minetest.settings:get_bool('tombs.creative') then
local groups = {oddly_breakable_by_hand=2, cracky=3}
-- end

for i, shape_def in ipairs(shapes) do
	local mesh = shape_def.name
	local shape = shape_def.description
	local centered_col = shape_def.center_box
	local offset_col = shape_def.offset_box
	local display_entity

	local def = table.copy(tombstone_common_def)

	if type(textures) == "string" then
		def.tiles = {textures..'.png'}
	else
		def.tiles = textures
	end
	if material_def.light ~= nil then
		def.light_source = material_def.light
	end

	-- display_entities
	if shape_def.text then
		local text_size = shape_def.text_size or {x = 10/16, y = 12/16}
		display_entity = {
			-- depth
			top = shape_def.text_top or -0.5,
			aspect_ratio = 0.4,
			size = text_size,
			maxlines = shape_def.text_maxlines or 1,
			on_display_update = font_api.on_display_update,
		}
		if shape_def.text_pitch then
			display_entity.pitch = shape_def.text_pitch
		end
		if material_def.color then
			display_entity.color = material_def.color
		end
	end

	def.description = "vystředěný náhrobek ("..shape..") z: "..desc
	def.mesh = 'tombs'..mesh..'_0.obj'
	def.selection_box = centered_col
	def.collision_box = centered_col
	if display_entity ~= nil then
		-- display_entity = table.copy(display_entity)
		display_entity.depth = def.selection_box.fixed[1][3] - display_api.entity_spacing + (shape_def.text_depth_shift or 0)
		def.display_entities = {[display_entity_name] = display_entity}
	end
	def.groups = ch_core.override_groups(groups, {gravestone = shape_def.id + 100, gravestone_centered = shape_def.id})

	minetest.register_node('tombs:'..string.lower(name)..mesh..'_0', table.copy(def))

	def.description = "náhrobek ("..shape..") z: "..desc
	def.mesh = 'tombs'..mesh..'_1.obj'
	def.selection_box = offset_col
	def.collision_box = offset_col
	if display_entity ~= nil then
		display_entity = table.copy(display_entity)
		display_entity.depth = def.selection_box.fixed[1][3] - display_api.entity_spacing + (shape_def.text_depth_shift or 0)
		def.display_entities = {[display_entity_name] = display_entity}
	end
	def.groups = ch_core.override_groups(groups, {gravestone = shape_def.id, gravestone_normal = shape_def.id})

	minetest.register_node('tombs:'..string.lower(name)..mesh..'_1', def)
end

   tombs.nodes[recipe] = true
   tombs.recipes[recipe] = string.lower(name)

end

function tombs.crafting(input, var)
	local name = tombs.recipes[input]
	local output = {}
	for _, tdef in ipairs(shapes) do
		local oname = "tombs:"..name..tdef.name.."_"..var
		table.insert(output, oname)
	end
	return output
end

