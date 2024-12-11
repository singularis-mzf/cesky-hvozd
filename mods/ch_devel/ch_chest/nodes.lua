-- local internal = ...

local has_pipeworks = core.get_modpath("pipeworks")
local ifthenelse = ch_core.ifthenelse

local def = {
	description = "moderní kovová truhla",
	drawtype = "normal",
	tiles = {
		{name = "ch_chest_material.png", backface_culling = true},
	},
	overlay_tiles = {
		{name = "ch_chest_top_overlay.png", color = "white", backface_culling = true},
		{name = "ch_chest_top_overlay.png", color = "white", backface_culling = true},
		{name = "ch_chest_side_overlay.png", color = "white", backface_culling = true},
		{name = "ch_chest_side_overlay.png", color = "white", backface_culling = true},
		{name = "ch_chest_side_overlay.png", color = "white", backface_culling = true},
		{name = "ch_chest_front_overlay.png", color = "white", backface_culling = true},
	},
	paramtype = "none",
	paramtype2 = "color4dir",
	palette = "unifieddyes_palette_bright_color4dir.png",
	_ch_ud_palette = "unifieddyes_palette_color4dir.png",
	is_ground_content = false,
	sounds =  default.node_sound_metal_defaults(),
	groups = {
		snappy = 2,
		choppy = 2,
		oddly_breakable_by_hand = 2,
		ud_param2_colorable = 1,
		chest = 1,
		ch_chest = 1,
	},
	ch_chest = {
		has_title = true,
		ownership = "owner",
		pipeworks = ifthenelse(has_pipeworks, true, false),
		qmove = true,
		trash = true,
	},

	on_construct = ch_chest.on_construct,
	preserve_metadata = ch_chest.preserve_metadata,
	after_place_node = ch_chest.after_place_node,
	after_dig_node = ch_chest.after_dig_node,
	can_dig = ch_chest.can_dig,
	on_rightclick = ch_chest.on_rightclick,
	allow_metadata_inventory_move = ch_chest.allow_metadata_inventory_move,
	allow_metadata_inventory_put = ch_chest.allow_metadata_inventory_put,
	allow_metadata_inventory_take = ch_chest.allow_metadata_inventory_take,
	on_metadata_inventory_move = ch_chest.on_metadata_inventory_move,
	on_metadata_inventory_put = ch_chest.on_metadata_inventory_put,
	on_metadata_inventory_take = ch_chest.on_metadata_inventory_take,
	on_blast = ch_chest.on_blast,
}

if has_pipeworks then
	def.groups.tubedevice = 1
	def.groups.tubedevice_receiver = 1
	def.tube = {
		insert_object = ch_chest.insert_object,
		can_insert = ch_chest.can_insert,
		remove_items = ch_chest.remove_items,
		input_inventory = "main",
		connect_sides = {left = 1, right = 1, front = 1, back = 1, top = 1, bottom = 1},
	}
end

core.register_node("ch_chest:metal", def)

--[[

Dokumentace metadat:

inventory main — hlavní inventář truhly, může mít libovolnou velikost; výchozí velikost je 8*4
inventory qmove — speciální inventář sloužící k rychlému přesunu dávek stejného typu, velikost 1
inventory trash – koš

int splitstacks — pro mód pipeworks: dovolí dělení dávek při vstupu z rour
string owner — postava s plnými právy k truhle; v případě darované truhly obdarovaná postava
-- string uuid — jedinečné ID truhly (textové)
-- string rights — řetězec, kde jednotlivé znaky reprezentují přístupová práva
string title — název truhly
string infotext
-- string ch_given_by — u darované truhly obsahuje jméno darující postavy
-- string ch_given_to — u darované truhly obsahuje jméno obdarované postavy

pořadí práv:
1,2,3 view (zobrazit)
4,5,6 sort (řadit)
7,8,9 put (vkládat)
10,11,12 take (brát)
13,14,15 dig (vytěžit)
16,17,18 set (nastavit)

]]
