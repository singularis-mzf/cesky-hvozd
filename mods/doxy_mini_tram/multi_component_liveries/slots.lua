-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

local S = minetest.get_translator("multi_component_liveries");

-- May livery_stack tables at indices 11 to 30.
multi_component_liveries.shared_slots = {};

-- Contains tables named after players.
-- Each table may livery_stack tables at indices 1 to 10.
multi_component_liveries.private_slots = {};

--! Replaces the data of @p livery_stack with that from a slot.
--!
--! @param playername Relevant for slot selection and feedback messages.
--! @param livery_stack is the livery_stack table which will be modified.
--! @param slot is the number of the slot which will be loaded from.
--! @param has_alpha_channel Whether the player’s tool has an alpha channel.
--!
--! @returns whether the layer stack has been changed. Textures need to be updated then.
function multi_component_liveries.load_from_slot(playername, livery_stack, slot, has_alpha_channel)
    if slot >= 1 and slot <= 10 then
        if not playername then
            return false;
        end

        if not (multi_component_liveries.private_slots[playername] and multi_component_liveries.private_slots[playername][slot]) then
            minetest.chat_send_player(playername, S("Private slot @1 is empty.", slot));
            return false;
        end

        multi_component_liveries.copy_livery_stack(multi_component_liveries.private_slots[playername][slot], livery_stack);

        return true;
    elseif slot >= 11 and slot <= 30 then
        if not multi_component_liveries.shared_slots[slot] then
            if playername then
                minetest.chat_send_player(playername, S("Shared slot @1 is empty.", slot));
            end
            return false;
        end

        multi_component_liveries.copy_livery_stack(multi_component_liveries.shared_slots[slot], livery_stack);

        return true;
    else
        if playername then
            if has_alpha_channel then
                minetest.chat_send_player(playername, S("There is no slot with number @1. Paint #000000 0% for help.", slot));
            else
                minetest.chat_send_player(playername, S("There is no slot with number @1. Paint #000000 for help.", slot));
            end
        end

        return false;
    end
end

--! Copies the data of @p livery_stack to a slot.
--!
--! @param playername Relevant for slot selection and feedback messages.
--! @param livery_stack is the livery_stack table which will be copied from.
--! @param slot is the number of the slot which will be saved to.
--! @param has_alpha_channel Whether the player’s tool has an alpha channel.
function multi_component_liveries.save_to_slot(playername, livery_stack, slot, has_alpha_channel)
    if slot >= 1 and slot <= 10 then
        if not playername then
            return;
        end

        if not multi_component_liveries.private_slots[playername] then
            multi_component_liveries.private_slots[playername] = {};
        end

        multi_component_liveries.private_slots[playername][slot] = {};
        multi_component_liveries.copy_livery_stack(livery_stack, multi_component_liveries.private_slots[playername][slot]);

        minetest.chat_send_player(playername, S("Saved livery in private slot @1.", slot));
    elseif slot >= 11 and slot <= 30 then
        multi_component_liveries.shared_slots[slot] = {};
        multi_component_liveries.copy_livery_stack(livery_stack, multi_component_liveries.shared_slots[slot]);

        if playername then
            minetest.chat_send_player(playername, S("Saved livery in shared slot @1.", slot));
        end
    else
        if playername then
            if has_alpha_channel then
                minetest.chat_send_player(playername, S("There is no slot with number @1. Paint #000000 0% for help.", slot));
            else
                minetest.chat_send_player(playername, S("There is no slot with number @1. Paint #000000 for help.", slot));
            end
        end
    end
end
