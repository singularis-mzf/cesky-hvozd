-- ch_extras:vystavni_ram
---------------------------------------------------------------
--[[
	thickness = tloušťka rámu
	y_shift = posun nodeboxu na ose +y
	shrink = o kolik má vnitřní hrana boxu zasahovat dovnitř ohraničeného bloku
]]
local function generate_vb_nodebox(thickness, y_shift, shrink)
	local w, sh, ip = thickness, y_shift, shrink
	local result = {}
	for _, a in ipairs({{-0.5 - w + ip, -0.5 + ip}, {0.5 - ip, 0.5 - ip + w}}) do
		for _, b in ipairs({{-0.5 + ip - w, -0.5 + ip}, {0.5 - ip, 0.5 - ip + w}}) do
			-- x
			table.insert(result, {-0.5 + ip - w, a[1] + sh, b[1], 0.5 - ip + w, a[2] + sh, b[2]})
			-- y
			table.insert(result, {a[1], -0.5 + ip - w + sh, b[1], a[2], 0.5 - ip + w + sh, b[2]})
			-- z
			table.insert(result, {a[1], b[1] + sh, -0.5 + ip - w, a[2], b[2] + sh, 0.5 - ip + w})
		end
	end
	return {type = "fixed", fixed = result}
end

local def = {
	description = "výstavní rám (barvitelný)",
	drawtype = "nodebox",
	tiles = {{name = "ch_core_white_pixel.png", backface_culling = true}},
	use_texture_alpha = "opaque",
	paramtype = "light",
	paramtype2 = "color",
	groups = {oddly_breakable_by_hand = 3, cracky = 1, ud_param2_colorable = 1},
	palette = "unifieddyes_palette_extended.png",
	node_box = generate_vb_nodebox(1/64, -1, 1/100),
	selection_box = {type = "fixed", fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25}},
	is_ground_content = false,
	walkable = false,
	on_construct = unifieddyes.on_construct,
	on_dig = unifieddyes.on_dig,
}
minetest.register_node("ch_extras:vystavni_ram", def)

for _, glass in ipairs({"building_blocks:smoothglass", "building_blocks:woodglass"}) do
	minetest.register_craft({
		output = "ch_extras:vystavni_ram",
		recipe = {
			{"default:mese_crystal_fragment", ""},
			{glass, ""},
		}
	})
end
