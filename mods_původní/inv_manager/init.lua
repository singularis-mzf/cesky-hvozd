--[[

The MIT License (MIT)
Copyright (C) 2023 Acronymmk

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

]]

local function is_slot_free(inv, itemstack, inventory_name)
    local free_slots = 0

    for i = 1, inv:get_size(inventory_name) do
        local stack = inv:get_stack(inventory_name, i)
        if stack:is_empty() then
            free_slots = free_slots + 1
        elseif stack:get_name() == itemstack:get_name() then
            local space_left = stack:get_free_space()
            if space_left > 0 then
                free_slots = free_slots + 1
            end
        end
    end
    return free_slots > 0
end

local function build_inventory_formspec(inv, playername, own_inv, owner_name, action)
    local elements = {
        "size[8,10.5]"
    }

    if action == "main" then
        table.insert(elements, "label[0,0;MAIN INVENTORY: " .. minetest.colorize("#00FF7F", playername or "unknown") .. "]")
    elseif action == "craft" then
        table.insert(elements, "label[0,0;CRAFT INVENTORY: " .. minetest.colorize("#00FF7F", playername or "unknown") .. "]")
    end

    table.insert(elements, "label[0,5.02;MAIN INVENTORY: " .. minetest.colorize("#01B5F7", owner_name or "unknown") .. "]")
    table.insert(elements, "box[-0.1,-0.1;8,0.7;black]")
    table.insert(elements, "box[-0.1,4.9;8,0.7;black]")
    table.insert(elements, "button_exit[0,9.9;2,1;cancel;Close]")

    if action == "main" then
        for i = 1, inv:get_size("main") do
            local itemstack = inv:get_stack("main", i)
            local itemname = itemstack:get_name()
            local itemcount = itemstack:get_count()
            
            local item_image = "item_image[" .. (i-1) % 8 .. "," .. math.floor((i-1) / 8) + 0.8 .. ";1,1;" .. itemname .. "]"
            local transfer_button = "image_button[" .. (i-1) % 8 .. "," .. math.floor((i-1) / 8) + 0.8 .. ";1,1;inv_manager_bg.png;transfer_" .. playername .. "_" .. i .. ";]"
            
            local itemcount_label = ""
            if itemcount > 1 then
                itemcount_label = "label[" .. (i-0.95) % 8 .. "," .. math.floor((i-1) / 8) + 1.3 .. ";" .. itemcount .. "]"
            end
            
            local tooltip = "tooltip[transfer_" .. playername .. "_" .. i .. ";" .. itemname .. "]"
            
            table.insert(elements, item_image)
            table.insert(elements, transfer_button .. tooltip)
            table.insert(elements, itemcount_label)
        end
    elseif action == "craft" then
        for i = 1, inv:get_size("craft") do
            local itemstack = inv:get_stack("craft", i)
            local itemname = itemstack:get_name()
            local itemcount = itemstack:get_count()
            
            local item_image = "item_image[" .. (i-1) % 3 + 2.5 .. "," .. math.floor((i-1) / 3) + 0.8 .. ";1,1;" .. itemname .. "]"
            local transfer_button = "image_button[" .. (i-1) % 3 + 2.5 .. "," .. math.floor((i-1) / 3) + 0.8 .. ";1,1;inv_manager_bg.png;transfer_" .. playername .. "_" .. i .. ";]"
            
            local itemcount_label = ""
            if itemcount > 1 then
                itemcount_label = "label[" .. (i-0.95) % 3 + 2.5 .. "," .. math.floor((i-1) / 3) + 1.3 .. ";" .. itemcount .. "]"
            end
            
            local tooltip = "tooltip[transfer_" .. playername .. "_" .. i .. ";" .. itemname .. "]"
            
            table.insert(elements, item_image)
            table.insert(elements, transfer_button .. tooltip)
            table.insert(elements, itemcount_label)
        end
    end

    for p = 1, own_inv:get_size("main") do
        local itemstack = own_inv:get_stack("main", p)
        local itemname = itemstack:get_name()
        local itemcount = itemstack:get_count()
        
        local item_image = "item_image[" .. (p-1) % 8 .. "," .. math.floor((p+23) / 8) + 2.8 .. ";1,1;" .. itemname .. "]"
        local transfer_button = "image_button[" .. (p-1) % 8 .. "," .. math.floor((p+23) / 8) + 2.8 .. ";1,1;inv_manager_bg.png;transfers_" .. playername .. "_" .. p .. ";]"
        
        local itemcount_label = ""
        if itemcount > 1 then
            itemcount_label = "label[" .. (p-0.95) % 8 .. "," .. math.floor((p+23) / 8) + 3.3 .. ";" .. itemcount .. "]"
        end
        
        local tooltip = "tooltip[transfers_" .. playername .. "_" .. p .. ";" .. itemname .. "]"
        
        table.insert(elements, item_image)
        table.insert(elements, transfer_button .. tooltip)
        table.insert(elements, itemcount_label)
    end

    return table.concat(elements, "")
end


local function update_inventory_formspec(name, playername, action)
    local player = minetest.get_player_by_name(playername)
    local owner = minetest.get_player_by_name(name)

    if not player then
        return
    end

    local inv = player:get_inventory()
    local own_inv = owner:get_inventory()
    local owner_name = owner:get_player_name(name)
    local formspec = build_inventory_formspec(inv, playername, own_inv, owner_name, action)

    if action == "main" then
        minetest.show_formspec(name, "inv_manager:inventory", formspec)

        minetest.register_on_player_receive_fields(function(player, formname, fields)
            if formname == "inv_manager:inventory" then
                if fields.cancel then
                    minetest.close_formspec(playername, "inv_manager:inventory")
                end

                for i = 1, inv:get_size("main") do
                    if fields["transfer_" .. playername .. "_" .. i] then
                        local itemstack = inv:get_stack("main", i)
                        local itemname = itemstack:get_name()
                        local itemcount = itemstack:get_count()

                        if is_slot_free(own_inv, ItemStack(itemname .. " " .. itemcount), "main") then
                            inv:remove_item("main", ItemStack(itemname .. " " .. itemcount))
                            own_inv:add_item("main", ItemStack(itemname .. " " .. itemcount))
                        end
                    end
                end

                for p = 1, own_inv:get_size("main") do
                    if fields["transfers_" .. playername .. "_" .. p] then
                        local itemstack = own_inv:get_stack("main", p)
                        local itemname = itemstack:get_name()
                        local itemcount = itemstack:get_count()

                        if is_slot_free(inv, ItemStack(itemname .. " " .. itemcount), "main") then
                            own_inv:remove_item("main", ItemStack(itemname .. " " .. itemcount))
                            inv:add_item("main", ItemStack(itemname .. " " .. itemcount))
                        end
                    end
                end
            end
        end)
    elseif action == "craft" then
        minetest.show_formspec(name, "inv_manager:craft_inventory", formspec)

        minetest.register_on_player_receive_fields(function(player, formname, fields)
            if formname == "inv_manager:craft_inventory" then
                if fields.cancel then
                    minetest.close_formspec(playername, "inv_manager:craft_inventory")
                end

                for i = 1, inv:get_size("craft") do
                    if fields["transfer_" .. playername .. "_" .. i] then
                        local itemstack = inv:get_stack("craft", i)
                        local itemname = itemstack:get_name()
                        local itemcount = itemstack:get_count()

                        if is_slot_free(own_inv, ItemStack(itemname .. " " .. itemcount), "main") then
                            inv:remove_item("craft", ItemStack(itemname .. " " .. itemcount))
                            own_inv:add_item("main", ItemStack(itemname .. " " .. itemcount))
                        end
                    end
                end

                for p = 1, own_inv:get_size("main") do
                    if fields["transfers_" .. playername .. "_" .. p] then
                        local itemstack = own_inv:get_stack("main", p)
                        local itemname = itemstack:get_name()
                        local itemcount = itemstack:get_count()

                        if is_slot_free(inv, ItemStack(itemname .. " " .. itemcount), "craft") then
                            own_inv:remove_item("main", ItemStack(itemname .. " " .. itemcount))
                            inv:add_item("craft", ItemStack(itemname .. " " .. itemcount))
                        end
                    end
                end
            end
        end)
    end
end

local inventory_lock = false

local function check_player_online(playername, targetname)
    local player = minetest.get_player_by_name(targetname)
    if not player then
        minetest.close_formspec(playername, "inv_manager:inventory")
        minetest.close_formspec(playername, "inv_manager:craft_inventory")
        return false
    end
    return true
end

minetest.register_privilege("inv_manager", {
    description = "Manage players' inventory",
    give_to_singleplayer = false,
})

minetest.register_chatcommand("inv_edit", {
    description = "Manage player inventory",
    params = "<playername> <action>",
    privs = {
        inv_manager = true
    },
    func = function(name, param)
        local params = param:split(" ")
        if #params ~= 2 then
            minetest.chat_send_player(name, "*** Server: wrong use, /inv_edit <playername> <main|craft>")
            return
        end

        local player = minetest.get_player_by_name(params[1])
        if player then
            local playername = player:get_player_name()
            if params[2] == "main" or params[2] == "craft" then
                if not inventory_lock then
                    inventory_lock = true
                    update_inventory_formspec(name, playername, params[2])
                    if not check_player_online(name, playername) then
                        inventory_lock = false
                        return
                    end

                    local timer = 0
                    local stop_globalstep = false

                    minetest.register_on_player_receive_fields(function(player, formname, fields)
                        if formname == "inv_manager:inventory" and fields.cancel then
                            stop_globalstep = true
                            inventory_lock = false
                            minetest.close_formspec(playername, "inv_manager:inventory")
                        end
                        if formname == "inv_manager:craft_inventory" and fields.cancel then
                            stop_globalstep = true
                            inventory_lock = false
                            minetest.close_formspec(playername, "inv_manager:craft_inventory")
                        end
                    end)

                    minetest.register_globalstep(function(dtime)
                        if not stop_globalstep then
                            timer = timer + dtime
                            if timer >= 1 then
                                if not check_player_online(name, playername) then
                                    inventory_lock = false
                                    return
                                end
                                update_inventory_formspec(name, playername, params[2])
                                timer = 0
                            end
                        end
                    end)
                else
                    minetest.chat_send_player(name, "*** Server: only 1 moderator/admin can use this command at a time. Please try again later.")
                end
            else
                minetest.chat_send_player(name, "*** Server: Invalid action, use '/inv_edit <playername> <main|craft>'.")
            end
        else
            minetest.chat_send_player(name, "*** Server: player '" .. params[1] .. "' not found.")
        end
    end
})
