-- SPDX-FileCopyrightText: 2021 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

max_string_line_length = 240;
max_code_line_length = 240;

ignore = {
    -- Callback handlers receive many unused variables.
    -- Mark intentionally unused ones with a leading underscore.
    "21/_.*",
};

globals = {
    "morelights_dim",
};

read_globals = {
    -- Minetest API
    "minetest",
    string = {fields = {"split", "trim"}},
    table = {fields = {"copy"}},

    -- busted API
    "describe",
    "it",
    "assert",
};
