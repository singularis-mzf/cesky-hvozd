ch_base.open_mod(core.get_current_modname())

local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
-- ch_containers = {}
local function divcheck(n)
	assert(n % 16 == 0)
	return n
end

local internal = {
	-- všechny hodnoty velikostí a pozic musejí být dělitelné 16!
	container_width = divcheck(64), -- vnitřní šířka/hloubka kontejneru
	container_height = divcheck(64), -- vnitřní výška kontejneru
	-- *_min udává pozici prvního kontejneru v mřížce:
	x_min = divcheck(-3840),
	y_min = divcheck(3488),
	z_min = divcheck(-3840),
	-- *_scale udává, jak daleko bude každý následující kontejner od předchozího (znaménková hodnota):
	x_scale = divcheck(96),
	y_scale = divcheck(256),
	z_scale = divcheck(96),
	-- *_count udává, kolik kontejnerů se může vytvořit podél každé osy:
	x_count = 80,
	y_count = 2,
	z_count = 80,

	free_queue_length = 20, -- požadovaná délka fronty kontejnerů připravených k použití

	storage = core.get_mod_storage(),
}
assert(0 < internal.x_count and internal.x_count < 4096)
assert(0 < internal.y_count and internal.y_count < 4096)
assert(0 < internal.z_count and internal.z_count < 4096)

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
