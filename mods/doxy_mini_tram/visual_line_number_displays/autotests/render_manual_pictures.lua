-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- This file registers the /render_manual_pictures chat command.
-- See the command description at the bottom of this file for details.

-- This is the test set of line number display strings,
-- for which PNG images shall be generated.
-- This test set also contains reference texture strings,
-- these are only relevant for the busted unit tests.
local reference = dofile(minetest.get_modpath("visual_line_number_displays") .. "/autotests/manual_pictures.lua");

-- These ASCII characters are problematic in file paths
-- or in texture strings, or are otherwise weird.
local characters_to_escape = {
    ["\\"] = true;
    ["/"] = true;
    ["."] = true;
    [" "] = true;
    ["%"] = true;
    ["+"] = true;
    [":"] = true;
    [";"] = true;
    ["^"] = true;
    ["#"] = true;
    ["\""] = true;
    ["'"] = true;
    ["|"] = true;
    ["{"] = true;
    ["}"] = true;
    ["("] = true;
    [")"] = true;
    ["<"] = true;
    [">"] = true;
    ["["] = true;
    ["]"] = true;
};

--! Returns a string containing byte @p octet, possibly escaped.
--! Escaping is done with @c +xx, similar to @c %xx in URLs.
local function escape_character(octet)
    local character = string.char(octet);
    if octet >= 0x7f or octet <= 0x20 or characters_to_escape[character] then
        return string.format("+%02X", octet);
    else
        return character;
    end
end

--! Returns a string containing @p input with @c +xx escape sequences.
local function escape_string(input)
    local result = "";
    for i = 1, #input do
        local octet = string.byte(input, i);
        result = result .. escape_character(octet);
    end
    return result;
end

--! PNG images shall be saved somewhere in the world directory,
--! because Minetest allows to create subdirectories there.
local image_directory = minetest.get_worldpath() .. "/manual_pictures/";

minetest.rmdir(image_directory, --[[ recursive ]] true);
minetest.mkdir(image_directory);

--! Returns an item from the test set @c reference.
--! If @p index is beyond the list of tests, returns nil.
--!
--! This function handles calculation of a texture string from
--! a line number display string.
--!
--! @returns texture_string, png_file_name
local function get_task(index)
    local test = reference[index];
    if not test then
        return nil;
    end

    local short_description = string.gsub(test[1], " ", "_");
    local display_string_input = test[2];
    local max_width = test[4][1];
    local height = test[4][2];
    local level = test[4][3];

    local display_description = {
        base_resolution = { width = max_width, height = height };
        base_texture = "vlnd_transparent.png";
        displays = {{
            position = { x = 0, y = 0 };
            height = height;
            max_width = max_width;
            center_width = 0;
            level = level;
        }};
    };

    local texture_string = visual_line_number_displays.render_displays(
        display_description,
        display_string_input
    );

    local png_file_name = image_directory .. "display_" .. index .. "_" .. escape_string(short_description) .. "_" .. level .. ".png";

    return texture_string, png_file_name;
end

--! Sets a HUD element of @c test_player to the texture string @p index.
--!
--! After 1 second, sets another HUD element for the next texture.
local function test_function(index, test_player)
    if index > #reference then
        minetest.chat_send_player(test_player, "/render_manual_pictures completed.");
        return;
    end

    local test_texture, image_file_path = get_task(index);
    local tries = 1;

    -- Find a task that is not done yet.
    while tries <= #reference and io.open(image_file_path, "r") do
        test_texture, image_file_path = get_task((index + tries - 1) % #reference + 1);
        tries = tries + 1;
    end

    if tries > #reference then
        minetest.chat_send_player(test_player, "/render_manual_pictures completed.");
        return;
    end

    if not test_texture then
        minetest.debug("No test data found.");
        return;
    end

    test_texture = "(" .. test_texture .. ")^[save:" .. image_file_path;

    local player = minetest.get_player_by_name(test_player);
    if not player then
        minetest.debug("Could not get player '" .. test_player .. "'!");
    else
        -- Note that I do not understand HUD mechanics.
        -- I tried to shotgun-wise add some image element,
        -- and the client appears to see it.
        -- It is not actually visible on the client’s screen...
        player:hud_add({
                hud_elem_type = "image";
                position = { x = 0.5, y = 0.5 };
                name = "Test Texture";
                text = test_texture;
            });
    end

    minetest.after(1, test_function, index + 1, test_player);
end

minetest.register_chatcommand("render_manual_pictures", {
        description = [[
Set various test texture strings as HUD elements.

This command causes the texture strings from manual_pictures.lua
to be calculated and sent to a client.
The client should have doxygen-spammer/save-texture-string-as-png
branch applied, so the '[save:filename.png' texture modifier
causes the texture to be calculated and saved as PNG.

This command is very likely only useful for "singleplayer",
because it works only in a singleplayer world.

This command is used in visual_line_number_displays to generate
documentation and unit test pictures semi-automatically.
]];
        func = function(playername)
            test_function(1, playername);
        end;
    });
