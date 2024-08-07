minetest.register_craft({
   output = 'tombs:machine',
   recipe = {
      {'default:stone', 'default:stone', 'default:stone'},
      {'default:steel_ingot', 'default:diamond', 'default:steel_ingot'},
      {'default:stone', 'default:stone', 'default:stone'}
   }
})

minetest.register_node('tombs:machine', {
   description = 'stroj na náhrobky',
   tiles = {
      'tombs_machine_side.png',
      'tombs_machine_side.png',
      'tombs_machine_side.png',
      'tombs_machine_side.png',
      'tombs_machine_side.png',
      'tombs_machine_front.png',
   },
   groups = {oddly_breakable_by_hand=3},
   paramtype2 = 'facedir',
   on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      meta:set_string('infotext', 'stroj na náhrobky')
      meta:set_string('formspec', tombs.machine_formspec_centered)
      meta:set_string('var', 0)
      local inv = meta:get_inventory()
      inv:set_size('tool', 1)
      inv:set_size('input', 1)
      inv:set_size('output', 15)
   end,
   on_receive_fields = function(pos, formname, fields, sender)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      local input_stack = inv:get_stack('input', 1)
      local input = input_stack:get_name()
      if fields ['offset'] then
         meta:set_string('formspec', tombs.machine_formspec_offset)
         meta:set_string('var', 1)
         tombs.populate_output(pos)
      elseif fields ['centered'] then
         meta:set_string('formspec', tombs.machine_formspec_centered)
         meta:set_string('var', 0)
         tombs.populate_output(pos)
      end
   end,
   can_dig = function(pos)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      if inv:is_empty('tool') and
      inv:is_empty('input') and
      inv:is_empty('output') then
         return true
      else
         return false
      end
   end,
   allow_metadata_inventory_put = function(pos, listname, index, stack, player)
      local stack_name, stack_count = stack:get_name(), stack:get_count()
      if listname == 'input' then
         return stack_count
      end
      if listname == 'tool' then
         if stack_name == 'tombs:chisel' or stack_name == 'mychisel:chisel' then
            return 1
         else
            return 0
         end
      end
      if listname == 'output' then
         return 0
      end
   end,
   allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
       return 0
   end,
   on_metadata_inventory_put = function(pos, listname, index, stack, player)
      tombs.populate_output(pos)
		if listname == "tool" then
			minetest.log("action", player:get_player_name().." put a chisel "..stack:get_name().." in a machine at "..minetest.pos_to_string(pos))
		end
   end,
   on_metadata_inventory_take = function(pos, listname, index, stack, player)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      local input_stack = inv:get_stack('input', 1)
      local tool_stack = inv:get_stack('tool', 1)
      local input = input_stack:get_name()
      local var = meta:get_string('var')
      if listname == 'input' then
         inv:set_list('output', {})
      elseif listname == 'tool' then
         inv:set_list('output', {})
		minetest.log("action", player:get_player_name().." took a chisel in a machine at "..minetest.pos_to_string(pos))
      elseif listname == 'output' then
         input_stack:take_item(1)
         if not minetest.is_creative_enabled(player:get_player_name()) and (tool_stack:get_name() == 'tombs:chisel' or tool_stack:get_name() == 'mychisel:chisel') then
            tool_stack:add_wear(65535 / 48)
            if tool_stack:is_empty() then
                minetest.log("action", player:get_player_name().." broke a chisel in a machine at "..minetest.pos_to_string(pos))
            end
         end
         minetest.log("action", player:get_player_name().." crafted "..stack:to_string().." in a machine at "..minetest.pos_to_string(pos))
         inv:set_stack('tool',1,tool_stack)
         inv:set_stack('input',1,input_stack)
         local stone_stack = inv:get_stack(listname,  index)
         if not stone_stack:is_empty() and stone_stack:get_name()~=stack:get_name() then
            local player_inv = player:get_inventory()
            if player_inv:room_for_item('main', stone_stack) then
               player_inv:add_item('main', stone_stack)
            end
         end
         if inv:is_empty('input') then
            inv:set_list('output', {})
         elseif inv:is_empty('tool') then
            inv:set_list('output', {})
         else
         tombs.populate_output(pos)
         end
      end
   end,
   allow_metadata_inventory_take = function(pos, listname, index, stack, player)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      local input_stack = inv:get_stack(listname,  index)
      local player_inv = player:get_inventory()
      if not player_inv:room_for_item('main', input_stack) then
         return 0
      else return stack:get_count()
      end
   end
})

function tombs.populate_output(pos)
   local meta = minetest.get_meta(pos)
   local inv = meta:get_inventory()
   local input_stack = inv:get_stack('input', 1)
   local tool_stack = inv:get_stack('tool', 1)
   local input = input_stack:get_name()
   local var = meta:get_string('var')
   if tombs.nodes[input] then
      if tool_stack:get_name() == 'tombs:chisel' or tool_stack:get_name() == 'mychisel:chisel' then
         inv:set_list('output', {})
         inv:set_list('output', tombs.crafting(input, var))
      end
   else
      inv:set_list('output', {})
   end
end
