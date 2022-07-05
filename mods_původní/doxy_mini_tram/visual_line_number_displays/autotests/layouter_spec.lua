-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Look for test subjects outside of autotests/
package.path = "visual_line_number_displays/?.lua;" .. package.path

-- See https://rubenwardy.com/minetest_modding_book/en/quality/unit_testing.html
_G.visual_line_number_displays = {};

require("layouter");

require("render_mocks");
require("string_mocks");

describe("calculate_block_size()", function()
    local cbs = visual_line_number_displays.calculate_block_size;

    local function wh(w, h)
        return { width = w, height = h };
    end

    local function t(text, shape)
        return {
            text = text;
            background_shape = shape;
            features = {};
        };
    end

    it("calculates size of plain shapeless blocks", function()
        assert.same(wh(0, 0), cbs(t("")).required_size);
        assert.same(wh(0, 0), cbs(t("")).text_size);
        assert.same(wh(5, 8), cbs(t(" ")).required_size);
        assert.same(wh(5, 8), cbs(t("A")).required_size);
        assert.same(wh(35, 8), cbs(t("123 456")).required_size);
        assert.same(wh(0, 16), cbs(t("\n")).required_size);
        assert.same(wh(5, 16), cbs(t("A\n")).required_size);
        assert.same(wh(5, 16), cbs(t("\nB")).required_size);
        assert.same(wh(5, 16), cbs(t("A\nB")).required_size);
        assert.same(wh(10, 16), cbs(t("A\nBc")).required_size);
        assert.same(wh(10, 24), cbs(t("A\nBc\nd")).required_size);
        assert.same(wh(5, 32), cbs(t("A\nB\nC\nD")).required_size);
        assert.same(wh(0, 24), cbs(t("\n\n")).required_size);
        assert.same(wh(60, 8), cbs(t("Hello World!")).required_size);
        assert.same(wh(60, 16), cbs(t("Hello World!\n")).required_size);
        assert.same(wh(60, 16), cbs(t("Hello World!\n")).text_size);
    end);

    it("calculates size of square blocks", function()
        assert.same(wh(4, 4), cbs(t("", "square")).required_size);
        assert.same(wh(9, 12), cbs(t("A", "square")).required_size);
        assert.same(wh(39, 12), cbs(t("123 456", "square")).required_size);
        assert.same(wh(4, 20), cbs(t("\n", "square")).required_size);
        assert.same(wh(9, 20), cbs(t("A\nB", "square")).required_size);
    end);

    it("calculates size of round and diamond blocks", function()
        -- These tests are prone to fail after minor adjustments.
        -- Adjust reference values as needed and appropriate.
        assert.same(wh(3, 3), cbs(t("", "round")).required_size);
        assert.same(wh(3, 3), cbs(t("", "diamond")).required_size);
        assert.same(wh(12, 12), cbs(t("A", "round")).required_size);
        assert.same(wh(13, 13), cbs(t("A", "diamond")).required_size);
        assert.same(wh(39, 12), cbs(t("123 456", "round")).required_size);
        assert.same(wh(59, 16), cbs(t("123 456", "diamond")).required_size);
    end);

    it("Operates on a list", function()
        local blocks = {
            t("", "square");
            t("A", "square");
        };

        visual_line_number_displays.calculate_block_sizes(blocks);

        local reference = {
            t("", "square");
            t("A", "square");
        };
        reference[1].required_size = wh(4, 4);
        reference[1].text_size = wh(0, 0);
        reference[2].required_size = wh(9, 12);
        reference[2].text_size = wh(5, 8);

        assert.same(reference, blocks);
    end);
end);

describe("blocks_layout", function()
    local bl = visual_line_number_displays.blocks_layout;

    describe("set_max_height()", function()
        it("scales all too high blocks down", function()
            local blocks = {
                {
                    text = "A";
                    required_size = { width = 1, height = 1 };
                };
                {
                    text = "B";
                    required_size = { width = 1, height = 20 };
                };
                {
                    text = "C";
                    required_size = { width = 1, height = 21 };
                };
            };
            local row = bl:new(blocks);

            row:set_max_height(10);

            local reference = {
                {
                    block = blocks[1];
                    position = { x = 0, y = 0 };
                    scale = 1;
                    size = { width = 1, height = 1 };
                };
                {
                    block = blocks[2];
                    position = { x = 0, y = 0 };
                    scale = 0.5;
                    size = { width = 1, height = 10 };
                };
                {
                    block = blocks[3];
                    position = { x = 0, y = 0 };
                    scale = 0.375;
                    size = { width = 1, height = 8 };
                };
            };
            assert.same(reference, row);
        end);
    end);

    describe("shrink()", function()
        it("shortens the longest block", function()
            local blocks = {
                {
                    text = "A";
                    required_size = { width = 1, height = 10 };
                };
                {
                    text = "B";
                    required_size = { width = 10, height = 1 };
                };
                {
                    text = "C";
                    required_size = { width = 1, height = 1 };
                };
            };
            local row = bl:new(blocks);

            row:shrink("width");

            local reference = {
                {
                    block = blocks[1];
                    position = { x = 0, y = 0 };
                    scale = 1;
                    size = { width = 1, height = 10 };
                };
                {
                    block = blocks[2];
                    position = { x = 0, y = 0 };
                    scale = 0.75;
                    size = { width = 8, height = 1 };
                };
                {
                    block = blocks[3];
                    position = { x = 0, y = 0 };
                    scale = 1;
                    size = { width = 1, height = 1 };
                };
            };
            assert.same(reference, row);
        end);

        it("flattens the highest block", function()
            local blocks = {
                {
                    text = "A";
                    required_size = { width = 10, height = 1 };
                };
                {
                    text = "B";
                    required_size = { width = 1, height = 10 };
                };
                {
                    text = "C";
                    required_size = { width = 1, height = 1 };
                };
            };
            local row = bl:new(blocks);

            row:shrink("height");

            local reference = {
                {
                    block = blocks[1];
                    position = { x = 0, y = 0 };
                    scale = 1;
                    size = { width = 10, height = 1 };
                };
                {
                    block = blocks[2];
                    position = { x = 0, y = 0 };
                    scale = 0.75;
                    size = { width = 1, height = 8 };
                };
                {
                    block = blocks[3];
                    position = { x = 0, y = 0 };
                    scale = 1;
                    size = { width = 1, height = 1 };
                };
            };
            assert.same(reference, row);
        end);

        it("shortens the block with highest scale, even if others are longer", function()
            local blocks = {
                {
                    text = "A";
                    required_size = { width = 100, height = 1 };
                };
                {
                    text = "B";
                    required_size = { width = 10, height = 1 };
                };
                {
                    text = "C";
                    required_size = { width = 10, height = 1 };
                };
                {
                    text = "B";
                    required_size = { width = 100, height = 1 };
                };
            };
            local row = bl:new(blocks);

            row:scale_block(1, 0.4)
            row:scale_block(2, 0.5)
            row:scale_block(4, 0.5)
            row:shrink("width");
            local reference = {
                {
                    block = blocks[1];
                    position = { x = 0, y = 0 };
                    scale = 0.375;
                    size = { width = 38, height = 1 };
                };
                {
                    block = blocks[2];
                    position = { x = 0, y = 0 };
                    scale = 0.5;
                    size = { width = 5, height = 1 };
                };
                {
                    block = blocks[3];
                    position = { x = 0, y = 0 };
                    scale = 0.75;
                    size = { width = 8, height = 1 };
                };
                {
                    block = blocks[4];
                    position = { x = 0, y = 0 };
                    scale = 0.5;
                    size = { width = 50, height = 1 };
                };
            };
            assert.same(reference, row);
        end);
    end);

    describe("can_be_shortened()", function()
        it("stops shortening", function()
            local blocks = {
                {
                    text = "A";
                    required_size = { width = 1, height = 1 };
                };
                {
                    text = "B";
                    required_size = { width = 1, height = 1 };
                };
                {
                    text = "C";
                    required_size = { width = 2, height = 1 };
                };
            };
            local row = bl:new(blocks);

            assert.same(true, row:can_be_shortened());
            row:shrink("width");
            assert.same(true, row:can_be_shortened());
            row:shrink("width");
            assert.same(true, row:can_be_shortened());
            row:shrink("width");
            assert.same(true, row:can_be_shortened());
            row:shrink("width");
            assert.same(false, row:can_be_shortened());

            local reference = {
                {
                    block = blocks[1];
                    position = { x = 0, y = 0 };
                    scale = 0.75;
                    size = { width = 1, height = 1 };
                };
                {
                    block = blocks[2];
                    position = { x = 0, y = 0 };
                    scale = 0.75;
                    size = { width = 1, height = 1 };
                };
                {
                    block = blocks[3];
                    position = { x = 0, y = 0 };
                    scale = 0.5;
                    size = { width = 1, height = 1 };
                };
            };
            assert.same(reference, row);
        end);
    end);

    describe("stretch_height()", function()
        it("stretches up to square shape", function()
            local blocks = {
                {
                    text = "A";
                    required_size = { width = 15, height = 5 };
                };
                {
                    text = "B";
                    background_shape = "square";
                    required_size = { width = 15, height = 5 };
                };
                {
                    text = "C";
                    background_shape = "square";
                    required_size = { width = 5, height = 8 };
                };
                {
                    text = "D";
                    background_shape = "square";
                    required_size = { width = 8, height = 9 };
                };
                {
                    text = "E";
                    background_shape = "square";
                    required_size = { width = 8, height = 5 };
                };
            };
            local row = bl:new(blocks);

            row:stretch_height(10);

            local reference = {
                {
                    block = blocks[1];
                    position = { x = 0, y = 0 };
                    scale = 1;
                    size = { width = 15, height = 5 };
                };
                {
                    block = blocks[2];
                    position = { x = 0, y = 0 };
                    scale = 1;
                    size = { width = 15, height = 10 };
                };
                {
                    block = blocks[3];
                    position = { x = 0, y = 0 };
                    scale = 1;
                    size = { width = 5, height = 8 };
                };
                {
                    block = blocks[4];
                    position = { x = 0, y = 0 };
                    scale = 1;
                    size = { width = 8, height = 9 };
                };
                {
                    block = blocks[5];
                    position = { x = 0, y = 0 };
                    scale = 1;
                    size = { width = 8, height = 8 };
                };
            };
            assert.same(reference, row);
        end);
    end);

    describe("align()", function()
        it("Centers blocks at some point", function()
            local blocks = {
                {
                    text = "A";
                    required_size = { width = 15, height = 5 };
                };
                {
                    text = "B";
                    background_shape = "square";
                    required_size = { width = 15, height = 5 };
                };
                {
                    text = "C";
                    background_shape = "round";
                    required_size = { width = 5, height = 8 };
                };
                {
                    text = "D";
                    background_shape = "diamond";
                    required_size = { width = 8, height = 9 };
                };
                {
                    text = "E";
                    required_size = { width = 80, height = 2 };
                };
            };
            local row = bl:new(blocks);
            row:scale_block(1, 0.5);
            row:scale_block(3, 2);

            row:align({ x = 60, y = 9 });

            local reference = {
                {
                    block = blocks[1];
                    position = { x = -5, y = 7 };
                    scale = 0.5;
                    size = { width = 8, height = 3 };
                };
                {
                    block = blocks[2];
                    position = { x = 5, y = 6 };
                    scale = 1;
                    size = { width = 15, height = 5 };
                };
                {
                    block = blocks[3];
                    position = { x = 22, y = 1 };
                    scale = 2;
                    size = { width = 10, height = 16 };
                };
                {
                    block = blocks[4];
                    position = { x = 34, y = 4 };
                    scale = 1;
                    size = { width = 8, height = 9 };
                };
                {
                    block = blocks[5];
                    position = { x = 44, y = 8 };
                    scale = 1;
                    size = { width = 80, height = 2 };
                };
            };
            assert.same(reference, row);
        end);
    end);
end);

describe("display_layout", function()
    local dl = visual_line_number_displays.display_layout;
    it("calculates a very simple layout", function()
        local number_blocks = {{
            text = "A";
            required_size = { width = 15, height = 5 };
        }};

        local display = dl:new(number_blocks);

        display:calculate_layout(40, 20);

        local reference = {
            number_section = {{
                block = number_blocks[1];
                position = { x = 2, y = 7 };
                scale = 1;
                size = { width = 15, height = 5 };
            }};
            text_section = {};
            details_section = {};
            x_padding = 2;
        };

        assert.same(reference, display);
        assert.same({ x = 19, y = 12 }, display:bottom_right());
    end);

    it("calculates a less simple layout", function()
        local number_blocks = {{
            text = "A";
            background_shape = "square";
            required_size = { width = 15, height = 5 };
        }};
        local text_blocks = {{
            text = "B";
            required_size = { width = 35, height = 15 };
        }};
        local details_blocks = {{
            text = "C";
            required_size = { width = 25, height = 7 };
        }};

        local display = dl:new(number_blocks, text_blocks, details_blocks);

        display:calculate_layout(41, 20);

        local reference = {
            number_section = {{
                block = number_blocks[1];
                position = { x = 0, y = 4 };
                scale = 0.75;
                size = { width = 12, height = 12 };
            }};
            text_section = {{
                block = text_blocks[1];
                position = { x = 14, y = 2 };
                scale = 0.75;
                size = { width = 27, height = 12 };
            }};
            details_section = {{
                block = details_blocks[1];
                position = { x = 21, y = 14 };
                scale = 0.5;
                size = { width = 13, height = 4 };
            }};
        };

        assert.same(reference, display);
        assert.same({ x = 41, y = 18 }, display:bottom_right());
    end);

    it("calculates a complex layout", function()
        local number_blocks = {{
            text = "RE11";
            background_shape = "diamond";
            required_size = { width = 35, height = 16 };
        }};
        local text_blocks = {
            {
                text = "Köln HBF";
                required_size = { width = 40, height = 8 };
            };
            {
                text = "U";
                background_shape = "square";
                required_size = { width = 9, height = 12 };
            };
            {
                text = "S";
                background_shape = "round";
                required_size = { width = 10, height = 10 };
            };
        };
        local details_blocks = {
            {
                text = "über:";
                required_size = { width = 25, height = 8 };
            };
            {
                text = "S";
                background_shape = "round";
                required_size = { width = 10, height = 10 };
            };
            {
                text = "Chorweiler";
                required_size = { width = 50, height = 8 };
            };
        };

        local display = dl:new(number_blocks, text_blocks, details_blocks);

        display:calculate_layout(120, 40);

        local reference = {
            number_section = {
                {
                    block = number_blocks[1];
                    position = { x = 0, y = 2 };
                    scale = 1;
                    size = { width = 35, height = 35 };
                };
            };
            text_section = {
                {
                    block = text_blocks[1];
                    position = { x = 37, y = 13 };
                    scale = 1;
                    size = { width = 40, height = 8 };
                };
                {
                    block = text_blocks[2];
                    position = { x = 79, y = 11 };
                    scale = 1;
                    size = { width = 9, height = 12 };
                };
                {
                    block = text_blocks[3];
                    position = { x = 90, y = 12 };
                    scale = 1;
                    size = { width = 10, height = 10 };
                };
            };
            details_section = {
                {
                    block = details_blocks[1];
                    position = { x = 45, y = 23 };
                    scale = 0.5;
                    size = { width = 13, height = 4 };
                };
                {
                    block = details_blocks[2];
                    position = { x = 60, y = 23 };
                    scale = 0.5;
                    size = { width = 5, height = 5 };
                };
                {
                    block = details_blocks[3];
                    position = { x = 67, y = 23 };
                    scale = 0.5;
                    size = { width = 25, height = 4 };
                };
            };
        };

        assert.same(reference, display);
        assert.same({ x = 100, y = 37 }, display:bottom_right());
    end);
end);
