local filepath = minetest.get_worldpath().."/wanted_blocks.txt"

local wanted_blocks = {
	"techpack_stairway:grating_grey",
	"techpack_stairway:handrail1_grey",
	"techpack_stairway:handrail2_grey",
	"techpack_stairway:handrail3_grey",
	"techpack_stairway:handrail4_grey",
	"techpack_stairway:bridge1_grey",
	"techpack_stairway:bridge2_grey",
	"techpack_stairway:bridge3_grey",
	"techpack_stairway:bridge4_grey",
	"techpack_stairway:stairway_grey",
	"techpack_stairway:ladder1_grey",
	"techpack_stairway:ladder2_grey",
	"techpack_stairway:ladder3_grey",
	"techpack_stairway:ladder4_grey",
	"techpack_stairway:ladder4",
}
local generation = 2

if #wanted_blocks == 0 then
	return
end

local f
local f_generation = 0

local function close_f(expected_generation)
	if f_generation ~= expected_generation then return end
	local lf = f
	if lf == nil then return end
	f = nil
	lf:close()
end

local last_plan_us = 0

local function plan_close()
	local us_time = minetest.get_us_time()
	if us_time - last_plan_us < 1000000 then return end
	f_generation = f_generation + 1
	minetest.after(2, close_f, f_generation)
	last_plan_us = us_time
end

local function on_lbm(pos, node, dtime_s)
	local date = os.date("%Y-%m-%d", os.time())
	if f == nil then
		f_generation = f_generation + 1
		f = io.open(filepath, "a")
		if f == nil then
			minetest.log("warning", "[ch_test] Cannot open "..filepath)
			return
		end
		last_plan_us = 0
	end
	f:write(node.name.."\t"..node.param2.."\t"..minetest.pos_to_string(pos).."\t"..date.."\tGEN="..generation.."\n")
	plan_close()
end

minetest.register_on_shutdown(function()
	local lf = f
	f = nil
	if lf ~= nil then
		lf:close()
	end
end)

minetest.register_lbm{
	label = "Search for blocks",
	name = string.format("ch_test:wanted_blocks_%04d", generation),
	nodenames = wanted_blocks,
	run_at_every_load = false,
	action = on_lbm,
}
