--Craft Recipes

minetest.register_craft({
      output = 'drinks:juice_press',
      recipe = {
         {'default:stick', 'default:steel_ingot', 'default:stick'},
         {'default:stick', 'bucket:bucket_empty', 'default:stick'},
         {'stairs:slab_wood', 'stairs:slab_wood', 'vessels:drinking_glass'},
         }
})

minetest.register_craft({
      output = 'drinks:liquid_barrel',
      recipe = {
         {'group:wood', 'group:wood', 'group:wood'},
         {'group:wood', 'group:wood', 'group:wood'},
         {'stairs:slab_wood', '', 'stairs:slab_wood'},
         }
})

minetest.register_craft({
      output = 'drinks:liquid_silo',
      recipe = {
         {'drinks:liquid_barrel'},
         {'drinks:liquid_barrel'},
         {'drinks:liquid_barrel'}
      }
})

local press_idle_formspec =
   'size[8,7]'..
   'label[1.5,0;Lis je připravený]' ..
   'label[4.3,.75;Sem vložte ovoce ->]'..
   'label[3.5,1.75;Sem vložte nádobu ->]'..
   'label[0.2,1.8;4 ks/sklenici,]'..
   'label[0.2,2.1;8 ks/láhev,]'..
   'label[0.2,2.4;16 ks/kbelík.]'..
   'button[1,1;2,1;press;Spustit lisování]'..
   'list[current_name;src;6.5,.5;1,1;]'..
   'list[current_name;dst;6.5,1.5;1,1;]'..
   'list[current_player;main;0,3;8,4;]'..
   'listring[current_name;dst]'..
   'listring[current_player;main]'..
   'listring[current_name;src]'

local press_running_formspec =
   'size[8,7]'..
   'label[1.5,0;Lisování probíhá]' ..
   'label[4.3,.75;Sem vložte ovoce ->]'..
   'label[3.5,1.75;Sem vložte nádobu ->]'..
   'label[0.2,1.8;4 ks/sklenici,]'..
   'label[0.2,2.1;8 ks/láhev,]'..
   'label[0.2,2.4;16 ks/kbelík.]'..
   'button[1,1;2,1;press;Spustit lisování]'..
   'list[current_name;src;6.5,.5;1,1;]'..
   'list[current_name;dst;6.5,1.5;1,1;]'..
   'list[current_player;main;0,3;8,4;]'..
   'listring[current_name;dst]'..
   'listring[current_player;main]'..
   'listring[current_name;src]'

local press_error_formspec =
   'size[8,7]'..
   'label[1.5,0;Na lisování je potřeba víc ovoce.]' ..
   'label[4.3,.75;Sem vložte ovoce ->]'..
   'label[3.5,1.75;Sem vložte nádobu ->]'..
   'label[0.2,1.8;4 ks/sklenici,]'..
   'label[0.2,2.1;8 ks/láhev,]'..
   'label[0.2,2.4;16 ks/kbelík.]'..
   'button[1,1;2,1;press;Spustit lisování]'..
   'list[current_name;src;6.5,.5;1,1;]'..
   'list[current_name;dst;6.5,1.5;1,1;]'..
   'list[current_player;main;0,3;8,4;]'..
   'listring[current_name;dst]'..
   'listring[current_player;main]'..
   'listring[current_name;src]'

minetest.register_node('drinks:juice_press', {
   description = 'lis na ovocnou šťávu',
   drawtype = 'mesh',
   mesh = 'drinks_press.obj',
   tiles = {'drinks_press.png'},
   use_texture_alpha = "opaque",
   groups = {choppy=2, dig_immediate=2,},
   paramtype = 'light',
   paramtype2 = 'facedir',
   selection_box = {
      type = 'fixed',
      fixed = {-.5, -.5, -.5, .5, .5, .5},
      },
   collision_box = {
      type = 'fixed',
      fixed = {-.5, -.5, -.5, .5, .5, .5},
      },
   on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      inv:set_size('main', 8*4)
      inv:set_size('src', 1)
      inv:set_size('dst', 1)
      meta:set_string('infotext', 'prázdný lis na ovoce')
      meta:set_string('formspec', press_idle_formspec)
   end,
   on_receive_fields = function(pos, formname, fields, sender)
      if fields ['press'] then
         local meta = minetest.get_meta(pos)
         local inv = meta:get_inventory()
         local timer = minetest.get_node_timer(pos)
         local instack = inv:get_stack("src", 1)
         local fruitstack = instack:get_name()
         -- local mod, fruit = fruitstack:match("([^:]+):([^:]+)")
         if drinks.juiceable[fruitstack] then
			meta:set_string('fruit', drinks.juiceable[fruitstack])
            local outstack = inv:get_stack("dst", 1)
            local vessel = outstack:get_name()
            if vessel == 'vessels:drinking_glass' then
               if instack:get_count() >= 4 then
                  meta:set_string('container', 'jcu_')
                  meta:set_string('fruitnumber', 4)
                  meta:set_string('infotext', 'lis pracuje...')
                  meta:set_string('formspec', press_running_formspec)
                  timer:start(4)
               else
                  meta:set_string('infotext', 'lis má nedostatek ovoce')
                  meta:set_string('formspec', press_error_formspec)
               end
            elseif vessel == 'vessels:glass_bottle' then
               if instack:get_count() >= 8 then
                  meta:set_string('container', 'jbo_')
                  meta:set_string('fruitnumber', 8)
                  meta:set_string('infotext', 'lis pracuje...')
                  meta:set_string('formspec', press_running_formspec)
                  timer:start(8)
               else
                  meta:set_string('infotext', 'lis má nedostatek ovoce')
                  meta:set_string('formspec', press_error_formspec)
               end
            elseif vessel == 'vessels:steel_bottle' then
               if instack:get_count() >= 8 then
                  meta:set_string('container', 'jsb_')
                  meta:set_string('fruitnumber', 8)
                  meta:set_string('infotext', 'lis pracuje...')
                  meta:set_string('formspec', press_running_formspec)
                  timer:start(8)
               else
                  meta:set_string('infotext', 'lis má nedostatek ovoce')
                  meta:set_string('formspec', press_error_formspec)
               end
            elseif vessel == 'bucket:bucket_empty' then
               if instack:get_count() >= 16 then
                  meta:set_string('container', 'jbu_')
                  meta:set_string('fruitnumber', 16)
                  meta:set_string('infotext', 'lis pracuje...')
                  meta:set_string('formspec', press_running_formspec)
                  timer:start(16)
               else
                  meta:set_string('infotext', 'lis má nedostatek ovoce')
                  meta:set_string('formspec', press_error_formspec)
               end
            elseif vessel == 'default:papyrus' then
               if instack:get_count() >= 2 then
                  local under_node = {x=pos.x, y=pos.y-1, z=pos.z}
                  local under_node_name = minetest.get_node_or_nil(under_node)
                  local under_node_2 = {x=pos.x, y=pos.y-2, z=pos.z}
                  local under_node_name_2 = minetest.get_node_or_nil(under_node_2)
                  if under_node_name.name == 'drinks:liquid_barrel' then
                     local meta_u = minetest.get_meta(under_node)
                     local stored_fruit = meta_u:get_string('fruit')
                     if fruit == stored_fruit or stored_fruit == 'empty' then
                        meta:set_string('container', 'tube')
                        meta:set_string('fruitnumber', 2)
                        meta:set_string('infotext', 'lis pracuje...')
                        meta_u:set_string('fruit', fruit)
                        timer:start(4)
                     else
                        meta:set_string('infotext', "Míchání nápojů není dovoleno!")
                     end
                  elseif under_node_name_2.name == 'drinks:liquid_silo' then
                     local meta_u = minetest.get_meta(under_node_2)
                     local stored_fruit = meta_u:get_string('fruit')
                     if fruit == stored_fruit or stored_fruit == 'empty' then
                        meta:set_string('container', 'tube')
                        meta:set_string('fruitnumber', 2)
                        meta:set_string('infotext', 'lis pracuje...')
                        meta_u:set_string('fruit', fruit)
                        timer:start(4)
                     else
                        meta:set_string('infotext', "Míchání nápojů není dovoleno!")
                     end
                  else
                     meta:set_string('infotext', 'lis má nedostatek ovoce')
                     meta:set_string('formspec', press_error_formspec)
                  end
               end
            end
         end
      end
   end,
   on_timer = function(pos)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      local container = meta:get_string('container')
      local instack = inv:get_stack("src", 1)
      local outstack = inv:get_stack("dst", 1)
      local fruit = meta:get_string('fruit')
	  local fruit_desc = (drinks.drink_table[fruit] or {})[2] or fruit
      local fruitnumber = tonumber(meta:get_string('fruitnumber'))
      if container == 'tube' then
         local timer = minetest.get_node_timer(pos)
         local under_node = {x=pos.x, y=pos.y-1, z=pos.z}
         local under_node_name = minetest.get_node_or_nil(under_node)
         local under_node_2 = {x=pos.x, y=pos.y-2, z=pos.z}
         local under_node_name_2 = minetest.get_node_or_nil(under_node_2)
         if under_node_name.name == 'drinks:liquid_barrel' then
            local meta_u = minetest.get_meta(under_node)
            local fullness = tonumber(meta_u:get_string('fullness'))
            instack:take_item(tonumber(fruitnumber))
            inv:set_stack('src', 1, instack)
            if fullness + 2 > 128 then
               timer:stop()
               meta:set_string('infotext', 'Barel je plný '..fruit_desc..'.')
               return
            else
               local fullness = fullness + 2
               meta_u:set_string('fullness', fullness)
               meta_u:set_string('infotext', "z "..(math.floor((fullness/128)*100))..' % plný '..fruit_desc..'.')
               meta_u:set_string('formspec', drinks.liquid_storage_formspec(fruit, fullness, 128))
               if instack:get_count() >= 2 then
                  timer:start(4)
               else
                  meta:set_string('infotext', 'lis má nedostatek ovoce')
               end
            end
         elseif under_node_name_2.name == 'drinks:liquid_silo' then
            local meta_u = minetest.get_meta(under_node_2)
            local fullness = tonumber(meta_u:get_string('fullness'))
            instack:take_item(tonumber(fruitnumber))
            inv:set_stack('src', 1, instack)
            if fullness + 2 > 256 then
               timer:stop()
               meta:set_string('infotext', 'Silo je plné '..fruit_desc..'.')
               return
            else
               local fullness = fullness + 2
               meta_u:set_string('fullness', fullness)
               meta_u:set_string('infotext', "z "..(math.floor((fullness/256)*100))..' % plné '..fruit_desc..'.')
               meta_u:set_string('formspec', drinks.liquid_storage_formspec(fruit, fullness, 256))
               if instack:get_count() >= 2 then
                  timer:start(4)
               else
                  meta:set_string('infotext', 'lis má nedostatek ovoce')
               end
            end
         end
      else
      meta:set_string('infotext', 'Vyjměte hotovou šťávu.')
      meta:set_string('formspec', press_idle_formspec)
      instack:take_item(tonumber(fruitnumber))
      inv:set_stack('src', 1, instack)
      inv:set_stack('dst', 1 ,'drinks:'..container..fruit)
      end
   end,
   on_metadata_inventory_take = function(pos, listname, index, stack, player)
      local timer = minetest.get_node_timer(pos)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      timer:stop()
      meta:set_string('infotext', 'Připraven na další lisování.')
      meta:set_string('formspec', press_idle_formspec)
   end,
   on_metadata_inventory_put = function(pos, listname, index, stack, player)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      meta:set_string('infotext', 'Připraven na lisování.')
   end,
   can_dig = function(pos)
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory()
      if inv:is_empty("src") and
         inv:is_empty("dst") then
         return true
      else
         return false
      end
   end,
   allow_metadata_inventory_put = function(pos, listname, index, stack, player)
      if listname == 'dst' then
		 if not minetest.get_meta(pos):get_inventory():is_empty("dst") then
			return 0
         elseif stack:get_name() == ('bucket:bucket_empty') then
            return 1
         elseif stack:get_name() == ('vessels:drinking_glass') then
            return 1
         elseif stack:get_name() == ('vessels:glass_bottle') then
            return 1
         elseif stack:get_name() == ('vessels:steel_bottle') then
            return 1
         elseif stack:get_name() == ('default:papyrus') then
            return 1
         else
            return 0
         end
      else
         return 100
      end
   end,
})

function drinks.drinks_liquid_sub(liq_vol, ves_typ, ves_vol, pos, able_to_fill, leftover_count, outputstack)
   local meta = minetest.get_meta(pos)
   local fullness = tonumber(meta:get_string('fullness'))
   local fruit = meta:get_string('fruit')
   local fruit_name = meta:get_string('fruit_name')
   local fruit_desc = (drinks.drink_table[fruit] or {})[2] or fruit
   local inv = meta:get_inventory()
   local fullness = fullness - (liq_vol*able_to_fill)
   meta:set_string('fullness', fullness)
   meta:set_string('infotext', "z "..(math.floor((fullness/ves_vol)*100))..' % plné '..fruit_desc..'.')
   if ves_vol == 128 then
      meta:set_string('formspec', drinks.liquid_storage_formspec(fruit_name, fullness, 128))
   elseif ves_vol == 256 then
      meta:set_string('formspec', drinks.liquid_storage_formspec(fruit_name, fullness, 256))
   end
   if ves_typ == 'jcu' or ves_typ == 'jbo' or ves_typ == 'jsb' or ves_typ == 'jbu' then
      inv:set_stack('dst', 1, 'drinks:'..ves_typ..'_'..fruit..' '..able_to_fill)
      inv:set_stack('src', 1, outputstack..' '..leftover_count)
   --[[ elseif ves_typ == 'thirsty:bronze_canteen' then
      inv:set_stack('dst', 1, {name="thirsty:bronze_canteen", count=1, wear=60, metadata=""})
   elseif ves_typ == 'thirsty:steel_canteen' then
      inv:set_stack('dst', 1, {name="thirsty:steel_canteen", count=1, wear=40, metadata=""}) ]]
   end
end

function drinks.drinks_liquid_avail_sub(liq_vol, ves_typ, ves_vol, outputstack, pos, count)
   local meta = minetest.get_meta(pos)
   local fullness = tonumber(meta:get_string('fullness'))
   if fullness - (liq_vol*count) < 0 then
      local able_to_fill = math.floor(fullness/liq_vol)
      local leftover_count = count - able_to_fill
      drinks.drinks_liquid_sub(liq_vol, ves_typ, ves_vol, pos, able_to_fill, leftover_count, outputstack)
   elseif fullness - (liq_vol*count) >= 0 then
      drinks.drinks_liquid_sub(liq_vol, ves_typ, ves_vol, pos, count, 0, outputstack)
   end
end

function drinks.drinks_liquid_add(liq_vol, ves_typ, ves_vol, pos, inputcount, leftover_count, inputstack)
   local meta = minetest.get_meta(pos)
   local fullness = tonumber(meta:get_string('fullness'))
   local fruit = meta:get_string('fruit')
   local fruit_name = meta:get_string('fruit_name')
   local fruit_desc = (drinks.drink_table[fruit] or {})[2] or fruit
   local inv = meta:get_inventory()
   local fullness = fullness + (liq_vol*inputcount)
   meta:set_string('fullness', fullness)
   inv:set_stack('src', 1, ves_typ..' '..inputcount)
   inv:set_stack('dst', 1, inputstack..' '..leftover_count)
   if ves_vol == 256 then
	  meta:set_string('infotext', "z "..(math.floor((fullness/ves_vol)*100))..' % plné '..fruit_desc.."")
      meta:set_string('formspec', drinks.liquid_storage_formspec(fruit_name, fullness, 256))
   elseif ves_vol == 128 then
	  meta:set_string('infotext', "z "..(math.floor((fullness/ves_vol)*100))..' % plný '..fruit_desc.."")
      meta:set_string('formspec', drinks.liquid_storage_formspec(fruit_name, fullness, 128))
   end
end

function drinks.drinks_liquid_avail_add(liq_vol, ves_typ, ves_vol, pos, inputstack, inputcount)
   local meta = minetest.get_meta(pos)
   local fullness = tonumber(meta:get_string('fullness'))
   if fullness + (liq_vol*inputcount) > ves_vol then
      local avail_ves_vol = ves_vol - fullness
      local can_empty = math.floor(avail_ves_vol/liq_vol)
      local leftover_count = inputcount - can_empty
      drinks.drinks_liquid_add(liq_vol, ves_typ, ves_vol, pos, can_empty, leftover_count, inputstack)
   elseif fullness + (liq_vol*inputcount) <= ves_vol then
      drinks.drinks_liquid_add(liq_vol, ves_typ, ves_vol, pos, inputcount, 0, inputstack)
   end
end

function drinks.drinks_barrel(pos, inputstack, inputcount)
   local meta = minetest.get_meta(pos)
   local vessel = string.sub(inputstack, 8, 10)
   drinks.drinks_liquid_avail_add(drinks.shortname[vessel].size, drinks.shortname[vessel].name, 128, pos, inputstack, inputcount)
end

function drinks.drinks_silo(pos, inputstack, inputcount)
   local meta = minetest.get_meta(pos)
   local vessel = string.sub(inputstack, 8, 10)
   drinks.drinks_liquid_avail_add(drinks.shortname[vessel].size, drinks.shortname[vessel].name, 256, pos, inputstack, inputcount)
end

minetest.register_node('drinks:liquid_barrel', {
   description = 'sud na nápoje',
   drawtype = 'mesh',
   mesh = 'drinks_liquid_barrel.obj',
   tiles = {'drinks_barrel.png'},
   use_texture_alpha = "opaque",
   groups = {choppy=2, dig_immediate=2,},
   paramtype = 'light',
   paramtype2 = 'facedir',
   selection_box = {
      type = 'fixed',
      fixed = {-.5, -.5, -.5, .5, .5, .5},
      },
   collision_box = {
      type = 'fixed',
      fixed = {-.5, -.5, -.5, .5, .5, .5},
      },
   on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      inv:set_size('main', 8*4)
      inv:set_size('src', 1)
      inv:set_size('dst', 1)
      meta:set_string('fullness', 0)
      meta:set_string('fruit', 'empty')
      meta:set_string('infotext', 'prázdný sud')
      meta:set_string('formspec', 'size[8,8]'..
      'label[0,0;Plňte jedním druhem nápoje.]'..
      'label[0,.4;Míchání nápojů není dovoleno!]'..
      'label[4.5,1.2;Nápoj k přidání ->]'..
      'label[.75,1.75;Sud je prázdný]'..
      'label[4.5,2.25;Nádoba k naplnění ->]'..
      'label[2,3.2;(Toto zcela vyprázdní sud)]'..
      'button[0,3;2,1;purge;Vylít vše]'..
      'list[current_name;src;6.5,1;1,1;]'..
      'list[current_name;dst;6.5,2;1,1;]'..
      'list[current_player;main;0,4;8,5;]')
   end,
   on_metadata_inventory_put = function(pos, listname, index, stack, player)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      local instack = inv:get_stack('src', 1)
      local outstack = inv:get_stack('dst', 1)
      local outputstack = outstack:get_name()
      local inputstack = drinks.translate_alias(instack:get_name())
      local outputcount = outstack:get_count()
      local inputcount = instack:get_count()
      local fruit = string.sub(inputstack, 12, -1)
      local fruit_in = meta:get_string('fruit')
      if fruit_in == 'empty' then
         meta:set_string('fruit', fruit)
         local fruit_name = minetest.registered_items[instack:get_name()]
         meta:set_string('fruit_name', string.lower(fruit_name.juice_type))
         local vessel = string.sub(inputstack, 8, 10)
         drinks.drinks_barrel(pos, inputstack, inputcount)
      end
      if fruit == fruit_in then
         local vessel = string.sub(inputstack, 8, 10)
         drinks.drinks_barrel(pos, inputstack, inputcount)
      end
      if drinks.longname[outputstack] then
         drinks.drinks_liquid_avail_sub(drinks.longname[outputstack].size, drinks.longname[outputstack].name, 128, outputstack, pos, outputcount)
      end
   end,
   on_receive_fields = function(pos, formname, fields, sender)
      if fields['purge'] then
         local meta = minetest.get_meta(pos)
         local fullness = 0
         local fruit_name = 'nic'
         meta:set_string('fullness', 0)
         meta:set_string('fruit', 'empty')
         meta:set_string('infotext', 'prázdný sud')
         meta:set_string('formspec', drinks.liquid_storage_formspec(fruit_name, fullness, 128))
      end
   end,
   can_dig = function(pos)
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory()
      if inv:is_empty("src") and
         inv:is_empty("dst") and
         tonumber(meta:get_string('fullness')) == 0 then
         return true
      else
         return false
      end
   end,
   allow_metadata_inventory_put = function(pos, listname, index, stack, player)
      local meta = minetest.get_meta(pos)
      if listname == 'src' then --adding liquid
         local inputstack = drinks.translate_alias(stack:get_name())
         local inputcount = stack:get_count()
         local valid = string.sub(inputstack, 1, 8)
         if valid == 'drinks:j' then
            return inputcount
         else
            return 0
         end
      elseif listname == 'dst' then --removing liquid
         --make sure there is a liquid to remove
         local juice = meta:get_string('fruit')
         if juice ~= 'empty' then
            local inputstack = drinks.translate_alias(stack:get_name())
            local inputcount = stack:get_count()
            local valid = string.sub(inputstack, 1, 7)
            if valid == 'vessels' or valid == 'bucket:' then
               return inputcount
            else
               return 0
            end
         else
            return 0
         end
      end
   end,
})

minetest.register_node('drinks:liquid_silo', {
   description = 'silo na nápoje',
   drawtype = 'mesh',
   mesh = 'drinks_silo.obj',
   tiles = {'drinks_silo.png'},
   groups = {choppy=2, dig_immediate=2,},
   paramtype = 'light',
   paramtype2 = 'facedir',
   selection_box = {
      type = 'fixed',
      fixed = {-.5, -.5, -.5, .5, 1.5, .5},
      },
   collision_box = {
      type = 'fixed',
      fixed = {-.5, -.5, -.5, .5, 1.5, .5},
      },
   on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      inv:set_size('main', 8*4)
      inv:set_size('src', 1)
      inv:set_size('dst', 1)
      meta:set_string('fullness', 0)
      meta:set_string('fruit', 'empty')
      meta:set_string('infotext', 'prázdné silo na nápoje')
      meta:set_string('formspec', 'size[8,8]'..
      'label[0,0;Plňte jedním druhem nápoje.]'..
      'label[0,.4;Míchání nápojů není dovoleno!]'..
      'label[4.5,1.2;Nápoj k přidání ->]'..
      'label[.75,1.75;Sud je prázdný]'..
      'label[4.5,2.25;Nádoba k naplnění ->]'..
      'label[2,3.2;(Toto zcela vyprázdní sud)]'..
      'button[0,3;2,1;purge;Vylít vše]'..
      'list[current_name;src;6.5,1;1,1;]'..
      'list[current_name;dst;6.5,2;1,1;]'..
      'list[current_player;main;0,4;8,5;]')
   end,
   on_metadata_inventory_put = function(pos, listname, index, stack, player)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      local instack = inv:get_stack("src", 1)
      local outstack = inv:get_stack('dst', 1)
      local outputstack = outstack:get_name()
      local inputstack = drinks.translate_alias(instack:get_name())
      local outputcount = outstack:get_count()
      local inputcount = instack:get_count()
      local fruit = string.sub(inputstack, 12, -1)
      local fruit_in = meta:get_string('fruit')
      if fruit_in == 'empty' then
         meta:set_string('fruit', fruit)
         local fruit_name = minetest.registered_items[instack:get_name()]
         meta:set_string('fruit_name', string.lower(fruit_name.juice_type))
         local vessel = string.sub(inputstack, 8, 10)
         drinks.drinks_silo(pos, inputstack, inputcount)
      end
      if fruit == fruit_in then
         local vessel = string.sub(inputstack, 8, 10)
         drinks.drinks_silo(pos, inputstack, inputcount)
      end
      if drinks.longname[outputstack] then
         drinks.drinks_liquid_avail_sub(drinks.longname[outputstack].size, drinks.longname[outputstack].name, 256, outputstack, pos, outputcount)
      end
   end,
   on_receive_fields = function(pos, formname, fields, sender)
      if fields['purge'] then
         local meta = minetest.get_meta(pos)
         local fullness = 0
         local fruit_name = 'nic'
         meta:set_string('fullness', 0)
         meta:set_string('fruit', 'empty')
         meta:set_string('infotext', 'prázdné silo na nápoje')
         meta:set_string('formspec', drinks.liquid_storage_formspec(fruit_name, fullness, 256))
      end
   end,
   can_dig = function(pos)
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory()
      if inv:is_empty("src") and
         inv:is_empty("dst") and
         tonumber(meta:get_string('fullness')) == 0 then
         return true
      else
         return false
      end
   end,
   allow_metadata_inventory_put = function(pos, listname, index, stack, player)
      local meta = minetest.get_meta(pos)
      if listname == 'src' then --adding liquid
         local inputstack = drinks.translate_alias(stack:get_name())
         local inputcount = stack:get_count()
         local valid = string.sub(inputstack, 1, 8)
         if valid == 'drinks:j' then
            return inputcount
         else
            return 0
         end
      elseif listname == 'dst' then --removing liquid
         --make sure there is liquid to take_item
         local juice = meta:get_string('fruit')
         if juice ~= 'empty' then
            local inputstack = drinks.translate_alias(stack:get_name())
            local inputcount = stack:get_count()
            local valid = string.sub(inputstack, 1, 7)
            if valid == 'vessels' or valid == 'bucket:' then
               return inputcount
            else
               return 0
            end
         else
            return 0
         end
      end
   end,
})
