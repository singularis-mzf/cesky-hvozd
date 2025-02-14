ch_base.open_mod(minetest.get_current_modname())
local profiler_start, profiler_stop
do
	local ie = minetest.request_insecure_environment()
	if not ie then
		error("To use jitprofiler, add it to secure.trusted_mods")
	end
	local profile = ie.require("jit.profile")
	local start, stop, dumpstack =
		profile.start, profile.stop, profile.dumpstack
	local tonumber = ie.tonumber
	function profiler_start(period, outfile)
		local function record(thread, samples, vmstate)
			outfile:write(dumpstack(thread, "pF;", -100), vmstate,
				" ", samples, "\n")
		end
		start("vfi" .. tonumber(period), record)
	end
	function profiler_stop()
		stop()
	end
end

local profiledir = minetest.get_worldpath() .. "/jitprofiles"
assert(minetest.mkdir(profiledir),
	"Could not create profile directory " .. profiledir)

local outfile

local function jitprofiler_start(_name, param)
	if outfile then
		return false, "Profiler already running"
	end

	local period, filename = param:match("^(%d*)%s+(.*)$")
	period = tonumber(period)
	if not period or not filename then
		return false
	end

	local path = profiledir .. "/" .. filename
	local err
	outfile, err = io.open(path, "w")
	if not outfile then
		return false, "Could not output file: " .. err
	end

	profiler_start(period, outfile)
	return true, "Profiler started and writing data to " .. path
end

minetest.register_chatcommand("jitprofiler_start", {
	description = "Start LuaJIT's profiler",
	params = "<period> <filename>",
	privs = {server = true},
	func = jitprofiler_start,
})

minetest.register_chatcommand("jitprofiler_stop", {
	description = "Stop LuaJIT's profiler",
	privs = {server = true},
	func = function()
		if not outfile then
			return false, "Profiler not running"
		end

		profiler_stop()
		outfile:close()
		outfile = nil
		return true, "Profiler stopped"
	end,
})

minetest.register_chatcommand("jps", {
	description = "Start LuaJIT's profiler with the default settings",
	privs = {server = true},
	func = function(_name, param)
		return jitprofiler_start(_name, "1 p")
	end,
})
ch_base.close_mod(minetest.get_current_modname())
