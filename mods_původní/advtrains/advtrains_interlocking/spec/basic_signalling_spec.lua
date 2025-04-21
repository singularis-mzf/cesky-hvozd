--[[
This file tests a large part of the signaling system, as a lot of tests for the
signaling system tend to overlap for various parts of the system.
]]

require("mineunit")
mineunit("core")

_G.advtrains = {
	interlocking = {
		aspect = fixture("../../aspect"),
	},
	ndb = {
		get_node = minetest.get_node,
		swap_node = minetest.swap_node,
	}
}

fixture("advtrains_helpers")
fixture("../../database")
sourcefile("distant")
sourcefile("signal_api")
sourcefile("signal_aspect_accessors")
fixture("../../demosignals")

minetest.register_node("advtrains_interlocking:signal_sign", {
	advtrains = {
		get_aspcet = function() return {main = 19} end
	}
})

local D = advtrains.distant
local I = advtrains.interlocking
local A = I.aspect

local stub_aspect_t1 = {
	free = {main = -1},
	slow = {main = 6},
	danger = {main = 0, shunt = false},
}
for k, v in pairs(stub_aspect_t1) do
	stub_aspect_t1[k] = A(v)
end
local stub_pos_t1 = {}
for i = 1, 4 do
	stub_pos_t1[i] = {x = 1, y = 0, z = i}
end

world.layout {
	{stub_pos_t1[1], "advtrains_interlocking:ds_danger"},
	{stub_pos_t1[2], "advtrains_interlocking:ds_slow"},
	{stub_pos_t1[3], "advtrains_interlocking:ds_free"},
	{stub_pos_t1[4], "advtrains_interlocking:signal_sign"},
}

describe("API for supposed signal aspects", function()
	it("should load and save data properly", function()
		local tbl = {_foo = {}}
		I.load_supposed_aspects(tbl)
		assert.same(tbl, I.save_supposed_aspects())
	end)
	it("should set and get signals properly", function ()
		local pos = stub_pos_t1[2]
		local asp = stub_aspect_t1.slow
		local newasp = A{ main = math.random(1,5) }
		assert.equal(asp, I.signal_get_aspect(pos))
		I.signal_set_aspect(pos, newasp)
		assert.equal(newasp, I.signal_get_aspect(pos))
		assert.equal(asp, I.signal_get_real_aspect(pos))
		I.signal_set_aspect(pos, asp)
	end)
end)

describe("Distant signaling", function()
	it("should assign distant signals and set the distant aspect correspondingly", function()
		for i = 1, 2 do
			D.assign(stub_pos_t1[i], stub_pos_t1[i+1])
		end
		assert.equal(stub_aspect_t1.danger, I.signal_get_aspect(stub_pos_t1[1]))
		assert.equal(A{main = 6, dst = 0}, I.signal_get_aspect(stub_pos_t1[2]))
		assert.equal(A{main = -1, dst = 6}, I.signal_get_aspect(stub_pos_t1[3]))
	end)
	it("should report assignments properly", function()
		assert.same({stub_pos_t1[1], "manual"}, {D.get_main(stub_pos_t1[2])})
		assert.same({[advtrains.encode_pos(stub_pos_t1[3])] = "manual"}, D.get_dst(stub_pos_t1[2]))
	end)
	it("should update distant aspects automatically", function()
		I.signal_set_aspect(stub_pos_t1[2], {main = 2, dst = -1})
		assert.equal(A{main = 2, dst = 0}, I.signal_get_aspect(stub_pos_t1[2]))
		assert.equal(A{main = -1, dst = 2}, I.signal_get_aspect(stub_pos_t1[3]))
	end)
	it("should unassign signals when one is removed", function()
		world.set_node(stub_pos_t1[2], "air")
		assert.same({}, D.get_dst(stub_pos_t1[1]))
		assert.same({}, {D.get_main(stub_pos_t1[3])})
		assert.same(stub_aspect_t1.free, I.signal_get_aspect(stub_pos_t1[3]))
	end)
	it("should reject signal signs", function()
		D.assign(stub_pos_t1[1], stub_pos_t1[4])
		assert.same({}, D.get_dst(stub_pos_t1[1]))
		assert.same({}, {D.get_main(stub_pos_t1[4])})
		D.assign(stub_pos_t1[4], stub_pos_t1[1])
		assert.same({}, D.get_dst(stub_pos_t1[4]))
		assert.same({}, {D.get_main(stub_pos_t1[1])})
	end)
end)
