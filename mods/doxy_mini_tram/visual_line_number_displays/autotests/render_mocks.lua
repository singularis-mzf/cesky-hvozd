-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Replacement for Font:render().
local function render(_self, text, width, height, style)
    local texture_string =  string.format("[combine:%ix%i:0,0=%s.png", width, height, text);
    if style.color then
        texture_string = texture_string .. "^[colorize:" .. style.color;
    end
    return texture_string;
end

-- Replacement for Font:get_width().
local function get_width(_self, text)
    return 5 * #text;
end

-- Replacement for Font:get_height().
local function get_height(_self, line_count)
    return 8 * line_count;
end

visual_line_number_displays.font = {
    get_width = get_width;
    get_height = get_height;
    render = render;
}

-- More readable replacement for texture_escape().
-- Minetest documents texture grouping with parentheses,
-- but the client source code doesn’t even care about it.
local function texture_escape(input)
    return "{" .. input .. "}";
end

visual_line_number_displays.texture_escape = texture_escape;
