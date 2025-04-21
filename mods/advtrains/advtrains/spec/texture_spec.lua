package.path = "../?.lua;" .. package.path
local T = require "texture"

describe("Texture creation", function()
	it("works", function()
		assert.same("^.png", tostring(T.raw"^.png"))
		assert.same("foo\\:bar.png", tostring(T"foo:bar.png"))
	end)
end)

describe("Texture modifiers", function()
	it("work", function()
		assert.same("x^[colorize:c", tostring(T"x":colorize"c"))
		assert.same("x^[colorize:c:alpha", tostring(T"x":colorize("c", "alpha")))
		assert.same("x^[multiply:c", tostring(T"x":multiply"c"))
		assert.same("x^[resize:2x3", tostring(T"x":resize(2, 3)))
		assert.same("x^[transformI", tostring(T"x":transform"I"))
	end)
end)
