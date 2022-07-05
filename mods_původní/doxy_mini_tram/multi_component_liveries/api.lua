-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

--! @class livery_definition
--! A livery_definition table is a Lua table which defines a livery set.
--!
--! The table must contain the elements @c components, @c presets, @c base_texture_file, and @c initial_livery.
--!
--! @c components is a list of tables, which define one livery component each.
--! Each livery component definition must have these properties:
--! \li @c description A user facing string to describe the component.
--! \li @c texture_file The file name of the component’s texture.
--!
--! @c presets is a list of 1 to 50 tables, which define one livery preset each.
--! The first preset defines the livery stack
--! until a player paints it the first time.
--! This livery stack should be equivalent to the base texture,
--! otherwise the first painting operation looks weird.
--! Each livery preset definition must have these properties:
--! \li @c description A user facing string to describe the preset.
--! \li @c livery_stack A livery_stack table.
--!
--! @c base_texture_file is the texture on which livery components are overlaid.
--!
--! @par Example
--! @code{.lua}
--! local cat_initial_livery = ...;
--! local cat_livery_set = {
--!     components = {
--!         {
--!             description = S("Fur on legs");
--!             texture_file = "my_cat_mod_cat_leg_overlay.png";
--!         };
--!         {
--!             description = S("Fur near feet");
--!             texture_file = "my_cat_mod_cat_feet_overlay.png";
--!         };
--!     };
--!     presets = {
--!         {
--!             description = S("Cat with red feet");
--!             livery_stack = cat_initial_livery;
--!         };
--!         {
--!             description = S("Cat with white feet");
--!             livery_stack = {
--!                 layers = {
--!                     {
--!                         component = 2;
--!                         color = "white";
--!                     };
--!                     {
--!                         component = 1;
--!                         color = "blue";
--!                     };
--!                 };
--!                 active_layer = 2;
--!             };
--!         };
--!     };
--!     base_texture_file = "my_cat_mod_cat_base.png";
--! };
--! @endcode

--! @class livery_stack
--! A livery_stack table is a Lua table which defines the state of a livery.
--!
--! The table must contain the elements @c layers and @c active_layer.
--!
--! @c layers is a list of tables, which define one livery layer each.
--! Each layer definition has these properties:
--! \li @c component The index of the livery component in the livery_definition.
--! \li @c color The color in which this component is painted.
--!
--! @c active_layer is the index of a layer in @c layers.
--! This layer shall be painted next.
--!
--! @par Example
--! @parblock
--! Together with the example for livery_stack,
--! this example defines a cat with blue legs and red feet.
--!
--! The red feet are not visible,
--! because the blue legs component is in a higher layer than the feet.
--! (Assuming that the leg texture also covers the feet.)
--!
--! The next time a player paints the cat, the legs will be recolored.
--! @code{.lua}
--! local cat_texture_stack = {
--!     layers = {
--!         {
--!             component = 2;
--!             color = "red";
--!         };
--!         {
--!             component = 1;
--!             color = "blue";
--!         };
--!     };
--!     active_layer = 2;
--! };
--! @endcode
--! @endparblock

--! Paints on @p livery_stack using @p color and @p alpha;
--! and possibly sends feedback and instructions to @p player via chat.
--!
--! This function implements painting individual components of complex liveries,
--! using “meta colors”.
--!
--! Components available for @p livery_stack are defined in @p livery_definition.
--!
--! @p player is a player ObjectRef (optional).
--! @p livery_definition is a livery_definition.
--! @p livery_stack is a livery_stack.
--! @p tool is the itemstack of the painting tool.
--!
--! @returns true if @p livery_stack was changed. Textures need to be updated then.
function multi_component_liveries.paint_on_livery(player, livery_definition, livery_stack, tool)
    local playername = player and player.is_player and player:is_player() and player:get_player_name();
    local r, g, b, a = multi_component_liveries.get_components_from_painting_tool(playername, tool);

    -- A meta painting operation is when the player chooses certain special
    -- colors, e. g. to choose which livery layer shall be painted next.
    local is_meta_color;
    if a then
        is_meta_color = r == 0 and a == 0;
    else
        is_meta_color = r == 0;
    end

    if is_meta_color then
        -- Meta painting commands consist of the G and B component.
        if g == 0 and b == 0 then
            -- Help text requested.
            multi_component_liveries.initialize_stack(livery_definition, livery_stack);
            multi_component_liveries.send_player_help_message(playername, livery_stack, livery_definition, a);
            return false;
        elseif g == 0 and b >= 1 and b <= 30 then
            -- Load livery from slot
            local slot = b;
            return multi_component_liveries.load_from_slot(playername, livery_stack, slot, a);
        elseif g == 0 and b >= 101 and b <= 130 then
            -- Save livery to slot
            local slot = b - 100;
            multi_component_liveries.save_to_slot(playername, livery_stack, slot, a);
            return false;
        elseif g == 0 and b >= 201 and b <= 250 then
            -- Load livery from preset
            local preset = b - 200;
            return multi_component_liveries.load_from_preset(playername, livery_stack, livery_definition, preset, a);
        elseif g >= 1 and g <= 254 then
            -- Livery component selection requested.
            multi_component_liveries.initialize_stack(livery_definition, livery_stack);
            local component = g;
            local layer = b;
            return multi_component_liveries.select_livery_component(playername, livery_stack, livery_definition, component, layer, a);
        else
            -- Undefined meta color painted.
            multi_component_liveries.handle_undefined_metacolor(playername, a);
            return false;
        end
    else
        -- Non-meta color painted.
        multi_component_liveries.initialize_stack(livery_definition, livery_stack);
        return multi_component_liveries.paint_active_layer(playername, livery_stack, string.format("#%02x%02x%02x", r, g, b), a);
    end
end

--! Calculates a texture string from a livery_definition and livery_stack.
function multi_component_liveries.calculate_texture_string(livery_definition, livery_stack)
    if not livery_definition then
        return "";
    end

    if not (livery_stack and livery_stack.layers) then
        return livery_definition.base_texture_file;
    end

    local textures = { livery_definition.base_texture_file };

    for _, layer in ipairs(livery_stack.layers) do
        -- Create a texture overlay.
        -- Because of version updates, the livery component stack may
        -- refer to not existing livery components. Skip those.
        local component = livery_definition.components[layer.component];
        if component then
            table.insert(textures, "(" .. component.texture_file .. "^[multiply:" .. layer.color .. ")");
        end
    end

    return table.concat(textures, "^");
end

--! Adds methods to an advtrains wagon definition to implement livery paiting.
--!
--! @param wagon_definition The “wagon prototype” which you pass to register_wagon().
--! @param livery_definition A livery_definition table,
--!    defines the available livery components and initial livery for this wagon.
--! @param slot Which texture slot shall be affected by the livery.
--! @see livery_definition, livery_stack.
function multi_component_liveries.setup_advtrains_wagon(wagon_definition, livery_definition, slot)
    wagon_definition.set_textures = multi_component_liveries.set_textures;
    wagon_definition.set_livery = multi_component_liveries.set_livery;
    wagon_definition.livery_definition = livery_definition;
    wagon_definition.livery_texture_slot = slot or 1;
end
