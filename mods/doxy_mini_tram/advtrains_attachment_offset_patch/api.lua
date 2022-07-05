-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

--! Tries to insert an attachment dummy to the attachment of @p player,
--! if it is attached to an entity called @p parent_name.
--!
--! @param player A player luaentity.
--! @param parent_name The entity name of the entity on which @p player is expected.
--! @param rotation Additional rotation for the new attachment. (Optional)
function advtrains_attachment_offset_patch.attach_player(player, parent_name, rotation)
    local attachment_parent, _, attachment_offset, attachment_rotation = player:get_attach();
    if not attachment_parent then
        return;
    end

    local attachment_parent_entity =  attachment_parent:get_luaentity();
    if attachment_parent_entity.name ~= parent_name then
        return;
    end

    if rotation then
        attachment_rotation.x = attachment_rotation.x + rotation.x;
        attachment_rotation.y = attachment_rotation.y + rotation.y;
        attachment_rotation.z = attachment_rotation.z + rotation.z;
    end

    local dummy = minetest.add_entity(attachment_parent:get_pos(), "advtrains_attachment_offset_patch:dummy_entity");
    dummy:set_attach(attachment_parent, "", attachment_offset, attachment_rotation);

    player:set_attach(dummy);
end

--! Removes attachment dummies attached to @p object which are not used anymore.
--! @p object is an ObjectRef.
function advtrains_attachment_offset_patch.cleanup_dummies(object)
    local attached_children = object:get_children();
    for _, child in ipairs(attached_children) do
        local luaentity = child:get_luaentity();
        if luaentity and luaentity.name == "advtrains_attachment_offset_patch:dummy_entity" then
            local attached_players = child:get_children();
            if not next(attached_players) then
                child:remove();
            end
        end
    end
end

--! Adds method overrides to the wagon definition table @p wagon,
--! so players are attached via a dummy entity,
--! whenever they get on the wagon via the advtrains core logic.
function advtrains_attachment_offset_patch.setup_advtrains_wagon(wagon)
    wagon.get_on = advtrains_attachment_offset_patch.get_on_override;
    wagon.get_off = advtrains_attachment_offset_patch.get_off_override;
end
