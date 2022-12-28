-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Look for test subjects outside of autotests/
package.path = "multi_component_liveries/?.lua;" .. package.path

-- See https://rubenwardy.com/minetest_modding_book/en/quality/unit_testing.html
_G.multi_component_liveries = {};

--! Replacement for minetest.get_translator().
local function get_translator()
    -- Make a non-translator.
    return(function(text)
        return text;
    end);
end

--! Replacement for minetest.chat_send_player().
local function chat_send_player(_player, _message)
end

--! Replacement for Minetest’s table.copy().
local function copy(t)
    local c = {};

    for k, v in pairs(t) do
        if type(v) == table then
            c[k] = copy(v);
        else
            c[k] = v;
        end
    end

    return c;
end

_G.minetest = {
    get_translator = get_translator;
    chat_send_player = chat_send_player;
};

_G.table.copy = copy;

-- The code does some access to the minetest global table.
-- But it should only do so if a player name is provided.
require("core");
require("api");
require("slots");

-- simple_liv, simple_def, etc. are functions which create brand new tables
-- on demand. This saves the need for table.copy().

--! Component 2 on layer 1.
local function simple_liv()
    return {
        layers = {
            {
                component = 2;
                color = "#123456";
            };
        };
        active_layer = 1;
    };
end

--! Component 2 in red.
local function red_liv()
    local red = simple_liv();
    red.layers[1].color = "#ff0000";
    return red;
end

--! Selects layer @p layer in the stack @p stack and returns resulting stack.
local function select_layer(stack, layer)
    stack.active_layer = layer;
    return stack;
end

--! Component 1 in magenta appended to simple_liv().
local function simple_liv_appended()
    local appended = simple_liv();
    appended.layers[2] = {
        component = 1;
        color = "#ff00ff";
    };
    return appended;
end

--! Component 1 in magenta appended to red_liv().
local function red_liv_appended()
    local appended = red_liv();
    appended.layers[2] = {
        component = 1;
        color = "#ff00ff";
    };
    return appended;
end

--! Component 1 in magenta prepended to simple_liv().
local function simple_liv_prepended()
    local prepended = simple_liv();
    table.insert(prepended.layers, 1, {
        component = 1;
        color = "#ff00ff";
    });
    return prepended;
end

--! Component 2, then component 1.
local function reverse_liv()
    local reverse = simple_liv();
    reverse.layers[2] = {
        component = 1;
        color = "#654321";
    };
    return reverse;
end

--! Component 5 (invalid) appended to simple_liv().
local function invalid_layer_liv()
    local reverse = simple_liv();
    reverse.layers[2] = {
        component = 5;
        color = "#aaaaaa";
    };
    return reverse;
end

--! Component 2 used twice.
local function duplicate_layer_liv()
    local duplicate = reverse_liv();
    duplicate.layers[2].component = 2;
    return duplicate;
end

--! No components present, no layer selected.
local function empty_liv()
    return {
        layers = {};
    };
end

--! Definition with 2 components, sufficient for simple_liv().
local function simple_def()
    return {
        components = {
            {
                description = "abc";
                texture_file = "comp1.png";
            };
            {
                description = "abc";
                texture_file = "comp2.png";
            };
        };
        presets = {
            {
                description = "simple_liv()";
                livery_stack = simple_liv();
            };
            {
                description = "red_liv()";
                livery_stack = red_liv();
            };
        };
        base_texture_file = "base.png";
    };
end

--! Creates a tool itemstack that has metadata with @c color and @c alpha.
local function painting_tool(color, alpha)
    return {
        get_meta = function(_self)
            return {
                get_string = function(_self1, key)
                    if key == "paint_color" then
                        return color;
                    elseif key == "alpha" then
                        return alpha;
                    end
                end
            };
        end
    };
end

--! Returns a table that behaves like a player luaentity.
local function player(playername)
    return {
        is_player = function(_self)
            return true;
        end;
        get_player_name = function(_self)
            return playername;
        end;
    };
end

describe("paint_on_livery()", function()
    local function paint(definition, stack, color, alpha, playername)
        -- The tool which is passed to paint_on_livery().
        -- This needs to return metadata with a get_string() method.
        local tool = painting_tool(color, alpha);

        local result = multi_component_liveries.paint_on_livery(playername and player(playername) or nil, definition, stack, tool);

        return {
            result = result;
            stack = stack;
        };
    end

    before_each(function()
        multi_component_liveries.private_slots = {};
        multi_component_liveries.shared_slots = {};
    end);

    it("preserves livery when requesting help", function()
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#000000", 0));
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#00000000"));
        assert.same({ result = false; stack = red_liv(); },
                    paint(simple_def(), red_liv(), "#00000000"));
    end);

    it("initializes livery when requesting help", function()
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), {}, "#00000000"));
    end);

    it("selects existing layers by component", function()
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), select_layer(simple_liv(), 2), "#000200", 0));
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), select_layer(simple_liv(), 3), "#00020000"));
        assert.same({ result = false; stack = reverse_liv(); },
                    paint(simple_def(), select_layer(reverse_liv(), 2), "#00020000"));
        assert.same({ result = false; stack = select_layer(reverse_liv(), 2); },
                    paint(simple_def(), reverse_liv(), "#00010000"));
    end);

    it("selects already selected layer by component", function()
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#00020000"));
        assert.same({ result = false; stack = reverse_liv(); },
                    paint(simple_def(), reverse_liv(), "#00020000"));
        assert.same({ result = false; stack = select_layer(reverse_liv(), 2); },
                    paint(simple_def(), select_layer(reverse_liv(), 2), "#00010000"));
    end);

    it("appends new component", function()
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), simple_liv(), "#00010000"));
    end);

    it("inserts new component", function()
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), simple_liv(), "#00010200"));
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), simple_liv(), "#0001fe00"));
        assert.same({ result = true; stack = simple_liv_prepended(); },
                    paint(simple_def(), simple_liv(), "#00010100"));
    end);

    it("initializes when inserting new component", function()
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), {}, "#00010000"));
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), {}, "#00010200"));
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), {}, "#0001fe00"));
        assert.same({ result = true; stack = simple_liv_prepended(); },
                    paint(simple_def(), {}, "#00010100"));
    end);

    it("deletes layer by component", function()
        assert.same({ result = true; stack = empty_liv(); },
                    paint(simple_def(), simple_liv(), "#0002ff00"));
        assert.same({ result = true; stack = select_layer(simple_liv(), nil); },
                    paint(simple_def(), reverse_liv(), "#0001ff00"));
    end);

    it("initializes when deleting layer", function()
        assert.same({ result = true; stack = empty_liv(); },
                    paint(simple_def(), {}, "#0002ff00"));
    end);

    it("moves layer by component, and selects it", function()
        assert.same({ result = true; stack = simple_liv_prepended(); },
                    paint(simple_def(), simple_liv_appended(), "#00010100"));
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), simple_liv_prepended(), "#00010200"));
    end);

    it("does not move layers past the end", function()
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), simple_liv_prepended(), "#0001fe00"));
    end);

    it("does not modify anything if moving selected layer to current position", function()
        assert.same({ result = false; stack = reverse_liv(); },
                    paint(simple_def(), reverse_liv(), "#00020100"));
    end);

    it("does not move the only layer", function()
        -- Painting update result does not matter in this corner case.
        assert.same(simple_liv(),
                    paint(simple_def(), simple_liv(), "#0002fe00").stack);
    end);

    it("does not insert invalid layers", function()
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#00050000"));
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#00050100"));
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#0005fe00"));
    end);

    it("does not modify anything if removing missing layer", function()
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#0001ff00"));
    end);

    it("removes invalid layers if present", function()
        assert.same({ result = true; stack = select_layer(simple_liv(), nil); },
                    paint(simple_def(), invalid_layer_liv(), "#0005ff00"));
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#0005ff00"));
    end);

    it("paints selected layer", function()
        assert.same({ result = true; stack = red_liv(); },
                    paint(simple_def(), simple_liv(), "#ff0000ff"));
        assert.same({ result = true; stack = red_liv_appended(); },
                    paint(simple_def(), simple_liv_appended(), "#ff0000ff"));
    end);

    it("initializes when painting", function()
        assert.same({ result = true; stack = red_liv(); },
                    paint(simple_def(), {}, "#ff0000ff"));
    end);

    it("Does not paint if no layer selected", function()
        assert.same({ result = false; stack = select_layer(simple_liv(), nil); },
                    paint(simple_def(), select_layer(simple_liv(), nil), "#ff0000ff"));
    end);

    it("loads presets by number", function()
        assert.same({ result = true; stack = simple_liv(); },
                    paint(simple_def(), {}, "#0000c900"));
        assert.same({ result = true; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#0000c900"));
        assert.same({ result = true; stack = red_liv(); },
                    paint(simple_def(), empty_liv(), "#0000ca00"));
        assert.same({ result = true; stack = red_liv(); },
                    paint(simple_def(), red_liv(), "#0000ca00"));
    end);

    it("does not load invalid presets", function()
        assert.same({ result = false; stack = {}; },
                    paint(simple_def(), {}, "#0000cb00"));
        assert.same({ result = false; stack = empty_liv(); },
                    paint(simple_def(), empty_liv(), "#0000cb00"));
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#0000cb00"));
    end);

    it("loads private slots by playername and number", function()
        multi_component_liveries.private_slots = {
            some_player = { [5] = red_liv() };
        };
        assert.same({ result = true; stack = red_liv(); },
                    paint(simple_def(), {}, "#00000500", nil, "some_player"));
        assert.same({ result = true; stack = red_liv(); },
                    paint(simple_def(), simple_liv(), "#00000500", nil, "some_player"));
    end);

    it("saves private slots by playername and number", function()
        assert.same({ result = false; stack = red_liv(); },
                    paint(simple_def(), red_liv(), "#00006b00", nil, "some_player"));
        assert.same({
                some_player = { [7] = red_liv() };
            }, multi_component_liveries.private_slots);
    end);

    it("loads shared slots by number", function()
        multi_component_liveries.shared_slots[25] = red_liv();
        assert.same({ result = true; stack = red_liv(); },
                    paint(simple_def(), {}, "#00001900"));
    end);

    it("saves shared slots by number", function()
        assert.same({ result = false; stack = red_liv(); },
                    paint(simple_def(), red_liv(), "#00007d00"));
        assert.same({
                [25] = red_liv();
            }, multi_component_liveries.shared_slots);
    end);

    it("does not load other players’ private slots", function()
        multi_component_liveries.private_slots = {
            other_player = { [5] = red_liv() };
        };
        assert.same({ result = false; stack = {}; },
                    paint(simple_def(), {}, "#00000500", nil, "some_player"));
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#00000500", nil, "some_player"));
    end);
end);

describe("calculate_texture_string()", function()
    local cts = multi_component_liveries.calculate_texture_string;

    it("Creates valid texture strings from valid livery stacks", function()
        assert.same("base.png^(comp2.png^[multiply:#123456)",
                    cts(simple_def(), simple_liv()));
        assert.same("base.png^(comp2.png^[multiply:#ff0000)",
                    cts(simple_def(), red_liv()));
        assert.same("base.png^(comp2.png^[multiply:#123456)^(comp1.png^[multiply:#654321)",
                    cts(simple_def(), reverse_liv()));
        assert.same("base.png",
                    cts(simple_def(), empty_liv()));
    end);

    it("Does not care about duplicate layers", function()
        assert.same("base.png^(comp2.png^[multiply:#123456)^(comp2.png^[multiply:#654321)",
                    cts(simple_def(), duplicate_layer_liv()));
    end);

    it("Skips invalid layers", function()
        assert.same("base.png^(comp2.png^[multiply:#123456)",
                    cts(simple_def(), invalid_layer_liv()));
    end);

    it("Uses base image for uninitialized livery", function()
        assert.same("base.png",
                    cts(simple_def(), {}));
    end);

    it("Uses base image for uninitialized livery", function()
        assert.same("base.png",
                    cts(simple_def(), {}));
    end);
end);

--! A pseudo wagon entity with simple_def() livery definition.
local function wagon()
    return {
        livery_definition = simple_def();
        set_textures = function() end;
    };
end

describe("Support for advtrains wagons which historically have strings as livery property.", function()
    describe("calculate_texture_string()", function()
        local cts = multi_component_liveries.calculate_texture_string;

        it("Returns base livery if it receives a string instead of a livery stack", function()
            assert.same("base.png",
                        cts(simple_def(), "legacy_data"));
        end);
    end);

    describe("set_livery()", function()
        local sl = multi_component_liveries.set_livery;

        it("initializes livery property if it is a string", function()
            local puncher = {};

            local itemstack = painting_tool("#000000", 0);

            local persistent_data = {
                livery = "legacy_data";
            };

            sl(wagon(), puncher, itemstack, persistent_data);

            assert.same(simple_liv(), persistent_data.livery);
        end);

        it("initializes livery property if painting on a string", function()
            local puncher = {};

            local itemstack = painting_tool("#ff0000");

            local persistent_data = {
                livery = "legacy_data";
            };

            sl(wagon(), puncher, itemstack, persistent_data);

            assert.same(red_liv(), persistent_data.livery);
        end);

        it("initializes livery property if it is missing", function()
            local puncher = {};

            local itemstack = painting_tool("#ff0000");

            local persistent_data = {
                livery = nil;
            };

            sl(wagon(), puncher, itemstack, persistent_data);

            assert.same(red_liv(), persistent_data.livery);
        end);

        it("paints on livery property as usual if it is valid", function()
            local puncher = {};

            local persistent_data = {
                livery = simple_liv();
            };

            sl(wagon(), puncher, painting_tool("#000100", 0), persistent_data);
            sl(wagon(), puncher, painting_tool("#654321", 255), persistent_data);

            assert.same(select_layer(reverse_liv(), 2), persistent_data.livery);
        end);
    end);
end);
