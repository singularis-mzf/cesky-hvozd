
-- Fallback functions for when `intllib` is not installed.
-- Code released under Unlicense <http://unlicense.org>.

-- Get the latest version of this file at:
--   https://raw.githubusercontent.com/minetest-mods/intllib/master/lib/intllib.lua

local S = minetest.get_translator("signs_road")

local function format(str, ...)
    return S(str, ...)
end

gettext = function(msgid, ...)
	return format(msgid, ...)
end

ngettext = function(msgid, msgid_plural, n, ...)
	return format(n==1 and msgid or msgid_plural, ...)
end

return gettext, ngettext
