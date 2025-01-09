ch_base.open_mod(core.get_current_modname())

local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
-- ch_containers = {}
local internal = {
	container_width = 64, -- vnitřní šířka/hloubka kontejneru (měla by být dělitelná 16)
	container_height = 64, -- vnitřní výška kontejneru (měla by být dělitelná 16)
	-- *_min udává pozici prvního kontejneru v mřížce:
	x_min = -3840,
	y_min = 3488,
	z_min = -3840,
	-- *_scale udává, jak daleko bude každý následující kontejner od předchozího:
	x_scale = 96,
	y_scale = 256,
	z_scale = 96,
	-- *_count udává, kolik kontejnerů se může vytvořit podél každé osy:
	x_count = 80,
	y_count = 2,
	z_count = 80,

	free_queue_length = 20, -- požadovaná délka fronty kontejnerů připravených k použití

	storage = core.get_mod_storage(),
}

local function mydofile(filename)
	local f = loadfile(modpath.."/"..filename)
	if f == nil then
		error("Cannot load: "..modpath.."/"..filename.."!")
	end
	return f(internal)
end

mydofile("formspec.lua")
mydofile("functions.lua")
mydofile("nodes.lua")
-- mydofile("digger.lua")

ch_base.close_mod(core.get_current_modname())
