-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

--! Splits the text_block_description @p block at section break characters.
--!
--! If such a character is present, returns two new blocks.
function visual_line_number_displays.split_at_section_break(block)
    if not block.braceless then
        return nil;
    end

    local newline = string.find(block.text, "\n", 1, --[[ plain ]] true);
    local semicolon = string.find(block.text, ";", 1, --[[ plain ]] true);

    local section_break;
    if newline and semicolon then
        section_break = math.min(newline, semicolon);
    else
        section_break = newline or semicolon;
    end

    if section_break then
        local left = {
            text = string.sub(block.text, 1, section_break - 1);
            features = {};
            braceless = true;
        };
        local right = {
            text = string.sub(block.text, section_break + 1);
            features = {};
            braceless = true;
        };

        return left, right;
    else
        return nil;
    end
end

--! Trims whitespace from braceless blocks
--! in the text_block_desctiption list @p blocks.
function visual_line_number_displays.simplify_braceless_blocks(blocks)
    local i = 1;
    while i <= #blocks do
        if blocks[i].braceless then
            blocks[i].text = string.trim(blocks[i].text);
            if blocks[i].text == "" then
                table.remove(blocks, i);
                i = i - 1;
            end
        end

        i = i + 1;
    end
end

--! Converts @p input from a line number string (with blocks syntax)
--! to lists of blocks describing a line number display section each.
--!
--! Returned blocks have escape sequences and coloration applied,
--! and minimum sizes calculated.
--!
--! @returns number_blocks, text_blocks, details_blocks,
--! which are lists of text_block_description tables; and background_color.
function visual_line_number_displays.parse_display_string(input)
    -- Parse escape sequences
    input = visual_line_number_displays.parse_escapes(input);

    -- Parse macro syntax
    for _ = 1, 4 do
        local result, continue = visual_line_number_displays.parse_macros(input);
        input = result;
        if not continue then
            break;
        end
    end

    -- Make blocks from syntax
    local block_list = visual_line_number_displays.parse_text_block_string(input);

    -- Split blocks in number, text, details sections
    local number_blocks = {};
    local text_blocks = {};
    local details_blocks = {};

    local sections = { number_blocks, text_blocks, details_blocks };
    local section = 1;
    for _, block in ipairs(block_list) do
        local left, right = visual_line_number_displays.split_at_section_break(block);
        if left then
            while true do
                table.insert(sections[section], left);
                section = math.min(section + 1, 3);

                -- One braceless block can contain more than one section break.
                local next_left, next_right = visual_line_number_displays.split_at_section_break(right);
                if next_left then
                    left, right = next_left, next_right;
                else
                    table.insert(sections[section], right);
                    break;
                end
            end
        else
            table.insert(sections[section], block);
        end
    end

    -- Remove leftover whitespace from section breaks
    visual_line_number_displays.simplify_braceless_blocks(number_blocks);
    visual_line_number_displays.simplify_braceless_blocks(text_blocks);
    visual_line_number_displays.simplify_braceless_blocks(details_blocks);

    -- Parse various syntax features in blocks
    visual_line_number_displays.parse_line_breaks_in_blocks(number_blocks);
    visual_line_number_displays.parse_line_breaks_in_blocks(text_blocks);
    visual_line_number_displays.parse_line_breaks_in_blocks(details_blocks);

    local colors = visual_line_number_displays.calculate_line_color(number_blocks);
    if not colors then
        colors = visual_line_number_displays.colors_for_line(1);
    end

    visual_line_number_displays.colorize_blocks(number_blocks, colors);
    local display_background_color = colors.background;
    visual_line_number_displays.colorize_blocks(text_blocks, colors);
    visual_line_number_displays.colorize_blocks(details_blocks, colors);

    visual_line_number_displays.parse_entities_in_blocks(number_blocks);
    visual_line_number_displays.parse_entities_in_blocks(text_blocks);
    visual_line_number_displays.parse_entities_in_blocks(details_blocks);

    visual_line_number_displays.calculate_block_sizes(number_blocks);
    visual_line_number_displays.calculate_block_sizes(text_blocks);
    visual_line_number_displays.calculate_block_sizes(details_blocks);

    -- Shade display background color if it is used by an outline-less block.
    for _, blocks in ipairs({ number_blocks, text_blocks, details_blocks }) do
        for _, block in ipairs(blocks) do
            if block.background_color == display_background_color then
                local shape = block.background_shape;
                if shape and (string.sub(shape, -9) ~= "_outlined") then
                    display_background_color = visual_line_number_displays.shade_background_color(display_background_color);
                    break;
                end
            end
        end
    end

    return number_blocks, text_blocks, details_blocks, display_background_color;
end

--! Returns a texture string.
--!
--! Returns an empty string if all layouts are empty.
--!
--! @param display_description A display_description table.
--! @param display_string The string used for the outside train display.
function visual_line_number_displays.render_displays(display_description, display_string)
    local base_texture = display_description.base_texture;

    if #display_description.displays == 0 then
        return base_texture;
    end

    local number, text, details, background_color = visual_line_number_displays.parse_display_string(display_string);

    local layouts = {};
    local superresolution = 1;

    for _, display in ipairs(display_description.displays) do
        -- Layout
        local layout;
        if display.level == "number" then
            layout = visual_line_number_displays.display_layout:new(number);
        elseif display.level == "text" then
            layout = visual_line_number_displays.display_layout:new(number, text);
        else
            layout = visual_line_number_displays.display_layout:new(number, text, details);
        end

        layout:calculate_layout(display.max_width, display.height);

        -- Required superresolution
        superresolution = math.max(superresolution, layout:required_superresolution());

        -- Horizontal alignment
        local used_width = layout:width();
        local center_to_left = display.center_width;
        local center_to_right = display.max_width - display.center_width;

        if (used_width * 0.5) >= center_to_left then
            -- Left align
            layout.x_offset = 0;
        elseif (used_width * 0.5) >= center_to_right then
            -- Right align
            layout.x_offset = display.max_width - used_width;
        else
            -- Center align
            layout.x_offset = math.floor(display.center_width - (used_width * 0.5));
        end

        table.insert(layouts, layout);
    end

    local texture_size = {
        width = display_description.base_resolution.width * superresolution;
        height = display_description.base_resolution.height * superresolution;
    };
    local size_string = string.format("%ix%i", texture_size.width, texture_size.height);
    -- Unfortunately, Minetest is unable to resize a base texture
    -- to the size of a combine texture modifier.
    -- Resize the base texture explictly.
    local texture_string = base_texture .. "^[resize:" .. size_string .. "^[combine:" .. size_string;

    local layout_strings = {}
    for i = 1, #display_description.displays do
        local layout_texture = visual_line_number_displays.render_layout(layouts[i], display_description.displays[i].height, superresolution, background_color);

        if layout_texture then
            layout_texture = visual_line_number_displays.texture_escape(layout_texture);

            local layout_position = {
                x = display_description.displays[i].position.x + layouts[i].x_offset * superresolution;
                y = display_description.displays[i].position.y * superresolution;
            };
            layout_texture = string.format(":%i,%i=", layout_position.x, layout_position.y) .. layout_texture;

            table.insert(layout_strings, layout_texture);
        end
    end

    if not next(layout_strings) then
        return base_texture;
    end

    return texture_string .. table.concat(layout_strings);
end

--! Updates the line number display textures of a wagon,
--! using the data available in the wagon (part of @p {...}),
--! and the definition consisting of @p display_description and @p slot.
--!
--! This function needs to be called from custom_on_step() of an advtrains wagon.
--!
--! @param display_description A display_description table.
--! @param slot Which texture slot shall receive the displays.
--! @param {...} Arguments passed to custom_on_step().
function visual_line_number_displays.advtrains_wagon_on_step(display_description, slot, ...)
    local self, _dtime, _data, train = ...;

    local display_string = train.text_outside or "";

    if display_string == self.display_string_cache then
        return;
    end

    self.display_string_cache = display_string;

    local texture = visual_line_number_displays.render_displays(display_description, display_string);

    local textures = self.object:get_properties().textures;
    textures[slot] = texture;
    self.object:set_properties({ textures = textures });
end
