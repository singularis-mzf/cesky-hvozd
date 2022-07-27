
local wrench_debug = 0

-- Hack to compute pitch based on eye position instead of feet position
local eye_offset_hack = 1.7

-- Number of uses of a steel wench. The actual number may be slightly
-- lower, depending on how well this number divides 65535
local wrench_uses_steel = 450

-- List of predefined wrench materials to register.
-- To disable, prefix with '--'. E.g.:
--	--wood = true,
-- To register the wrench, but not the recipe, set the value to false. E.g.:
--	steel = false,
-- To register the wrench, and the recipe, set the value to true. E.g.:
--	steel = true,
local default_wrenches = {
	--wood = true,	-- disabled
	steel = true,
	copper = true,
	gold = true,
	}

local mod_name = "rotate"

local privilege_name
-- Privilege associated with the wrench.
-- privilege checking is disabled if set to nil (or false)
--privilege_name = "twist"

-- Choose recipe.
-- Options:
-- 	"beak_north"		-- may conflict with another wrench (technic ?)
--	"beak_northwest"
--	"beak_west"
--	"beak_southwest"
--	"beak_south"
local craft_recipe = "beak_west"
-- Register a second, alternate recipe
local alt_recipe = false

-- How to incidate the orientation of the positioning wrenches.
-- "axis_rot": uses the 'axismode' and 'rotmode' images
-- "cube": use an exploded cube with different colors
-- "linear": use images 'wrench_mode_<mode>.png'. E.g.: wrench_mode_s53.png
--	(Note: such images do not exist yet...)
local wrench_orientation_indicator = "cube"

----------------------------------------
----- END OF CONFIGURATION SECTION -----
----------------------------------------

local mod_name_upper=string.upper(mod_name)

-- Global entry point - for other mods that wish to define custom wrenches,
-- or custom crafting recipes
if rawget(_G,mod_name) ~= nil then
	error(string.format("[%s] cannot register global name '%s' - name already exists", mod_name_upper, mod_name))
end
_G[mod_name] = {}
local module = _G[mod_name]

module.debug = wrench_debug
module.api_config = {
	eye_offset_hack = eye_offset_hack,
	craft_recipe = craft_recipe,
	alt_recipe = alt_recipe,
	wrench_orientation_indicator = wrench_orientation_indicator,
	wrench_uses_steel = wrench_uses_steel,
	privilege_name = privilege_name,
	}
module.wrenches_config = {
	default_wrenches = default_wrenches,
	}


local modpath = minetest.get_modpath(mod_name)
dofile(modpath .. "/wrench_api.lua")
dofile(modpath .. "/register_default.lua")

-- make private stuff inaccessible
_G[mod_name] = module.api

return module.api

