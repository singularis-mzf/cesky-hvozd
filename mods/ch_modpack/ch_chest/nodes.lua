local internal = ...

local has_pipeworks = minetest.get_modpath("pipeworks")
local has_unifieddyes = minetest.get_modpath("unifieddyes")

local def = {
	"moderní kovová truhla",
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
	paramtype2 = "4dir",
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
		ch_chest = 1,
	},

	on_construct = internal.on_construct,
	preserve_metadata = internal.preserve_metadata,
	after_place_node = internal.after_place_node,
	after_dig_node = internal.after_dig_node,
	can_dig = internal.can_dig,
	on_rightclick = internal.on_rightclick,
	allow_metadata_inventory_move = internal.allow_metadata_inventory_move,
	allow_metadata_inventory_put = internal.allow_metadata_inventory_put,
	allow_metadata_inventory_take = internal.allow_metadata_inventory_take,
	on_metadata_inventory_move = internal.on_metadata_inventory_move,
	on_metadata_inventory_put = internal.on_metadata_inventory_put,
	on_metadata_inventory_take = internal.on_metadata_inventory_take,
	on_blast = function() end,
}

if has_pipeworks then
	def.tube = {
		insert_object = internal.insert_object,
		can_insert = internal.can_insert,
		remove_items = internal.remove_items,
		input_inventory = "main",
		connect_sides = {left = 1, right = 1, front = 1, back = 1, top = 1, bottom = 1},
	},
end

if has_unifieddyes then
	def.paramtype2 = "color4dir"
	def.palette = "unifieddyes_palette_bright_color4dir.png"
	def._ch_ud_palette = "unifieddyes_palette_color4dir.png"
end

minetest.register_node("ch_chest:metal", def)

--[[

Dokumentace metadat:

inventory main — hlavní inventář truhly, může mít libovolnou velikost; výchozí velikost je 8*4
inventory qmove — speciální inventář sloužící k rychlému přesunu dávek stejného typu, velikost 1

int width — šířka inventáře pro zobrazení; >= 1
int height — výška inventáře pro zobrazení; >= 1
int splitstacks — pro mód pipeworks: dovolí dělení dávek při vstupu z rour
int autosort — je povoleno automatické řazení? 0 = ne, 1 = ano
int sort_mode — režim řazení (0 = výchozí režim)
int ch_given — 0 = truhla není darovaná; 1 = truhla je darovaná neanonymně; 2 = darovaná anonymně
string owner — postava s plnými právy k truhle; v případě darované truhly obdarovaná postava
string agroup_raw — seznam postav ve skupině, jak ho zadal vlastník/ice
string agroup — seznam postav ve skupině v normalizovaném tvaru (|postava1|postava2|)
string uuid — jedinečné ID truhly (textové)
string rights — řetězec, kde jednotlivé znaky reprezentují přístupová práva
string title — název truhly
string infotext
string ch_given_by — u darované truhly obsahuje jméno darující postavy
string ch_given_to — u darované truhly obsahuje jméno obdarované postavy

pořadí práv:
1,2,3 view (zobrazit)
4,5,6 sort (řadit)
7,8,9 put (vkládat)
10,11,12 take (brát)
13,14,15 dig (vytěžit)
16,17,18 set (nastavit)

]]
