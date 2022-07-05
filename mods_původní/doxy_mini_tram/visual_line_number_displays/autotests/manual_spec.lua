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

local reference = require("manual_pictures");

describe("User manual reference pictures --", function()
    for _, test in ipairs(reference) do
        local short_description = test[1];
        local display_string_input = test[2];
        local expected_texture_string = test[3];
        local max_width = test[4][1];
        local height = test[4][2];
        local level = test[4][3];

        local display_description = {
            base_resolution = { width = max_width, height = height };
            base_texture = "vlnd_transparent.png";
            displays = {{
                position = { x = 0, y = 0 };
                height = height;
                max_width = max_width;
                center_width = 0;
                level = level;
            }};
        };

        it(short_description, function()
            assert.same(
                {
                    input = display_string_input;
                    display_description = display_description;
                    output = expected_texture_string;
                },
                {
                    input = display_string_input;
                    display_description = display_description;
                    output = visual_line_number_displays.render_displays(
                        display_description,
                        display_string_input
                    );
                }
            );
        end);
    end
end);
