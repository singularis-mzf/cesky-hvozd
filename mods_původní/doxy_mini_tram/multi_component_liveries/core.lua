-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later
--
-- This file contains code from the JR_E231series_modpack.
-- https://git.bananach.space/JR_E231series_modpack.git
-- SPDX-FileCopyrightText: 2019 Gabriel Pérez-Cerezo <gabriel@gpcf.eu>
-- SPDX-License-Identifier: LGPL-2.1-only

local S = minetest.get_translator("multi_component_liveries");

--! Extracts red, green, blue, and optionally alpha components from @p itemstack.
--! If the tool does not provide appropriate data, an error message is sent to @p playername.
--!
--! @returns components r, g, b, a; each as integer 0..255 or nil; or nil on failure.
function multi_component_liveries.get_components_from_painting_tool(playername, itemstack)
    -- This function contains code from the JR_E231series_modpack.
    local meta = itemstack:get_meta();
    local color = meta:get_string("paint_color");
    local alpha = meta:get_string("alpha");

    if color == "" then
        if playername then
            minetest.chat_send_player(playername, S("This tool does not provide recognized color data."));
        end
        return nil;
    end

    local r, g, b, a;
    if string.find(color, "^#%x%x%x%x%x%x$") or string.find(color, "^#%x%x%x%x%x%x%x%x$") then
        r = tonumber(string.sub(color, 2, 3), 16);
        g = tonumber(string.sub(color, 4, 5), 16);
        b = tonumber(string.sub(color, 6, 7), 16);

        if #color == 9 then
            a = tonumber(string.sub(color, 8, 9), 16);
        else
            a = tonumber(alpha);
        end

        return r, g, b, a;
    else
        if playername then
            minetest.chat_send_player(playername, S("This tool has invalid color data: @1", color));
        end
        return nil;
    end
end

--! Sends a message that the used color is a meta color which is not defined.
--!
--! @param playername Message is sent to this player.
--! @param has_alpha_channel Whether the player’s tool has an alpha channel.
function multi_component_liveries.handle_undefined_metacolor(playername, has_alpha_channel)
    if not playername then
        return;
    end

    if has_alpha_channel then
        minetest.chat_send_player(playername, S("Undefined meta color. Paint #000000 0% for help."));
    else
        minetest.chat_send_player(playername, S("Undefined meta color. Paint #000000 for help."));
    end
end

--! Sends instructions for how to paint this livery via a chat message.
--!
--! @param playername Instructions are sent to this player.
--! @param livery_stack Describes the current livery state.
--! @param livery_definition Describes available livery components.
--! @param has_alpha_channel Whether the player’s tool has an alpha channel.
function multi_component_liveries.send_player_help_message(playername, livery_stack, livery_definition, has_alpha_channel)
    if not playername then
        return;
    end

    local meta_definition;
    if has_alpha_channel then
        meta_definition = S("Meta colors have red and alpha components set to zero.");
    else
        meta_definition = S("Meta colors have the red component set to zero.");
    end

    local preset_choices = {};
    for i, v in ipairs(livery_definition.presets) do
        table.insert(preset_choices, S(" * P = @1 — @2", i, v.description));
    end
    preset_choices = table.concat(preset_choices, "\n");

    local component_choices = {};
    for i, v in ipairs(livery_definition.components) do
        table.insert(component_choices, S(" * C = @1 — @2", i, v.description));
    end
    component_choices = table.concat(component_choices, "\n");

    local current_components = {};
    if #livery_stack.layers >= 1 then
        for i, v in ipairs(livery_stack.layers) do
            table.insert(current_components, S("@1.: @2 @3", i, v.component, v.color));
        end
        current_components = table.concat(current_components, S(" — "));
    else
        current_components = S("nothing");
    end

    local help_text = S([[
This wagon offers multiple livery components. To access them, you can paint some “meta colors”, which are explained here. @1
 * Green == 0 — Commands
    - Blue == 0 — Print this help text.
    - Blue == S; 1 ≤ S ≤ 30 — Load livery from slot S.
    - Blue == S; 101 ≤ (S + 100) ≤ 130 — Save livery to slot S. (S ≤ 10 are personal slots, S ≥ 11 are public slots; slots are not persistent.)
    - Blue == P; 201 ≤ (P + 200) ≤ 250 — Load livery from preset P.
 * Green == C; 1 ≤ C ≤ 254 — Select livery component C to paint next.
    - Blue == 0 — Paint livery component on its current position or on top.
    - Blue == L; 1 ≤ L ≤ 254 — Move livery component to layer L. Higher L goes on top of lower L.
    - Blue == 255 — Remove livery component C.
You can load these presets:
@2
You can choose from these livery components:
@3
Current livery: @4
]], meta_definition, preset_choices, component_choices, current_components);
    minetest.chat_send_player(playername, help_text);
end

--! Initializes the livery stack @p livery_stack in case it does not
--! contain livery data yet.
function multi_component_liveries.initialize_stack(livery_definition, livery_stack)
    if not livery_stack.layers then
        multi_component_liveries.copy_livery_stack(livery_definition.presets[1].livery_stack, livery_stack);
    end
end

--! Copies a livery_stack table @p from to livery_stack table @p to.
function multi_component_liveries.copy_livery_stack(from, to)
    to.layers = table.copy(from.layers);
    to.active_layer = from.active_layer;
end

--! Replaces the data of @p livery_stack with that from a preset.
--!
--! @param playername Relevant for slot selection and feedback messages.
--! @param livery_stack is the livery_stack table which will be modified.
--! @param livery_definition defines the available presets.
--! @param slot is the number of the preset which will be loaded from.
--! @param has_alpha_channel Whether the player’s tool has an alpha channel.
--!
--! @returns whether the layer stack has been changed. Textures need to be updated then.
function multi_component_liveries.load_from_preset(playername, livery_stack, livery_definition, preset, has_alpha_channel)
    if livery_definition.presets[preset] then
        multi_component_liveries.copy_livery_stack(livery_definition.presets[preset].livery_stack, livery_stack);

        return true;
    else
        if playername then
            if has_alpha_channel then
                minetest.chat_send_player(playername, S("There is no preset with number @1. Paint #000000 0% for help.", preset));
            else
                minetest.chat_send_player(playername, S("There is no preset with number @1. Paint #000000 for help.", preset));
            end
        end

        return false;
    end
end

--! Selects the next layer to be painted in @p livery_stack.
--!
--! @param playername Feedback messages are sent to this player.
--! @param livery_stack is the livery_stack table which will be modified.
--! @param livery_definition defines which components can be selected.
--! @param component is the component index which shall be on this layer.
--! @param layer is the layer index on which @p component shall appear.
--! @param has_alpha_channel Whether the player’s tool has an alpha channel.
--!
--! If @p layer is zero, the component will stay on its current layer,
--! or will be put on the top-most layer if it is not used yet.
--! If @p layer is 255, the component will be removed from the layer stack.
--! Otherwise, the component will be moved to layer @p layer.
--!
--! @returns whether the layer stack has been changed. Textures need to be updated then.
function multi_component_liveries.select_livery_component(playername, livery_stack, livery_definition, component, layer, has_alpha_channel)
    -- Find the layer of the selected component.
    local existing_layer = nil;
    for i, l in ipairs(livery_stack.layers) do
        if l.component == component then
            existing_layer = i;
            break;
        end
    end

    local description = livery_definition.components[component];
    description = description and description.description;
    if layer ~= 255 and not description then
        -- Player wants to select an invalid component.
        if playername then
            if has_alpha_channel then
                minetest.chat_send_player(playername, S("There is no livery component with index @1. Paint #000000 0% for help.", component));
            else
                minetest.chat_send_player(playername, S("There is no livery component with index @1. Paint #000000 for help.", component));
            end
        end
        return false;
    end

    if layer == 0 then
        if not existing_layer then
            -- Append the requested component.
            local new_layer = {
                component = component;
                color = "#ff00ff"; -- Magenta, for highlighting.
            };
            table.insert(livery_stack.layers, new_layer);

            -- Select for painting.
            livery_stack.active_layer = #livery_stack.layers;

            if playername then
                minetest.chat_send_player(playername, S("Now painting on newly added livery component “@1”.", description));
            end

            return true;
        else
            -- Select the requested component.
            livery_stack.active_layer = existing_layer;

            if playername then
                minetest.chat_send_player(playername, S("Now painting on livery component “@1”.", description));
            end

            return false;
        end
    elseif layer >= 1 and layer <= 254 then
        -- Insert component in the layer stack.
        if existing_layer == layer then
            -- Component already at requested layer, select it.
            livery_stack.active_layer = existing_layer;
            if playername then
                minetest.chat_send_player(playername, S("Now painting on livery component “@1” at layer @2.", description, layer));
            end
            return false;
        end

        local current_color = "#ff00ff"; -- Magenta, as fallback.

        -- Remove from stack if already used.
        if existing_layer then
            current_color = livery_stack.layers[existing_layer].color;
            table.remove(livery_stack.layers, existing_layer);
        end

        -- Insert at new position, but without making gaps in the stack.
        local new_layer = {
            component = component;
            color = current_color;
        };
        local new_position = math.min(#livery_stack.layers + 1, layer);
        table.insert(livery_stack.layers, new_position, new_layer);

        if playername then
            if existing_layer then
                minetest.chat_send_player(playername, S("Now painting on livery component “@1”, moved to layer @2.", description, new_position));
            else
                minetest.chat_send_player(playername, S("Now painting on newly added livery component “@1” at layer @2.", description, new_position));
            end
        end

        -- Select for painting.
        livery_stack.active_layer = new_position;
        return true;
    elseif layer == 255 then
        -- Remove component from the layer stack.
        if existing_layer then
            table.remove(livery_stack.layers, existing_layer)

            if playername then
                minetest.chat_send_player(playername, S("Removed livery component “@1” from layer @2.", description or component, existing_layer));
            end

            -- Deselect for painting.
            livery_stack.active_layer = nil;
            return true;
        else
            if playername then
                minetest.chat_send_player(playername, S("Livery component “@1” not present.", description or component));
            end
            return false;
        end
    end
end

--! Paints the active layer of @p livery_stack.
--!
--! @param playername Error messages are sent to this player, if necessary.
--! @param livery_stack The livery_stack table which will be modified.
--! @param color The color string to be applied to the active layer.
--! @param has_alpha_channel Whether the player’s tool has an alpha channel.
--!
--! @returns whether the layer stack was modified. Textures need to be updated then.
function multi_component_liveries.paint_active_layer(playername, livery_stack, color, has_alpha_channel)
    if livery_stack.active_layer then
        -- Paint layer.
        livery_stack.layers[livery_stack.active_layer].color = color;
        return true;
    else
        if playername then
            -- No layer selected, warn player.
            local error_message;

            if has_alpha_channel then
                error_message = S("No livery component selected. Paint #000000 0% for help.");
            else
                error_message = S("No livery component selected. Paint #000000 for help.");
            end

            minetest.chat_send_player(playername, error_message);
        end

        return false;
    end
end

--! Updates the livery of a wagon using the unofficial API introduced in
--! advtrains commit b71c72b4ab.
--!
--! This function needs to be the @c set_livery method of a wagon definition.
--! The method is then called when the player punches the wagon
--! with a painting tool.
--!
--! Calls set_textures() automatically.
--!
--! @param self A lua entity of the wagon definition.
--! @param puncher The player, not used here.
--! @param itemstack The tool used by the player. Carries color data.
--! @param persistent_data advtrains data of the wagon.
function multi_component_liveries.set_livery(self, puncher, itemstack, persistent_data)
    -- This function has been adapted from the JR_E231series_modpack.
    if type(persistent_data.livery) ~= "table" then
        persistent_data.livery = {};
    end

    if self.livery_definition then
        if multi_component_liveries.paint_on_livery(puncher, self.livery_definition, persistent_data.livery, itemstack) then
            self:set_textures(persistent_data);
        end
    end
end

--! Updates the livery of an advtrains wagon’s lua etity,
--! using the unofficial API introduced in advtrains commit b71c72b4ab.
--!
--! This function needs to be the @c set_textures method of a wagon definition.
--! The method is then called by advtrains when the livery is needed.
--!
--! @param self A lua entity of the wagon definition.
--! @param persistent_data advtrains data of the wagon.
function multi_component_liveries.set_textures(self, persistent_data)
    -- This function has been adapted from the JR_E231series_modpack.
    local layers = persistent_data.livery;
    local definition = self.livery_definition;
    local texture = multi_component_liveries.calculate_texture_string(definition, layers);

    local textures = self.object:get_properties().textures;
    textures[self.livery_texture_slot] = texture;
    self.object:set_properties({
        textures = textures;
    });
end
