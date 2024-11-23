if not minetest.get_modpath("ropes") then
    return
end
local texture = "[combine:16x16:3,0=ropes_5.png:0,0=ropes_5.png:-5,0=ropes_5.png^[noalpha"
local def = {
    description = "lano",
    tiles = {{name = texture, align_style = "world", backface_culling = true,}},
    paramtype = "none",
    paramtype2 = "facedir", -- ?
    is_ground_content = false,
    groups = {choopy = 3, snappy = 1},
}
minetest.register_node("ch_extras:rope_block", def)
stairsplus:register_all("ch_extras", "rope_block", "ch_extras:rope_block", def)

if minetest.get_modpath("technic_cnc") then
    technic_cnc.register_all("ch_extras:rope_block", def.groups, {texture}, def.description)
end

minetest.register_craft({
    output = "ch_extras:rope_block",
    recipe = {
        {"ropes:ropesegment", "ropes:ropesegment", "ropes:ropesegment"},
        {"ropes:ropesegment", "ropes:ropesegment", "ropes:ropesegment"},
        {"ropes:ropesegment", "ropes:ropesegment", "ropes:ropesegment"},
    },
})
