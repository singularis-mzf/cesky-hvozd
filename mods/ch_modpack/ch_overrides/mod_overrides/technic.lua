local description_overrides = {
    ["technic:cnc_mk2"] = "CNC soustruh značky 2",
    ["technic:cnc"] = "CNC soustruh značky 1",
    ["technic:forcefield_emitter_off"] = "emitor silového pole",
    ["technic:forcefield_emitter_on"] = "emitor silového pole",
    ["technic:geothermal"] = "geotermální generátor",
    ["technic:hv_nuclear_reactor_core"] = "jádro jaderného reaktoru",
    ["technic:music_player"] = "hudební přehravač",
    ["technic:mv_alloy_furnace"] = "slévací pec",
    ["technic:mv_centrifuge"] = "centrifuga",
    ["technic:mv_compressor"] = "elektrický kompresor",
    ["technic:mv_electric_furnace"] = "elektrická pec",
    ["technic:mv_extractor"] = "extraktor",
    ["technic:mv_freezer"] = "chladič",
    ["technic:mv_grinder"] = "elektrický drtič",
    ["technic:quarry"] = "těžební stroj",
    ["technic:supply_converter"] = "transformátor",
    ["technic:tool_workshop"] = "opravna nářadí",
}

for name, description in pairs(description_overrides) do
    local override = {description = description}
    if minetest.registered_nodes[name] then
        minetest.override_item(name, override)
    end
    if minetest.registered_nodes[name.."_active"] then
        minetest.override_item(name, override)
    end
end
