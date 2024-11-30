--[[
local get_objects_in_area = minetest.get_objects_in_area
minetest.get_objects_in_area = function(...)
	local stopwatch_start = minetest.get_us_time()
	local results = {get_objects_in_area(...)}
	local stopwatch_stop = minetest.get_us_time()
	print(("DEBUG: get_objects_in_area() in %f s\n::%s"):format((stopwatch_stop - stopwatch_start) / 1000000, debug.traceback()))
	return unpack(results)
end
]]

local get_objects_inside_radius = minetest.get_objects_inside_radius
local acc_elapsed = 0
local calls = 0

minetest.get_objects_inside_radius = function(...)
    local old_acc_elapsed = acc_elapsed
	local stopwatch_start = minetest.get_us_time()
	local results = {get_objects_inside_radius(...)}
	local stopwatch_stop = minetest.get_us_time()
    local elapsed = (stopwatch_stop - stopwatch_start) / 1000000
    acc_elapsed = acc_elapsed + elapsed
    calls = calls + 1
    if math.floor(old_acc_elapsed) ~= math.floor(acc_elapsed) then
        minetest.log("warning", "get_objects_inside_radius(): "..math.floor(acc_elapsed).." seconds reached ("..calls.." calls).")
    end
	-- print("\n\n"..debug.traceback())
	return unpack(results)
end
