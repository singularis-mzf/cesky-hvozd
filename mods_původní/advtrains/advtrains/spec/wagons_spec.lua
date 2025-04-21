require "mineunit"
mineunit "core"

_G.advtrains = {
	wagon_load_range = 32
}
sourcefile "wagons"

local myproto = {_test = true}
advtrains.register_wagon(":mywagon", myproto, "My wagon", "", false)
advtrains.register_wagon_alias(":myalias", ":mywagon")
advtrains.register_wagon_alias(":myotheralias", ":myalias")

local myotherproto = {_other = true}
advtrains.register_wagon(":noalias", myotherproto, "Not aliased wagon", "", false)
advtrains.register_wagon_alias(":noalias", ":mywagon")

advtrains.register_wagon_alias(":nilalias", ":nil")

advtrains.register_wagon_alias(":R1", ":R2")
advtrains.register_wagon_alias(":R2", ":R3")
advtrains.register_wagon_alias(":R3", ":R1")

describe("wagon alias system", function()
	it("should work", function()
		assert.same({":mywagon", myproto}, {advtrains.resolve_wagon_alias(":myalias")})
		assert.equal(myproto, advtrains.wagon_prototypes[":myalias"])
		assert.same({":mywagon", myproto}, {advtrains.resolve_wagon_alias(":myotheralias")})
	end)
	it("should respect wagon registration", function()
		assert.same({":noalias", myotherproto}, {advtrains.resolve_wagon_alias(":noalias")})
	end)
	it("should handle recursive loops", function()
		assert.same({}, {advtrains.resolve_wagon_alias(":R1")})
	end)
	it("should return nil for missing entries", function()
		assert.same({}, {advtrains.resolve_wagon_alias(":what")})
		assert.same({}, {advtrains.resolve_wagon_alias(":nilalias")})
	end)
end)
