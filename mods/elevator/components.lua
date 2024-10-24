
local phash = elevator.phash
local get_node = elevator.get_node
local ifthenelse = ch_core.ifthenelse

local homedecor_path = minetest.get_modpath("homedecor")
local mineclone_path = core.get_modpath("mcl_core") and mcl_core
local default_path = core.get_modpath("default") and default
local aurum_path = core.get_modpath("aurum") and aurum

local moditems = {} -- local table to hold substitutes

-- Use homedecor's placeholder if possible.
if homedecor_path then
    minetest.register_alias("elevator:placeholder", "homedecor:expansion_placeholder")
else
    -- Placeholder node, in the style of homedecor.
    minetest.register_node("elevator:placeholder", {
        description = "místodržící blok pro růst",
        selection_box = {
            type = "fixed",
            fixed = {0, 0, 0, 0, 0, 0},
        },
        groups = {
            not_in_creative_inventory=1
        },
        drawtype = "airlike",
        paramtype = "light",
        sunlight_propagates = true,

        walkable = false,
        buildable_to = false,
        is_ground_content = false,

        on_dig = function(pos, node, player)
            minetest.remove_node(pos)
            minetest.set_node(pos, {name="elevator:placeholder"})
        end
    })
end

if mineclone_path then
  moditems.el_shaft_groups = {pickaxey=1,axey=1,handy=1,swordy=1,transport=1,dig_by_piston=1}
  moditems.el_motor_groups = {pickaxey=1,axey=1,handy=1,swordy=1,transport=1,dig_by_piston=1}
  moditems.elevator_groups = {pickaxey=1,axey=1,handy=1,swordy=1,transport=1,dig_by_piston=1}
  moditems.elevator_special_groups = {not_in_creative_inventory=1,pickaxey=1,axey=1,handy=1,swordy=1,transport=1,dig_by_piston=1}
  moditems.sounds_stone = mcl_sounds.node_sound_stone_defaults
  moditems.el_motor_gfx = "elevator_motor_mcl.png"
  moditems.el_shaft_gfx = "elevator_shaft_mcl.png"
  moditems.el_box_gfx = "elevator_box_mcl.png"
  moditems.steel_block_image = "default_steel_block.png"
elseif default_path then
  moditems.el_shaft_groups = {cracky=2,oddly_breakable_by_hand=0} -- removing ability to destroy by hand to prevent accidental breakage of whole elevators
  moditems.el_motor_groups = {cracky=1}
  moditems.elevator_groups = {cracky=1,choppy=1,snappy=1}
  moditems.elevator_special_groups = {not_in_creative_inventory=1}
  moditems.sounds_stone = default.node_sound_stone_defaults
  moditems.el_motor_gfx = "elevator_motor.png"
  moditems.el_shaft_gfx = "elevator_shaft.png"
  moditems.el_box_gfx = "elevator_box.png"
  moditems.steel_block_image = "default_steel_block.png"
elseif aurum_path then
    moditems.el_shaft_groups = {dig_pick = 2}
    moditems.el_motor_groups = {dig_pick = 1}
    moditems.elevator_groups = {dig_pick = 1}
    moditems.elevator_special_groups = {not_in_creative_inventory=1}
    moditems.sounds_stone = aurum.sounds.stone
    moditems.el_motor_gfx = "elevator_motor.png"
    moditems.el_shaft_gfx = "elevator_shaft.png"
    moditems.el_box_gfx = "elevator_box.png"
    moditems.steel_block_image = "aurum_ore_white.png^[colorize:#cbcdcd:255^aurum_ore_bumps.png^aurum_ore_block.png"
end

moditems.elevator_groups_on = moditems.elevator_groups
moditems.elevator_groups_off = table.copy(moditems.elevator_groups)
moditems.elevator_groups_off.not_in_creative_inventory = 1

if minetest.global_exists("screwdriver") then
    moditems.on_rotate_disallow = screwdriver.disallow
end

minetest.register_node("elevator:shaft", {
    description = "šachta výtahu",
    -- _doc_items_longdesc = "An elevator shaft that connects elevators to other elevators and motors.",
    -- _doc_items_usagehelp = "Building a vertical stack of elevators and shafts with an elevator motor on top allows vertical transportation.",
    tiles = { moditems.el_shaft_gfx },
    drawtype = "nodebox",
    use_texture_alpha = "clip",
    paramtype = "light",
    on_rotate = moditems.on_rotate_disallow,
    sunlight_propagates = true,
    groups = moditems.el_shaft_groups,
    sounds = moditems.sounds_stone(),
    climbable = true,
    node_box = {
        type = "fixed",
        fixed = {
            {-8/16,-8/16,-8/16,-7/16,8/16,8/16},
            {7/16,-8/16,-8/16,8/16,8/16,8/16},
            {-7/16,-8/16,-8/16,7/16,8/16,-7/16},
            {-7/16,-8/16,8/16,7/16,8/16,7/16},
        },
    },
    collisionbox = {
        type = "fixed",
        fixed = {
            {-8/16,-8/16,-8/16,-7/16,8/16,8/16},
            {7/16,-8/16,-8/16,8/16,8/16,8/16},
            {-7/16,-8/16,-8/16,7/16,8/16,-7/16},
            {-7/16,-8/16,8/16,7/16,8/16,7/16},
        },
    },
    after_place_node = function(pos)
        -- We might have connected a motor above to an elevator below.
        elevator.build_motor(elevator.locate_motor(pos))
    end,
    on_destruct = function(pos)
        -- Remove boxes and deactivate elevators below us.
        elevator.unbuild(pos, 1)
    end,
    _mcl_blast_resistance = 15, -- mineclone2 specific
    _mcl_hardness = 5, -- mineclone2 specific
  })

minetest.register_node("elevator:motor", {
    description = "motor výtahu",
    -- _doc_items_longdesc = "The engine powering an elevator shaft. Placed at the top.",
    -- _doc_items_usagehelp = "Place the motor on the top of a stack of elevators and elevator shafts. The elevators will activate and you can then use them.",
    tiles = {
        moditems.steel_block_image,
        moditems.steel_block_image,
        moditems.el_motor_gfx,
        moditems.el_motor_gfx,
        moditems.el_motor_gfx,
        moditems.el_motor_gfx,
    },
    groups = moditems.el_motor_groups,
    sounds = moditems.sounds_stone(),
    after_place_node = function(pos, placer, itemstack)
        -- Set up the motor table.
        elevator.motors[phash(pos)] = {
            elevators = {},
            pnames = {},
            labels = {},
        }
        elevator.save_elevator()
        elevator.build_motor(phash(pos))
    end,
    on_destruct = function(pos)
        -- Destroy everything related to this motor.
        elevator.boxes[phash(pos)] = nil
        elevator.motors[phash(pos)] = nil
        elevator.save_elevator()
    end,
    _mcl_blast_resistance = 15,  -- mineclone2 specific
	  _mcl_hardness = 5, -- mineclone2 specific
})

-- Box of the active entitity.
local box_box = {
    { 0.48, -0.5,-0.5,  0.5,  1.5, 0.5},
    {-0.5 , -0.5, 0.48, 0.48, 1.5, 0.5},
    {-0.5,  -0.5,-0.5 ,-0.48, 1.5, 0.5},
    {-0.5 , -0.5, -0.48, 0.5, 1.5, -0.5},
    { -0.5,-0.5,-0.5,0.5,-0.48, 0.5},
    { -0.5, 1.45,-0.5,0.5, 1.5, 0.5},
}

-- Elevator box node. Not intended to be placeable.
minetest.register_node("elevator:elevator_box", {
    description = "stanice výtahu",
    drawtype = "nodebox",
    paramtype = 'light',
    paramtype2 = "facedir",
    wield_scale = {x=0.6, y=0.6, z=0.6},

    selection_box = {
            type = "fixed",
            fixed = { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 }
    },

    collision_box = {
            type = "fixed",
            fixed = box_box,
    },

    node_box = {
            type = "fixed",
            fixed = box_box,
    },

    tiles = {
            moditems.steel_block_image,
            moditems.steel_block_image,
            moditems.el_box_gfx,
            moditems.el_box_gfx,
            moditems.el_box_gfx,
            moditems.el_box_gfx,
    },
    groups = moditems.elevator_special_groups,
    use_texture_alpha = "clip",

    light_source = 4,
    _mcl_blast_resistance = 15, -- mineclone2 specific
    _mcl_hardness = 5, -- mineclone2 specific
})

local function elevator_on_rightclick(pos, node, sender, itemstack, pointed_thing)
    local player_name = sender and sender:is_player() and sender:get_player_name()
    if not player_name then
        return
    end
    local nodename = node.name
    -- When the player is holding elevator components, just place them instead of opening the formspec.
    if ({
      ["elevator:elevator_off"] = true,
      ["elevator:shaft"] = true,
      ["elevator:motor"] = true,
    })[sender:get_wielded_item():get_name()] then
        return core.item_place_node(itemstack, sender, pointed_thing)
    end
    local formspec = {"size[4,5.75]"}
    local meta = minetest.get_meta(pos)
    elevator.formspecs[sender:get_player_name()] = {pos}
    local motorhash = meta:get_string("motor")
    local is_protected = minetest.is_protected(pos, player_name)
    if node.name == "elevator:elevator_on" and elevator.motors[motorhash] then
        -- aktivní výtah s motorem:
        -- ========================
        if vector.distance(sender:get_pos(), pos) > 1 or minetest.get_node(sender:get_pos()).name ~= nodename then
            ch_core.systemovy_kanal(player_name, "Nestojíte uvnitř kabiny!")
            return
        end
        -- Build the formspec from the motor table.
        local tpnames = {}
        local tpnames_l = {}
        local motor = elevator.motors[motorhash]
        for ji,jv in ipairs(motor.pnames) do
            if tonumber(jv) ~= pos.y then
                table.insert(tpnames, jv)
                table.insert(tpnames_l, (motor.labels[ji] and motor.labels[ji] ~= "") and (jv.." - "..minetest.formspec_escape(motor.labels[ji])) or jv)
            end
        end
        elevator.formspecs[player_name] = {pos, tpnames}
        if #tpnames > 0 then
            table.insert(formspec, "label[0,0;Zvolte cílové patro:]"..
                "textlist[-0.1,0.5;4,4;target;"..table.concat(tpnames_l, ",").."]")
        else
            table.insert(formspec, "label[0,0;Žádné cílové stanice.]")
        end
        table.insert(formspec, "label[0,4.6;ZDE: >"..minetest.formspec_escape(meta:get_string("label")).."<]")
    elseif not elevator.motors[motorhash] then
        -- výtah bez motoru
        table.insert(formspec, "label[0,0;Výtah je mimo provoz.]")
    elseif elevator.boxes[motorhash] then
        table.insert(formspec, "label[0,0;Tato šachta je již obsazena.]")
    else
        formspec = nil
    end

    if formspec ~= nil then
        if not is_protected then
            table.insert(formspec, "button[-0.05,5.0;4,1;edit;Přejmenovat patro...]")
        end
        formspec = table.concat(formspec)
        minetest.show_formspec(player_name, "elevator:elevator", formspec)
    end
end


for _,mode in ipairs({"on", "off"}) do
    local nodename = "elevator:elevator_"..mode
    local on = (mode == "on")
    local box
    local cbox
    if on then
        -- Active elevators have a ceiling and floor.
        box = {

            { 0.48, -0.5,-0.5,  0.5,  1.5, 0.5},
            {-0.5 , -0.5, 0.48, 0.48, 1.5, 0.5},
            {-0.5,  -0.5,-0.5 ,-0.48, 1.5, 0.5},

            { -0.5,-0.5,-0.5,0.5,-0.48, 0.5},
            { -0.5, 1.45,-0.5,0.5, 1.5, 0.5},
        }
        cbox = table.copy(box)
        -- But you can enter them from the top.
        cbox[5] = nil
    else
        -- Inactive elevators are almost like shafts.
        box = {

            { 0.48, -0.5,-0.5,  0.5,  1.5, 0.5},
            {-0.5 , -0.5, 0.48, 0.48, 1.5, 0.5},
            {-0.5,  -0.5,-0.5 ,-0.48, 1.5, 0.5},
            {-0.5 , -0.5, -0.48, 0.5, 1.5, -0.5},
        }
        cbox = box
    end
    minetest.register_node(nodename, {
        description = "stanice výtahu",
        drawtype = "nodebox",
        sunlight_propagates = false,
        paramtype = "light",
        paramtype2 = "facedir",
        on_rotate = moditems.on_rotate_disallow,
        climbable = true,

        -- _doc_items_longdesc = on and "An active elevator, ready for transporting." or "An inactive elevator, not connected to a motor.",
        -- _doc_items_usagehelp = on and "Step inside this elevator and use it (right-click) to be transported to any other elevator along the shaft." or "This elevator is inactive; it is disconnected from a motor. It may be extended with shafts and other elevators in a vertical line with an elevator motor on top to power the whole shaft and enable transport.",

        selection_box = {
                type = "fixed",
                fixed = box,
        },

        collision_box = {
                type = "fixed",
                fixed = cbox,
        },

        node_box = {
                type = "fixed",
                fixed = box,
        },

        tiles = on and {
                moditems.steel_block_image,
                moditems.steel_block_image,
                moditems.el_box_gfx,
                moditems.el_box_gfx,
                moditems.el_box_gfx,
                moditems.el_box_gfx,
        } or {
                moditems.el_box_gfx,
                moditems.el_box_gfx,
                moditems.el_box_gfx,
                moditems.el_box_gfx,
                moditems.el_box_gfx,
                moditems.el_box_gfx,
        },
        use_texture_alpha = "clip",

        groups = mode == "on" and moditems.elevator_groups_on or moditems.elevator_groups_off,
        drop = "elevator:elevator_off",

        -- Emit a bit of light when active.
        light_source = (on and 4 or nil),

        after_place_node  = function(pos, placer, itemstack)
            local meta = minetest.get_meta(pos)
            meta:set_int("version", elevator.VERSION)

            -- Add a placeholder to avoid nodes being placed in the top.
            local p = vector.add(pos, {x=0, y=1, z=0})
            local p2 = minetest.dir_to_facedir(placer:get_look_dir())
            minetest.set_node(p, {name="elevator:placeholder", paramtype2="facedir", param2=p2})

            -- Try to build a motor above.
            local motor = elevator.locate_motor(pos)
            if motor then
                elevator.build_motor(motor)
            end
        end,

        after_dig_node = function(pos, node, meta, digger)
            elevator.unbuild(pos, 2)
        end,

        on_place = function(itemstack, placer, pointed_thing)
            local pos  = pointed_thing.above
            local node = minetest.get_node(vector.add(pos, {x=0, y=1, z=0}))
            if (node ~= nil and node.name ~= "air" and node.name ~= "elevator:placeholder") then
                return
            end
            return minetest.item_place(itemstack, placer, pointed_thing)
        end,

        on_rightclick = elevator_on_rightclick,

        on_destruct = function(pos)
            local p = vector.add(pos, {x=0, y=1, z=0})
            if get_node(p).name == "elevator:placeholder" then
                minetest.remove_node(p)
            end
        end,

        _mcl_blast_resistance = 15, -- mineclone2 specific
        _mcl_hardness = 5, -- mineclone2 specific
    })
end

-- Compatability with an older version.
minetest.register_alias("elevator:elevator", "elevator:elevator_off")
