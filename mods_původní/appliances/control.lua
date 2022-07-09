
appliances.controls = {}

function appliances.add_control(control_name, control_def)
  if appliances.all_extensions[control_name] then
    minetest.log("error", "Another appliances mod extension with name \""..control_name.."\" is already registered.")
    return ;
  end
  appliances.controls[control_name] = control_def;
  appliances.all_extensions[control_name] = control_def;
end

-- template
if true then
  local control =
    {
      control_wait = function (self, control, pos, meta)
          if control.control_wait then
            return control.control_wait(self, control, pos, meta)
          end
          return false;
        end,
      activate = function (self, control, pos, meta)
          if control.activate then
            control.activate(self, control, pos, meta)
          end
        end,
      deactivate = function (self, control, pos, meta)
          if control.deactivate then
            control.deactivate(self, control, pos, meta)
          end
        end,
      running = function (self, control, pos, meta)
          if control.running then
            control.running(self, control, pos, meta)
          end
        end,
      waiting = function (self, control, pos, meta)
          if control.waiting then
            control.waiting(self, control, pos, meta)
          end
        end,
      no_power = function (self, control, pos, meta)
          if control.no_power then
            control.no_power(self, control, pos, meta)
          end
        end,
      on_production = function (self, control, timer_step)
          if control.on_production then
            control.on_production(self, control, timer_step)
          end
        end,
      update_node_def = function (self, control, node_def)
          if control.update_node_def then
            control.update_node_def(self, control, node_def)
          end
        end,
      update_node_inactive_def = function (self, control, node_def)
          if control.update_node_inactive_def then
            control.update_node_inactive_def(self, control, node_def)
          end
        end,
      update_node_active_def = function (self, control, node_def)
          if control.update_node_active_def then
            control.update_node_active_def(self, control, node_def)
          end
        end,
      update_node_waiting_def = function (self, control, node_def)
          if control.update_node_waiting_def then
            control.update_node_waiting_def(self, control, node_def)
          end
        end,
      after_register_node = function (self, control)
          if control.after_register_node then
            control.after_register_node(self, control)
          end
        end,
      on_destruct = function (self, control, pos, meta)
          if control.on_destruct then
            control.on_destruct(self, control, pos, meta)
          end
        end,
      after_destruct = function (self, control, pos, oldnode)
          if control.after_destruct then
            control.after_destruct(self, control, pos, oldnode)
          end
        end,
      after_place_node = function (self, control, pos, placer, itemstack, pointed_thing)
          if control.after_place_node then
            control.after_place_node(self, control, pos, placer, itemstack, pointed_thing)
          end
        end,
      after_dig_node = function (self, control, pos, oldnode, oldmetadata, digger)
          if control.after_dig_node then
            control.after_dig_node(self, control, pos, oldnode, oldmetadata, digger)
          end
        end,
      can_dig = function (self, control, pos, player)
          if control.can_dig then
            return control.can_dig(self, control, pos, player)
          end
          return true
        end,
      on_punch = function (self, control, pos, node, puncher, pointed_thing)
          if control.on_punch then
            control.on_punch(self, control, pos, node, puncher, pointed_thing)
          end
        end,
      on_blast = function (self, control, pos, intensity)
          if control.on_blast then
            control.on_blast(self, control, pos, intensity)
          end
        end,
    };
  appliances.add_control("template_control", control);
end

-- punch
if true then
  local control =
    {
      control_wait = function (self, control, pos, meta)
          local state = meta:get_int("punch_control");
          if (state~=0) then
            return false;
          end
          return true;
        end,
      deactivate = function (self, control, pos, meta)
          if control.power_off_on_deactivate then
            meta:set_int("punch_control", 0);
          end
        end,
      after_place_node = function (self, control, pos, meta)
          minetest.get_meta(pos):set_int("punch_control", 0);
        end,
      on_punch = function (self, control, pos, node, puncher, pointed_thing)
          local meta = minetest.get_meta(pos);
          local state = meta:get_int("punch_control");
          if (state~=0) then
            meta:set_int("punch_control", 0);
          else
            meta:set_int("punch_control", 1);
            self:activate(pos, meta);
          end
        end,
    };
  appliances.add_control("punch_control", control);
end

-- mesecons
if appliances.have_mesecons then
  local control =
    {
      control_wait = function (self, control, pos, meta)
          local state = meta:get_int("mesecons_control");
          if (state~=0) then
            return false;
          end
          return true;
        end,
      deactivate = function (self, control, pos, meta)
          if control.power_off_on_deactivate then
            meta:set_int("mesecons_control", 0);
          end
        end,
      update_node_def = function (self, control, node_def)
          node_def.effector = {
            action_on = function (pos, node)
              minetest.get_meta(pos):set_int("mesecons_control", 1);
              self:activate(pos, minetest.get_meta(pos));
            end,
            action_off = function (pos, node)
              minetest.get_meta(pos):set_int("mesecons_control", 0);
            end,
          }
        end,
      after_place_node = function (self, control, pos, meta)
          minetest.get_meta(pos):set_int("mesecons_control", 0);
        end,
      
    };
  appliances.add_control("mesecons_control", control);
end

-- digilines
if appliances.have_digilines then
  local control =
    {
      control_wait = function (self, control, pos, meta)
          local state = meta:get_float("digilines_control");
          if (state~=0) then
            return false;
          end
          return true;
        end,
      deactivate = function (self, control, pos, meta)
          if control.power_off_on_deactivate then
            meta:set_float("digilines_control", 0);
          end
        end,
      update_node_def = function (self, control, node_def)
          node_def.digilines = {
            receptor = {},
            effector = {
              action = function (pos, _, channel, msg)
                minetest.get_meta(pos):set_float("digilines_control", 0);
              end,
            },
          }
        end,
      after_place_node = function (self, control, pos, meta)
          minetest.get_meta(pos):set_int("digilines_control", 0);
        end,
      
    };
  appliances.add_control("digilines_control", control);
end

