package.path = "../?.lua;" .. package.path
advtrains = {}
_G.advtrains = advtrains
local poconvert = require("poconvert")

describe("PO file converter", function()
	it("should convert PO files", function()
		assert.equals([[
# textdomain: foo
foo=bar
baz=
#@=wh\at\\@n=@=w\as\\@n
multiline@nstrings=multiline@nresult
with context?=oder doch nicht]], poconvert.from_string("foo", [[
msgid ""
msgstr "whatever metadata"

msgid "foo"
msgstr "bar"

msgid "baz"
msgstr ""

#, fuzzy
msgid "=wh\\at\\\\\n"
msgstr "=w\\as\\\\\n"

msgid "multi"
"line\n"
"strings"
msgstr "multi"
"line\n"
"result"

msgctxt "i18n context"
msgid "with context?"
msgstr "oder doch nicht"]]))
	end)
	it("should reject invalid tokens", function()
		assert.has.errors(function()
			poconvert.from_string("", [[
foo ""
bar ""]])
		end, "Invalid token: foo")
	end)
	it("should reject entries without a msgstr", function()
		assert.has.errors(function()
			poconvert.from_string("", [[msgid "foo"]])
		end, "Missing translated string")
	end)
	it("should reject entries without a msgid", function()
		assert.has.errors(function()
			poconvert.from_string("", [[msgstr "foo"]])
		end, "Missing untranslated string")
	end)
	it("should reject entries with improperly enclosed strings", function()
		assert.has.errors(function()
			poconvert.from_string("", [[
msgid "foo"
msgstr "bar \]])
		end, "String extends beyond the end of input")
	end)
	it("should reject incomplete input", function()
		assert.has.errors(function()
			poconvert.from_string("", [[
msgid "foo"
msgstr]])
		end, "No string provided for msgstr")
	end)
end)
