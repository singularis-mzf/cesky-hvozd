-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Look for test subjects outside of autotests/
package.path = "visual_line_number_displays/?.lua;" .. package.path

-- See https://rubenwardy.com/minetest_modding_book/en/quality/unit_testing.html
_G.visual_line_number_displays = {};

require("api");
require("colorizer");

describe("colors_for_line()", function()
    local cfl = visual_line_number_displays.colors_for_line;

    it("returns subway wagon colors", function()
        assert.same({
                background = "#1e00ff";
                background_explicit = true;
                text = "#ffffff";
                text_explicit = false;
                secondary_background = "#550000";
                secondary_background_explicit = false;
                feature = "#ff2222";
                feature_explicit = true;
            }, cfl(1));
        assert.same({
                background = "#ff001e";
                background_explicit = true;
                text = "#ffffff";
                text_explicit = false;
                secondary_background = "#ffaaff";
                secondary_background_explicit = false;
                feature = "#000000";
                feature_explicit = true;
            }, cfl(2));
        assert.same(nil, cfl(""));
        assert.same(nil, cfl("1"));
    end);
end);
