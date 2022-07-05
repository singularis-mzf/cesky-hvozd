-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Look for test subjects outside of autotests/
package.path = "visual_line_number_displays/?.lua;" .. package.path
package.path = "visual_line_number_displays/autotests/?.lua;" .. package.path

-- See https://rubenwardy.com/minetest_modding_book/en/quality/unit_testing.html
_G.visual_line_number_displays = {};

require("api");
require("basic_entities");
require("colorizer");
require("parser");

require("string_mocks");

local function line_1_colors()
    return {
        background = "#1e00ff";
        background_explicit = true;
        text = "#ffffff";
        text_explicit = false;
        secondary_background = "#550000";
        secondary_background_explicit = false;
        feature = "#ff2222";
        feature_explicit = true;
    };
end

local function line_1_colorize(block)
    block.background_color = "#1e00ff";
    block.text_color = "#ffffff";
    block.secondary_background_color = "#550000";
    block.feature_color = "#ff2222";
    return block;
end

local function t(text)
    return {
        text = text;
        features = {};
        braceless = true;
    };
end


describe("calculate_line_color()", function()
    local clc = visual_line_number_displays.calculate_line_color;
    local ptbs = visual_line_number_displays.parse_text_block_string;

    it("calculates line number colors like the subway wagon", function()
        assert.same(line_1_colors(), clc(ptbs("1")));
    end);

    it("fails for empty input", function()
        assert.same(nil, clc(ptbs("")));
    end);

    it("fails for missing line number (instead of returning a default)", function()
        assert.same(nil, clc(ptbs("not a line number [neither]")));
    end);

    it("calculates colors for more complex line number strings", function()
        assert.same(line_1_colors(), clc(ptbs("something else [1]")));
        assert.same(line_1_colors(), clc(ptbs("Line 1")));
        assert.same(line_1_colors(), clc(ptbs("[1] (also 2)")));
        assert.not_same(line_1_colors(), clc(ptbs("(also 2) [1]")));
        assert.same(line_1_colors(), clc(ptbs("1A")));
    end);

    it("avoids any brace sequences", function()
        assert.same(line_1_colors(), clc(ptbs("something {t:\"2\"} else [1]")));
        assert.same(line_1_colors(), clc(ptbs("{b:#123} Line 1")));
        assert.same(line_1_colors(), clc(ptbs("{{3}} [1] (also 2)")));
        assert.not_same(line_1_colors(), clc(ptbs("{f:#dd1}(also 2) [1]")));
        assert.same(line_1_colors(), clc(ptbs("1A {s:#ab1}")));
    end);
end);

describe("colorize_block()", function()
    local cb = visual_line_number_displays.colorize_block;

    it("colorizes a plain block", function()
        local block = t("A");
        local colors = line_1_colors();
        cb(block, line_1_colors());
        assert.same(line_1_colorize(t("A")), block);
        assert.same(line_1_colors(), colors);
    end);

    it("colorizes a shaped block", function()
        local block = t("A");
        block.background_shape = "round";

        local reference = t("A");
        reference.background_shape = "round";
        reference = line_1_colorize(reference);

        local colors = line_1_colors();
        cb(block, colors);

        assert.same(reference, block);
        assert.same(line_1_colors(), colors);
    end);

    it("colorizes a shaped block with color sequence 1", function()
        local block = t("A{background:#1e00ff}");
        block.background_shape = "round";
        block.braceless = nil;

        local reference = t("A");
        reference.background_shape = "round";
        reference.braceless = nil;
        reference = line_1_colorize(reference);

        local colors = line_1_colors();
        colors.background = "#1c00ff";

        local colors_leftover_reference = line_1_colors();
        colors_leftover_reference.background = "#1c00ff";

        cb(block, line_1_colors());

        assert.same(reference, block);
        assert.same(colors_leftover_reference, colors);
    end);

    it("colorizes a shaped block with color sequence 2", function()
        -- The color #000 seemed to cause bugs.
        local block = t("A{b:#000}");
        block.background_shape = "round";
        block.braceless = nil;

        local reference = t("A");
        reference.background_shape = "round";
        reference.braceless = nil;
        reference = line_1_colorize(reference);
        reference.background_color = "#000000";
        reference.secondary_background_color = "#ffaaff";

        local colors = line_1_colors();
        colors.background = "#000000";
        colors.secondary_background = "#ffaaff";

        local colors_leftover_reference = line_1_colors();
        colors_leftover_reference.background = "#000000";
        colors_leftover_reference.secondary_background = "#ffaaff";

        cb(block, line_1_colors());

        assert.same(reference, block);
        assert.same(colors_leftover_reference, colors);
    end);

    it("propagates color sequences from braceless blocks", function()
        local block = t("A{b:#1e00ff}");

        local reference = t("A");
        reference = line_1_colorize(reference);
        reference.background_color = "#1c00ff";

        local colors = line_1_colors();
        colors.background = "#1c00ff";

        local colors_leftover_reference = line_1_colors();

        local split_blocks = cb(block, colors);

        assert.same({reference}, split_blocks);
        assert.same(colors_leftover_reference, colors);
    end);

    it("splits braceless blocks 1", function()
        local block = t("A{b:#1e00ff}B");

        local reference = {};
        reference[1] = line_1_colorize(t("A"));
        reference[1].background_color = "#1c00ff";
        reference[2] = line_1_colorize(t("B"));

        local colors = line_1_colors();
        colors.background = "#1c00ff";

        local colors_leftover_reference = line_1_colors();

        local split_blocks = cb(block, colors);

        assert.same(reference, split_blocks);
        assert.same(colors_leftover_reference, colors);
    end);

    it("splits braceless blocks 2", function()
        local block = t("{b:#1e00ff}B");

        local reference = {};
        reference[1] = line_1_colorize(t("B"));

        local colors = line_1_colors();
        colors.background = "#1c00ff";

        local colors_leftover_reference = line_1_colors();

        local split_blocks = cb(block, colors);

        assert.same(reference, split_blocks);
        assert.same(colors_leftover_reference, colors);
    end);

    it("processes multiple color sequences 1", function()
        local block = t("{b:#1e00ff}B{b:#1a00ff}C");

        local reference = {};
        reference[1] = line_1_colorize(t("B"));
        reference[2] = line_1_colorize(t("C"));
        reference[2].background_color = "#1a00ff";

        local colors = line_1_colors();
        colors.background = "#1c00ff";

        local colors_leftover_reference = line_1_colors();
        colors_leftover_reference.background = "#1a00ff";

        local split_blocks = cb(block, colors);

        assert.same(reference, split_blocks);
        assert.same(colors_leftover_reference, colors);
    end);

    it("processes multiple color sequences 2", function()
        local block = t("{b:#1e00ff}{b:#1a00ff}C");

        local reference = {};
        reference[1] = line_1_colorize(t("C"));
        reference[1].background_color = "#1a00ff";

        local colors = line_1_colors();
        colors.background = "#1c00ff";

        local colors_leftover_reference = line_1_colors();
        colors_leftover_reference.background = "#1a00ff";

        local split_blocks = cb(block, colors);

        assert.same(reference, split_blocks);
        assert.same(colors_leftover_reference, colors);
    end);

    it("processes references to line numbers 1", function()
        local block = t('{t:"4"}');

        local reference = {};

        local colors = line_1_colors();

        local split_blocks = cb(block, colors);

        assert.same(reference, split_blocks);
        assert.same("#007f00", colors.text);
    end);

    it("processes references to line numbers 2", function()
        local block = t('{all:6}');

        local reference = {};

        local colors = line_1_colors();

        local split_blocks = cb(block, colors);

        assert.same(reference, split_blocks);
        assert.same("#ffff00", colors.background);
        assert.same("#000000", colors.text);
    end);

    it("clears explicit colors", function()
        local block = t('{t:}');

        local reference = {};

        local colors = line_1_colors();

        local split_blocks = cb(block, colors);

        assert.same(reference, split_blocks);
        assert.same(false, colors.text_explicit);
    end);
end);

describe("colorize_blocks", function()
    local cb = visual_line_number_displays.colorize_blocks;
    local ptbs = visual_line_number_displays.parse_text_block_string;

    it("colorizes a simple display", function()
        local blocks = ptbs("A");
        local colors = line_1_colors();

        cb(blocks, colors);

        local reference = { line_1_colorize(t("A")) };

        assert.same(reference, blocks);
        assert.same(line_1_colors(), colors);
    end);

    it("colorizes a simple colored display", function()
        local blocks = ptbs("A {b:#10f} B");
        local colors = line_1_colors();

        cb(blocks, colors);

        local reference = {
            line_1_colorize(t("A"));
            line_1_colorize(t("B"));
        };
        reference[2].background_color = "#1100ff";

        local color_reference = line_1_colors();
        color_reference.background = "#1100ff";

        assert.same(reference, blocks);
        assert.same(color_reference, colors);
    end);

    it("colorizes a colored display with shaped blocks", function()
        local blocks = ptbs("A {square|B{b:#10f}} C {b:#20f} {round|{b:#11f} D} {<>|E}");
        local colors = line_1_colors();

        cb(blocks, colors);

        local reference = {
            line_1_colorize(t("A"));
            line_1_colorize(t("B"));
            line_1_colorize(t("C"));
            line_1_colorize(t(" D"));
            line_1_colorize(t("E"));
        };
        reference[2].braceless = nil;
        reference[4].braceless = nil;
        reference[5].braceless = nil;

        reference[2].background_shape = "square";
        reference[4].background_shape = "round";
        reference[5].background_shape = "diamond";
        reference[2].background_color = "#1100ff";
        reference[4].background_color = "#1111ff";
        reference[4].feature_color = "#ff2222";
        reference[5].background_color = "#2200ff";

        local color_reference = line_1_colors();
        color_reference.background = "#2200ff";

        assert.same(reference, blocks);
        assert.same(color_reference, colors);
    end);
end);
