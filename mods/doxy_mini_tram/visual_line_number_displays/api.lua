-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

--! @class color_state
--! A color_state table describes the four colors used for a
--! line number display, and which of these were set explicitly.
--!
--! It contains these fields:
--! \li @c text Foreground color for text.
--! \li @c background Primary background color.
--! \li @c secondary_background Used for background shape patterns.
--! \li @c feature Feature color, used e. g. for strikethrough.
--!
--! These fields are strings of the format @c #rrggbb.
--!
--! It can contain these boolean fields: @c text_explicit, @c background_explicit,
--! @c secondary_background_explicit, and @c feature_explicit.
--! If these are true, that color will not be calculated automatically.

--! Fixed primary colors for certain line numbers.
--!
--! You may add elements to this table.
--! The key must be an integer or a string.
--! The value must be a string of the format @c #rrggbb.
--! The value will be used as initial background color for matching lines.
--! Secondary background color, text color, and feature color are calculated
--! automatically to provide good contrast.
--!
--! For every block in the line number string,
--! the block content as string will be looked up in this table.
--! If the string doesn’t match, an integer will be extracted and looked up.
--! If the integer doesn’t match, the next block is tried.
--!
--! If the value is a color_state table, colors are defined individually.
--! At least the element @c background must be provided.
--! If the other colors are omitted, they are calculated automatically.
visual_line_number_displays.line_colors = {};

--! Returns a color_state table for @p line, or nil.
--!
--! This function looks up line_colors,
--! and passing strings or integers gives different results.
--!
--! @param line A string or an integer, identifying the train line.
--! @param current_state A color_state table containing previous color definitions.
function visual_line_number_displays.colors_for_line(line, current_state)
    local preset = visual_line_number_displays.line_colors[line] or visual_line_number_displays.fixed_line_colors[line] or visual_line_number_displays.subway_algorithm(line);
    if not preset then
        return nil;
    end

    local result;

    if type(preset) == "table" then
        result = {
            text = preset.text;
            text_explicit = preset.text;
            background = preset.background;
            background_explicit = preset.background;
            secondary_background = preset.secondary_background;
            secondary_background_explicit = preset.secondary_background;
            feature = preset.feature;
            feature_explicit = preset.feature;
        };
    else
        result = {
            background = preset;
            background_explicit = true;
        };
    end

    local c = current_state or {};
    if c.text_explicit then
        result.text = c.text
        result.text_explicit = true;
    end
    if c.background_explicit then
        result.background = c.background;
        result.background_explicit = true;
    end
    if c.secondary_background_explicit then
        result.secondary_background = c.secondary_background
        result.secondary_background_explicit = true;
    end
    if c.feature_explicit then
        result.feature = c.feature;
        result.feature_explicit = true;
    end

    return visual_line_number_displays.populate_color_state(result);
end

--! @class display_description
--! A display_description table describes the geometry of some displays,
--! which are available in a texture slot.
--!
--! It needs to have these elements:
--! \li @c base_resolution Table with elements @c width and @c height,
--! describing the size of the texture slot without superresolution.
--! \li @c base_texture Texture string that will be used as base for
--! the generated textures. (Usually a transparent image.)
--! \li @c displays A list of descriptions for each display.
--!
--! Each element in the @c displays list needs to be a table with these elements:
--! \li @c position Table with elements @c x and @c y,
--! describing the top-left corner of the display in the texture,
--! at base resolution, and before applying transformation.
--! \li @c height The fixed height at base resolution.
--! \li @c max_width The available width at base resolution.
--! \li @c center_width If less than @c max_width is needed,
--! the display is centered around this width position.
--! (Examples: 0 = left alignment; 0.5 * max_width = center alignment.)
--! \li @c level String specifying up to which section it is rendered.
--! Values: @c number, @c text, @c details.

--! Macros are brace sequences which are parsed at the very beginning
--! of processing a line number display string.
--! Macros expand to another string, which is placed at the position of the macro.
--!
--! Example: “{some_macro}”
--!
--! To define a macro, add an element to this table.
--! The key must be a string, which is the macro name without braces.
--! The value must be a string, which is the expanded form of the macro.
--!
--! Macros can take arguments separated by bar characters.
--! Example: “{macro|argument}”
--!
--! The value must be a list of strings and numbers.
--! These strings are then concatenated, with the numbers replaced by arguments.
--!
--! Example:
--! @code
--! macros["l"] = { "{line", 1, "}" }
--! @endcode
visual_line_number_displays.macros = {};

--! Adds line number displays to advtrains wagon @c wagon_definition.
--!
--! @param wagon_definition The table which will be passed to advtrains.register_wagon().
--! @param display_description A display_description table.
--! @param slot Which texture slot shall receive the displays.
function visual_line_number_displays.setup_advtrains_wagon(wagon_definition, display_description, slot)
    local old_on_step = wagon_definition.custom_on_step;

    wagon_definition.custom_on_step = function(...)
        visual_line_number_displays.advtrains_wagon_on_step(display_description, slot, ...);

        if old_on_step then
            old_on_step(...)
        end
    end
end
