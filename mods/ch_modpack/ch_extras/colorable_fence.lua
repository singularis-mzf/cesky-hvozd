-- lakovaný plot
------------------
local ifthenelse = assert(ch_core.ifthenelse)

local texture = "ch_extras_colorable_fence.png"
ch_core.register_fence("ch_extras:colorable_texture", {
	fence = {
		name = "ch_extras:colorable_fence",
		texture = def.texture,
	},
	rail = {
		name = "ch_extras:colorable_fence_rail",
		texture = def.texture,
	},
	fencegate = {
		name = "ch_extras:colorable_fence_gate_v1",
		texture = def.texture,
	},
})
local def = {
	description = "lakovaný plot",
	tiles = {texture},
	paramtype2 = "color",
	palette = "unifieddyes_palette_extended.png",
	on_dig = unifieddyes.on_dig,
	groups = ch_core.assembly_groups(minetest.registered_nodes["ch_extras:colorable_fence"].groups,
		{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, ud_param2_colorable = 1}),
}
minetest.override_item("ch_extras:colorable_fence", def)

def.description = "lakované zábradlí"
def.groups = ch_core.assembly_groups(minetest.registered_nodes["ch_extras:colorable_fence_rail"].groups,
	{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, ud_param2_colorable = 1})
minetest.override_item("ch_extras:colorable_fence_rail", def)

def.description = "lakovaný plot: branka"
def.paramtype2 = "color4dir"
def.palette = "unifieddyes_palette_color4dir.png"
for _, item in ipairs({"ch_extras:colorable_fence_gate_v1_open", "ch_extras:colorable_fence_gate_v1_closed"}) do
	def.groups = ch_core.assembly_groups(minetest.registered_nodes[item].groups, {ud_param2_colorable = 1})
	minetest.override_item(item, def)
end
