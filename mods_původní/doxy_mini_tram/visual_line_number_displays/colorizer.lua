-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

visual_line_number_displays.fixed_line_colors = {
    [0] = { background = "#000000", feature = "#ff2222" };
    [1] = { background = "#1e00ff", feature = "#ff2222" };
    [2] = { background = "#ff001e", feature = "#000000" };
    [3] = { background = "#7f007f", feature = "#ff2222" };
    [4] = { background = "#007f00", feature = "#ff2222" };
    [5] = "#ffa400";
    [6] = "#ffff00";
    [7] = { background = "#797979", feature = "#ff2222" };
    [8] = { background = "#ff1ed0", feature = "#ff8800" };
    [9] = "#00c0b1";
};

--! Returns a color string for line number @p number (integer),
--! calculated with the subway wagon’s line color algorithm.
function visual_line_number_displays.subway_algorithm(number)
    if type(number) ~= "number" then
        return nil;
    end

    local r = math.floor(math.fmod(number * 67 + 101, 255));
    local g = math.floor(math.fmod(number * 97 + 109, 255));
    local b = math.floor(math.fmod(number * 73 + 127, 255));

    return string.format("#%02x%02x%02x", r, g, b);
end

--! Returns integers @c r, @c g, @c b for an input string of format @c #rrggbb.
local function rgb(color_string)
    local r = tonumber(string.sub(color_string, 2, 3), 16);
    local g = tonumber(string.sub(color_string, 4, 5), 16);
    local b = tonumber(string.sub(color_string, 6, 7), 16);
    return r, g, b;
end

-- Lua 5.1 does not support hexadecimal floats.
local inv_255 = 1 / 255;

--! Returns a color metric distance for color strings @p a and @p b.
local function redmean_sqr(a, b)
    -- Components.
    local r1, g1, b1 = rgb(a);
    local r2, g2, b2 = rgb(b);

    -- Redmean quasi-metric:
    -- delta_color variables
    local dr = r1 - r2;
    local dg = g1 - g2;
    local db = b1 - b2;
    -- mean_red variable
    local r_ = (r1 + r2) * 0.5;
    -- color_weight variables
    local rw = (2 + r_ * inv_255);
    local gw = 4;
    local bw = 5 - rw;

    -- Luma metric using redmean weights as luma coefficients
    local dl = (r1 * rw + g1 * gw + b1 * bw) - (r2 * rw + g2 * gw + b2 * bw);
    local lw = 3;
    return rw * dr * dr + gw * dg * dg + bw * db * db + lw * dl * dl;
end

local implicit_color_pool = {
    -- Desaturated colors for text.
    text = {
        { "#000000", 1.0 };
        { "#ffffff", 1.0 };
        { "#ff2222", 0.8 };
        { "#22ff22", 0.8 };
        { "#2222ff", 0.8 };
        { "#55aaaa", 0.6 };
        { "#aa55aa", 0.6 };
        { "#aaaa55", 0.6 };
    };
    -- Saturated colors for background.
    background = {
        { "#ff0000", 1.0 };
        { "#00ff00", 1.0 };
        { "#0000ff", 1.0 };
        { "#00ffff", 0.8 };
        { "#ff00ff", 0.8 };
        { "#ffff00", 0.7 };
    };
    -- Dark and bright colors for secondary background.
    secondary_background = {
        { "#000000", 0.2 };
        { "#ffffff", 1.0 };
        { "#aaffff", 0.7 };
        { "#ffaaff", 0.7 };
        { "#ffffaa", 0.7 };
        { "#550000", 0.7 };
        { "#005500", 0.7 };
        { "#000055", 0.7 };
    };
    -- Alert colors for features.
    feature = {
        { "#ff2222", 1.0 };
        { "#ff8800", 0.8 };
        { "#ff0088", 0.7 };
        { "#882222", 0.5 };
        { "#ffdd33", 0.4 };
        { "#000000", 0.3 };
    };
};

--! Returns a color from @p pool with maximum contrast to colors in @p state.
--!
--! @param pool A list of color strings.
--! @param state A color_state table.
local function max_contrast(pool, state)
    local other_colors = {};
    table.insert(other_colors, state.text);
    table.insert(other_colors, state.background);
    table.insert(other_colors, state.secondary_background);
    table.insert(other_colors, state.feature);

    local best_color;
    local best_color_distance = 0;

    for _, c in ipairs(pool) do
        local color, factor = c[1], c[2]
        local min_distance = math.huge;
        for _, other_color in ipairs(other_colors) do
            min_distance = math.min(min_distance, redmean_sqr(color, other_color) * factor);
        end
        if min_distance > best_color_distance then
            best_color = color;
            best_color_distance = min_distance;
        end
    end

    return best_color;
end

--! Returns a color_state table that contains all expclicit colors from
--! @p current_state, and contrast maximized colors for the other colors.
function visual_line_number_displays.populate_color_state(current_state)
    local result = {
        text_explicit = current_state.text_explicit and true or false;
        background_explicit = current_state.background_explicit and true or false;
        secondary_background_explicit = current_state.secondary_background_explicit and true or false;
        feature_explicit = current_state.feature_explicit and true or false;
    };

    if result.text_explicit then
        result.text = current_state.text;
    end
    if result.background_explicit then
        result.background = current_state.background;
    end
    if result.secondary_background_explicit then
        result.secondary_background = current_state.secondary_background;
    end
    if result.feature_explicit then
        result.feature = current_state.feature;
    end

    if not result.text then
        result.text = max_contrast(implicit_color_pool.text, result);
    end
    if not result.background then
        result.background = max_contrast(implicit_color_pool.background, result);
    end
    if not result.feature then
        result.feature = max_contrast(implicit_color_pool.feature, result);
    end
    if not result.secondary_background then
        result.secondary_background = max_contrast(implicit_color_pool.secondary_background, result);
    end

    return result;
end

--! Tries to find a line number or line string in @p blocks,
--! and returns the appropriate color_state table for that line, or nil.
--!
--! @param blocks A list of text_block_description tables.
function visual_line_number_displays.calculate_line_color(blocks)
    -- Match whole string.
    for _, block in ipairs(blocks) do
        local colors = visual_line_number_displays.colors_for_line(block.text);
        if colors then
            return colors;
        end
    end

    -- Match any integer in the string.
    for _, block in ipairs(blocks) do
        -- Remove all brace sequences, because these may contain digits.
        local text = "";
        local pos = 1;
        while pos <= #block.text do
            local left = string.find(block.text, "{", pos, --[[ plain ]] true);
            if not left then
                text = text .. string.sub(block.text, pos);
                break;
            end

            local right = string.find(block.text, "}", left + 1, --[[ plain ]] true);
            if not right then
                text = text .. string.sub(block.text, pos);
                break;
            end

            text = text .. string.sub(block.text, pos, left - 1);
            pos = right + 1;
        end

        -- This pattern is faster than bytewise checking for digits.
        local digits = string.match(text, "-?[0-9]+");
        if digits then
            local colors = visual_line_number_displays.colors_for_line(tonumber(digits));
            if colors then
                return colors;
            end
        end
    end

    return nil;
end

--! Parses the user-facing color string @p input.
--!
--! @returns String of format @c #rrggbb or nil.
function visual_line_number_displays.parse_color_string(input)
    if #input == 7 and string.sub(input, 1, 1) == "#" then
        local number = tonumber(string.sub(input, 2), 16);
        if number and number > 0 then
            return input;
        end
    elseif #input == 4 and string.sub(input, 1, 1) == "#" then
        local number = tonumber(string.sub(input, 2), 16);
        if number and number >= 0 then
            local r = string.sub(input, 2, 2);
            local g = string.sub(input, 3, 3);
            local b = string.sub(input, 4, 4);
            return "#" .. r .. r .. g .. g .. b .. b;
        end
    elseif string.sub(input, 1, 1) == '"' and string.sub(input, -1) == '"' then
        local line_string = string.sub(input, 2, -2);
        local line_number = tonumber(line_string);
        local colors;
        if line_number then
            colors = visual_line_number_displays.colors_for_line(line_number);
        end
        if not colors then
            colors = visual_line_number_displays.colors_for_line(line_string);
        end
        if colors then
            return colors.background;
        end
    end

    return nil;
end

visual_line_number_displays.color_brace_sequences = {
    a = "all";
    all = "all";
    t = "text";
    text = "text";
    b = "background";
    background = "background";
    s = "secondary_background";
    secondary_background = "secondary_background";
    b2 = "secondary_background";
    p = "secondary_background";
    pattern = "secondary_background";
    f = "feature";
    feature = "feature";
};

--! Parses the next color brace sequence after @p offset in @p text.
--!
--! Returns the position of the brace sequence,
--! and updates @p colors, which is a color_state table.
--!
--! Brace sequences other than colors are not parsed.
--!
--! @returns start_position, end_position; or nil.
function visual_line_number_displays.parse_color_brace_sequence(text, colors, offset)
    local start_pos = string.find(text, "{", offset, --[[ plain ]] true);
    if not start_pos then
        -- No opening brace.
        return nil;
    end

    local end_pos = string.find(text, "}", start_pos + 1, --[[ plain ]] true);
    if not end_pos then
        -- No closing brace.
        return nil;
    end

    local sequence = string.sub(text, start_pos + 1, end_pos - 1);
    local colon_pos = string.find(sequence, ":", 1, --[[ plain ]] true);
    if not colon_pos then
        -- Not a color sequence. Try next one.
        return visual_line_number_displays.parse_color_brace_sequence(text, colors, end_pos + 1);
    end

    local which = string.sub(sequence, 1, colon_pos - 1);
    which = visual_line_number_displays.color_brace_sequences[which];
    if not which then
        -- Invalid color sequence. Try next one.
        return visual_line_number_displays.parse_color_brace_sequence(text, colors, end_pos + 1);
    end

    local value = string.sub(sequence, colon_pos + 1);
    if (which == "all") and (value ~= "") then
        -- Apply full color scheme of a line.
        local new_colors;
        if string.sub(value, 1, 1) == '"' and string.sub(value, -1) == '"' then
            -- Fetch color scheme for string.
            new_colors = visual_line_number_displays.colors_for_line(string.sub(value, 2, -2));
        else
            -- Fetch color scheme for integer.
            value = tonumber(value);
            if not value then
                -- Invalid color sequence. Try next one.
                return visual_line_number_displays.parse_color_brace_sequence(text, colors, end_pos + 1);
            end
            new_colors = visual_line_number_displays.colors_for_line(value);
        end
        if not new_colors then
            -- Invalid color sequence. Try next one.
            return visual_line_number_displays.parse_color_brace_sequence(text, colors, end_pos + 1);
        end

        for k, v in pairs(new_colors) do
            colors[k] = v;
        end

        return start_pos, end_pos;
    elseif value == "" then
        -- Clear explicit color.
        colors[which .. "_explicit"] = false;
        return start_pos, end_pos;
    else
        value = visual_line_number_displays.parse_color_string(value);
        if not value then
            -- Invalid color. Try next one.
            return visual_line_number_displays.parse_color_brace_sequence(text, colors, end_pos + 1);
        end
    end

    colors[which] = value;
    colors[which .. "_explicit"] = true;

    return start_pos, end_pos;
end

--! Colorizes @p block using @p colors and brace sequences.
--!
--! Brace sequences in braceless blocks will modify @p color in-place,
--! and cause the block to be split.
--!
--! @returns A list of text_block_description tables if the block needs to be split.
function visual_line_number_displays.colorize_block(block, colors)
    if not block.braceless then
        -- Brace block.
        -- Collect all colors in this block in a color_state,
        -- and then apply them on the whole block.
        local block_colors = {};
        for k, v in pairs(colors) do
            block_colors[k] = v;
        end

        local pos = 1;
        local text = block.text;
        while pos <= #text do
            local start_pos, end_pos = visual_line_number_displays.parse_color_brace_sequence(text, block_colors, pos);

            if not start_pos then
                break;
            end

            text = string.sub(text, 1, start_pos - 1) .. string.sub(text, end_pos + 1);
            pos = start_pos;
        end
        block.text = text;

        -- Populate color state once after parsing all color sequences.
        block_colors = visual_line_number_displays.populate_color_state(block_colors);

        block.background_color = block_colors.background;
        block.secondary_background_color = block_colors.secondary_background;
        block.text_color = block_colors.text;
        block.feature_color = block_colors.feature;
    else
        -- Braceless block.
        -- Initialize block with current colors,
        -- and split the block at every color sequence.

        local split_blocks = {};

        local text = block.text;
        while text ~= "" do
            block.background_color = colors.background;
            block.secondary_background_color = colors.secondary_background;
            block.text_color = colors.text;
            block.feature_color = colors.feature;

            local start_pos, end_pos = visual_line_number_displays.parse_color_brace_sequence(text, colors, 1);

            if not start_pos then
                -- No more color sequences,
                -- include the part after the last sequence as a last block.
                local text_after = string.trim(text);
                if text_after ~= "" then
                    local block_after = {};
                    for k, v in pairs(block) do
                        block_after[k] = v;
                    end
                    block_after.text = text_after;
                    table.insert(split_blocks, block_after);
                end
                break;
            end

            local text_before = string.trim(string.sub(text, 1, start_pos - 1));
            if text_before ~= "" then
                local block_before = {};
                for k, v in pairs(block) do
                    block_before[k] = v;
                end
                block_before.text = text_before;
                table.insert(split_blocks, block_before);
            end

            text = string.sub(text, end_pos + 1);

            -- Populate color state after every color sequence.
            -- TODO This may be inefficient.
            local new_colors = visual_line_number_displays.populate_color_state(colors);
            for k, v in pairs(new_colors) do
                colors[k] = v;
            end
        end

        return split_blocks;
    end
end

--! Colorizes @p blocks using @p colors and brace sequences.
--!
--! Brace sequences in shapeless blocks will modify @p color in-place.
--! Brace sequences in shaped blocks are applied only locally.
--!
--! @param blocks A list of text_block_description tables.
--! @param colors A color_state table.
function visual_line_number_displays.colorize_blocks(blocks, colors)
    local i = 1;
    while i <= #blocks do
        local insert = visual_line_number_displays.colorize_block(blocks[i], colors);
        if insert then
            table.remove(blocks, i);
            for _, block in ipairs(insert) do
                table.insert(blocks, i, block);
                i = i + 1;
            end
        else
            i = i + 1;
        end
    end
end

--! Returns x modulo y.
--! The reference manual on math.fmod() is broken. It also doesn’t work here.
local function mod(x, y)
    return x - y * math.floor(x / y);
end

--! Returns @c color slightly desaturated.
--!
--! Colors are strings with the format @c #rrggbb.
function visual_line_number_displays.shade_background_color(color)
    local r, g, b = rgb(color);

    r, g, b = r * inv_255, g * inv_255, b * inv_255;

    local value = math.max(r, g, b);
    local min = math.min(r, g, b);
    local chroma = value - min;
    local lightness = 0.5 * (value + min);

    -- -1 .. 5
    local hue;
    if chroma == 0 then
        hue = 0;
    elseif value == r then
        hue = (g - b) / chroma;
    elseif value == g then
        hue = 2 + (b - r) / chroma;
    else
        hue = 4 + (r - g) / chroma;
    end

    local saturation;
    if lightness == 0 or lightness == 1 then
        saturation = 0;
    else
        saturation = (value - lightness) / math.min(lightness, 1 - lightness);
    end

    if lightness > 0.5 then
        lightness = lightness - 0.15;
    else
        lightness = lightness + 0.05;
    end

    if saturation > 0.5 then
        saturation = saturation - 0.4;
    else
        saturation = saturation * 1.3;
    end

    chroma = math.min(chroma, (1 - math.abs(2 * lightness - 1)) * saturation);
    min = lightness - 0.5 * chroma;
    local x = chroma * (1 - math.abs(mod(hue, 2) - 1));
    if hue < 0 then
        r, g, b = chroma, 0, x;
    elseif hue < 1 then
        r, g, b = chroma, x, 0;
    elseif hue < 2 then
        r, g, b = x, chroma, 0;
    elseif hue < 3 then
        r, g, b = 0, chroma, x;
    elseif hue < 4 then
        r, g, b = 0, x, chroma;
    else
        r, g, b = x, 0, chroma;
    end

    r, g, b = r + min, b + min, g + min;
    r, g, b = math.floor(r * 255), math.floor(b * 255), math.floor(g * 255);

    return string.format("#%02x%02x%02x", r, g, b);
end
