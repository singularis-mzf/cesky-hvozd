ch_base.open_mod(minetest.get_current_modname())

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
ch_containers = {}
local internal = {
	default_width = 8,
	default_height = 4,
	base = vector.new(-3840, 3744, -3840),
	offset = vector.new(96, -256, 96),
	limit = vector.new(80, 2, 80),
	storage = minetest.get_mod_storage(),
}

local function mydofile(filename)
	local f = loadfile(modpath.."/"..filename)
	if f == nil then
		error("Cannot load: "..modpath.."/"..filename.."!")
	end
	return f(internal)
end

mydofile("nodes.lua")
mydofile("formspec.lua")
mydofile("functions.lua")

ch_base.close_mod(minetest.get_current_modname())
