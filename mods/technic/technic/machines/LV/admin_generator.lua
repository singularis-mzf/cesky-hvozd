local S = technic.getter

local eu_supply = 100000

local run = function(pos, node)
	local meta = minetest.get_meta(pos)
	-- meta:set_int("LV_EU_supply", eu_supply)
	meta:set_string("infotext", S("Admin @1 Generator", S("LV")).." ("..technic.EU_string(meta:get_int("LV_EU_supply"))..")")
end

minetest.register_node("technic:lv_admin_generator", {
	description = S("Admin @1 Generator", S("LV")),
	tiles = {"technic_water_mill_top_active.png^(technic_lv_cable.png^[opacity:120)"},
	paramtype2 = "none",
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2,
		technic_machine=1, technic_lv=1},
	sounds = default.node_sound_wood_defaults(),
	technic_run = run,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Admin @1 Generator", S("LV")))
		meta:set_int("LV_EU_supply", 0)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if placer:is_player() and minetest.check_player_privs(placer, "server") then
			local meta = minetest.get_meta(pos)
			meta:set_int("LV_EU_supply", eu_supply)
		end
	end,
	_ch_help = "Administrátorské generátory poskytují napájení jen tehdy, když je umístí postava s administrátorským oprávněním.",
	_ch_help_group = "admin_generator",
})

technic.register_machine("LV", "technic:lv_admin_generator", technic.producer)
