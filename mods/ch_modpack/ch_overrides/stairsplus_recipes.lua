local recipeitems = stairsplus:get_recipeitems()
local shapes = assert(ch_core.get_stairsplus_custom_shapes(nil))
local empty_row = {"", "", ""}
local from, from2, from3, to

if #recipeitems == 0 then
    error("No recipeitems gathered from staisplus!")
end

for _, recipeitem in ipairs(recipeitems) do
    local shape_to_node = {}
    for _, shape in ipairs(shapes) do
        shape_to_node[shape[1].."/"..shape[2]] = stairsplus:get_shape(recipeitem, shape[1], shape[2])
    end

    local function register_shape_selector_group_simple(shapes)
        local nodes = {}
        for _, shape in ipairs(shapes) do
            local n = shape_to_node[shape]
            if n ~= nil then
                table.insert(nodes, n)
            end
        end
        if #nodes > 1 then
            ch_core.register_shape_selector_group({nodes = nodes})
        end
        return #nodes
    end

    -- složit/rozložit trojitý díl
    for _, p in ipairs({
        {"slab/_1", "slab/_triplet"},
        {"slope/_roof22", "slope/_roof22_3"},
        {"slope/_roof22_raised", "slope/_roof22_raised_3"},
        {"slope/_roof45", "slope/_roof45_3"},
    }) do
        from, to = shape_to_node[p[1]], shape_to_node[p[2]]
        if from ~= nil and to ~= nil then
            minetest.register_craft({
                output = to,
                recipe = {
                    {from, from, from},
                    empty_row,
                    empty_row,
                },
            })
            minetest.register_craft({
                output = from.." 3",
                recipe = {{to}},
            })
        end
    end

    -- složit celý blok z protilehlých desek či svahů
    for _, p in ipairs({
        {"slab/_1", "slab/_15"},
        {"slab/_2", "slab/_14"},
        {"slab/_quarter", "slab/_three_quarter"},
        {"slab/", "slab/"},
        {"slope/", "slope/"},
        {"slope/_half", "slope/_half_raised"},
    }) do
        from, from2 = shape_to_node[p[1]], shape_to_node[p[2]]
        if from ~= nil and from2 ~= nil then
            minetest.register_craft({output = recipeitem, type = "shapeless", recipe = {from, from2}})
        end
    end

    -- podložit nízký blok na vyšší
    from2 = shape_to_node["slab/"]
    if from2 ~= nil then
        local bottom_row = {from2, ""}
        for _, p in ipairs({
            {"slope/_half", "slope/_half_raised"},
            {"slope/_inner_half", "slope/_inner_half_raised"},
            {"slope/_inner_cut_half", "slope/_inner_cut_half_raised"},
            {"slope/_outer_half", "slope/_outer_half_raised"},
        }) do
            from, to = shape_to_node[p[1]], shape_to_node[p[2]]
            if from ~= nil and from2 ~= nil and to ~= nil then
                minetest.register_craft({
                    output = to,
                    recipe = {{from, ""}, bottom_row},
                })
            end
        end
    end

    -- složit trojitý svah
    from, from2, from3 = shape_to_node["slope/_half"], shape_to_node["slab/"], shape_to_node["slope/_half_raised"]
    to = shape_to_node["slope/_tripleslope"]
    if from ~= nil and from2 ~= nil and from3 ~= nil and to ~= nil then
        minetest.register_craft({
            output = to,
            recipe = {
                {from, from2, from3},
                empty_row,
                empty_row,
            }
        })
        minetest.register_craft({
            output = to,
            recipe = {
                {from3, from2, from},
                empty_row,
                empty_row,
            }
        })
    end

    -- složit dvě stejné desky/panely/mikrobloky na desku/panel/mikroblok dvojnásobné tloušťky
    for _, p in ipairs({
        {"micro/_1", "micro/_2"},
        {"micro/_2", "micro/_4"},
        {"micro/_4", "micro/"},
        {"slab/_1", "slab/_2"},
        {"slab/_2", "slab/_quarter"},
        {"slab/_quarter", "slab/"},
        {"panel/_1", "panel/_2"},
        {"panel/_2", "panel/_4"},
        {"panel/_4", "panel/"},
        {"panel/_element", "panel/_wall"},
    }) do
        from, to = shape_to_node[p[1]], shape_to_node[p[2]]
        if from ~= nil and to ~= nil then
            minetest.register_craft({output = to, type = "shapeless", recipe = {from, from}})
        end
    end

    -- složit široký panel
    from, to = shape_to_node["panel/"], shape_to_node["panel/_wide"]
    if from ~= nil and to ~= nil then
        minetest.register_craft({
            output = to,
            recipe = {{from, from}, {"", ""}},
        })
    end

    -- složit k sobě dvě vychýlené tyče / rozložit
    from, to = shape_to_node["panel/_special"], shape_to_node["panel/_l"]
    if from ~= nil and to ~= nil then
        minetest.register_craft({
            output = to,
            recipe = {{from, from}, {"", ""}},
        })
        minetest.register_craft({
            output = to,
            recipe = {{from, ""}, {from, ""}},
        })
        minetest.register_craft({
            output = from.." 2",
            recipe = {{to}},
        })
    end

    -- přepnout zvýšené/nezvýšené střešní díly 22°
    from, to = shape_to_node["slope/_roof22"], shape_to_node["slope/_roof22_raised"]
    if from ~= nil and to ~= nil then
        minetest.register_craft({output = to, recipe = {{from}}})
        minetest.register_craft({output = from, recipe = {{to}}})
    end

    register_shape_selector_group_simple({"slope/_roof22", "slope/_roof22_raised", "slope/_roof45"})
    register_shape_selector_group_simple({"slope/_roof22_3", "slope/_roof22_raised_3", "slope/_roof45_raised"})

    from, from2, to = shape_to_node["slope/_diagfiller22a"], shape_to_node["slope/_diagfiller22b"], shape_to_node["slope/_diagfiller45"]
    if from ~= nil and from2 ~= nil and to ~= nil then
        ch_core.register_shape_selector_group({
            columns = 4, rows = 3, nodes = {
                {name = from,  param2 = 0xFC00, label = "+Z"},
                {name = from,  param2 = 0xFC01, label = "+X"},
                {name = from,  param2 = 0xFC02, label = "-Z"},
                {name = from,  param2 = 0xFC03, label = "-X"},
                {name = from2, param2 = 0xFC00, label = "+Z"},
                {name = from2, param2 = 0xFC01, label = "+X"},
                {name = from2, param2 = 0xFC02, label = "-Z"},
                {name = from2, param2 = 0xFC03, label = "-X"},
                {name = to,    param2 = 0xFC00, label = "+Z"},
                {name = to,    param2 = 0xFC01, label = "+X"},
                {name = to,    param2 = 0xFC02, label = "-Z"},
                {name = to,    param2 = 0xFC03, label = "-X"},
            },
        })
        minetest.register_craft({output = from2, recipe = {{from}}})
        minetest.register_craft({output = to, recipe = {{from2}}})
        minetest.register_craft({output = from, recipe = {{to}}})
    end
    -- register_shape_selector_group_simple({"slope/_diagfiller22a", "slope/_diagfiller22b", "slope/_diagfiller45"})

    -- přepínání spojujících se a přímých tvarů
    for _, shape in ipairs({"panel/_wall", "panel/_element", "panel/_pole", "panel/_pole_thin", "slab/_arcade"}) do
        from, to = shape_to_node[shape], shape_to_node[shape.."_flat"]
        if from ~= nil and to ~= nil then
            minetest.register_craft({output = to, recipe = {{from}}})
            minetest.register_craft({output = from, recipe = {{to}}})
            ch_core.register_shape_selector_group({nodes = {from, to}})
        end
    end
end
