
local mod_name = "rotate"

local mod_name_upper=string.upper(mod_name)

if _G[mod_name] == nil then
	error(string.format("[%s] global data not found - is the mod name correct ??", mod_name_upper))
end
local module = _G[mod_name]


local wrench_materials = {
	-- Wooden wrench is an extra - for players who have not mined metals yet
	-- Its low usage count is intentional: it is dirt-cheap, and they shouldn't
	-- be needed anyway.
	wood = {
		description = "Wooden",
		ingredient = "group:stick",
		use_parameter = 10,			-- integral, so interpreted as absolute number
		},
	steel = {
		description = "Steel",
		ingredient = "default:steel_ingot",
		use_parameter = 1.01,			-- Must not be integral to be interpreted as a factor
		},
	copper = {
		description = "Copper",
		ingredient = "default:copper_ingot",
		use_parameter = 1.55,
		},
	gold = {
		description = "Gold",
		ingredient = "default:gold_ingot",
		use_parameter = 2.1,
		},
	}

local function register_all_wrenches()
	local material, register_recipe
	for material, register_recipe in pairs(module.wrenches_config.default_wrenches) do
		if wrench_materials[material] == nil then
			error(string.format("[%s] default_wrenches: material '%s' is not predefined",mod_name_upper, tostring(material)))
		end
		if register_recipe == false then
			wrench_materials[material].ingredient = nil
		end
		wrench_materials[material].material = material
		wrench_materials[material].mod_name = mod_name
		module.api.register_wrench(wrench_materials[material])
	end
end

--
-- Setup / initialize default wrenches mod
--
register_all_wrenches()

