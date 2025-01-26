local revealed_nodes = {}

local function reveal(pos, node)
    if node.name == "ch_test:reveal_air" or node.name == "air" or node.name == "ignore" then
        return false
    end
    local epos = core.hash_node_position(pos)
    local meta = core.get_meta(pos)
    local timer = core.get_node_timer(pos)
    local old_name = node.name
    meta:set_string("_ch_test_original_node_name", old_name)
    node.name = "ch_test:reveal_air"
    core.swap_node(pos, node)
    revealed_nodes[epos] = node.name
    timer:start(60)
end

local function hide(pos, node)
    if node.name ~= "ch_test:reveal_air" then
        return false
    end
    local epos = core.hash_node_position(pos)
    local timer = core.get_node_timer(pos)
    local meta = core.get_meta(pos)
    local old_name = meta:get_string("_ch_test_original_node_name")
    if old_name ~= "" and old_name ~= "air" and core.registered_nodes[old_name] ~= nil then
        timer:stop()
        node.name = old_name
        core.swap_node(pos, node)
        meta:set_string("_ch_test_original_node_name", "")
    else
        core.remove_node(pos)
    end
    revealed_nodes[epos] = nil
end

local function on_timer(pos, elapsed)
    core.load_area(pos)
    hide(pos, core.get_node(pos))
end

local function hide_all()
    local positions = table.copy(revealed_nodes)
    for epos, _ in pairs(positions) do
        local pos = core.get_position_from_hash(epos)
        core.load_area(pos)
        local node = core.get_node(pos)
        hide(pos, node)
    end
    revealed_nodes = {}
end

local def = {
    description = "vzduch odkrytí",
    drawtype = "airlike",
    paramtype = "light",
    paramtype2 = "none",
    light_source = 2,
    pointable = false,
    sunlight_propagates = true,
    walkable = false,
    groups = {not_in_creative_inventory = 1},
    on_place = function() return ItemStack() end,
    on_timer = on_timer,
    on_use = function() return ItemStack() end,
}
core.register_node("ch_test:reveal_air", def)

def = {
    description = "administrátorská hůlka odkrytí",
    inventory_image = "blank.png^[noalpha^[multiply:#000000^[invert:rgb",
}
function def.on_place(itemstack, placer, pointed_thing)
    if placer == nil or ch_core.get_player_role(placer) ~= "admin" or pointed_thing.type ~= "node" then
        return
    end
    local pos = pointed_thing.above
    local node = core.get_node(pos)
    if node.name == "ch_test:reveal_air" then
        hide(pos, node)
    else
        reveal(pos, node)
    end
end

function def.on_use(itemstack, user, pointed_thing)
    if user == nil or ch_core.get_player_role(user) ~= "admin" or pointed_thing.type ~= "node" then
        return
    end
    local pos = pointed_thing.under
    local node = core.get_node(pos)
    reveal(pos, node)
end
core.register_tool("ch_test:reveal_wand", def)

def = {
    description = "skryje všechny bloky odkryté pomocí hůlky odkrytí",
    privs = {server = true},
    func = hide_all,
}

core.register_chatcommand("skrýtodkryté", def)
core.register_chatcommand("skrytodkryte", def)

def = {
    label = "Clear reveal air",
    name = "ch_test:clear_reveal_air",
    nodenames = {"ch_test:reveal_air"},
    run_at_every_load = true,
    action = hide,
}
core.register_lbm(def)
