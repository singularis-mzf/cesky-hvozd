
appliances.battery_supplies = {}

function appliances.add_battery_supply(supply_name, battery_supply)
  if appliances.all_extensions[supply_name] then
    minetest.log("error", "Another appliances mod extension with name \""..supply_name.."\" is already registered.")
    return ;
  end
  appliances.battery_supplies[supply_name] = battery_supply;
  appliances.all_extensions[supply_name] = battery_supply;
end

-- no battery
if true then
  local battery_supply =
    {
    };
  appliances.add_battery_supply("no_battery", battery_supply)
end

-- technic
if appliances.have_technic then
  local battery_supply =
    {
      update_tool_def = function (self, battery_supply, tool_def)
	        tool_def.wear_represents = "technic_RE_charge"
          tool_def.technic_get_charge = function(itemstack)
              local meta = itemstack:get_meta()
              return self:get_energy(itemstack, meta), self.max_stored_energy
            end
          tool_def.technic_set_charge = function(itemstack, charge)
              local meta = itemstack:get_meta()
              self:set_energy(itemstack, meta, charge)
              self:update_wear(itemstack, meta)
            end
          technic.power_tools[self.tool_name] = self.max_stored_energy
        end,
    };
  appliances.add_battery_supply("technic_battery", battery_supply)
end
