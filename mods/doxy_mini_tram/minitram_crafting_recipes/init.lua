-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

local S = minetest.get_translator("minitram_crafting_recipes");

--! Returns the first registered item name from the list @p names.
--! The empty string is considered registered.
--! If none is registered, prints a warning message.
local function choose(names)
    for _, name in ipairs(names) do
        if name == "" or minetest.registered_items[names] then
            return name;
        end
    end

    minetest.log("warning", "minitram_crafting_recipes: None of these items is registered: '" .. table.concat(names, "', '") .. "'");
    return "";
end

local steel_ingot = choose({
    "technic:carbon_steel_ingot";
    "default:steel_ingot";
});

local steel_plate = choose({
    "default:ladder_steel";
    "technic:carbon_steel_ingot";
    steel_ingot;
});

-- Minitram pretends to run on battery, that is why the pantograph is lowered.
local battery = choose({
    "technic:blue_energy_crystal";
    "basic_materials:energy_crystal_simple";
    "";
});

local controller = choose({
    "technic:control_logic_unit";
    "mesecons_luacontroller:luacontroller0000";
    "mesecons_microcontroller:microcontroller0000";
    "basic_materials:ic";
    "";
});

local door = choose({
    "doors:door_steel";
    steel_plate;
});

local gem = choose({
    "default:mese_crystal";
    "";
});

local gear = choose({
    "basic_materials:gear_steel";
    "carts:rail";
    "default:ladder_steel";
    "";
});

local glass = choose({
    "xpanes:obsidian_pane_flat";
    "default:obsidian_glass";
    "default:glass";
});

local graphite = choose({
    "technic:graphite_rod";
    "mesecons:wire_00000000_off";
    "default:coal_lump";
});

local insulator = choose({
    "technic:rubber";
    "mesecons_materials:fiber";
    "basic_materials:cement_block";
    "default:clay_brick";
});

-- Lighting in crafting recipes.
-- Unfortunately, these mods do not provide groups like technical_light.
local lamp = choose({
    "morelights_modern:bar_light";
    "technic:lv_led";
    "default:meselamp";
});

local motor = choose({
    "technic:motor";
    "basic_materials:motor";
    "default:mese_crystal";
    "";
});

local paper = choose({
    "default:paper";
});

-- Dynamic line number signs in crafting recipes.
-- Unfortunately, these mods do not provide a sign group.
local sign;
-- Make sure that the signs mod is the one from display_modpack.
local signs_modpath = minetest.get_modpath("signs");
if signs_modpath and string.find(signs_modpath, "display_modpack", 1, --[[ plain ]] true) then
    sign = "group:display_api";
else
    sign = choose({
        "digilines:lcd";
        "default:sign_wall_steel";
    });
end

local steel_rod = choose({
    "technic:rebar";
    "basic_materials:steel_bar";
    steel_ingot;
});

local steel_block = choose({
    "technic:carbon_steel_block";
    "default:steelblock";
});

local trapdoor = choose({
    "doors:trapdoor_steel";
    "doors:door_steel";
    steel_ingot;
});

local wheel = choose({
    "advtrains:wheel"
});

local wool = choose({
    "lrfurn:armchair_blue";
    "wool:blue";
});

local template = "minitram_crafting_recipes:minitram_template";
minetest.register_craftitem(template, {
    description = S("Minitram Template\nCrafting ingredient for Minitram products");
    groups = {
        minitram = 1;
    };
    inventory_image = "minitram_crafting_recipes_template.png";
});
minetest.register_craft({
    output = template;
    recipe = {
        { paper, gem, paper };
        { "group:dye,color_cyan", gem, "group:dye,color_blue" };
        { paper, gear, paper };
    };
});

local seat = "minitram_crafting_recipes:minitram_seat_assembly";
minetest.register_craftitem(seat, {
    description = S("Minitram Seat Assembly\nFolding seat for Minitram vehicles.");
    groups = {
        minitram = 1;
    };
    inventory_image = "minitram_crafting_recipes_seat_assembly.png";
});
minetest.register_craft({
    output = seat;
    recipe = {
        { wool, template, wool };
        { trapdoor, steel_plate, trapdoor };
    };
});

local automatic_door = "minitram_crafting_recipes:minitram_door";
minetest.register_craftitem(automatic_door, {
    description = S("Minitram Automatic Door\nDoor for Minitram vehicles.");
    groups = {
        minitram = 1;
        metal = 1;
    };
    inventory_image = "minitram_crafting_recipes_door_assembly.png";
});
minetest.register_craft({
    output = automatic_door;
    type = "shapeless";
    recipe = { template, motor, steel_ingot, door, glass, glass };
});

local pantograph = "minitram_crafting_recipes:minitram_pantograph";
minetest.register_craftitem(pantograph, {
    description = S("Minitram Pantograph\nOverhead current collector for Minitram vehicles.");
    groups = {
        minitram = 1;
        metal = 1;
    };
    inventory_image = "minitram_crafting_recipes_pantograph.png";
});
minetest.register_craft({
    output = pantograph;
    recipe = {
        { graphite, template, graphite };
        { steel_rod, steel_ingot, steel_rod };
        { insulator, motor, insulator };
    };
});

local body = "minitram_crafting_recipes:minitram_konstal_105_body";
minetest.register_craftitem(body, {
    description = S("Minitram Konstal 105 Body Structure\nA steel shell waiting to be painted.");
    groups = {
        metal = 1;
        minitram = 1;
    };
    inventory_image = "minitram_crafting_recipes_konstal_105_body.png";
});
minetest.register_craft({
    output = body;
    recipe = {
        { steel_plate, steel_plate, steel_plate };
        { steel_rod, template, steel_rod };
        { steel_block, steel_block, steel_block };
    };
});


local body_assembly = "minitram_crafting_recipes:minitram_konstal_105_body_assembly";
minetest.register_craftitem(body_assembly, {
    description = S("Minitram Konstal 105 Body Assembly\nA steel shell with some furniture and paint.");
    groups = {
        metal = 1;
        minitram = 1;
    };
    inventory_image = "minitram_crafting_recipes_konstal_105_body_assembly.png";
});
minetest.register_craft({
    output = body_assembly;
    recipe = {
        { lamp, glass, lamp };
        { automatic_door, "group:dye,color_orange", automatic_door };
        { seat, body, seat };
    };
});

local bogie = "minitram_crafting_recipes:minitram_bogie";
minetest.register_craftitem(bogie, {
    description = S("Minitram Bogie\nThe “feet” of Minitram vehicles.");
    groups = {
        metal = 1;
        minitram = 1;
    };
    inventory_image = "minitram_crafting_recipes_bogie.png";
});
minetest.register_craft({
    output = bogie;
    recipe = {
        { wheel, steel_block, wheel };
        { motor, template, motor };
        { wheel, steel_block, wheel };
    };
});

local konstal_105 = "minitram_konstal_105:minitram_konstal_105_normal";
minetest.register_craft({
    output = konstal_105;
    recipe = {
        { battery, battery, "minitram_crafting_recipes:minitram_pantograph" };
        { sign, body_assembly, sign };
        { bogie, controller, bogie };
    };
});

-- Cheap additional templates.
minetest.register_craft({
    output = template;
    recipe = {
        { paper, "", paper };
        { "", "group:minitram", "" };
        { paper, "", paper };
    };
    -- preserve option is not implemented.
    replacements = {
        { template, template };
        { seat, seat };
        { door, door };
        { pantograph, pantograph };
        { body, body };
        { body_assembly, body_assembly };
        { bogie, bogie };
        { konstal_105, konstal_105 };
    };
});
