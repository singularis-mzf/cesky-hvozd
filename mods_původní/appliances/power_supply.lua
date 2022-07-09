
local S = appliances.translator

appliances.power_supplies = {}

function appliances.add_power_supply(supply_name, power_supply)
  if appliances.all_extensions[supply_name] then
    minetest.log("error", "Another appliances mod extension with name \""..supply_name.."\" is already registered.")
    return ;
  end
  appliances.power_supplies[supply_name] = power_supply;
  appliances.all_extensions[supply_name] = power_supply;
end

-- no power
if true then
  local power_supply =
    {
      is_powered = function (self, power_supply, pos, meta)
          return 0;
        end,
    };
  appliances.add_power_supply("no_power", power_supply)
end

-- time
if true then
  local power_supply =
    {
      hard_help = "time",
      is_powered = function (self, power_supply, pos, meta)
          return power_supply.run_speed;
        end,
    };
  appliances.add_power_supply("time_power", power_supply)
end

-- punch
if true then
  local power_supply =
    {
      hard_help = "punching",
      is_powered = function (self, power_supply, pos, meta)
          local is_powered = meta:get_int("is_powered");
          if (is_powered>0) then
            meta:set_int("is_powered", is_powered-1);
            return power_supply.run_speed;
          end
          return 0;
        end,
      power_need = function (self, power_supply, pos, meta)
          meta:set_int("is_powered", 0);
        end,
      power_idle = function (self, power_supply, pos, meta)
          meta:set_int("is_powered", 0);
        end,
      on_punch = function (self, power_supply, pos, node, puncher, pointed_thing)
          local meta = minetest.get_meta(pos);
          meta:set_int("is_powered", power_supply.punch_power or 1);
          
        end,
    };
  appliances.add_power_supply("punch_power", power_supply)
end

-- mesecons
if appliances.have_mesecons then
  local power_supply =
    {
      hard_help = S("active mese"),
      is_powered = function (self, power_supply, pos, meta)
          local is_powered = meta:get_int("is_powered");
          if (is_powered~=0) then
            return power_supply.run_speed;
          end
          return 0;
        end,
      update_node_def = function (self, power_supply, node_def)
          node_def.effector = {
            action_on = function (pos, node)
              minetest.get_meta(pos):set_int("is_powered", 1);
            end,
            action_off = function (pos, node)
              minetest.get_meta(pos):set_int("is_powered", 0);
            end,
          }
        end,
      after_place_node = function (self, power_supply, pos, meta)
          minetest.get_meta(pos):set_int("is_powered", 0);
        end,
    };
  appliances.add_power_supply("mesecons_power", power_supply)
end

-- technic
if appliances.have_technic then
  -- LV
  local power_supply =
    {
      units = S("LV EU"),
      is_powered = function (self, power_data, pos, meta)
          local eu_input = meta:get_int("LV_EU_input");
          local demand = power_data.demand or power_data.get_demand(self, pos, meta)
          if (eu_input>=demand) then
            return power_data.run_speed;
          end
          return 0;
        end,
      power_need = function (self, power_data, pos, meta)
          local demand = power_data.demand or power_data.get_demand(self, pos, meta)
          meta:set_int("LV_EU_demand", demand)
        end,
      power_idle = function (self, power_data, pos, meta)
          meta:set_int("LV_EU_demand", 0)
        end,
      activate = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      deactivate = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      running = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      waiting = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      no_power = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      update_node_def = function (self, power_data, node_def)
          self.meta_infotext = "technic_info";
          node_def.groups.technic_machine = 1;
          node_def.groups.technic_lv = 1;
          node_def.connect_sides = self.power_connect_sides;
          node_def.technic_run = function (pos, node)
            local meta = minetest.get_meta(pos);
            meta:set_string("infotext", meta:get_string("technic_info"));
          end
          node_def.technic_on_disable = function (pos, node)
            local meta = minetest.get_meta(pos);
            meta:set_string("infotext", meta:get_string("technic_info"));
          end
        end,
      after_register_node = function (self, power_data)
          technic.register_machine("LV", self.node_name_inactive, technic.receiver)
          technic.register_machine("LV", self.node_name_active, technic.receiver)
        end,
      on_construct = function (self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
    };
  appliances.add_power_supply("LV_power", power_supply)
  -- MV
  power_supply =
    {
      units = S("MV EU"),
      is_powered = function (self, power_data, pos, meta)
          local eu_input = meta:get_int("MV_EU_input");
          local demand = power_data.demand or power_data.get_demand(self, pos, meta)
          if (eu_input>=demand) then
            return power_data.run_speed;
          end
          return 0;
        end,
      power_need = function (self, power_data, pos, meta)
          local demand = power_data.demand or power_data.get_demand(self, pos, meta)
          meta:set_int("MV_EU_demand", demand)
        end,
      power_idle = function (self, power_data, pos, meta)
          meta:set_int("MV_EU_demand", 0)
        end,
      activate = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      deactivate = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      running = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      waiting = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      no_power = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      update_node_def = function (self, power_data, node_def)
          self.meta_infotext = "technic_info";
          node_def.groups.technic_machine = 1;
          node_def.groups.technic_mv = 1;
          node_def.connect_sides = self.power_connect_sides;
          node_def.technic_run = function (pos, node)
            local meta = minetest.get_meta(pos);
            meta:set_string("infotext", meta:get_string("technic_info"));
          end
          node_def.technic_on_disable = function (pos, node)
            local meta = minetest.get_meta(pos);
            meta:set_string("infotext", meta:get_string("technic_info"));
          end
        end,
      after_register_node = function (self, power_data)
          technic.register_machine("MV", self.node_name_inactive, technic.receiver)
          technic.register_machine("MV", self.node_name_active, technic.receiver)
        end,
      on_construct = function (self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
    };
  appliances.add_power_supply("MV_power", power_supply)
  -- HV
  power_supply =
    {
      units = S("HV EU"),
      is_powered = function (self, power_data, pos, meta)
          local eu_input = meta:get_int("HV_EU_input");
          local demand = power_data.demand or power_data.get_demand(self, pos, meta)
          if (eu_input>=demand) then
            return power_data.run_speed;
          end
          return 0;
        end,
      power_need = function (self, power_data, pos, meta)
          local demand = power_data.demand or power_data.get_demand(self, pos, meta)
          meta:set_int("HV_EU_demand", demand)
        end,
      power_idle = function (self, power_data, pos, meta)
          meta:set_int("HV_EU_demand", 0)
        end,
      activate = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      deactivate = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      running = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      waiting = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      no_power = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
      update_node_def = function (self, power_data, node_def)
          self.meta_infotext = "technic_info";
          node_def.groups.technic_machine = 1;
          node_def.groups.technic_hv = 1;
          node_def.connect_sides = self.power_connect_sides;
          node_def.technic_run = function (pos, node)
            local meta = minetest.get_meta(pos);
            meta:set_string("infotext", meta:get_string("technic_info"));
          end
          node_def.technic_on_disable = function (pos, node)
            local meta = minetest.get_meta(pos);
            meta:set_string("infotext", meta:get_string("technic_info"));
          end
        end,
      after_register_node = function (self, power_data)
          technic.register_machine("HV", self.node_name_inactive, technic.receiver)
          technic.register_machine("HV", self.node_name_active, technic.receiver)
        end,
      on_construct = function (self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("technic_info"));
        end,
    };
  appliances.add_power_supply("HV_power", power_supply)
end

-- elapower
-- 16 EpU  equvivalent to 200 EU from technic (coal fired generator)
if minetest.get_modpath("elepower_papi") then
  local power_supply =
    {
      units = S("EpU"),
      is_powered = function (self, power_data, pos, meta)
          --local capacity   = ele.helpers.get_node_property(meta, pos, "capacity")
          --local usage   = ele.helpers.get_node_property(meta, pos, "usage")
          local storage   = ele.helpers.get_node_property(meta, pos, "storage")
          local demand = power_data.demand or power_data.get_demand(self, pos, meta)
          if (storage>=demand) then
            return power_data.run_speed;
          end
          return 0;
        end,
      power_need = function (self, power_data, pos, meta)
          local demand = power_data.demand or power_data.get_demand(self, pos, meta)
          meta:set_int("usage", demand)
          
          if not power_data.ele_capacity then
            -- like no real usable storage?
            local storage   = ele.helpers.get_node_property(meta, pos, "storage")
            demand = demand*2
            if storage<demand then
              meta:set_int("capacity", 2*demand)
            else
              meta:set_int("capacity", storage)
            end
          end
        end,
      power_idle = function (self, power_data, pos, meta)
          meta:set_int("usage", 0)
        end,
      no_power = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("infotext").." (Active)");
        end,
      running = function(self, power_data, pos, meta)
          meta:set_string("infotext", meta:get_string("infotext").." (Active)");
          
          local storage   = ele.helpers.get_node_property(meta, pos, "storage")
          local usage   = ele.helpers.get_node_property(meta, pos, "usage")
          
          meta:set_int("storage", math.max(storage-usage, 0))
        end,
      update_node_def = function (self, power_data, node_def)
          node_def.groups.ele_user = 1;
          node_def.groups.ele_machine = 1;
          node_def.ele_active_node = true
          node_def.ele_capacity = power_data.ele_capacity or 128
          node_def.ele_inrush = power_data.ele_inrush or 64
          node_def.ele_usage = power_data.ele_usage or 64
          node_def.ele_output = power_data.ele_output or 0
          --sides is not supported by elapowers at time of writing this
          --node_def.ela_sides = ???
        end,
      on_construct = function (self, power_data, pos, meta)
          meta:set_string("storage", 0);
          ele.clear_networks(pos)
        end,
      after_destruct = function (self, power_data, pos, meta)
          ele.clear_networks(pos)
        end,
    };
  appliances.add_power_supply("elepower_power", power_supply)
end

-- techpack
-- 80 ku equvivalent to 200 EU from technic (coal-fired generator)
--
if minetest.get_modpath("techage") then
  local power = techage.power
  --local Pipe = techage.LiquidPipe
  --local liquid = techage.liquid
  
  local side_to_taside = {
    front = "F",
    back = "B",
    right = "R",
    left = "L",
    bottom = "D",
    top = "U",
  }
  
  local is_running = function(pos)
    local meta = minetest.get_meta(pos)
    local state = meta:get("state") or "idle"
    return state=="running"
  end
  
  --local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end
  --local CRDN = function(node) return (minetest.registered_nodes[node.name] or {}).consumer end
  
  -- TA2
  local power_supply =
    {
      units = S("TA axle"),
      is_powered = function (self, power_data, pos, meta)
          if power.power_available(pos, techage.Axle) then
            return power_data.run_speed;
          end
          return 0
        end,
      power_need = function (self, power_data, pos, meta)
          power.consumer_start(pos, techage.Axle, 1)
        end,
      power_idle = function (self, power_data, pos, meta)
          power.consumer_stop(pos, techage.Axle)
        end,
      update_node_def = function (self, power_data, node_def)
          local network = {
            sides = {},
            ntype = "con1",
            nominal = power_data.demand,
            --on_power = fuction(pos) end,
            --on_nopower = function(pos) end,
            --is_running = function(pos, nvm) return is_running(pos) end,
					}
          for _,side in pairs(self.power_connect_sides) do
            network.sides[side_to_taside[side]] = 1
          end
          
          node_def.networks = node_def.networks or {}
          node_def.networks.axle = network
        end,
      after_register_node = function(self, power_data)
          local node_names = {
              self.node_name_inactive,
              self.node_name_active,
            }
          if self.node_name_waiting then
            table.insert(node_names, self.node_name_waiting)
          end
          techage.Axle:add_secondary_node_names(node_names)
        end,
      after_place_node = function (self, power_data, pos, placer, itemstack, pointed_thing)
          techage.Axle:after_place_node(pos)
        end,
      after_dig_node = function (self, power_data, pos, oldnode, oldmetadata, digger)
          techage.Axle:after_dig_node(pos)
          techage.remove_node(pos, oldnode, oldmetadata)
          techage.del_mem(pos)
        end,
    };
  appliances.add_power_supply("techage_axle_power", power_supply)
  
  -- TA3 (TE4 ?)
  power_supply =
    {
      units = S("ku"),
      is_powered = function (self, power_data, pos, meta)
          if power.power_available(pos, techage.ElectricCable) then
            return power_data.run_speed;
          end
          return 0
        end,
      power_need = function (self, power_data, pos, meta)
          power.consumer_start(pos, techage.ElectricCable, 1)
        end,
      power_idle = function (self, power_data, pos, meta)
          power.consumer_stop(pos, techage.ElectricCable)
        end,
      update_node_def = function (self, power_data, node_def)
          local network = {
            sides = {},
            ntype = "con1",
            nominal = power_data.demand,
            --on_power = fuction(pos) end,
            --on_nopower = function(pos) end,
            is_running = function(pos, nvm) return is_running(pos) end,
					}
          for _,side in pairs(self.power_connect_sides) do
            network.sides[side_to_taside[side]] = 1
          end
          
          node_def.networks = node_def.networks or {}
          node_def.networks.ele1 = network
        end,
      after_register_node = function(self, power_data)
          local node_names = {
              self.node_name_inactive,
              self.node_name_active,
            }
          if self.node_name_waiting then
            table.insert(node_names, self.node_name_waiting)
          end
          techage.ElectricCable:add_secondary_node_names(node_names)
        end,
      after_place_node = function (self, power_data, pos, placer, itemstack, pointed_thing)
          techage.ElectricCable:after_place_node(pos)
        end,
      after_dig_node = function (self, power_data, pos, oldnode, oldmetadata, digger)
          techage.ElectricCable:after_dig_node(pos)
          techage.remove_node(pos, oldnode, oldmetadata)
          techage.del_mem(pos)
        end,
    };
  appliances.add_power_supply("techage_electric_power", power_supply)
end

-- factory
-- 16 EU  equvivalent to 200 EU from technic (coal fired generator)
if minetest.get_modpath("factory") then
  
  local function on_push_electricity(pos, energy)
    local meta = minetest.get_meta(pos)
    local stored = meta:get_int("factory_energy")
    local capacity = meta:get_int("factory_max_charge")
    meta:set_int("factory_energy", math.min(stored + energy, capacity))
    return math.max(energy - (capacity - stored), 0)
  end
  
  local power_supply =
    {
      units = S("Factory EU"),
      is_powered = function (self, power_data, pos, meta)
          local stored = meta:get_int("factory_energy")
          
          local demand = power_data.demand or power_data.get_demand(self, pos, meta)
          if (stored>=demand) then
            meta:set_int("factory_usage", demand)
            return power_data.run_speed;
          end
          return 0;
        end,
      power_idle = function (self, power_data, pos, meta)
          meta:set_int("factory_usage", 0)
        end,
      running = function(self, power_data, pos, meta)
          local stored   = meta:get_int("factory_energy")
          local usage   = meta:get_int("factory_usage")
          
          meta:set_int("factory_energy", stored-usage)
        end,
      update_node_def = function (self, power_data, node_def)
          node_def.groups.factory_electronic = 1;
          --sides is not supported by factory at time of writing this
          --node_def.ela_sides = ???
          node_def.on_push_electricity = on_push_electricity;
        end,
      on_construct = function (self, power_data, pos, meta)
          meta:set_string("factory_energy", 0);
          meta:set_string("factory_max_charge", power_data.dev_capacity or 20);
        end,
    };
  appliances.add_power_supply("factory_power", power_supply)
end

