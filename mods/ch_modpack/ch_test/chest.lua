local ifthenelse = ch_core.ifthenelse
local has_pipeworks = minetest.get_modpath("pipeworks")

local ACCESS_PUBLIC = 0 -- všichni mají plný přístup (tzn. včetně možnosti truhlu vytěžit)
local ACCESS_SERVICE = 1 -- všichni mohou vkládat/brát předměty, jen vlastník/ice může měnit nastavení
local ACCESS_PUTONLY = 2 -- všichni mohou vkládat předměty, ostatní může jen vlastník/ice
local ACCESS_TAKEONLY = 3 -- všichni mohou brát předměty, ostatní může jen vlastník/ice
local ACCESS_VIEWONLY = 4 -- všichni mohou zobrazit obsah, ostatní může jen vlastník/ice
local ACCESS_PRIVATE = 5 -- přístup jen pro vlastníka/ici (jmenované osoby mohou vkládat/brát)
local ACCESS_GIFT = 6 -- přístup jen pro vlastníka/ici a obdarovanou osobu
-- obdarovaná osoba může truhlu zvednout a tím se stane jejím vlastníkem/icí
local ACCESS_SHARED = 7 -- jako ACCESS_PRIVATE, ale jmenované osoby mají plný přístup k nastavení včetně možnosti truhlu vytěžit

local function on_construct(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	meta:set_int("width", 8)
	meta:set_int("height", 4)
	local s
	s = minetest.registered_nodes[node.name]
	if s ~= nil then
		s = s.description
		if s ~= nil then
			s = minetest.get_translated_string("cs", s) or s
		end
	end
	if s ~= nil then
		meta:set_string("title", s)
	end
	inv:set_size("main", 8 * 4)
	inv:set_size("qmove", 1)
	-- int locked = 0
	-- int
end

local function preserve_metadata(pos, oldnode, oldmeta, drops)
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	if minetest.is_player(placer) then
		local meta = minetest.get_meta(pos)
		if meta:get_string("owner") == "" then
			meta:set_string("owner", placer:get_player_name())
		end
	end
	local node = minetest.get_node(pos)
	if node.param2 < 4 then
		-- nastavit náhodnou barvu
		node.param2 = node.param2 + 4 * math.random(1, 63)
		minetest.swap_node(pos, node)
	end
	local meta = minetest.get_meta(pos)
	if has_pipeworks and meta:get_int("disable_pipeworks") == 0 then
		pipeworks.after_place(pos)
	end
	-- [ ] TODO: aktualizovat infotext
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	print("DEBUG: "..dump2({oldnode = oldnode, oldmetadata = oldmetadata}))
	if has_pipeworks and (oldmetadata.metas.disable_pipeworks or 0) == 0 then
		pipeworks.after_dig(pos)
	end
end

local function can_dig(pos, player)
	return true -- TODO
end

local function get_formspec(pos)
end

local function formspec_callback(custom_state, player, formname, fields)
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local custom_state = {
		pos = pos,
		node = node,
	}
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	return count
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	return stack:get_count()
end

local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
end

local function can_insert(pos, node, stack)
end

local function insert_object(pos, node, stack)
end

local function remove_items(pos, node, stack, dir, count, list, index)
end

local function change_size(pos, new_width, new_height)
	if
		new_width < 1 or new_height < 1 or new_width ~= math.floor(new_width) or
		new_height ~= math.floor(new_height)
	then
		error("Invalid arguments: "..new_width..", "..new_height.."!")
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local current_size = inv:get_size("main")
	local new_size = new_width * new_height
	if new_size < current_size and not inv:is_empty("main") then
		for i = current_size, new_size + 1, -1 do
			if not inv:get_stack("main", i):is_empty() then
				return false
			end
		end
	end
	meta:set_int("width", new_width)
	meta:set_int("height", new_height)
	inv:set_size("main", new_size)
	return true
end

local def = {
	description = "testovací truhla [EXPERIMENTÁLNÍ]",
	drawtype = "normal",
	tiles = {
		{name = "ch_test_chest_material.png", backface_culling = true},
	},
	overlay_tiles = {
		{name = "ch_test_chest_top_overlay.png", color = "white", backface_culling = true},
		{name = "ch_test_chest_top_overlay.png", color = "white", backface_culling = true},
		{name = "ch_test_chest_side_overlay.png", color = "white", backface_culling = true},
		{name = "ch_test_chest_side_overlay.png", color = "white", backface_culling = true},
		{name = "ch_test_chest_side_overlay.png", color = "white", backface_culling = true},
		{name = "ch_test_chest_front_overlay.png", color = "white", backface_culling = true},
	},
	paramtype = "none",
	paramtype2 = "color4dir",
	palette = "unifieddyes_palette_bright_color4dir.png",
	_ch_ud_palette = "unifieddyes_palette_color4dir.png",
	is_ground_content = false,
	sounds =  default.node_sound_wood_defaults(),
	groups = {
		snappy = 2,
		choppy = 2,
		oddly_breakable_by_hand= 2,
		tubedevice = 1,
		tubedevice_receiver = 1,
		ud_param2_colorable = 1,
		chest = 1,
	},

	on_construct = on_construct,
	preserve_metadata = preserve_metadata,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	can_dig = can_dig,
	on_rightclick = on_rightclick,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_metadata_inventory_move = on_metadata_inventory_move,
	on_metadata_inventory_put = on_metadata_inventory_put,
	on_metadata_inventory_take = on_metadata_inventory_take,
	on_blast = function() end,
	_ch_change_size = change_size,

	tube = {
		insert_object = insert_object,
		can_insert = can_insert,
		remove_items = remove_items,
		input_inventory = "main",
		connect_sides = {left = 1, right = 1, front = 1, back = 1, top = 1, bottom = 1},
	},
}

minetest.register_node("ch_test:chest", def)
