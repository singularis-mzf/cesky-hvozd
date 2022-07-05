-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

--! Escapes @p input for use in Minetest texture strings.
--!
--! This is bad, texture grouping with parentheses would make more sense.
function visual_line_number_displays.texture_escape(input)
    return string.gsub(input, "[:^\\]", "\\%1");
end

--! Renders a white background shape of size @p size.
--!
--! @param size Table with elements @p width and @p height.
--! @param shape Name of the background shape.
--!
--! @returns Standalone texture string.
function visual_line_number_displays.render_background_shape(size, shape)
    if shape == "square" then
        return string.format("vlnd_pixel.png^[resize:%ix%i", size.width, size.height);
    elseif shape == "diamond" then
        return string.format("vlnd_diamond.png^[resize:%ix%i", size.width, size.height);
    elseif shape == "round" then
        local circle = string.format("vlnd_circle.png^[resize:%ix%i", size.height, size.height);

        if size.width == size.height then
            return circle;
        end

        circle = visual_line_number_displays.texture_escape(circle);

        local rectangle = string.format("vlnd_pixel.png^[resize:%ix%i", size.width - math.floor(size.height * 0.5) * 2, size.height);
        rectangle = visual_line_number_displays.texture_escape(rectangle);

        return string.format("[combine:%ix%i:0,0=%s:%i,0=%s:%i,0=%s", size.width, size.height, circle, math.floor(size.height * 0.5), rectangle, size.width - size.height, circle);
    else
        error("Invalid background shape: " .. shape);
    end
end

--! Renders a transparency limited pattern for
--! the secondary background color of a background pattern.
--!
--! @param size Table with elements @p width and @p height.
--! @param pattern Name of the background pattern. Not all are supported.
--! @param align For diagonal patterns, may be @c stretch or @c center.
--!
--! @returns Standalone texture string.
function visual_line_number_displays.render_background_pattern(size, pattern, align)
    local size_string = string.format("%ix%i", size.width, size.height);

    if pattern == "left" then
        return "vlnd_left.png^[resize:" .. size_string;
    elseif pattern == "upper" then
        return "vlnd_upper.png^[resize:" .. size_string;
    elseif pattern == "plus_4" then
        return "vlnd_plus.png^[resize:" .. size_string;
    end

    if align == "stretch" then
        if pattern == "x_upper" then
            return "vlnd_x.png^[resize:" .. size_string;
        elseif pattern == "diag_1" then
            return "vlnd_corner_1.png^[resize:" .. size_string;
        elseif pattern == "diag_2" then
            return "vlnd_corner_2.png^[resize:" .. size_string;
        end
    else -- align == "center"
        if size.width <= size.height then
            -- For square aspects, using stretch is simpler.
            -- There should not be any shapes taller than wide.
            return visual_line_number_displays.render_background_pattern(size, pattern, "stretch");
        end

        -- Put pattern image in the center,
        -- and fill up with rectangles on the sides.

        local combine = "[combine:" .. size_string;

        -- Horizontal placement and width of components.
        local middle = math.floor((size.width - size.height) * 0.5);
        local right = middle + size.height;
        local right_width = size.width - right;

        local middle_size = string.format("%ix%i", size.height, size.height);
        local right_size = string.format("%ix%i", right_width, size.height);

        if pattern == "x_upper" then
            local x = visual_line_number_displays.texture_escape("vlnd_x.png^[resize:" ..middle_size);
            return combine .. string.format(":%i,0=", middle) .. x;
        elseif pattern == "diag_1" then
            local diag = visual_line_number_displays.texture_escape("vlnd_corner_1.png^[resize:" .. middle_size);
            local rect = visual_line_number_displays.texture_escape("vlnd_pixel.png^[resize:" .. right_size);
            return combine .. string.format(":%i,0=%s:%i,0=%s", middle, diag, right, rect);
        elseif pattern == "diag_2" then
            local diag = visual_line_number_displays.texture_escape("vlnd_corner_2.png^[resize:" .. middle_size);
            local rect = visual_line_number_displays.texture_escape("vlnd_pixel.png^[resize:" .. right_size);
            return combine .. string.format(":%i,0=%s:%i,0=%s", middle, diag, right, rect);
        end
    end

    error("Invalid background pattern: " .. pattern);
end

local outlined_shapes = {
    square_outlined = "square";
    round_outlined = "round";
    diamond_outlined = "diamond";
};

--! Renders a text block background including shape and pattern.
--!
--! @param size Table with elements @p width and @p height.
--! @param shape Name of the background shape. (Required)
--! @param pattern Name of the background pattern or nil.
--! @param color_1 Primary background color string.
--! @param color_2 Secondary background color string, used for patterns.
--! @param outline_width Width of outline.
--! @param outline_color Outline color string..
--!
--! @returns Standalone texture string.
function visual_line_number_displays.render_block_background(size, shape, pattern, color_1, color_2, outline_width, outline_color)
    if outlined_shapes[shape] then
        -- Handle outlined shapes by calling this function itself
        -- for outline shape and inner shape, and combining the results.
        local combine = string.format("[combine:%ix%i:0,0=", size.width, size.height);

        local outline_height = outline_width;
        if shape == "diamond_outlined" then
            -- Adjust to diamond aspect ratio.
            outline_width = math.ceil(outline_width * size.width / size.height);
        end

        local inner_size = {
            width = size.width - 2 * outline_width;
            height = size.height - 2 * outline_height;
        };
        local inner_placement = string.format(":%i,%i=", outline_width, outline_height);

        local outline = visual_line_number_displays.render_block_background(size, outlined_shapes[shape], nil, outline_color);
        local inner = visual_line_number_displays.render_block_background(inner_size, outlined_shapes[shape], pattern, color_1, color_2);

        outline = visual_line_number_displays.texture_escape(outline);
        inner = visual_line_number_displays.texture_escape(inner);

        return combine .. outline .. inner_placement .. inner;
    end

    if not pattern then
        local texture = visual_line_number_displays.render_background_shape(size, shape);

        if color_1 ~= "#ffffff" then
            texture = texture .. "^[multiply:" .. color_1;
        end

        return texture;
    else
        -- Normalize symmetric patterns.
        if pattern == "lower" then
            pattern = "upper";
            color_1, color_2 = color_2, color_1;
        elseif pattern == "right" then
            pattern = "left";
            color_1, color_2 = color_2, color_1;
        elseif pattern == "diag_3" then
            pattern = "diag_1";
            color_1, color_2 = color_2, color_1;
        elseif pattern == "diag_4" then
            pattern = "diag_2";
            color_1, color_2 = color_2, color_1;
        elseif pattern == "x_left" then
            pattern = "x_upper";
            color_1, color_2 = color_2, color_1;
        elseif pattern == "plus_1" then
            pattern = "plus_4";
            color_1, color_2 = color_2, color_1;
        end

        -- Render shape texture.
        local shape_texture = visual_line_number_displays.render_background_shape(size, shape);

        -- Render pattern texture.
        local align = "stretch";
        if shape == "round" then
            align = "center";
        end
        local pattern_texture = visual_line_number_displays.render_background_pattern(size, pattern, align);

        -- Clip pattern to shape.
        if shape ~= "square" then
            pattern_texture = pattern_texture .. "^[mask:" .. visual_line_number_displays.texture_escape(shape_texture);
        end

        -- Colorize.
        if color_1 ~= "#ffffff" then
            shape_texture = shape_texture .. "^[multiply:" .. color_1;
        end

        if color_2 ~= "#ffffff" then
            pattern_texture = pattern_texture .. "^[multiply:" .. color_2;
        end

        return shape_texture .. "^(" .. pattern_texture .. ")";
    end
end

--! Makes texture strings for background and foreground features @p features.
--!
--! @param size Table with elements @p width and @p height.
--! @param features Table with elements indicating which features to paint.
--! @param color Feature color string.
--!
--! @returns background_features, foreground_features as standalone texture strings.
function visual_line_number_displays.render_block_features(size, features, color)
    local background = {};
    local foreground = {};

    -- Collect features.
    if features.stroke_background then
        table.insert(background, "vlnd_stroke.png");
    end
    if features.stroke_foreground then
        table.insert(foreground, "vlnd_stroke.png");
    end
    if features.stroke_13_background then
        table.insert(background, "vlnd_stroke_13.png");
    end
    if features.stroke_13_foreground then
        table.insert(foreground, "vlnd_stroke_13.png");
    end
    if features.stroke_24_background then
        table.insert(background, "vlnd_stroke_24.png");
    end
    if features.stroke_24_foreground then
        table.insert(foreground, "vlnd_stroke_24.png");
    end

    background = table.concat(background, "^");
    foreground = table.concat(foreground, "^");

    -- Resize to requested size.
    local resize = string.format("^[resize:%ix%i", size.width, size.height);

    if background ~= "" then
        background = background .. resize;
    end
    if foreground ~= "" then
        foreground = foreground .. resize;
    end

    -- Colorize
    if (color ~= "#ffffff") and (background ~= "") then
        background = background .. "^[multiply:" .. color;
    end
    if (color ~= "#ffffff") and (foreground ~= "") then
        foreground = foreground .. "^[multiply:" .. color;
    end

    return background, foreground;
end

--! Makes a texture string depicting @p block.
--!
--! Result needs to be added to a @c combine modifier.
--! It is returned with leading colon, and sufficiently escaped.
--!
--! @param block Layouted block; element from a blocks_layout table.
--! @param sr_scale superresolution scaling factor for this display.
function visual_line_number_displays.render_text_block(block, sr_scale)
    -- Calculate block position and size in superresolution coordinates.
    -- Because superresolution scales are integers, no rounding is needed here.
    local block_position = {
        x = block.position.x * sr_scale;
        y = block.position.y * sr_scale;
    };
    local block_size = {
        width = block.size.width * sr_scale;
        height = block.size.height * sr_scale;
    };

    -- Calculate text position and size in block coordinates,
    -- and keep text centered if the block is enlarged by the layouter.
    local block_text_position = {
        x = (block.size.width - block.block.text_size.width * block.scale) * 0.5;
        y = (block.size.height - block.block.text_size.height * block.scale) * 0.5;
    };

    -- Calculate text position and size in layout coordinates.
    local layout_text_position = {
        x = block.position.x + block_text_position.x;
        y = block.position.y + block_text_position.y;
    };
    local layout_text_size = {
        width = block.block.text_size.width * block.scale;
        height = block.block.text_size.height * block.scale;
    };

    -- Calculate text position and size in superresolution coordinates.
    local text_position = {
        x = math.floor(layout_text_position.x * sr_scale);
        y = math.floor(layout_text_position.y * sr_scale);
    };
    local feature_placement = string.format(":%i,%i=", text_position.x, text_position.y);
    -- Metro font is consistently one pixel left of where it should be.
    local text_placement = string.format(":%i,%i=", text_position.x + math.floor(block.scale * sr_scale), text_position.y);
    local text_size = {
        width = math.ceil(layout_text_size.width * sr_scale);
        height = math.ceil(layout_text_size.height * sr_scale);
    };

    -- Render background
    local background_texture = "";
    if block.block.background_shape then
        local outline_width = math.ceil(1.4 * sr_scale * block.scale);
        local b = visual_line_number_displays.render_block_background(block_size, block.block.background_shape, block.block.background_pattern, block.block.background_color, block.block.secondary_background_color, outline_width, block.block.text_color);

        b = visual_line_number_displays.texture_escape(b);
        background_texture = string.format(":%i,%i=", block_position.x, block_position.y) .. b;
    end

    -- Render features
    local background_features, foreground_features = visual_line_number_displays.render_block_features(text_size, block.block.features, block.block.feature_color);

    if background_features ~= "" then
        background_features = feature_placement .. visual_line_number_displays.texture_escape(background_features);
    end
    if foreground_features ~= "" then
        foreground_features = feature_placement .. visual_line_number_displays.texture_escape(foreground_features);
    end

    -- Render text.
    local text_color = block.block.text_color;
    if text_color == "black" or text_color == "#000000" then
        text_color = nil;
    end
    local text_style = {
        halign = "center";
        color = text_color;
    };
    local text_texture = visual_line_number_displays.font:render(block.block.text, block.block.text_size.width, block.block.text_size.height, text_style);

    local total_text_scale = block.scale * sr_scale;
    if total_text_scale ~= 1 then
        text_texture = text_texture .. string.format("^[resize:%ix%i", text_size.width, text_size.height);
    end

    text_texture = visual_line_number_displays.texture_escape(text_texture);

    text_texture = text_placement .. text_texture;

    return background_texture .. background_features .. text_texture .. foreground_features;
end

--! Makes a texture string depicting @p layout.
--!
--! Result is a stand-alone texture string.
--! @p layout starts with top-left at origin.
--!
--! @param layout A display_layout table.
--! @param fixed_height Intended height of the display without superresolution.
--! @param sr_scale superresolution scaling factor for this display.
--! @param background_color Color for the whole display background.
--!
--! @returns texture string, or nil if the layout is empty.
function visual_line_number_displays.render_layout(layout, fixed_height, sr_scale, background_color)
    local bottom_right = layout:bottom_right();
    local size = {
        width = bottom_right.x * sr_scale;
        height = bottom_right.y * sr_scale;
    }

    local texture_string = string.format("[combine:%ix%i", size.width, size.height);

    local block_strings = {};
    for _, section in ipairs({ layout.number_section, layout.text_section, layout.details_section }) do
        for _, block in ipairs(section) do
            table.insert(block_strings, visual_line_number_displays.render_text_block(block, sr_scale));
        end
    end

    if not next(block_strings) then
        return nil;
    end

    local background = string.format("vlnd_pixel.png^[multiply:%s^[resize:%ix%i", background_color, size.width, fixed_height * sr_scale);

    return background .. "^" .. texture_string .. table.concat(block_strings);
end
