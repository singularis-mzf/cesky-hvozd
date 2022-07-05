-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

visual_line_number_displays = {};

visual_line_number_displays.font = font_api.get_font("metro");

local modpath = minetest.get_modpath("visual_line_number_displays")
dofile(modpath .. "/api.lua");
dofile(modpath .. "/basic_entities.lua");
dofile(modpath .. "/colorizer.lua");
dofile(modpath .. "/core.lua");
dofile(modpath .. "/layouter.lua");
dofile(modpath .. "/parser.lua");
dofile(modpath .. "/renderer.lua");

-- This placeholder is expanded by git-archive,
-- so in a mod archive the variable is false.
-- The autotests/ directory is not available in a mod archive.
--
-- The file is necessary for the /render_manual_pictures command,
-- so it is needless to say it will only work correctly with a custom client.
local render_manual_pictures = string.sub("$Format:%%$", 1, 1) == "$";
if render_manual_pictures then
    pcall(dofile, modpath .. "/autotests/render_manual_pictures.lua");
end
