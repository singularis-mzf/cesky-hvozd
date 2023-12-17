-- NODE DEFINITION
local function on_construct(pos)
	minetest.get_meta(pos):set_string("infotext", "pozice pro nehráčskou postavu")
end

local function on_punch(pos, node, clicker, itemstack)
	return ch_npc.update_npc(pos, node)
end

local function on_rightclick(pos, node, clicker, itemstack)
	if minetest.check_player_privs(clicker, "spawn_npc") then
		local player_name = clicker:get_player_name()
		local meta = minetest.get_meta(pos)
		local formspec = ch_npc.internal.get_node_formspec(meta)
		ch_npc.internal.show_formspec(pos, player_name, "ch_npc:node_formspec", formspec)
	end
end

local def = {
	description = "nehráčská postava (zobrazená)",
	drawtype = "nodebox",
	node_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 1/16 - 0.5, 0.5}},
	tiles = {"ch_core_white_pixel.png^[opacity:0"},
	use_texture_alpha = "clip",
	inventory_image = "default_invisible_node_overlay.png",
	wield_image = "default_invisible_node_overlay.png",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {ch_npc_spawner = 1, not_in_creative_inventory = 1},
	walkable = false,
	pointable = true,
	light_source = 1,

	on_construct = on_construct,
	on_punch = on_punch,
	on_rightclick = on_rightclick,
}

minetest.register_node("ch_npc:npc", table.copy(def))

def.description = "nehráčská postava"
def.tiles = {"ch_core_white_pixel.png^[opacity:16"}
def.use_texture_alpha = "blend"
def.light_source = 5
def.groups = {ch_npc_spawner = 2}

minetest.register_node("ch_npc:npc_hidden", def)
