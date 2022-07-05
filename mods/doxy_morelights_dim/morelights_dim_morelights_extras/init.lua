-- SPDX-FileCopyrightText: 2021 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT
--
print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
morelights_dim.register_texture_for_dimming("morelights_extras_f_block.png");
morelights_dim.register_texture_for_dimming("morelights_extras_blocklight.png");
-- morelights_dim.register_texture_for_dimming("morelights_extras_stairlight.png");

morelights_dim.register_dim_variants("morelights_extras:f_block");
morelights_dim.register_dim_variants("morelights_extras:dirt_with_grass");
morelights_dim.register_dim_variants("morelights_extras:stone_block");
morelights_dim.register_dim_variants("morelights_extras:sandstone_block");
-- morelights_dim.register_dim_variants("morelights_extras:stairlight");
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
