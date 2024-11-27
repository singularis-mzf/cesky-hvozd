ch_base.open_mod(minetest.get_current_modname())
-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

multi_component_liveries = {};


dofile(minetest.get_modpath("multi_component_liveries") .. "/core.lua");
dofile(minetest.get_modpath("multi_component_liveries") .. "/api.lua");
dofile(minetest.get_modpath("multi_component_liveries") .. "/slots.lua");

ch_base.close_mod(minetest.get_current_modname())
