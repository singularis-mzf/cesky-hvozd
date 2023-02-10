local Ombrellone_n_list = {
	{ "červený plážový slunečník (kulatý)", "red"},
	{ "oranžový plážový slunečník (kulatý)", "orange"},
    { "černý plážový slunečník (kulatý)", "black"},
	{ "žlutý plážový slunečník (kulatý)", "yellow"},
	{ "zelený plážový slunečník (kulatý)", "green"},
	{ "modrý plážový slunečník (kulatý)", "blue"},
	{ "fialový plážový slunečník (kulatý)", "violet"},
	{ "bílý plážový slunečník (kulatý)", "white"},
}

for i in ipairs(Ombrellone_n_list) do
	local Ombrellone_ndesc = Ombrellone_n_list[i][1]
	local colour = Ombrellone_n_list[i][2]

	local def = {
	    description = Ombrellone_ndesc.." (otevřený)",
	    drawtype = "mesh",
		mesh = "omb_n_o.obj",
	    tiles = {"Ombrellone_n_"..colour..".png"},
		use_texture_alpha = "opaque",
        inventory_image = "ombo_"..colour.."_r.png",
        wield_image  = "ombo_"..colour.."_r.png" ,
	    paramtype = "light",
	    paramtype2 = "facedir",
	    sunlight_propagates = true,
	    walkable = false,
	    selection_box = {
	        type = "fixed",
	        fixed = { -0.25, -0.5, -0.25, 0.25,0.5, 0.25 },
	    },
		groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
		sounds = default.node_sound_wood_defaults(),
        drop = "summer:ombrellone_n_"..colour.."_ch",
		on_rightclick = function(pos, node, clicker)
	        node.name = "summer:ombrellone_n_"..colour.."_ch"
	        minetest.set_node(pos, node)
	    end,
	}
	minetest.register_node("summer:ombrellone_n_"..colour, table.copy(def))

	def.description = Ombrellone_ndesc.." (zavřený)"
	def.mesh = "omb_n_c.obj"
	def.inventory_image = "ombc_"..colour.."_r.png"
	def.wield_image = "ombc_"..colour.."_r.png"
	def.drop = "summer:ombrellone_n_"..colour
	def.on_rightclick = function(pos, node, clicker)
		node.name = "summer:ombrellone_n_"..colour..""
		minetest.set_node(pos, node)
	end
	minetest.register_node("summer:ombrellone_n_"..colour.."_ch", def)
end
