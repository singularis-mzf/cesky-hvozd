# Appliances API


See example folder for appliance examples.

## Appliances API functions (common)

### appliances.swap_node(pos, name)

* Function swap node by using minetest.swap_node fucntion.
* Metadata of node isn't affected.
* pos - node position
* name - new node name

### appliances.register_craft_type(type_name, type_def)

* Register craft type.
* type_name - Unique name of crafting type
* type_def - table with definition of crafting type
  * description - description of crafting type
  * icon - icon picture name
  * width - width of recipe
  * height - height of recipe
  * dynamic_display_size - unified_inventory callback only
  
		{
			-- description text
			description = "",
			-- path to icon file, can be nil
			icon = "",
			-- width of recipe (unified only)
			width = 1,
			-- height of recipe (unified only)
			height = 1,
			-- unified callback only
			dynamic_display_size = nil,
		}


### appliances.register_craft(craft_def)

* Register craft recipe.
* craft_def - table with craft recipe definition
  * type - type of recipe
  * output - recipe product
  * items - input items
 
		{
			-- type name (some of registered craft type)
			type = "",
			-- item string of recipe product
			output = "",
			-- input items
			items = {""},
		}

### appliances.get_side_pos(pos_from, node_from, side)

* Return side position

### appliances.get_sides_pos(pos_from, node_from, sides)

* Return combinated sides position

### appliances.is_connected_to(pos_from, node_from, pos_to, sides)

* Check if node is connected to pos by some of given sides.

## Appliance object definition

	{
		-- this field have to be set manually always, in time of new appliance creation
		-- this fields specifi active and inactive appliance node names
		node_name_active = "default:furnace_active",
		node_name_incative = "default:furnace",
		-- can be set, if appliance should have special registered node for waiting state
		node_name_waiting = nil,
		
		input_stack = "input",
		-- input stack name
		
		input_stack_size = 1,
		-- input stack size
		-- use 0 value to disable stack creation
		-- if input stack size is different from 1, method get_formspec should be override
		
		have_input = true,
		-- enable/disable input stack checks
		
		use_stack = "use_in",
		-- use stack name
		
		use_stack_size = 1,
		-- use stack size
		-- use 0 value to disable stack creation
		-- if size of use stack is different from 1 and have_usage is true, method get_formspec should be override
		
		have_usage = true,
		-- enable/disable usage stack checks
		
		output_stack = "output",
		-- output stack name
		
		output_stack_size = 4,
		-- output stack size
		-- use 0 value to disable stack creation
		-- if output stack size is different from 4, method get_formspec should be override
		
		stoppable_production = true,
		-- when false, production is not interruptable
		stoppable_consumption = true,
		-- when false, consumption is not interruptable
		
		items_connect_sides = {"right", "left"},
		-- sides item supply can be connected from/to
		-- right, left, front, back, top, bottom
		
		supply_connect_sides = {"top"}; 
		-- sides general supply can be connected from/to
		-- right, left, front, back, top, bottom
		
		power_connect_sides = {"back"};
		-- sides power supply can be connected from/to
		-- right, left, front, back, top, bottom
		
		control_connect_sides = {"right", "left", "front", "back", "top", "bottom"};
		-- sides control can be connected from/to
		-- right, left, front, back, top, bottom

		meta_infotext = "infotext",
		-- metadata name for store infotext.
		-- uses for example when appliance if powered by technic mod
		
		sounds = {
			-- use in state running
			running = {
				sound = <SimpleSoundSpec>,
				sound_param = {},
				repeat_timer = 5,
			},
			-- use in state waiting
			waiting = {
				sound = <SimpleSoundSpec>,
				sound_param = {}.
			},
			-- use in state activate
			activate = {
				sound = <SimpleSoundSpec>,
				sound_param = {}.
				repeat_timer = 0,
			},
			-- use when state is changed from waiting to running
			waiting_running = {
				sound = <SimpleSoundSpec>,
				sound_param = {}.
				repeat_timer = 0,
			},
			-- use when state is changed from running to waiting
			running_waiting = {
				sound = <SimpleSoundSpec>,
				sound_param = {}.
				repeat_timer = 0,
			},
			-- use in state nopower
			nopower = {
				sound = <SimpleSoundSpec>,
				sound_param = {loop = true}.
        key = "nopower",
        fade_step = 0.2,
			},
			-- use when state is changet from nopower to running
			nopower_running = {
				sound = <SimpleSoundSpec>,
				sound_param = {}.
        update_sound = function (self, pos, meta, old_state, new_state, sound)
          -- return edited sound object, DO NOT EDIT ORIGINAL TABLE STORED IN DEFINITION!
          return {
            sound = sound.sound
            sound_param = table.copy(sound.sound_param)
          }
        end
			},
		}
	}


## Appliance object functions

Methods of object appliances.appliance.

### appliance:new(definition)

See [Appliance object definition] for definition description.

### appliance:power_data_register(power_data)

* Take only useful power_data.
* Always should be used. For machines without power requirements, use power_data '{time_power={}}'.

### appliance:item_data_register(item_data)

* Take only useful item_data.

### appliance:supply_data_register(supply_data)

* Take only useful supply_data.

### appliance:control_data_register(control_data)

* Take only useful control_data.

### appliance:get_power_help(prefix, suffix, separator)

* default values: prefix=\"\", suffix=\"\" and separator="/"
* Should be called after method 'power_data_register'
* Generate description power string for powered nodes which require some units of power.
* require 'units' or 'hard_help'  field in power supply definition
* require field 'help_units' or 'demand_min' or 'demand_max' or 'demand' in power data.

### appliance:recipe_register_input(input_name, input_def)

* Registration of input recipe.
* for input_stack_size = 1, input_name have to be eqqual to recipe input item name.
* for input_stack_size > 1, input_def have to include field inputs, which should be en array of input item names.
* input_def:

		{			
			-- number of input items, if input_stack_size = 1
			inputs = 1,
			-- inputs item table, if input_stack_size > 1
			inputs = {"",""},
			-- list of one or more outputs, if more outputs, one record is selected randomly
			outputs = {"output_item", {"multi_output1", "multi_output2"}},
			-- output when production is interrupted
			losts = {},
			-- nil, if every usage item can be used
			require_usage = {["item"]=true},
			-- time to product outputs
			production_time = 160,
			-- change usage consumption speed (1 means no change)
			consumption_step_size = 1,
			-- optional function for update output items list, when production is finished, return new outputs list
			on_done = function(self, timer_step, outputs),
		}

### appliance:recipe_register_usage(usage_name, usage_def)

 Registration of usage recipe.
* usage_name have to be equal to recipe input item name.
* usage_def:
	
		{
			-- list of one or more outputs, if more outputs, one record is selected randomly
			outputs = {"output_item", {"multi_output1", "multi_output2"}},
			-- output when production is interrupted
			losts = {},
			-- time to change usage item to outputs
			consumption_time = 60,
			-- speed of production output (1 means no change)
			production_step_size = 1,
			-- optional function for update output items list, when item is consumpted, return new outputs list
			on_done = function(self, timer_step, outputs),
		}

### appliance:register_nodes(shared_def, inactive_def, active_def, waiting_def)

This functions register appliance nodes.

* shared_def - table with specific node definition data (like tiles, mesh etc.)
* inactive_def - table with field which should be updated/added in/to shared_def to gen full inactive node deifnition.
* active_def - table with field which should be updated/added in/to shared_def to gen full active node deifnition.
* waiting_def - table with field which should be updated/added in/to shared_def to gen full waiting node deifnition.

## Extensions

Appliance mod part for add some specific functionality/dependency.

## Extension power supply

### Predefined

* no_power
* time_power
* punch_power
* mesecons_power (modpack mesecons)
* LV_power (technic mod - fire powered generator 200 LV EU)
* MV_power (technic mod)
* HV_power (technic mod)
* elepower_power (modpack elepower - 16 EpU ~= 200 LV EU)
* techage_axle_power (techage mod)
* techage_electric_power (techage mod - 80 ku ~= 200 LV EU)
* factory_power (mod factory - 10 Factory EU ~= 200 LV EU)

Examples (use only subset of them):

		appliance:power_data_register({
			["no_power"] = {
				-- no power, should be used, when no useful power source is aviable
			},
			["time_power"] = {
				-- run speed if this power data is used
				run_speed = 1,
			},
			["punch_power"] = {
				-- run speed if this power data is used
				run_speed = 1,
				-- can be used to specify required punching interval in seconds
				-- if not defined, value 1 is used
				punch_power = 1, 
			},
			["mesecons_power"] = {
				-- run speed if this power data is used
				run_speed = 1,
				-- can be used to disable some power data if this power type is registered/aviable
				disable = {"time_power","no_power"},
			},
			-- LV_power or MV_power or HV_power
			["LV_power"] = {
				-- run speed if this power data is used
				run_speed = 1,
				-- demand or get_demand
				demand = 100,
				get_demand = function(self, pos, meta)
				  return 100
				end,
				-- can be used to disable some power data if this power type is registered/aviable
				disable = {"no_power"},
			},
			["elepower_power"] = {
				-- run speed if this power data is used
				run_speed = 1,
				-- demand or get_demand
				demand = 8,
				get_demand = function(self, pos, meta)
				  return 8
				end,
				-- can be used to disable some power data if this power type is registered/aviable
				disable = {"no_power"},
			},
			["techage_electric_power"] = {
				-- run speed if this power data is used
				run_speed = 1,
				-- demand
				demand = 40,
				-- can be used to disable some power data if this power type is registered/aviable
				disable = {"no_power"},
			},
			["factory_power"] = {
				-- run speed if this power data is used
				run_speed = 1,
				-- demand or get_demand
				demand = 5,
				get_demand = function(self, pos, meta)
				  return 5
				end,
				-- can be used to disable some power data if this power type is registered/aviable
				disable = {"no_power"},
			},
		})

### appliances.add_power_supply(supply_name, power_supply)

* supply_name - unique supply name (shared across extensions)
* power_supply - definition

### Power extension specific callback functions

* is_powered(self, supply_data, pos, meta)
* power_need(self, supply_data, pos, meta)
* power_idle(self, supply_data, pos, meta)

## Extension general supply

### Predefined

* no_supply
* water_pipe_liquid (mod pipeworks)

		appliance:supply_data_register({
			["no_supply"] = {
			},
			["water_pipe_liquid"] = {
				-- check if water pipe with water is connected to appliance
				-- no special data is required
				disable = {"no_supply"},
			},
		})

### appliances.add_supply(supply_name, general_supply)

* supply_name - unique supply name (shared across extensions)
* general_supply - definition

### Supply extension specific callback functions

This functions can be defined in supply definition.

* have_supply(self, supply_data, pos, meta)

## Extension item supply

### Predefined

* tube_item (mod pipeworks)
* techage_item (mod techage)
* minecart_item (mod minecart)

Example:

		appliance:supply_data_register({
			["tube_item"] = {
				-- add pipeworks tube support
				-- no special data is required
			},
			["techage_item"] = {
				-- add techage tube support
				-- no special data is required
			},
		})

### appliances.add_item_supply(supply_name, item_supply)

* supply_name - unique supply name (shared across extensions)
* item_supply - definition


## Extension control

### Predefined

* punch_control
* mesecons_control (modpack mesecons)

		appliance:control_data_register({
			["punch_control"] = {
				-- appliance have to be punched to start/stop
				power_off_on_deactivate = false/true, -- if true, control is disabled when appliance is deactivated
			},
			["mesecons_control"] = {
				-- appliance start/stop is driven by messecon signal
				-- no special data is required
			},
		})

### appliances.add_control(control_name, control_def)

* control_name - unique supply name (shared across extensions)
* control_def - definition

### Control extension specific callback functions

This functions can be defined in control definition.

control_wait(self, control_data, pos, meta)

## Extensions aviable callback functions

This functions can be defined in any extension definition.

* activate(self, extension_data, pos, meta)
* deactivate(self, extension_data, pos, meta)
* running(self, extension_data, pos, meta)
* waiting(self, extension_data, pos, meta)
* no_power(self, extension_data, pos, meta)

* update_node_def(self, extension_data, node_def)
* update_node_inactive_def(self, extension_data, node_def)
* update_node_active_def(self, extension_data, node_def)

* after_register_node(self, extension_data)
* on_construct(self, extension_data, pos, meta)
* on_destruct(self, extension_data, pos, meta)
* after_destruct(self, extension_data, pos, oldnode)
* after_place_node(self, extension_data, pos, placer, itemstack, pointed_thing)
* after_dig_node(self, extension_data, pos, oldnode, oldmetadata, digger)
* can_dig(self, extension_data, pos, player)
* on_punch(self, extension_data, pos, node, puncher, pointed_thing)
* on_blast(self, extension_data, pos, intensity)


## Callback for potencionally redefinition


All methods can be redefined in child class.

Methods with prefix cb_\* is ideal for redefinition if some special function have to be added/changed.

Redefine method get\_formspec if you are not using default configuration of inventory sizes. Default method support setting have\_usage.

It is recommended to check original function code before redefinition. Some functions have to be redefined carefully to prevent problems (like cb_on_timer).

* cb_play_sound(pos, meta, old_state, new_state)

* cb_activate(pos, meta)
* cb_deactivate(pos, meta)
* cb_running(pos, meta)
* cb_waiting(pos, meta)
* cb_no_power(pos, meta)

* cb_on_construct(pos)
* cb_after_place_node(pos, placer, itemstack, pointed_thing)
* cb_can_dig(pos)
* cb_after_dig_node(pos, oldnode, oldmetadata, digger)
* cb_on_punch(pos, node, puncher, pointed_thing)
* cb_on_blast(pos, intensity)

* cb_on_production(timer_step)
* cb_on_timer(pos, elapsed)

* cb_allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
* cb_allow_metadata_inventory_put(pos, listname, index, stack, player)
* cb_allow_metadata_inventory_take(pos, listname, index, stack, player)

* cb_on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
* cb_on_metadata_inventory_put(pos, listname, index, stack, player)
* cb_on_metadata_inventory_take(pos, listname, index, stack, player)

* cb_after_update_node_def(node_def)
* cb_after_update_node_inactive_def(node_def)
* cb_after_update_node_active_def(node_def)
