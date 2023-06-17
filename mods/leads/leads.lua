--[[
    Leads — Adds leads for transporting animals to Minetest.
    Copyright © 2023, Silver Sandstone <@SilverSandstone@craftodon.social>

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
]]


--- Lead entity definition.
-- @module leads


local S = leads.S;


leads.MIN_BREAK_AGE = 1.0;
leads.STRETCH_SOUND_INTERVAL = 2.0;


--- The main lead entity.
-- @type LeadEntity
leads.LeadEntity = {};

leads.LeadEntity.description = S'Lead';

leads.LeadEntity._leads_immobile = true;

leads.LeadEntity.initial_properties =
{
    visual       = 'mesh';
    visual_size  = vector.new(0.5, 0.5, 0.5);
    mesh         = 'leads_lead.obj';
    textures     = {'leads_lead.png'};
    physical     = false;
    selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5};
};

--- Spawns or unloads a lead.
function leads.LeadEntity:on_activate(staticdata, dtime_s)
    self.current_length = 1;
    self.max_length = leads.settings.lead_length;
    self.rotation = vector.zero();
    self.leader_attach_offset = vector.zero();
    self.follower_attach_offset = vector.zero();
    self.age = 0.0;
    self.sound_timer = 0.0;

    local data = minetest.deserialize(staticdata);
    if data then
        self:load_from_data(data);
    end;

    self.object:set_armor_groups{fleshy = 0};
end;

--- Initialises the lead's state from a table.
function leads.LeadEntity:load_from_data(data)
    self.item = data.item or self.item;
    self.max_length = data.max_length or self.max_length;
    self.leader_id = data.leader_id or {};
    self.follower_id = data.follower_id or {};
    self.leader_id.pos   = vector.new(self.leader_id.pos);
    self.follower_id.pos = vector.new(self.follower_id.pos);
    self:update_visuals();
end;

--- Steps the knot.
function leads.LeadEntity:on_step(dtime)
    self.age = self.age + dtime;
    self:_update_connectors();
    local success, pos, offset = self:step_physics(dtime);
    if success then
        self.current_length = math.max(offset:length(), 0.25);
        self.rotation = offset:dir_to_rotation();
        self.object:move_to(pos, true);
        self:update_visuals();
    end;
end;

--- Simulates the lead's physics.
-- @param dtime [number]  The time elapsed since the last tick, in seconds.
-- @return      [boolean] true if the lead is functioning correctly, or false if it should break.
-- @return      [vector]  The centre position of the lead.
-- @return      [vector]  The offset between the leader and the follower.
function leads.LeadEntity:step_physics(dtime)
    local l_pos = self.leader_pos;
    local f_pos = self.follower_pos;
    if not (l_pos and f_pos) then
        self:break_lead();
        return false, nil, nil;
    end;

    l_pos = l_pos + self.leader_attach_offset;
    f_pos = f_pos + self.follower_attach_offset;

    local pull_distance = self.max_length;
    local break_distance = pull_distance * 2;
    local distance = l_pos:distance(f_pos);
    if distance > break_distance and self.age > leads.MIN_BREAK_AGE then
        -- Lead is too long, break:
        self:break_lead(nil, true);
        return false, nil, nil;
    end;

    local pos = (f_pos + l_pos) / 2;
    if self.follower and distance > pull_distance then
        -- Pull follower:
        if not leads.is_immobile(self.follower) then
            local force = (distance - pull_distance) * leads.settings.pull_force / pull_distance;
            self.follower:add_velocity((l_pos - f_pos):normalize() * dtime * force);
        end;

        -- Play stretching sound:
        self.sound_timer = self.sound_timer + dtime;
        if self.sound_timer >= leads.STRETCH_SOUND_INTERVAL then
            self.sound_timer = self.sound_timer - leads.STRETCH_SOUND_INTERVAL;
            if leads.util.rng:next(0, 8) == 0 then
                minetest.sound_play(leads.sounds.stretch, {pos = pos}, true);
            end;
        end;
    end;
    return true, pos, f_pos - l_pos;
end;

--- Updates the connector references and stored positions.
-- @local
function leads.LeadEntity:_update_connectors()
    local function _get_pos(key)
        local object = self[key];
        local pos = object and object:get_pos();
        local id = self[key .. '_id'];
        if not pos then
            pos = id.pos;
            if not pos then
                return nil;
            end;

            local object = leads.util.deserialise_objref(id);
            if object then
                pos = object:get_pos();
                self[key] = object;
                self[key .. '_attach_offset'] = leads.util.get_attach_offset(object);
            else
                -- The object reference is invalid and deserialising the
                -- object failed. This could mean that the object has been
                -- removed and the lead should break, or it could mean that
                -- the object's mapblock has been unloaded, and the lead
                -- should just wait until it gets loaded again. We can figure
                -- out which one by checking if the mapblock is active.
                if minetest.compare_block_status(pos, 'active') then
                    return nil;
                end;
            end;
        end;
        id.pos = pos or id.pos;
        return pos;
    end;

    self.leader_pos   = _get_pos('leader');
    self.follower_pos = _get_pos('follower');
end;

--- Handles the lead being punched.
function leads.LeadEntity:on_punch(puncher, time_from_last_punch, tool_capabilities, dir, damage)
    self:break_lead(puncher);

    local name = puncher and puncher:get_player_name();
    if name and name ~= '' then
        leads.util.block_player_interaction(name, 0.25);
    end;

    return true;
end;

--- Handles the lead being ‘killed’.
function leads.LeadEntity:on_death(killer)
    self:break_lead(killer);
end;

--- Returns the lead's state as a table.
function leads.LeadEntity:get_staticdata()
    local data = {};
    data.item = self.item;
    data.max_length = self.max_length;
    data.leader_id = self.leader_id;
    data.follower_id = self.follower_id;
    return minetest.serialize(data);
end;

--- Breaks the lead, possibly giving/dropping an item.
-- @param breaker [ObjectRef|nil] The object breaking the lead.
-- @param snap    [boolean|nil]   true if the lead is breaking due to tension.
function leads.LeadEntity:break_lead(breaker, snap)
    if leads.settings.debug then
        minetest.debug(debug.traceback(('[Leads] Breaking lead %s at %s.'):format(self, self.object:get_pos())));
    end;

    -- Notify leader and follower:
    self:notify_connector_removed(self.leader,   true);
    self:notify_connector_removed(self.follower, false);

    -- Give or drop item:
    if self.item then
        local owner = breaker;
        if not (owner and owner:get_inventory()) then
            owner = self.leader;
        end;
        local pos = self.object:get_pos();
        minetest.handle_node_drops(pos, {self.item}, owner);
    end;

    -- Play sound:
    if snap then
        minetest.sound_play(leads.sounds.snap, {pos = self.object:get_pos()}, true);
    else
        minetest.sound_play(leads.sounds.remove, {pos = self.object:get_pos()}, true);
    end;

    -- Remove lead:
    self.object:remove();
    self.item = nil;
end;

--- Updates the visual properties of the lead to show its current state.
function leads.LeadEntity:update_visuals()
    local SCALE = 8;

    local properties = {visual_size = vector.new(10, 10, 10 * self.current_length)};
    if leads.settings.dynamic_textures then
        local texture = leads.util.tile_texture('leads_lead.png', 96 * SCALE, 2 * SCALE, math.floor(self.current_length * 16 * SCALE), 2 * SCALE);
        properties.textures = {texture};
    end;
    if leads.settings.rotate_selection_box then
        properties.selectionbox = {-0.0625, -0.0625, -self.current_length / 2,
                                    0.0625,  0.0625,  self.current_length / 2, rotate = true};
    end;
    self.object:set_properties(properties);
    self.object:set_rotation(self.rotation);
end;

--- Updates the connector IDs to reflect the current connectors.
function leads.LeadEntity:update_objref_ids()
    self.leader_id   = leads.util.serialise_objref(self.leader)   or self.leader_id;
    self.follower_id = leads.util.serialise_objref(self.follower) or self.follower_id;
    self:update_attach_offsets();
end;


--- Updates the attachment offsets to reflect the current connectors' properties.
function leads.LeadEntity:update_attach_offsets()
    self.leader_attach_offset   = leads.util.get_attach_offset(self.leader)   or self.leader_attach_offset;
    self.follower_attach_offset = leads.util.get_attach_offset(self.follower) or self.follower_attach_offset;
end;

--- Transfers this lead to a new leader.
-- @param leader [ObjectRef] The new leader object.
-- @return       [boolean]   true on success.
function leads.LeadEntity:set_leader(leader)
    return self:set_connector(leader, true);
end;

--- Transfers this lead to a new follower.
-- @param follower [ObjectRef] The new follower object.
-- @return         [boolean]   true on success.
function leads.LeadEntity:set_follower(follower)
    return self:set_connector(follower, false);
end;

--- Transfers this lead to a new leader or follower.
-- @param object    [ObjectRef] The new connector.
-- @param is_leader [boolean]   true to set the leader, false to set the follower.
-- @return          [boolean]   true on success.
function leads.LeadEntity:set_connector(object, is_leader)
    if (self.leader   and leads.util.is_same_object(object, self.leader)) or
       (self.follower and leads.util.is_same_object(object, self.follower)) then
        return false;
    end;

    local key = is_leader and 'leader' or 'follower';
    local old_object = self[key];
    self:notify_connector_removed(old_object, is_leader);
    self[key] = object;
    self:notify_connector_added(object, is_leader);
    self:update_objref_ids();
    self.age = 0.0;
    return true;
end;

--- Reverses the direction of the lead, swapping the leader and follower.
function leads.LeadEntity:reverse()
    self.leader,    self.follower    = self.follower,    self.leader;
    self.leader_id, self.follower_id = self.follower_id, self.leader_id;
end;

--- Notifies the connector that this lead has been added.
-- @param object    [ObjectRef] The connector to notify.
-- @param is_leader [boolean]   true if the connector is the leader.
function leads.LeadEntity:notify_connector_added(object, is_leader)
    local entity = object and object:get_luaentity();
    if entity and entity._leads_lead_add then
        entity:_leads_lead_add(self, is_leader or false);
    end;
end;

--- Notifies the connector that this lead has been removed.
-- @param object    [ObjectRef] The connector to notify.
-- @param is_leader [boolean]   true if the connector was the leader.
function leads.LeadEntity:notify_connector_removed(object, is_leader)
    local entity = object and object:get_luaentity();
    if entity and entity._leads_lead_remove then
        entity:_leads_lead_remove(self, is_leader or false);
    end;
end;

minetest.register_entity('leads:lead', leads.LeadEntity);
