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
require("core");
require("layouter");
require("parser");
require("renderer");

require("render_mocks");
require("string_mocks");

local function line_1_colorize(blocks)
    for _, block in ipairs(blocks) do
        block.text_color = "#ffffff";
        block.background_color = "#1e00ff";
        block.secondary_background_color = "#550000";
        block.feature_color = "#ff2222";
    end

    return blocks;
end

describe("parse_display_string()", function()
    local pds = visual_line_number_displays.parse_display_string;

    local function wh(w, h)
        return { width = w, height = h };
    end

    it("parses very simple line numbers", function()
        local number, text, details = pds("1");

        local number_reference = {
            {
                text = "1";
                features = {};
                braceless = true;
                required_size = wh(5, 8);
                text_size = wh(5, 8);
            };
        };

        assert.same(line_1_colorize(number_reference), number);
        assert.same({}, text);
        assert.same({}, details);
    end);

    it("parses usual line numbers 1", function()
        local number, text, details = pds("{square|1}\nZürich\nüber Basel");

        local number_reference = {
            {
                text = "1";
                background_shape = "square";
                features = {};
                required_size = wh(9, 12);
                text_size = wh(5, 8);
            };
        };

        local text_reference = {
            {
                text = "Zürich";
                features = {};
                braceless = true;
                required_size = wh(35, 8);
                text_size = wh(35, 8);
            };
        };

        local details_reference = {
            {
                text = "über Basel";
                features = {};
                braceless = true;
                required_size = wh(55, 8);
                text_size = wh(55, 8);
            };
        };

        assert.same(line_1_colorize(number_reference), number);
        assert.same(line_1_colorize(text_reference), text);
        assert.same(line_1_colorize(details_reference), details);
    end);

    it("parses usual line numbers 2", function()
        local number, text, details = pds("{square|1}; {Zürich}; {über Basel}");

        local number_reference = {
            {
                text = "1";
                background_shape = "square";
                features = {};
                required_size = wh(9, 12);
                text_size = wh(5, 8);
            };
        };

        local text_reference = {
            {
                text = "Zürich";
                features = {};
                required_size = wh(35, 8);
                text_size = wh(35, 8);
            };
        };

        local details_reference = {
            {
                text = "über Basel";
                features = {};
                required_size = wh(55, 8);
                text_size = wh(55, 8);
            };
        };

        assert.same(line_1_colorize(number_reference), number);
        assert.same(line_1_colorize(text_reference), text);
        assert.same(line_1_colorize(details_reference), details);
    end);

    it("parses complex line numbers", function()
        local number, text, details = pds("{diamond|left_right|RE1}; Köln HBF {square|U} {round|S}\nüber: {round|S} Chorweiler  {lpar}tief{rpar}");

        local number_reference = {
            {
                text = "RE1";
                background_shape = "diamond";
                background_pattern = "x_left";
                features = {};
                required_size = wh(21, 21);
                text_size = wh(15, 8);
            };
        };

        local text_reference = {
            {
                text = "Köln HBF";
                features = {};
                braceless = true;
                required_size = wh(45, 8);
                text_size = wh(45, 8);
            };
            {
                text = "U";
                background_shape = "square";
                features = {};
                required_size = wh(9, 12);
                text_size = wh(5, 8);
            };
            {
                text = "S";
                background_shape = "round";
                features = {};
                required_size = wh(12, 12);
                text_size = wh(5, 8);
            };
        };

        local details_reference = {
            {
                text = "über:";
                features = {};
                braceless = true;
                required_size = wh(30, 8);
                text_size = wh(30, 8);
            };
            {
                text = "S";
                background_shape = "round";
                features = {};
                required_size = wh(12, 12);
                text_size = wh(5, 8);
            };
            {
                text = "Chorweiler\n(tief)";
                features = {};
                braceless = true;
                required_size = wh(50, 16);
                text_size = wh(50, 16);
            };
        };

        assert.same(line_1_colorize(number_reference), number);
        assert.same(line_1_colorize(text_reference), text);
        assert.same(line_1_colorize(details_reference), details);
    end);
end);

describe("render_displays()", function()
    local rd = visual_line_number_displays.render_displays;
    it("renders empty display", function()
        local display_description = {
            base_resolution = { width = 128, height = 128 };
            base_texture = "base.png";
            displays = {{
                position = { x = 0, y = 18 };
                height = 24;
                max_width = 128;
                center_width = 0;
                level = "details";
            }};
        };

        assert.same("base.png", rd(display_description, ""));
    end);

    it("renders a basic display", function()
        local display_description = {
            base_resolution = { width = 128, height = 128 };
            base_texture = "base.png";
            displays = {{
                position = { x = 0, y = 18 };
                height = 24;
                max_width = 128;
                center_width = 0;
                level = "details";
            }};
        };

        assert.same("base.png^[resize:128x128^[combine:128x128:0,18={vlnd_pixel.png^[multiply:#998314^[resize:92x24^[combine:92x16:1,8={[combine:10x8:0,0=16.png^[colorize:#ffffff}:13,8={[combine:80x8:0,0=Some Destination.png^[colorize:#ffffff}}", rd(display_description, "16; Some Destination"));
    end);

    it("renders a long display", function()
        local display_description = {
            base_resolution = { width = 128, height = 128 };
            base_texture = "base.png";
            displays = {{
                position = { x = 0, y = 18 };
                height = 24;
                max_width = 128;
                center_width = 0;
                level = "details";
            }};
        };

        assert.same("base.png^[resize:256x256^[combine:256x256:0,36={vlnd_pixel.png^[multiply:#998314^[resize:220x48^[combine:220x32:2,16={[combine:10x8:0,0=16.png^[colorize:#ffffff^[resize:20x16}:25,18={[combine:130x8:0,0=Some Loooooong Destination.png^[colorize:#ffffff^[resize:195x12}}", rd(display_description, "16; Some Loooooong Destination"));
    end);

    it("renders a display with pattern background", function()
        local display_description = {
            base_resolution = { width = 128, height = 128 };
            base_texture = "base.png";
            displays = {{
                position = { x = 0, y = 4 };
                height = 24;
                max_width = 128;
                center_width = 0;
                level = "number";
            }};
        };

        assert.same("base.png^[resize:128x128^[combine:128x128:0,4={vlnd_pixel.png^[multiply:#998314^[resize:24x24^[combine:24x22:2,2={[combine:20x20:0,0={vlnd_circle.png^[resize:20x20}:2,2={vlnd_circle.png^[resize:16x16^[multiply:#998314^(vlnd_x.png^[resize:16x16^[mask:{vlnd_circle.png^[resize:16x16}^[multiply:#ffaaff)}}:8,8={[combine:10x8:0,0=16.png^[colorize:#ffffff}}", rd(display_description, "{_()_|upper_lower|16}"));
    end);
end);
