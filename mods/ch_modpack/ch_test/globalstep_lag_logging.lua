local get_us_time = minetest.get_us_time
local dtime_acc = 0
local dtimes = {}
local last_us_time = get_us_time()
local ustimes = {}
local counter = 0
local dtime_max, ustime_max = 0, 0

local function gllstep(dtime)
	local new_us_time = get_us_time()
	local ustime = (new_us_time - last_us_time) / 1000000.0
	counter = counter + 1
	table.insert(dtimes, string.format("%.3f", dtime))
	table.insert(ustimes, string.format("%.3f", ustime))
	last_us_time = new_us_time
	dtime_acc = dtime_acc + dtime
	if dtime_acc > 1 or dtime > 1 or ustime > 1 then
		dtime_acc = dtime_acc % 1
		if #dtimes < 10 and #ustimes < 10 then
			minetest.log("action", "[glstep_ll] C = "..counter.."; dtimes: "..table.concat(dtimes, ";").." ["..#dtimes.."], ustimes: "..table.concat(ustimes, ";").." ["..#ustimes.."]")
		end
		dtimes = {}
		ustimes = {}
	end
	if counter ~= 1000 then
		if dtime > dtime_max then
			if counter > 1 then
				minetest.log("action", "[glstep_ll] C = "..counter..": dtime_max increased: "..dtime_max.." => "..dtime)
			end
			dtime_max = dtime
		end
		if ustime > ustime_max then
			if counter > 1 then
				minetest.log("action", "[glstep_ll] C = "..counter..": ustime_max increased: "..ustime_max.." => "..ustime)
			end
			ustime_max = ustime
		end
	else
		dtime_max = dtime
		ustime_max = ustime
		minetest.log("action", "[glstep_ll] C = "..counter..": dtime_max and ustime_max reset")
	end
end

minetest.register_globalstep(gllstep)
