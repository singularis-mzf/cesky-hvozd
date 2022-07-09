

appliances.general_supplies = {}

function appliances.add_supply(supply_name, general_supply)
  if appliances.all_extensions[supply_name] then
    minetest.log("error", "Another appliances mod extension with name \""..supply_name.."\" is already registered.")
    return ;
  end
  appliances.general_supplies[supply_name] = general_supply;
  appliances.all_extensions[supply_name] = general_supply;
end

if true then
  local no_supply = {
      have_supply = function(self, supply_data, pos, meta)
        return 0
      end,
    }
  appliances.add_supply("no_supply", no_supply)
end

-- pipeworks
if appliances.have_pipeworks then
  local pipeworks_pipe_loaded = {
        ["pipeworks:pipe_1_loaded"] = true,
        ["pipeworks:pipe_2_loaded"] = true,
        ["pipeworks:pipe_3_loaded"] = true,
        ["pipeworks:pipe_4_loaded"] = true,
        ["pipeworks:pipe_5_loaded"] = true,
        ["pipeworks:pipe_6_loaded"] = true,
        ["pipeworks:pipe_7_loaded"] = true,
        ["pipeworks:pipe_8_loaded"] = true,
        ["pipeworks:pipe_9_loaded"] = true,
        ["pipeworks:pipe_10_loaded"] = true,
      };
  local pipeworks_pipe_with_facedir_loaded = {
        ["pipeworks:valve_on_loaded"] = true,
        ["pipeworks:entry_panel_loaded"] = true,
        ["pipeworks:flow_sensor_loaded"] = true,
        ["pipeworks:straight_pipe_loaded"] = true,
      };
  local pipe_connections = {
    left = {
      left = true,
      right = true,
      front = true,
      back = true,
      left_param2 = 2,
      right_param2 = 0,
      front_param2 = 1,
      back_param2 = 3,
    },
    right = {
      left = true,
      right = true,
      front = true,
      back = true,
      left_param2 = 0,
      right_param2 = 2,
      front_param2 = 3,
      back_param2 = 1,
    },
    front = {
      left = true,
      right = true,
      front = true,
      back = true,
      left_param2 = 1,
      right_param2 = 3,
      front_param2 = 0,
      back_param2 = 2,
    },
    back = {
      left = true,
      right = true,
      front = true,
      back = true,
      left_param2 = 3,
      right_param2 = 1,
      front_param2 = 2,
      back_param2 = 0,
    },
  }

  local liquid_supply =
    {
      -- have_supply function
      have_supply = function(self, liquid_data, pos, meta)
          for _,side in pairs(self.supply_connect_sides) do
            local side_pos = appliances.get_side_pos(pos, nil, side);
            local node = minetest.get_node(side_pos);
            if (pipeworks_pipe_loaded[node.name]) then
              return 1;
            end
            if (pipeworks_pipe_with_facedir_loaded[node.name]) then
              local facedir = minetest.facedir_to_dir(node.param2%32);
              local diff = vector.subtract(pos, side_pos);
              if (   ((facedir.x~=0) and (diff.x~=0))
                  or ((facedir.y~=0) and (diff.y~=0))
                  or ((facedir.z~=0) and (diff.z~=0))) then
                return 1;
              end
            end
          end
          return 0;
        end,
      update_node_def = function(self, liquid_data, node_def)
          node_def.pipe_connections = {};
          for _,pipe_side in pairs(self.supply_connect_sides) do
            node_def.pipe_connections[pipe_side] = true;
            if pipe_connections[pipe_side] then
              for key,value in pairs(pipe_connections[pipe_side]) do
                node_def.pipe_connections[key] = value;
              end
            end
          end
        end,
      after_place_node = function(self, liquid_data, pos)
          pipeworks.scan_for_pipe_objects(pos);
        end,
      after_dig_node = function(self, liquid_data, pos)
          pipeworks.scan_for_pipe_objects(pos);
        end,
    };
  appliances.add_supply("water_pipe_liquid", liquid_supply)
end

