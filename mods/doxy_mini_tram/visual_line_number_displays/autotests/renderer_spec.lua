-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Look for test subjects outside of autotests/
package.path = "visual_line_number_displays/?.lua;" .. package.path
package.path = "visual_line_number_displays/autotests/?.lua;" .. package.path

-- See https://rubenwardy.com/minetest_modding_book/en/quality/unit_testing.html
_G.visual_line_number_displays = {};

require("layouter");
require("renderer");

require("render_mocks");

local function s(w, h)
    return { width = w, height = h };
end

describe("render_background_shape()", function()
    local rbs = visual_line_number_displays.render_background_shape;

    it("renders stretched shapes", function()
        assert.same("vlnd_pixel.png^[resize:1x1", rbs(s(1, 1), "square"));
        assert.same("vlnd_pixel.png^[resize:15x12", rbs(s(15, 12), "square"));
        assert.same("vlnd_diamond.png^[resize:22x16", rbs(s(22, 16), "diamond"));
    end);

    it("renders round shapes", function()
        assert.same("vlnd_circle.png^[resize:15x15", rbs(s(15, 15), "round"));
        assert.same("[combine:8x4:0,0={vlnd_circle.png^[resize:4x4}:2,0={vlnd_pixel.png^[resize:4x4}:4,0={vlnd_circle.png^[resize:4x4}", rbs(s(8, 4), "round"));
        assert.same("[combine:17x11:0,0={vlnd_circle.png^[resize:11x11}:5,0={vlnd_pixel.png^[resize:7x11}:6,0={vlnd_circle.png^[resize:11x11}", rbs(s(17, 11), "round"));
    end);
end);

describe("render_background_pattern()", function()
    local rbp = visual_line_number_displays.render_background_pattern;

    it("renders straight patterns", function()
        assert.same("vlnd_upper.png^[resize:4x4", rbp(s(4, 4), "upper", "stretch"));
        assert.same("vlnd_left.png^[resize:15x12", rbp(s(15, 12), "left", "stretch"));
        assert.same("vlnd_plus.png^[resize:22x16", rbp(s(22, 16), "plus_4", "stretch"));
    end);

    it("renders diagonal patterns stretched", function()
        assert.same("vlnd_x.png^[resize:4x4", rbp(s(4, 4), "x_upper", "stretch"));
        assert.same("vlnd_corner_1.png^[resize:15x12", rbp(s(15, 12), "diag_1", "stretch"));
        assert.same("vlnd_corner_2.png^[resize:22x16", rbp(s(22, 16), "diag_2", "stretch"));
    end);

    it("renders diagonal patterns centered", function()
        assert.same("[combine:6x4:1,0={vlnd_x.png^[resize:4x4}", rbp(s(6, 4), "x_upper", "center"));
        assert.same("[combine:15x12:1,0={vlnd_corner_1.png^[resize:12x12}:13,0={vlnd_pixel.png^[resize:2x12}", rbp(s(15, 12), "diag_1", "center"));
        assert.same("[combine:22x16:3,0={vlnd_corner_2.png^[resize:16x16}:19,0={vlnd_pixel.png^[resize:3x16}", rbp(s(22, 16), "diag_2", "center"));
    end);

    it("renders diagonal patterns fit to square", function()
        assert.same("vlnd_x.png^[resize:4x4", rbp(s(4, 4), "x_upper", "center"));
        assert.same("vlnd_corner_1.png^[resize:15x15", rbp(s(15, 15), "diag_1", "center"));
        assert.same("vlnd_corner_2.png^[resize:22x22", rbp(s(22, 22), "diag_2", "center"));
    end);
end);

describe("render_block_background()", function()
    local rbb = visual_line_number_displays.render_block_background;

    it("renders backgrounds without pattern", function()
        assert.same("vlnd_pixel.png^[resize:1x1", rbb(s(1, 1), "square", nil, "#ffffff", "#abcdef"));
        assert.same("vlnd_pixel.png^[resize:15x12^[multiply:#112233", rbb(s(15, 12), "square", nil, "#112233", "#abcdef"));
        assert.same("vlnd_diamond.png^[resize:22x16^[multiply:#112233", rbb(s(22, 16), "diamond", nil, "#112233", "#ffffff"));
    end);

    it("renders square backgrounds with pattern", function()
        assert.same("vlnd_pixel.png^[resize:15x12^[multiply:#123456^(vlnd_left.png^[resize:15x12^[multiply:#abcdef)", rbb(s(15, 12), "square", "left", "#123456", "#abcdef"));
    end);

    it("renders square backgrounds with inverted pattern", function()
        assert.same("vlnd_pixel.png^[resize:15x12^[multiply:#abcdef^(vlnd_upper.png^[resize:15x12^[multiply:#123456)", rbb(s(15, 12), "square", "lower", "#123456", "#abcdef"));
    end);

    it("renders non-square backgrounds with pattern", function()
        assert.same("vlnd_diamond.png^[resize:15x12^[multiply:#123456^(vlnd_x.png^[resize:15x12^[mask:{vlnd_diamond.png^[resize:15x12}^[multiply:#abcdef)", rbb(s(15, 12), "diamond", "x_upper", "#123456", "#abcdef"));
    end);

    it("renders non-square backgrounds with inverted pattern", function()
        assert.same("vlnd_diamond.png^[resize:15x12^[multiply:#abcdef^(vlnd_x.png^[resize:15x12^[mask:{vlnd_diamond.png^[resize:15x12}^[multiply:#123456)", rbb(s(15, 12), "diamond", "x_left", "#123456", "#abcdef"));
    end);

    it("renders outlined background", function()
        assert.same("[combine:10x10:0,0={vlnd_pixel.png^[resize:10x10^[multiply:#123456}:2,2={vlnd_pixel.png^[resize:6x6}", rbb(s(10, 10), "square_outlined", nil, "#ffffff", "#abcdef", 2, "#123456"));
    end);
end);

describe("render_text_block()", function()
    local rtb = visual_line_number_displays.render_text_block;

    it("renders plain text blocks", function()
        local block = {
            block = {
                text = "A";
                required_size = { width = 5, height = 8 };
                text_size = { width = 5, height = 8 };
                features = {};
            };
            scale = 1;
            position = { x = 0, y = 1 };
            size = { width = 5, height = 8 };
        };

        assert.same(":1,1={[combine:5x8:0,0=A.png}", rtb(block, 1));
    end);

    it("renders superresolution text blocks", function()
        local block = {
            block = {
                text = "A";
                required_size = { width = 5, height = 8 };
                text_size = { width = 5, height = 8 };
                features = {};
            };
            scale = 1;
            position = { x = 0, y = 1 };
            size = { width = 5, height = 8 };
        };

        assert.same(":2,2={[combine:5x8:0,0=A.png^[resize:10x16}", rtb(block, 2));
    end);

    it("renders scaled text blocks", function()
        local block = {
            block = {
                text = "A";
                required_size = { width = 5, height = 8 };
                text_size = { width = 5, height = 8 };
                features = {};
            };
            scale = 0.5;
            position = { x = 1, y = 2 };
            size = { width = 3, height = 4 };
        };

        assert.same(":3,4={[combine:5x8:0,0=A.png}", rtb(block, 2));
    end);

    it("renders deplaced text blocks", function()
        local block = {
            block = {
                text = "A";
                required_size = { width = 9, height = 16 };
                text_size = { width = 5, height = 8 };
                features = {};
            };
            scale = 1;
            position = { x = 0, y = 1 };
            size = { width = 9, height = 16 };
        };

        assert.same(":3,5={[combine:5x8:0,0=A.png}", rtb(block, 1));
    end);

    it("renders deplaced scaled text blocks in superresolution", function()
        local block = {
            block = {
                text = "A";
                required_size = { width = 9, height = 16 };
                text_size = { width = 5, height = 8 };
                features = {};
            };
            scale = 0.375;
            position = { x = 15, y = 4 };
            size = { width = 9, height = 16 };
        };

        assert.same(":37,21={[combine:5x8:0,0=A.png^[resize:4x6}", rtb(block, 2));
    end);

    it("renders colored text blocks", function()
        local block = {
            block = {
                text = "A";
                required_size = { width = 5, height = 8 };
                text_size = { width = 5, height = 8 };
                text_color = "#00ff00";
                features = {};
            };
            scale = 1;
            position = { x = 0, y = 1 };
            size = { width = 5, height = 8 };
        };

        assert.same(":1,1={[combine:5x8:0,0=A.png^[colorize:#00ff00}", rtb(block, 1));
    end);

    it("renders text block with features", function()
        local block = {
            block = {
                text = "A";
                features = {
                    stroke_background = true;
                    stroke_13_foreground = true;
                };
                required_size = { width = 5, height = 8 };
                text_size = { width = 5, height = 8 };
                text_color = "#000000";
                feature_color = "#ff0000";
            };
            scale = 1;
            position = { x = 0, y = 1 };
            size = { width = 5, height = 8 };
        };

        assert.same(":0,1={vlnd_stroke.png^[resize:5x8^[multiply:#ff0000}:1,1={[combine:5x8:0,0=A.png}:0,1={vlnd_stroke_13.png^[resize:5x8^[multiply:#ff0000}", rtb(block, 1));
    end);
end);

describe("render_layout()", function()
    local rl = visual_line_number_displays.render_layout;

    it("renders deplaced scaled text blocks in superresolution", function()
        local number_section = {{
            block = {
                text = "A";
                required_size = { width = 9, height = 16 };
                text_size = { width = 5, height = 8 };
                features = {};
            };
            scale = 0.375;
            position = { x = 15, y = 4 };
            size = { width = 9, height = 16 };
        }};

        local details_section = {{
            block = {
                text = "A";
                required_size = { width = 5, height = 8 };
                text_size = { width = 5, height = 8 };
                text_color = "#00ff00";
                features = {};
            };
            scale = 1;
            position = { x = 0, y = 1 };
            size = { width = 5, height = 8 };
        }};

        local layout = visual_line_number_displays.display_layout:new({});
        layout.number_section = number_section;
        layout.details_section = details_section;

        assert.same("vlnd_pixel.png^[multiply:#000000^[resize:48x40^[combine:48x40:37,21={[combine:5x8:0,0=A.png^[resize:4x6}:2,2={[combine:5x8:0,0=A.png^[colorize:#00ff00^[resize:10x16}", rl(layout, 20, 2, "#000000"));
    end);
end);
