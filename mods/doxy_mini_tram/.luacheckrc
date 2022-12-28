-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

ignore = {
    -- Callback handlers receive many unused variables.
    -- Mark intentionally unused ones with a leading underscore.
    "21/_.*",

    -- max_string_line_length does not for strings without newline,
    -- so the whole line length stuff does not work because of autotests.
    "631",

    -- Empty if branches are used by the visual_line_number_displays parser.
    -- TODO Reimplement the parser and remove this exception.
    "542",
};

globals = {
    "advtrains_attachment_offset_patch";
    "minitram_konstal_105_liveries";
    "multi_component_liveries";
    "visual_line_number_displays";

    -- Necessary to mock Minetest string helpers.
    "string"
};

read_globals = {
    -- Other mods’ API
    advtrains = { fields = { "register_wagon" } };
    font_api = { fields = { "get_font" } };

    -- Minetest API
    "minetest";
    table = { fields = { "copy" } };
    vector = { fields = { "new" } };
    "dump";

    -- busted API
    "describe";
    "it";
    "assert";
    "setup";
    "teardown";
    "before_each";
};
