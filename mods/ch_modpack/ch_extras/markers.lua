-- ch_extras:marker_{red_white,yellow_black}
---------------------------------------------------------------
local def
local ifthenelse = assert(ch_core.ifthenelse)

local function marker_update(pos, meta)
	if not meta then
		meta = minetest.get_meta(pos)
	end
	local owner = meta:get_string("owner")
	local date = meta:get_string("date")
	local view_name
	if owner ~= "" then
		view_name = ch_core.prihlasovaci_na_zobrazovaci(owner)
	else
		view_name = "neznámá postava"
	end
	meta:set_string("infotext", string.format("%s\ntyč umístil/a: %s\n%s", minetest.pos_to_string(pos), view_name, date))
end

local function marker_after_place_node(pos, placer, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	local player_name = placer and placer.get_player_name and placer:get_player_name()
	local cas = ch_time.aktualni_cas()
	if player_name then
		meta:set_string("owner", player_name)
	end
	meta:set_string("date", cas:YYYY_MM_DD())
	marker_update(pos, meta)
end

local function marker_check_for_pole(pos, node, _def, pole_pos, pole_node, pole_def)
	return ifthenelse((0 <= pole_node.param2 and pole_node.param2 <= 3) or (20 <= pole_node.param2 and pole_node.param2 <= 23), true, false)
end

def = {
	description = "značkovací tyč červeno-bílá",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-1/16, -8/16, -1/16, 1/16, 24/16, 1/16},
	},
	tiles = {
		"ch_extras_crvb_pruhy.png^[verticalframe:16:1",
		"ch_extras_crvb_pruhy.png^[verticalframe:16:5",
		"ch_extras_crvb_pruhy.png",
	},
	paramtype = "light",
	paramtype2 = "colorwallmounted",
	is_ground_content = false,
	sunlight_propagates = true,
	light_source = 3,
	groups = {oddly_breakable_by_hand = 2, ch_marker = 1},
	check_for_pole = marker_check_for_pole,
	after_place_node = marker_after_place_node,
	preserve_metadata = function(pos, oldnode, oldmeta, drops)
		for _, stack in ipairs(drops) do
			stack:get_meta():set_string("palette_index", "")
		end
	end,
}
minetest.register_node("ch_extras:marker_red_white", table.copy(def))

def.description = "značkovací tyč žluto-černá"
def.tiles = {
	"ch_extras_czl_pruhy.png^[verticalframe:16:1",
	"ch_extras_czl_pruhy.png^[verticalframe:16:5",
	"ch_extras_czl_pruhy.png",
}
minetest.register_node("ch_extras:marker_yellow_black", def)

minetest.register_lbm({
	label = "Marker updates",
	name = "ch_extras:marker_updates",
	nodenames = {"group:ch_marker"},
	run_at_every_load = true,
	action = function(pos, node)
		marker_update(pos)
	end,
})

minetest.register_craft({
	output = "ch_extras:marker_red_white 64",
	recipe = {
		{"", "default:steel_ingot", "dye:red"},
		{"", "default:steel_ingot", "dye:white"},
		{"", "default:steel_ingot", ""},
	}
})
minetest.register_craft({
	output = "ch_extras:marker_yellow_black 64",
	recipe = {
		{"", "default:steel_ingot", "dye:yellow"},
		{"", "default:steel_ingot", "dye:black"},
		{"", "default:steel_ingot", ""},
	}
})
