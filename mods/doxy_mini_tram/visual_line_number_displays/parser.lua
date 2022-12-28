-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

--! Returns the byte width of the UTF-8 character starting at @p position.
--! Returns 1 for invalid UTF-8 bytes.
local function utf_8_width(input, position)
    local msb = string.byte(input, position);

    if msb < 0xc0 then
        -- 0x00 .. 0x7f are single byte sequences.
        -- 0x80 .. 0xbf are non-MSB bytes.
        return 1;
    elseif msb < 0xe0 then
        -- 0xc0 .. 0xc1 are start of invalid two byte sequences.
        -- 0xc2 .. 0xdf are start of two byte sequences.
        return 2;
    elseif msb < 0xf0 then
        -- Start of three byte sequences.
        return 3;
    elseif msb < 0xf8 then
        -- 0xf0 .. 0xf4 are start of four byte sequences.
        -- 0xf5 .. 0xf7 are start of invalid four byte sequences.
        return 4;
    else
        -- Start of 5+ byte sequences or entirely invalid bytes.
        return 1;
    end
end

--! Returns the unicode codepoint of the UTF-8 character @p input as integer.
local function string_to_codepoint(input)
    local bytes = utf_8_width(input, 1)

    if bytes == 1 then
        return string.byte(input, 1)
    elseif bytes == 2 then
        return (string.byte(input, 1) - 0xc0) * 0x40
            + string.byte(input, 2) - 0x80;
	elseif bytes == 3 then
		return (string.byte(input, 1) - 0xe0) * 0x1000
			+ (string.byte(input, 2) - 0x80) * 0x40
			+ string.byte(input, 3) - 0x80
	elseif bytes == 4 then
		return (string.byte(input, 1) - 0xf0) * 0x40000
			+ (string.byte(input, 2) - 0x80) * 0x1000
			+ (string.byte(input, 3) - 0x80) * 0x40
			+ string.byte(input, 4) - 0x80
	end
end

--! @class text_block_description
--! A text_block_description table describes style and text of one text block.
--!
--! The table must contain the element @c text, which is a string.
--!
--! The table can contain the elements @c features, @c background_shape,
--! and @c background_pattern, and some elements to describe colors.
--! The table may contain @c required_size and @c text_size.
--!
--! @c features is a table with these properties, which may be set true:
--! \li @c stroke_background A red horizontal line centered under the text.
--! \li @c stroke_foreground Centered over the text (strikethrough).
--! \li @c stroke_13_background Line from bottom left to top right.
--! \li @c stroke_13_foreground
--! \li @c stroke_24_background Line from top left to bottom right.
--! \li @c stroke_24_foreground
--!
--! @c background_shape can be one of these strings:
--! @c square, @c round, @c diamond.
--!
--! @c background_pattern can be set to one of these strings,
--! if @c background_shape is set:
--! \li @c left Only left half of the background is colored in the background color.
--! \li @c right
--! \li @c upper
--! \li @c lower
--! \li @c plus_1 Only bottom-left and top-right quarters are colored.
--! \li @c plus_4 Only top-left and bottom-right quarters are colored.
--! \li @c diag_1 Only top-right half is colored, with 45° border through the center.
--! \li @c diag_2 Only bottom-right half is colored.
--! \li @c diag_3 Only bottom-left half is colored.
--! \li @c diag_4 Only top-left half is colored.
--! \li @c x_left Only left and right quarters are colored, with two 45º borders.
--! \li @c x_upper Only upper and lower quarters are colored.
--!
--! With @c background_pattern, the uncolored parts are colored in a secondary
--! background color, usually white.
--!
--! The digits 1, 2, 3, 4 describe quarters as in BSicon names.
--!
--! The table may contain these elements, which are color strings each:
--! \li @c text_color Default: black or white, depending on background colors.
--! \li @c background_color if @c background_shape is set.
--! \li @c secondary_background_color if @c background_pattern is set. Default: white.
--! \li @c feature_color Default: red.
--!
--! @c required_size may be a table with @c width and @c height,
--! which shall be set so the block can be rendered in a box of this size.
--!
--! @c text_size may be a table with @c width and @c height,
--! which shall be set to the size where text glyphs will be rendered.

--! Parses a text block string, returns a list of text block descriptions.
--!
--! @returns List of text_block_description tables.
function visual_line_number_displays.parse_text_block_string(input)
    local result = {};

    local function add_braceless_text(text)
        if (#result > 0) and result[#result].braceless then
            result[#result].text = result[#result].text .. text;
        else
            table.insert(result, { text = text, features = {}, braceless = true });
        end
    end

    local pos = 1;
    while pos <= #input do
        local left, right, parts = visual_line_number_displays.next_brace_pair(input, pos);
        if not left then
            break;
        end

        if left > pos then
            add_braceless_text(string.sub(input, pos, left - 1));
        end

        local block = visual_line_number_displays.parse_text_block(parts);
        if block then
            table.insert(result, block);
        else
            add_braceless_text(string.sub(input, left, right));
        end

        pos = right + 1;
    end

    if pos <= #input then
        add_braceless_text(string.sub(input, pos));
    end

    return result;
end

local background_shapes = {
    square = "square";
    ["[]"] = "square";
    round = "round";
    ["()"] = "round";
    diamond = "diamond";
    ["<>"] = "diamond";
    square_outlined = "square_outlined";
    ["_[]_"] = "square_outlined";
    round_outlined = "round_outlined";
    ["_()_"] = "round_outlined";
    diamond_outlined = "diamond_outlined";
    ["_<>_"] = "diamond_outlined";
};

local background_patterns = {
    left = "left";
    right = "right";
    upper = "upper";
    lower = "lower";
    ["1"] = "diag_1";
    ["2"] = "diag_2";
    ["3"] = "diag_3";
    ["4"] = "diag_4";
    upper_right = "diag_1";
    lower_right = "diag_2";
    lower_left = "diag_3";
    upper_left = "diag_4";
    ["13"] = "plus_1";
    ["24"] = "plus_4";
    upper_right_lower_left = "plus_1";
    upper_left_lower_right = "plus_4";
    upper_lower = "x_upper";
    left_right = "x_left";
};

local features = {
    stroke = "stroke_foreground";
    stroke_bg = "stroke_background";
    stroke_fg = "stroke_foreground";
    stroke_background = "stroke_background";
    stroke_foreground = "stroke_foreground";
    ["-"] = "stroke_foreground";
    stroke_13 = "stroke_13_foreground";
    stroke_13_bg = "stroke_13_background";
    stroke_13_fg = "stroke_13_foreground";
    stroke_13_background = "stroke_13_background";
    stroke_13_foreground = "stroke_13_foreground";
    ["/"] = "stroke_13_foreground";
    stroke_24 = "stroke_24_foreground";
    stroke_24_bg = "stroke_24_background";
    stroke_24_fg = "stroke_24_foreground";
    stroke_24_background = "stroke_24_background";
    stroke_24_foreground = "stroke_24_foreground";
};

--! Parses the inner parts of a brace pair of a text block string.
--!
--! @returns one text_block_description table or nil.
function visual_line_number_displays.parse_text_block(parts)
    if #parts == 1 then
        if visual_line_number_displays.entity_value(parts[1]) then
            -- Do not consume entities.
            return nil;
        else
            local colon = string.find(parts[1], ":", 1, --[[ plain ]] true);
            if colon and visual_line_number_displays.color_brace_sequences[string.sub(parts[1], 1, colon - 1)] then
                -- Do not consume color brace sequences.
                return nil;
            end
        end
    end

    local block = {
        text = parts[#parts];
        features = {};
    };

    for i = 1, (#parts - 1) do
        local part = parts[i];

        if string.find(part, ":", 1, --[[ plain ]] true) then
            -- Convert color specifications to color brace sequences.
            block.text = "{" .. part .. "}" .. block.text;
        elseif background_shapes[part] and (not block.background_shape) then
            block.background_shape = background_shapes[part];
        elseif background_patterns[part] and (not block.background_pattern) then
            block.background_pattern = background_patterns[part];
        elseif features[part] then
            block.features[features[part]] = true;
        else
            -- Pass through invalid options.
            block.text = part .. "|" .. block.text;
        end
    end

    return block
end

--! Parses backslash escape sequences in the display string @p input.
--!
--! Any UTF-8 character may be escaped with a backslash.
--!
--! @returns a string with escape sequences replaced by entities.
function visual_line_number_displays.parse_escapes(input)
    local result = "";
    local pos = 1;

    while pos <= #input do
        local next_pos = string.find(input, "\\", pos, --[[ plain ]] true);
        if not next_pos then
            result = result .. string.sub(input, pos);
            break;
        end

        result = result .. string.sub(input, pos, next_pos - 1);
        pos = next_pos;

        -- Parse escape sequence at position pos.

        if pos == #input then
            -- Escaping nothing. Add the backslash as-is.
            result = result .. "\\";
            break;
        end

        local bytes = utf_8_width(input, pos + 1);
        if pos + bytes > #input then
            -- Early string end. Add the backslash as-is.
            result = result .. "\\";
            break;
        end

        local codepoint = string_to_codepoint(string.sub(input, pos + 1, pos + bytes));
        result = result .. string.format("{#x%X}", codepoint);

        -- Continue after end of escaped character.
        pos = pos + 1 + bytes;
    end

    return result;
end

--! Returns the start and end position of the next balanced brace pair,
--! and the content split at bar characters (outside nested brace pairs).
function visual_line_number_displays.next_brace_pair(input, offset)
    local left, right = string.find(input, "%b{}", offset, --[[ plain ]] false);
    if not left then
        return nil;
    end

    local content = string.sub(input, left + 1, right - 1);
    local parts = {};

    local last_bar = 0;
    local pos = 1;
    while pos <= #content do
        local bar = string.find(content, "|", pos, --[[ plain ]] true);
        if not bar then
            break;
        end

        local inner_left, inner_right = string.find(content, "%b{}", pos, --[[ plain ]] false);
        if (not inner_left) or inner_left > bar then
            -- Bar appeared before any brace pair.
            -- Use text until there as part.
            table.insert(parts, string.sub(content, last_bar + 1, bar - 1));
            last_bar = bar;
            pos = bar + 1;
        else
            -- Bar appeared within or after brace pair.
            -- Skip to end of brace pair.
            pos = inner_right + 1;
        end
    end
    table.insert(parts, string.sub(content, last_bar + 1));

    return left, right, parts;
end

--! Parses space sequences in @p blocks, modifying blocks in-place.
--! @p blocks is a list of text_block_description tables.
function visual_line_number_displays.parse_line_breaks_in_blocks(blocks)
    -- UTF-8 parsing is not necessary here,
    -- because everything relevant is only 7 bit.

    for _, block in ipairs(blocks) do
        local pos = 1;
        local text = block.text

        while pos < #text do
            pos = string.find(text, "  ", pos, --[[ plain ]] true);
            if not pos then
                break;
            end

            text = string.sub(text, 1, pos - 1) .. "\n" .. string.sub(text, pos + 2);
        end

        block.text = text;
    end
end

--! Returns the string value of the entity @p entity (without braces) or nil.
function visual_line_number_displays.entity_value(entity)
    if string.sub(entity, 1, 1) == "#" then
        -- Parse as HTML-like codepoint entity.
        local codepoint;
        if string.sub(entity, 2, 2) == "x" then
            codepoint = tonumber(string.sub(entity, 3), 16);
        else
            codepoint = tonumber(string.sub(entity, 2), 10);
        end
        if not codepoint then
            return nil;
        end

        -- Split in UTF-8 bytes.
        return visual_line_number_displays.codepoint_to_string(codepoint);
    else
        return visual_line_number_displays.basic_entities[entity];
    end
end

--! Parses entity brace sequences in @p blocks, modifying blocks in-place.
--! @p blocks is a list of text_block_description tables.
function visual_line_number_displays.parse_entities_in_blocks(blocks)
    for _, block in ipairs(blocks) do
        local pos = 1;
        local text = block.text

        while pos < #text do
            local left, right, parts = visual_line_number_displays.next_brace_pair(text, pos);
            if not left then
                break;
            end

            if #parts == 1 then
                local value = visual_line_number_displays.entity_value(parts[1]);

                if value then
                    text = string.sub(text, 1, left - 1) .. value .. string.sub(text, right + 1);
                    pos = left + #value;
                else
                    pos = right + 1;
                end
            else
                pos = right + 1;
            end
        end

        block.text = text;
    end
end

--! Parses the parts list of a brace pair as macro, and returns the result.
function visual_line_number_displays.expand_macro(parts)
    local macro_name = parts[1];
    local macro = visual_line_number_displays.macros[macro_name];
    if not macro then
        return nil;
    end

    if type(macro) == "string" then
        return macro;
    end

    local result = "";
    for _, macro_part in ipairs(macro) do
        if type(macro_part) == "string" then
            result = result .. macro_part;
        else
            result = result .. parts[macro_part + 1] or "";
        end
    end
    return result;
end

--! Parses macro brace sequences in @p input, and returns the result.
--!
--! To handle nested macros, it also returns whether macros were expanded.
--!
--! @returns string, may_contain_nested_macros
function visual_line_number_displays.parse_macros(input)
    local result = "";
    local expanded_anything = false;

    local pos = 1;
    while pos <= #input do
        local left, right, parts = visual_line_number_displays.next_brace_pair(input, pos);
        if not left then
            return result .. string.sub(input, pos), expanded_anything;
        end
        result = result .. string.sub(input, pos, left - 1);

        local expanded = visual_line_number_displays.expand_macro(parts);
        if not expanded then
            result = result .. string.sub(input, left, right);
        else
            result = result .. expanded;
            expanded_anything = true;
        end

        pos = right + 1;

        if #result > 250 then
            -- Macro expansion too long,
            -- add a warning that should be always outside any brace sequences.
            -- Return false to stop further processing of macros.
            return result .. string.sub(input, pos) .. "} maximum length exceeded", false;
        end
    end

    return result, expanded_anything;
end
