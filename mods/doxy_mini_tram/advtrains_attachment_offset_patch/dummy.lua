-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

local V = vector.new;

--! Executes the on_rightclick() method of the attachment parent of @p self,
--! if available.
local function forward_rightclick(self, clicker)
    local parent = self.object:get_attach();

    if parent then
        parent = parent:get_luaentity();
    else
        return;
    end

    if parent and parent.on_rightclick then
        return parent:on_rightclick(clicker);
    end
end

--! Executes the on_punch() method of the attachment parent of @p self,
--! if available, and if there are still players attached to this dummy.
--!
--! Otherwise, detaches any attached objects and destroys itself.
local function dummy_on_punch(self, clicker)
    local parent = self.object:get_attach();
    local children = self.object:get_children();

    if parent and next(children) then
        parent = parent:get_luaentity();
        if parent and parent.on_punch then
            return parent:on_punch(clicker);
        end
    else
        for _, child in ipairs(children) do
            child:set_detach();
        end

        self.object:remove();
    end
end

--! Inconveniently, entities disappear on their own when punched in any way,
--! and this can not be disabled in the entity definition.
local function make_immortal(self)
    self.object:set_armor_groups({ immortal = 1 });
end

--! Entities do not disappear automatically when their parent is removed.
local function disappear(self)
    self.object:remove();
end

local dummy_def = {
    -- The collision box encloses the player and that way allows
    -- to right-click the wagon even if outside the wagon’s
    -- not rotating collision box.
    collisionbox = { -0.7, -0.2, -0.7, 0.7, 2.2, 0.7 };

    -- Make semi-invisible.
    visual = "mesh";
    mesh = "advtrains_attachment_offset_patch_dummy.b3d";

    physical = false;
    static_save = false;
    visual_size = V(1, 1, 1);
    on_activate = make_immortal;
    on_detach = disappear;
    on_punch = dummy_on_punch;
    on_rightclick = forward_rightclick;
};

minetest.register_entity("advtrains_attachment_offset_patch:dummy_entity", dummy_def);
