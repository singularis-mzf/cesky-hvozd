-- loom

local S = clothing.translator;

clothing.loom = appliances.appliance:new(
    {
      node_name_inactive = "clothing:loom",
      node_name_active = "clothing:loom_active",
      
      node_description = S("Loom"),
      node_help = S("Weaving fabric from yarn.").."\n"..
                  S("Powered by punching."),
      
      input_stack = "input",
      input_stack_size = 4,
      input_stack_width = 2,
      use_stack = "input",
      use_stack_size = 0,
      have_usage = false,
      
      sounds = {
        running = {
          sound = "clothing_loom_running",
          sound_param = {max_hear_distance = 8, gain = 1},
          repeat_timer = 0,
        },
      },
    }
  );

local loom = clothing.loom;

loom:power_data_register(
  {
    ["punch_power"] = {
        run_speed = 1,
      },
  })

--------------
-- Formspec --
--------------

function loom:get_formspec(meta, production_percent, consumption_percent)
  local progress = "image[5.1,1;4,1.5;appliances_production_progress_bar.png^[transformR270]]";
  if production_percent then
    progress = "image[5.1,1;4,1.5;appliances_production_progress_bar.png^[lowpart:" ..
            (production_percent) ..
            ":appliances_production_progress_bar_full.png^[transformR270]]";
  end
  
  local formspec =  "formspec_version[3]" .. "size[12.75,9.5]" ..
                    "background[-1.25,-1.25;15,11;appliances_appliance_formspec.png]" ..
                    progress..
                    "list[current_player;main;1.5,4;8,4;]" ..
                    "list[context;input;1.5,0.75;2,2;]" ..
                    "list[context;output;9.75,0.75;2,2;]" ..
                    "listring[current_player;main]" ..
                    "listring[context;input]" ..
                    "listring[current_player;main]" ..
                    "listring[context;output]" ..
                    "listring[current_player;main]";
  return formspec;
end

--------------------
-- Node callbacks --
--------------------

----------
-- Node --
----------

local node_def = {
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 2,},
    legacy_facedir_simple = true,
    is_ground_content = false,
    sounds = default.node_sound_wood_defaults(),
    drawtype = "mesh",
    -- selection box {x=0, y=0, z=0}
    selection_box = {
      type = "fixed",
      fixed = {
        {-0.375,-0.5,-0.5,0.375,-0.4375,0.5},
        {-0.375,-0.4375,-0.4375,-0.3125,-0.125,-0.375},
        {0.3125,-0.4375,-0.4375,0.375,-0.125,-0.375},
        {-0.375,-0.1875,-0.375,-0.3125,-0.125,0.5},
        {0.3125,-0.1875,-0.375,0.375,-0.125,0.5},
        {-0.375,-0.375,-0.25,0.375,-0.1875,0.25},
        {-0.3125,-0.1875,-0.25,0.3125,-0.125,0.25},
        {-0.3125,-0.125,-0.25,0.3125,0.0,0.25},
        {-0.5,-0.5,-0.125,-0.375,0.5,0.1875},
        {0.375,-0.5,-0.125,0.5,0.5,0.1875},
        {-0.375,0.0,-0.125,0.375,0.0625,0.1875},
        {-0.375,-0.4375,0.375,-0.3125,-0.1875,0.4375},
        {0.3125,-0.4375,0.375,0.375,-0.1875,0.4375},
        {-0.4375,-0.1875,0.4375,-0.375,-0.125,0.5},
        {-0.3125,-0.1875,0.4375,0.3125,-0.125,0.5},
        {0.375,-0.1875,0.4375,0.4375,-0.125,0.5},
        -- 
        {-0.4375,-0.1875,-0.5,0.4375,-0.125,-0.4375},
        {-0.5,0.3125,-0.1875,0.5,0.5,-0.125},
        {-0.5,0.1875,0.1875,0.5,0.375,0.25},
      },
    },
    sunlight_propagates = true,
  }
local inactive_node = {
    tiles = {
      "clothing_loom_wood.png",
      "clothing_loom_black.png",
      "clothing_loom_front.png",
      "clothing_loom_top.png",
    },
    mesh = "clothing_loom.obj",
  }
local active_node = {
    tiles = {
      "clothing_loom_wood.png",
      "clothing_loom_black.png",
      {
        image = "clothing_loom_front_active.png",
        backface_culling = true,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2,
        }
      },
      {
        image = "clothing_loom_top_active.png",
        backface_culling = true,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2,
        }
      },
    },
    use_texture_alpha = "clip",
    mesh = "clothing_loom_active.obj",
  }

loom:register_nodes(node_def, inactive_node, active_node)

-------------------------
-- Recipe Registration --
-------------------------

appliances.register_craft_type("clothing_weaving", {
    description = S("Weaving"),
    icon = "clothing_recipe_weaving.png",
    width = 2,
    height = 2,
  })
  
for color, data in pairs(clothing.colors) do
  if (data.hex2==nil) then
    local spool = "clothing:yarn_spool_"..color;
    loom:recipe_register_input(
      "",
      {
        inputs = {spool, spool,
                  spool, spool,
                 },
        outputs = {{"clothing:fabric_"..color, "clothing:yarn_spool_empty 4"},},
        production_time = 30,
        consumption_step_size = 1,
      });
  else
    local spool = "clothing:yarn_spool_"..data.key1;
    local spool2 = "clothing:yarn_spool_"..data.key2;
    loom:recipe_register_input(
      "",
      {
        inputs = {spool2, spool,
                  spool, spool2,
                 },
        outputs = {{"clothing:fabric_"..color,"clothing:yarn_spool_empty 4"},},
        production_time = 30,
        consumption_step_size = 1,
      });
  end
end

loom:register_recipes("clothing_weaving", "")

minetest.register_lbm({
    label = "Upgrade old clothing loom.",
    name = "clothing:upgrade_loom",
    nodenames = {"clothing:loom"},
    run_at_every_load = false,
    action = function(pos, node)
        local meta = minetest.get_meta(pos);
        local inv = meta:get_inventory();
        if (inv:get_size("input")==1) then
          -- old loom detected
          inv:set_size("input", 4);
          inv:set_size("output", 4);
          loom:update_formspec(meta, 0, 1, 0, 1);
        end
      end,
  });
