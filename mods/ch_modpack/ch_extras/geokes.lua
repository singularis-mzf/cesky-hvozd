-- Geocache sign and cache

local ch_help = "Značka geokešingu pro umístění na cedule a směrovky existuje ve dvou variantách,\njedna pro normální cedule a druhá pro cedule na tyčích.\nZnačka se ve skutečnosti uloží do bloku 2 m před tyčí/pokladem a lze ji otáčet klíčem nebo šroubovákem.\nPozor na neintuitivní umístění výběrového kvádru značky! Značku je možno skombinovat s nápisem na ceduli."

local def = {
    description = "značka geokešingu (pro umístění na cedule a směrovky)",
    drawtype = "nodebox",
    tiles = {
        "ch_core_empty.png",
        "ch_core_empty.png",
        "ch_core_empty.png",
        "ch_core_empty.png",
        "ch_core_empty.png",
        {name = "ch_extras_geocaching.png", backface_culling = true},
    },
    use_texture_alpha = "clip",
    inventory_image = "ch_extras_geocaching.png",
    wield_image = "ch_extras_geocaching.png",
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    groups = {dig_immediate = 2, geocache_mark = 1},
    node_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, 1.425 * 4, 0.5, 0.5, 1.425 * 4},
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.125, -0.125, 1.4, 0.125, 0.125, 1.45},
    },
    visual_scale = 0.25,
    walkable = false,
    legacy_wallmounted = true,
    sounds = default.node_sound_leaves_defaults(),
    _ch_help_group = "gcache_mark",
    _ch_help = ch_help,
}
minetest.register_node("ch_extras:geocache_sign", def)

local pos = 1.8

def = table.copy(def)
def.description = "značka geokešingu (pro umístění na cedule a směrovky na tyčích)"
def.node_box = {
    type = "fixed",
    fixed = {-0.5, -0.5, pos * 4, 0.5, 0.5, pos * 4},
}
function def.on_place(itemstack, placer, pointed_thing)
    if pointed_thing.type == "node" then
        local node = minetest.get_node(pointed_thing.under)
        local ndef = minetest.registered_nodes[node.name]
        if ndef ~= nil and ndef.paramtype2 == "facedir" then
            local v = minetest.facedir_to_dir(node.param2)
            pointed_thing.above = vector.subtract(pointed_thing.under, v)
        end
    end
    return minetest.item_place(itemstack, placer, pointed_thing)
end
minetest.register_node("ch_extras:geocache_sign2", def)

minetest.register_craft({
    output = "ch_extras:geocache_sign",
    recipe = {
        {"", "dye:black", ""},
        {"dye:black", "", "dye:black"},
        {"", "dye:black", "dye:black"},
    },
})
minetest.register_craft({
    output = "ch_extras:geocache_sign",
    recipe = {{"ch_extras:geocache_sign2"}},
})
minetest.register_craft({
    output = "ch_extras:geocache_sign2",
    recipe = {{"ch_extras:geocache_sign"}},
})

local box = {
    type = "fixed",
    fixed = {-0.375, -0.5, -0.375, 0.375, 0.25, 0.375},
}

def = {
    description = "geokeš",
    drawtype = "mesh",
    mesh = "ch_extras_geocache.obj",
    tiles = {
        "[combine:64x64:0,0=default_chest_top.png\\^[resize\\:64x64:8,8=ch_extras_geocaching.png\\^[resize\\:48x48",
        "default_chest_top.png",
        "default_chest_side.png^[transformFX",
        "default_chest_side.png",
        "default_chest_side.png",
        "[combine:64x64:0,0=default_chest_front.png\\^[resize\\:64x64:16,32=ch_extras_geocaching.png\\^[resize\\:32x32",
    },
    paramtype = "light",
    paramtype2 = "4dir",
    groups = {dig_immediate = 2},
    selection_box = box,
    collision_box = box,
    sounds = default.node_sound_wood_defaults(),
}

minetest.register_node("ch_extras:geocache", def)

for _, chest in ipairs({"default:chest", "default:chest_locked"}) do
    minetest.register_craft({
        output = "ch_extras:geocache",
        recipe = {{"group:geocache_mark", ""}, {chest, ""}},
    })
end
