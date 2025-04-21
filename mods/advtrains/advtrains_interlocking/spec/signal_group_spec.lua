require "mineunit"
mineunit("core")

_G.advtrains = {
	interlocking = {
		aspect = sourcefile("aspect"),
	},
	ndb = {
		get_node = minetest.get_node,
		swap_node = minetest.swap_node,
	}
}

fixture("advtrains_helpers")
sourcefile("database")
sourcefile("signal_api")
sourcefile("distant")
sourcefile("signal_aspect_accessors")

local A = advtrains.interlocking.aspect
local D = advtrains.distant
local I = advtrains.interlocking
local N = advtrains.ndb

local groupdef = {
	name = "foo",
	aspects = {
		proceed = {main = -1},
		caution = {},
		danger = {main = 0},
		"proceed",
		{"caution"},
		"danger",
	},
}

for k, v in pairs(groupdef.aspects) do
	minetest.register_node("advtrains_interlocking:" .. k, {
		advtrains = {
			supported_aspects = {
				group = "foo",
			},
			get_aspect = function() return A{group = "foo", name = k} end,
			set_aspect = function(pos, _, name)
				N.swap_node(pos, {name = "advtrains_interlocking:" .. name})
			end,
		}
	})
end

local origin = vector.new(0, 0, 0)
local dstpos = vector.new(0, 0, 1)

world.layout {
	{origin, "advtrains_interlocking:danger"},
	{dstpos, "advtrains_interlocking:proceed"},
}

describe("signal group registration", function()
	it("should work", function()
		A.register_group(groupdef)
		assert(A.get_group_definition("foo"))
	end)
	it("should only be allowed once for the same group", function()
		assert.has.errors(function() A.register_group(type2def) end)
	end)
	it("should handle nonexistant groups", function()
		assert.is_nil(A.get_group_definition("something_else"))
	end)
	it("should reject invalid definitions", function()
		assert.has.errors(function() A.register_group({}) end)
		assert.has.errors(function() A.register_group({name="",label={}}) end)
		assert.has.errors(function() A.register_group({name="",aspects={}}) end)
	end)
end)

describe("signal aspect", function()
	it("should handle empty fields properly", function()
		assert.equal(A{main = 0}, A{group="foo", name="danger"}:to_group())
	end)
	it("should be converted properly", function()
		assert.equal(A{main = 0}, A{group="foo", name="danger"})
		assert.equal(A{}, A{group="foo", name="caution"})
		assert.equal(A{main = -1}, A{group="foo", name="proceed"})
	end)
end)

describe("signals in groups", function()
	it("should support distant signaling", function()
		assert.equal("caution", A():adjust_distant(A{group="foo",name="danger"}).name)
		assert.equal("proceed", A():adjust_distant(A{group="foo",name="caution"}).name)
		assert.equal("proceed", A():adjust_distant(A{group="foo",name="proceed"}).name)
		assert.equal("danger", A{group="foo",name="danger"}:adjust_distant{}.name)
	end)
end)
