
-- Fallback functions for when `intllib` is not installed.
-- Code released under Unlicense <http://unlicense.org>.

-- Get the latest version of this file at:
--   https://raw.githubusercontent.com/minetest-mods/intllib/master/lib/intllib.lua

local S = minetest.get_translator("signs_lib")

local gettext = function(msgid, ...)
	return S(msgid, ...)
end

local ngettext = function(msgid, msgid_plural, n, ...)
	return S(n==1 and msgid or msgid_plural, ...)
end

return gettext, ngettext
