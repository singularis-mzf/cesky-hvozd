-- SPDX-FileCopyrightText: 2021 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT
--
-- Look for test subjects outside of autotests/
package.path = "morelights_dim/?.lua;" .. package.path

-- See https://rubenwardy.com/minetest_modding_book/en/quality/unit_testing.html
_G.morelights_dim = {};

require("util");

describe("texture_escape_level", function()
    local tel = morelights_dim.texture_escape_level;
    it("determines escape level in texture strings", function()
        assert.same(0, tel("1234567890123456789012345678901234567890", 1));
        assert.same(0, tel("a.png^b.png", 1));
        assert.same(0, tel("a.png^b.png", 7));
        assert.same(1, tel("a.png^[mask:b.png", 13));
        assert.same(1, tel("a.png^[mask:b.png\\^c.png", 20));
        assert.same(0, tel("a.png^[mask:b.png^c.png", 19));
        assert.same(0, tel("1234567890123456789012345678901234567890", 1));
        assert.same(2, tel("a.png^[mask:b.png\\^[mask\\:c.png\\^d.png", 27));
        assert.same(1, tel("a.png^[mask:b.png\\^[mask\\:c.png\\^d.png", 34));
        assert.same(2, tel("a.png^[mask:b.png\\^[mask\\:c.png\\^d.png", 27));
        assert.same(1, tel("a.png^[mask:b.png^[mask:c.png\\^d.png", 32));
        assert.same(0, tel("a.png^[mask:b.png\\^[mask\\:c.png^d.png", 33));
        assert.same(0, tel("a.png^[mask:b.png^[mask:c.png^d.png", 31));
    end);
end);

describe("texture_multiply_parts", function()
    local tmp = morelights_dim.texture_multiply_parts;
    it("multiplies texture parts in texture strings", function()
        assert.same("a.png^(b.png^[multiply:#dddddd)",
                    tmp("a.png^b.png", "b.png", "#dddddd"));
        assert.same("(a.png^[multiply:#dddddd)^b.png",
                    tmp("a.png^b.png", "a.png", "#dddddd"));
        assert.same("(b.png^[multiply:#dddddd)^(b.png^[multiply:#dddddd)",
                    tmp("b.png^b.png", "b.png", "#dddddd"));
        assert.same("(b.png^[multiply:#dddddd)",
                    tmp("b.png", "b.png", "#dddddd"));
        assert.same("a.png^((b.png^[multiply:#dddddd))",
                    tmp("a.png^(b.png)", "b.png", "#dddddd"));
        assert.same("a.png^(b.png^[multiply:#dddddd)^[multiply:#dddddd",
                    tmp("a.png^b.png^[multiply:#dddddd", "b.png", "#dddddd"));
    end);
    it("respects escaping", function()
        assert.same("a.png^[mask:(b.png\\^[multiply\\:#dddddd)",
                    tmp("a.png^[mask:b.png", "b.png", "#dddddd"));
        assert.same("a.png^[mask:(b.png\\^[multiply\\:#dddddd)\\^[mask\\:c.png",
                    tmp("a.png^[mask:b.png\\^[mask\\:c.png", "b.png", "#dddddd"));
        assert.same(
                "a.png^[mask:b.png\\^[mask\\:(c.png\\\\^[multiply\\\\:#dddddd)",
                tmp("a.png^[mask:b.png\\^[mask\\:c.png", "c.png", "#dddddd"));
        assert.same("a.png^[mask:b.png^(c.png^[multiply:#dddddd)",
                    tmp("a.png^[mask:b.png^c.png", "c.png", "#dddddd"));
        assert.same("a.png^[mask:b.png\\^(c.png\\^[multiply\\:#dddddd)",
                    tmp("a.png^[mask:b.png\\^c.png", "c.png", "#dddddd"));
        assert.same(
                "a.png^[mask:b.png\\^[mask\\:c.png^(d.png^[multiply:#dddddd)",
                tmp("a.png^[mask:b.png\\^[mask\\:c.png^d.png", "d.png",
                    "#dddddd"));
    end);
end);
