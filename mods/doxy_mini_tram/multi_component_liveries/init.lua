-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

multi_component_liveries = {};

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

dofile(minetest.get_modpath("multi_component_liveries") .. "/core.lua");
dofile(minetest.get_modpath("multi_component_liveries") .. "/api.lua");
dofile(minetest.get_modpath("multi_component_liveries") .. "/slots.lua");

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
