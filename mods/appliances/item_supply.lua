

appliances.item_supplies = {}

function appliances.add_item_supply(supply_name, item_supply)
  if appliances.all_extensions[supply_name] then
    minetest.log("error", "Another appliances mod extension with name \""..supply_name.."\" is already registered.")
    return ;
  end
  appliances.item_supplies[supply_name] = item_supply;
  appliances.all_extensions[supply_name] = item_supply;
end

-- pipeworks
if appliances.have_pipeworks then
  -- tube can insert
  local appliance = appliances.appliance
  function appliance:tube_can_insert (pos, node, stack, direction, owner)
    if minetest.is_protected(pos, owner or "") then
      return false
    end
    if self.recipes then
      if self.have_input then
        if (self.input_stack_size <= 1) then
          local can_insert = self:recipe_inventory_can_put(pos, self.input_stack, 1, stack, owner);
          if (can_insert~=0) then
            return can_insert;
          end
        else
          for index = 1,self.input_stack_size do
            local can_insert = self:recipe_inventory_can_put(pos, self.input_stack, index, stack, owner);
            if (can_insert~=0) then
              return can_insert;
            end
          end
        end
      end
      if self.have_usage then
        return self:recipe_inventory_can_put(pos, self.use_stack, 1, stack, owner);
      end
    end
    return false;
  end
  function appliance:tube_insert (pos, node, stack, direction, owner)
    if minetest.is_protected(pos, owner or "") then
      return stack
    end
    if self.recipes then
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory();
      
      if self.have_input then
        if (self.input_stack_size <= 1) then
          local can_insert = self:recipe_inventory_can_put(pos, self.input_stack, 1, stack, owner);
          if can_insert~=0 then
            return inv:add_item(self.input_stack, stack);
          end
        else
          for index = 1,self.input_stack_size do
            local can_insert = self:recipe_inventory_can_put(pos, self.input_stack, index, stack, owner);
            if (can_insert~=0) then
              local input_stack = inv:get_stack(self.input_stack,index);
              local remind = input_stack:add_item(stack);
              inv:set_stack(self.input_stack,index, input_stack);
              return remind;
            end
          end
        end
      end
      if self.have_usage then
        local can_insert = self:recipe_inventory_can_put(pos, self.use_stack, 1, stack, nil);
        if can_insert~=0 then
          return inv:add_item(self.use_stack, stack);
        end
      end
    end
    
    minetest.log("error", "Unexpected call of tube_insert function. Stack "..stack:to_string().." cannot be added to inventory.")
    
    return stack;
  end
  -- appliance node callbacks for pipeworks
  function appliance:cb_tube_insert_object(pos, node, stack, direction, owner)
    stack = self:tube_insert(pos, node, stack, direction, owner);
    
    local meta = minetest.get_meta(pos);
    local inv = meta:get_inventory();
    local use_input, _ = self:recipe_aviable_input(inv)
    if use_input then
      self:activate(pos, meta);
    end
    
    return stack;
  end
  function appliance:cb_tube_can_insert(pos, node, stack, direction, owner)
    return self:tube_can_insert(pos, node, stack, direction, owner);
  end
  local item_supply =
    {
      update_node_def = function (self, supply_data, node_def)
          node_def.groups.tubedevice = 1;
          node_def.groups.tubedevice_receiver = 1;
          node_def.tube =
            {
              insert_object = function(pos, node, stack, direction, owner)
                return self:cb_tube_insert_object(pos, node, stack, direction, owner);
                end,
              can_insert = function(pos, node, stack, direction, owner)
                  return self:cb_tube_can_insert(pos, node, stack, direction, owner);
                end,
              connect_sides = {},
              input_inventory = self.output_stack,
            };
          for _,side in pairs(self.items_connect_sides)do
            node_def.tube.connect_sides[side] = 1
          end
        end,
      after_dig_node = function(self, liquid_data, pos)
          pipeworks.scan_for_tube_objects(pos);
        end,
      after_place_node = function(self, liquid_data, pos)
          pipeworks.scan_for_tube_objects(pos);
        end,
    };
  appliances.add_item_supply("tube_item", item_supply)
end

-- techpack
if minetest.get_modpath("techage") then
  local appliance = appliances.appliance
  function appliance:on_push_item(pos, in_dir, stack)
    if self.recipes then
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory();
      local num = stack:get_count()
      
      if self.have_input then
        if (self.input_stack_size <= 1) then
          local can_insert = self:recipe_inventory_can_put(pos, self.input_stack, 1, stack, nil);
          if can_insert>=num then
            inv:add_item(self.input_stack, stack);
            return true
          end
        else
          for index = 1,self.input_stack_size do
            local can_insert = self:recipe_inventory_can_put(pos, self.input_stack, index, stack, nil);
            if (can_insert>=num) then
              local input_stack = inv:get_stack(self.input_stack,index);
              local remind = input_stack:add_item(stack);
              if remind:getcount()==0 then
                inv:set_stack(self.input_stack,index, input_stack);
                return true;
              end
            end
          end
        end
      end
      if self.have_usage then
        local can_insert = self:recipe_inventory_can_put(pos, self.use_stack, 1, stack, nil);
        if can_insert>=num then
          inv:add_item(self.use_stack, stack);
          return true
        end
      end
    end
    
    return false;
  end
  function appliance:on_pull_item(pos, in_dir, num)
    if self.output_stack_size>0 then
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory();
      
      for n=1,self.output_stack_size do
        local stack = inv:get_stack(self.output_stack, n)
        if stack:get_count()>0 then
          local pull = stack:take_item(num)
          if pull:get_count()>0 then
            inv:set_stack(self.output_stack, n, stack)
            return pull
          end
        end
      end
    end
    return nil
  end
  function appliance:on_unpull_item(pos, in_dir, stack)
    if self.output_stack_size>0 then
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory();
      
      local leftover = inv:add_item(self.output_stack, stack)
      if leftover:get_count()>0 then
        minetest.add_item(pos, leftover)
      end
      return true
    end
    return false
  end
  function appliance:cb_on_push_item(pos, in_dir, stack)
    return self:on_push_item(pos, in_dir, stack)
  end
  function appliance:cb_on_pull_item(pos, in_dir, num)
    return self:on_pull_item(pos, in_dir, num)
  end
  function appliance:cb_on_unpull_item(pos, in_dir, stack)
    return self:on_unpull_item(pos, in_dir, stack)
  end
  local item_supply =
    {
      after_register_node = function(self, supply_data)
          local node_names = {
              self.node_name_inactive,
              self.node_name_active,
            }
          if self.node_name_waiting then
            table.insert(node_names, self.node_name_waiting)
          end
          print("register to techage: "..dump(node_names))
          techage.register_node(node_names, {
              on_push_item = function(pos, in_dir, stack)
                self:cb_on_push_item(pos, in_dir, stack)
              end,
              on_pull_item = function(pos, in_dir, num)
                self:cb_on_pull_item(pos, in_dir, num)
              end,
              on_unpull_item = function(pos, in_dir, stack)
                self:cb_on_unpull_item(pos, in_dir, stack)
              end,
            })
        end,
    };
  appliances.add_item_supply("techage_item", item_supply)
end

-- minecart
if minetest.get_modpath("minecart") then
  local appliance = appliances.appliance
  function appliance:minecart_hopper_additem(pos, stack)
    if self.recipes then
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory();
      
      if self.have_input then
        if (self.input_stack_size <= 1) then
          local can_insert = self:recipe_inventory_can_put(pos, self.input_stack, 1, stack, nil);
          if can_insert>=0 then
            return inv:add_item(self.input_stack, stack);
          end
        else
          for index = 1,self.input_stack_size do
            local can_insert = self:recipe_inventory_can_put(pos, self.input_stack, index, stack, nil);
            if (can_insert>=0) then
              local input_stack = inv:get_stack(self.input_stack,index);
              local remind = input_stack:add_item(stack);
              inv:set_stack(self.input_stack,index, input_stack);
              return remind
            end
          end
        end
      end
      if self.have_usage then
        local can_insert = self:recipe_inventory_can_put(pos, self.use_stack, 1, stack, nil);
        if can_insert>0 then
          return inv:add_item(self.use_stack, stack);
        end
      end
    end
    
    return stack;
  end
  function appliance:minecart_hopper_takeitem(pos, num)
    if self.output_stack_size>0 then
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory();
      
      for n=1,self.output_stack_size do
        local stack = inv:get_stack(self.output_stack, n)
        if stack:get_count()>0 then
          local pull = stack:take_item(num)
          if pull:get_count()>0 then
            inv:set_stack(self.output_stack, n, stack)
            return pull
          end
        end
      end
    end
    return nil
  end
  function appliance:minecart_hopper_untakeitem(pos, stack)
    if self.output_stack_size>0 then
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory();
      
      local leftover = inv:add_item(self.output_stack, stack)
      return leftover
    end
    return nil
  end
  function appliance:cb_on_additem(pos, stack)
    return self:minecart_hopper_additem(pos, stack)
  end
  function appliance:cb_on_takeitem(pos, num)
    return self:minecart_hopper_takeitem(pos, num)
  end
  function appliance:cb_on_untakeitem(pos, stack)
    return self:minecart_hopper_untakeitem(pos, stack)
  end
  local item_supply =
    {
      update_node_def = function (self, supply_data, node_def)
          node_def.minecart_hopper_additem = function(pos, stack)
              self:cb_minecart_hopper_additem(pos, stack)
            end
          node_def.minecart_hopper_pull_item = function(pos, num)
              self:cb_minecart_hopper_takeitem(pos, num)
            end
          node_def.minecart_hopper_unpull_item = function(pos, stack)
              self:cb_minecart_hopper_untakeitem(pos, stack)
            end
        end,
    };
  appliances.add_item_supply("minecart_item", item_supply)
end

