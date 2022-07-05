-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Look for test subjects outside of autotests/
package.path = "visual_line_number_displays/?.lua;" .. package.path

-- See https://rubenwardy.com/minetest_modding_book/en/quality/unit_testing.html
_G.visual_line_number_displays = {};

require("api");
require("parser");
require("basic_entities");
require("colorizer");

describe("parse_text_block_string()", function()
    local ptbs = visual_line_number_displays.parse_text_block_string;

    -- Creates a table of braceless text_block_description tables.
    local function plain(texts)
        local result = {};
        for _, t in ipairs(texts) do
            table.insert(result, { text = t, features = {}, braceless = true });
        end
        return result;
    end

    it("parses very plain texts", function()
        assert.same(plain({ "1" }), ptbs("1"));
        assert.same(plain({ "S30" }), ptbs("S30"));
        assert.same(plain({ "Porta Westfalica" }), ptbs("Porta Westfalica"));
    end);

    it("preserves non-brace brackets", function()
        assert.same(plain({ "(single) [brackets] <preserved>" }), ptbs("(single) [brackets] <preserved>"));
        assert.same(plain({ "((many)) [[brackets]] <([preserved])>" }), ptbs("((many)) [[brackets]] <([preserved])>"));
    end);

    it("preserves whitespace", function()
        assert.same(plain({ " some \nwhitespace   " }), ptbs(" some \nwhitespace   "));
        assert.same({{
                text = " \n More whitespace\t ";
                features = {};
            }}, ptbs("{ \n More whitespace\t }"));
        assert.same({
                {
                    text = "Space between";
                    features = {};
                };
                {
                    text = "\n";
                    features = {};
                    braceless = true;
                };
                {
                    text = "blocks";
                    features = {};
                };
            }, ptbs("{Space between}\n{blocks}"));
    end);

    it("recognizes single features", function()
        assert.same({{
                text = "A";
                features = {
                    stroke_13_foreground = true;
                };
            }}, ptbs("{/|A}"));
        assert.same({{
                text = "abc";
                features = {
                    stroke_24_background = true;
                };
            }}, ptbs("{stroke_24_background|abc}"));
    end);

    it("recognizes multiple features", function()
        assert.same({{
                text = "A";
                features = {
                    stroke_24_background = true;
                    stroke_13_foreground = true;
                    stroke_foreground = true;
                };
            }}, ptbs("{-|/|stroke_24_background|A}"));
    end);

    it("passes through invalid features", function()
        assert.same({{
                text = "invalid|feature";
                features = {
                    stroke_foreground = true;
                };
            }}, ptbs("{invalid|-|feature}"));
    end);

    it("respects nested brace pairs", function()
        -- Not really necessary, since macros are parsed before blocks.
        assert.same({{
                text = "{some|/|macro}";
                features = {
                    stroke_foreground = true;
                };
            }}, ptbs("{-|{some|/|macro}}"));
    end);

    it("preserves braceless color brace sequences", function()
        assert.same(plain({ "{t:#000}" }), ptbs("{t:#000}"));
        assert.same(plain({ "{text:}" }), ptbs("{text:}"));
        assert.same({{
                text = "invalid:#000";
                features = {};
            }}, ptbs("{invalid:#000}"));
    end);


    it("recognizes background shapes", function()
        assert.same({{
                text = "A";
                background_shape = "square";
                features = {};
            }}, ptbs("{[]|A}"));
        assert.same({{
                text = "A";
                background_shape = "square";
                features = {};
            }}, ptbs("{square|A}"));
        assert.same({{
                text = "abc";
                background_shape = "round";
                features = {};
            }}, ptbs("{()|abc}"));
        assert.same({{
                text = "First\nSecond";
                background_shape = "diamond";
                features = {};
            }}, ptbs("{<>|First\nSecond}"));
        assert.same({{
                text = "A";
                background_shape = "square_outlined";
                features = {};
            }}, ptbs("{_[]_|A}"));
        assert.same({{
                text = "abc";
                background_shape = "round_outlined";
                features = {};
            }}, ptbs("{_()_|abc}"));
        assert.same({{
                text = "First\nSecond";
                background_shape = "diamond_outlined";
                features = {};
            }}, ptbs("{_<>_|First\nSecond}"));
    end);

    it("preserves emptyness in blocks", function()
        assert.same({{
                text = "";
                features = {};
            }}, ptbs("{}"));
        assert.same({{
                text = "";
                background_shape = "diamond";
                features = {};
            }}, ptbs("{<>|}"));
    end);

    it("recognizes background patterns", function()
        assert.same({{
                text = "A";
                background_pattern = "diag_4";
                features = {};
            }}, ptbs("{4|A}"));
        assert.same({{
                text = "A";
                background_shape = "round";
                background_pattern = "diag_2";
                features = {};
            }}, ptbs("{round|lower_right|A}"));
        assert.same({{
                text = "A";
                background_shape = "diamond";
                background_pattern = "diag_1";
                features = {};
            }}, ptbs("{1|<>|A}"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "upper";
                features = {};
            }}, ptbs("{[]|upper|A}"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "right";
                features = {};
            }}, ptbs("{right|square|A}"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "x_left";
                features = {};
            }}, ptbs("{left_right|[]|A}"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "x_upper";
                features = {};
            }}, ptbs("{[]|upper_lower|A}"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "plus_4";
                features = {};
            }}, ptbs("{upper_left_lower_right|square|A}"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "plus_4";
                features = {};
            }}, ptbs("{[]|24|A}"));
    end);

    it("recognizes features and background patterns together", function()
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "diag_4";
                features = {
                    stroke_13_background = true;
                };
            }}, ptbs("{4|stroke_13_background|[]|A}"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "left";
                features = {
                    stroke_foreground = true;
                };
            }}, ptbs("{-|square|left|A}"));
    end);

    it("discards additional background patterns", function()
        assert.same({{
                text = "upper_lower|A";
                background_shape = "square";
                background_pattern = "x_left";
                features = {};
            }}, ptbs("{[]|left_right|upper_lower|A}"));
        assert.same({{
                text = "left|A";
                background_shape = "square";
                background_pattern = "right";
                features = {};
            }}, ptbs("{right|left|square|A}"));
    end);

    it("discards additional background shapes", function()
        assert.same({
                {
                    text = "round|A";
                    background_shape = "square";
                    features = {};
                };
            }, ptbs("{[]|round|A}"));
        assert.same({
                {
                    text = "()|A";
                    background_shape = "round";
                    features = {};
                };
            }, ptbs("{round|()|A}"));
    end);

    it("preserves additional braces", function()
        assert.same({{
                text = "{}";
                features = {};
            }}, ptbs("{{}}"));
        assert.same({{
                text = "invalid {option}|some {braces}";
                background_shape = "square";
                features = {};
            }}, ptbs("{square|invalid {option}|some {braces}}"));
    end);

    it("passes through incomplete blocks", function()
        assert.same(plain({ "incomplete {block" }), ptbs("incomplete {block"));
        assert.same(plain({ "incomplete} block" }), ptbs("incomplete} block"));
    end);

    it("parses options of empty blocks", function()
        assert.same({{
                text = "";
                features = {
                    stroke_13_foreground = true;
                };
            }}, ptbs("{/|}"));
        assert.same({{
                text = "";
                background_shape = "square";
                features = {};
            }}, ptbs("{square|}"));
    end);
end);

describe("parse_entities_in_blocks()", function()
    local function peb(blocks)
        visual_line_number_displays.parse_entities_in_blocks(blocks);
        return blocks;
    end

    local function t(text)
        return {
            text = text;
            features = {};
        };
    end

    it("Replaces basic entities", function()
        assert.same({t("[")}, peb({t("{lbrak}")}));
        assert.same({t("{{")}, peb({t("{lcurl}{lcurl}")}));
        assert.same({t("<>")}, peb({t("{lt}{gt}")}));
        assert.same({t("\n ")}, peb({t("{nl}{sp}")}));
        assert.same({t("\n ")}, peb({t("{newline}{space}")}));
    end);

    -- For convenience of the person doing the test,
    -- some UTF-8 strings will be compared as byte lists.
    local function bytes(text_or_block)
        local text = text_or_block;
        if type(text_or_block) == "table" then
            text = text_or_block[1].text;
        end

        local result = {};
        for i = 1, #text do
            table.insert(result, string.format("0x%02x", string.byte(string.sub(text, i, i))));
        end
        return result;
    end

    describe("bytes() helper function", function()
        assert.same({ "0x20", "0x7f" }, bytes(" \127"));
    end);

    it("Replaces numeric entities", function()
        assert.same({t(" ")}, peb({t("{#x20}")}));
        assert.same({t(" ")}, peb({t("{#32}")}));
        assert.same({t("\0")}, peb({t("{#0}")}));
        assert.same({t("\127")}, peb({t("{#127}")}));
        assert.same(bytes("\194\128"), bytes(peb({t("{#128}")})));
        assert.same(bytes("±"), bytes(peb({t("{#xb1}")})));
        assert.same(bytes("±"), bytes(peb({t("{#x00b1}")})));
        assert.same(bytes("ł"), bytes(peb({t("{#x142}")})));
        assert.same(bytes("❶"), bytes(peb({t("{#x2776}")})));
        assert.same(bytes("𠃑"), bytes(peb({t("{#x200d1}")})));
        assert.same(bytes("{#}"), bytes(peb({t("{#}")})));
        assert.same(bytes("{#x110000}"), bytes(peb({t("{#x110000}")})));
    end);

    it("Preserves text", function()
        assert.same({t("")}, peb({t("")}));
        assert.same({t("lbrak}")}, peb({t("lbrak}")}));
        assert.same({t("lcurl}{")}, peb({t("lcurl}{lcurl}")}));
        assert.same({t("{lcurl}")}, peb({t("{lcurl}lcurl}")}));
        assert.same({t("lt>")}, peb({t("lt{gt}")}));
        assert.same({t("lt}>")}, peb({t("lt}{gt}")}));
        assert.same({t("ltgt")}, peb({t("ltgt")}));
        assert.same({t("lt}gt")}, peb({t("lt}gt")}));
        assert.same({t("<gt")}, peb({t("{lt}gt")}));
    end);

    it("Preserves invalid entities", function()
        assert.same({t("{")}, peb({t("{")}));
        assert.same({t("{{")}, peb({t("{lcurl}{")}));
        assert.same({t("{{lcurl}}")}, peb({t("{{lcurl}}")}));
        assert.same({t("{}")}, peb({t("{lcurl}}")}));
        assert.same({t("{lcurl")}, peb({t("{lcurl")}));
        assert.same({t("}(")}, peb({t("}{lpar}")}));
        assert.same({t("<{gt")}, peb({t("{lt}{gt")}));
        assert.same({t("{invalidentity}")}, peb({t("{invalidentity}")}));
    end);
end);

describe("parse_macros()", function()
    local function pm(input)
        local a, b = visual_line_number_displays.parse_macros(input);
        return { a, b };
    end

    local macros = {
        macro1 = "macro_1_expanded";
        macro2 = "";
        macro3 = "{macro3}";
        ["macro4"] = { "before", 1, "between", 1, "after" };
        ["macro5"] = { "" };
        ["macro6"] = {};
        macro7 = "ab{macro3}de{{macro2}}fg{{}macro7}";
    };

    setup(function()
        for k, v in pairs(macros) do
            visual_line_number_displays.macros[k] = v;
        end
    end);

    it("replaces basic macros", function()
        assert.same({ "macro_1_expanded", true }, pm("{macro1}"));
        assert.same({ "macro1", false }, pm("macro1"));
        assert.same({ "macro_1_expandedmacro_1_expanded", true }, pm("{macro1}{macro1}"));
        assert.same({ "bla macro_1_expanded}macro_1_expanded bla", true }, pm("bla {macro1}}{macro1} bla"));
        assert.same({ "{{macro1}}", false }, pm("{{macro1}}"));
        assert.same({ "", true }, pm("{macro2}"));
        assert.same({ "{macro3}", true }, pm("{macro3}"));
        assert.same({ "{macrowrong}", false }, pm("{macrowrong}"));
        assert.same({ "{macrowrong{}{macro1}}", false }, pm("{macrowrong{}{macro1}}"));
        assert.same({ "{}macro_1_expanded}", true }, pm("{}{macro1}}"));
    end);

    it("replaces macros with parameter", function()
        assert.same({ "beforeparambetweenparamafter", true }, pm("{macro4|param}"));
        assert.same({ "before{macro1}between{macro1}after", true }, pm("{macro4|{macro1}}"));
        assert.same({ "before{macro4|{}}between{macro4|{}}after", true }, pm("{macro4|{macro4|{}}}"));
        assert.same({ "blabla", true }, pm("bla{macro5|abc}bla"));
        assert.same({ "blabla", true }, pm("bla{macro6|abc}bla"));
    end);

    teardown(function()
        for k, _ in pairs(macros) do
            visual_line_number_displays.macros[k] = nil;
        end
    end);
end);

describe("parse_escapes()", function()
    local pes = visual_line_number_displays.parse_escapes;

    it("replaces escape sequences", function()
        assert.same("A{#x20}B", pes("A\\ B"));
        assert.same("{#x20AC}", pes("\\€"));
        assert.same("{#x20AC}{#x20AC}", pes("\\€\\€"));
        assert.same("{#x5C}", pes("\\\\"));
        assert.same("{#x40}", pes("\\\064"));
    end);

    it("preserves other stuff", function()
        assert.same("", pes(""));
        assert.same(" ", pes(" "));
        assert.same("ABC", pes("ABC"));
    end);

    it("tolerates early string end", function()
        assert.same("\\", pes("\\"));
        assert.same("\\", pes("\\\193"));
    end);
end);

describe("next_brace_pair()", function()
    local nbp = visual_line_number_displays.next_brace_pair;

    it("finds brace pairs", function()
        assert.same({1, 2, { "" }}, { nbp("{}", 1) });
        assert.same({}, { nbp("{}", 2) });
        assert.same({3, 4, { "" }}, { nbp("{}{}", 2) });
        assert.same({1, 4, { "{}" }}, { nbp("{{}}", 1) });
        assert.same({2, 3, { "" }}, { nbp("{{}}", 2) });
        assert.same({1, 11, { "{blablah}" }}, { nbp("{{blablah}}", 1) });
    end);

    it("does not find unclosed brace pairs", function()
        assert.same({}, { nbp("{", 1) });
        assert.same({2, 3, { "" }}, { nbp("{{}", 1) });
        assert.same({}, { nbp("}", 1) });
        assert.same({}, { nbp("blablah}{", 1) });
    end);

    it("splits content at bars", function()
        assert.same({1, 10, { "bla", "blah" }}, { nbp("{bla|blah}", 1) });
        assert.same({1, 7, { "", "blah" }}, { nbp("{|blah}", 1) });
        assert.same({1, 6, { "bla", "" }}, { nbp("{bla|}", 1) });
        assert.same({1, 3, { "", "" }}, { nbp("{|}", 1) });
        assert.same({1, 4, { "", "", "" }}, { nbp("{||}", 1) });
    end);

    it("preserves bars wrapped into inner brace pairs", function()
        assert.same({1, 12, { "{bla|blah}" }}, { nbp("{{bla|blah}}", 1) });
        assert.same({2, 11, { "bla", "blah" }}, { nbp("{{bla|blah}}", 2) });
        assert.same({1, 12, { "bla{|}blah" }}, { nbp("{bla{|}blah}", 1) });
    end);
end);
