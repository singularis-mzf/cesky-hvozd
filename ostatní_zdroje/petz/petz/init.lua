--
-- petz
-- License:GPLv3
--

local modname = "petz"
local modpath = minetest.get_modpath(modname)

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

--
--The Petz
--

petz = {}

--
--Settings
--
petz.settings = {}
petz.settings.mesh = nil
petz.settings.visual_size = {}
petz.settings.rotate = 0

assert(loadfile(modpath .. "/settings.lua"))(modpath) --Load the settings

petz.tamed_by_owner = {} --a list of tamed petz with owner

assert(loadfile(modpath .. "/api/api.lua"))(modpath, S)
assert(loadfile(modpath .. "/brains/brains.lua"))(modpath)
assert(loadfile(modpath .. "/misc/misc.lua"))(modpath, S)
assert(loadfile(modpath .. "/server/cron.lua"))(modname)

petz.file_exists = function(name)
   local f = io.open(name,"r")
   if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

if petz.settings["remove_list"] then
	for i = 1, #petz.settings["remove_list"] do
		local file_name = modpath .. "/petz/"..petz.settings["remove_list"][i].."_kitz"..".lua"
		if petz.file_exists(file_name) then
			assert(loadfile(file_name))(S)
		end
		--Override the petz_list
		for j = 1, #petz.settings["petz_list"] do --load all the petz.lua files
			if petz.settings["remove_list"][i] == petz.settings["petz_list"][j] then
				table.remove(petz.settings["petz_list"], j)
				--kitz.remove_table_by_key(petz.settings["petz_list"], j)
			end
		end
	end
end

for i = 1, #petz.settings["petz_list"] do --load all the petz.lua files
	local file_name = modpath .. "/petz/"..petz.settings["petz_list"][i].."_mobkit"..".lua"
	if petz.file_exists(file_name) then
		assert(loadfile(file_name))(S)
	end
end
