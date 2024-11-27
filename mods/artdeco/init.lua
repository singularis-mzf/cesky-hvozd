ch_base.open_mod(minetest.get_current_modname())
artdeco = {}
local modname = minetest.get_current_modname()
artdeco.modname = modname
artdeco.modpath = minetest.get_modpath(modname)

function artdeco.log(level, message, ...)
	minetest.log(level, ('[%s] %s'):format(modname, message:format(...)))
end

dofile(artdeco.modpath .. '/nodes.lua')
dofile(artdeco.modpath .. '/moreblocks.lua')
dofile(artdeco.modpath .. '/facade.lua')
dofile(artdeco.modpath .. '/nodeboxes.lua')
dofile(artdeco.modpath .. '/doors.lua')
dofile(artdeco.modpath .. '/recipes.lua')
ch_base.close_mod(minetest.get_current_modname())
