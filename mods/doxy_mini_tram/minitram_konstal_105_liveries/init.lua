-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

local S = minetest.get_translator("minitram_konstal_105_liveries");

minitram_konstal_105_liveries = {};

function minitram_konstal_105_liveries.add_liveries_konstal_105(wagon_definition)
    local livery_definition = {
        components = {
            {
                description = S("Side walls");
                texture_file = "minitram_konstal_105_liveries_normal_livery_walls.png";
            };
            {
                description = S("Window background strip");
                texture_file = "minitram_konstal_105_liveries_normal_livery_window_strip.png";
            };
            {
                description = S("Doors");
                texture_file = "minitram_konstal_105_liveries_normal_livery_doors.png";
            };
            {
                description = S("Lower skirt");
                texture_file = "minitram_konstal_105_liveries_normal_livery_skirt.png";
            };
            {
                description = S("Front Area");
                texture_file = "minitram_konstal_105_liveries_normal_livery_front.png";
            };
            {
                description = S("Back Area");
                texture_file = "minitram_konstal_105_liveries_normal_livery_back.png";
            };
            {
                description = S("Stripes on skirt");
                texture_file = "minitram_konstal_105_liveries_normal_livery_stripes.png";
            };
            {
                description = S("Window detail");
                texture_file = "minitram_konstal_105_liveries_normal_livery_window_detail.png";
            };
            {
                description = S("Bumper");
                texture_file = "minitram_konstal_105_liveries_normal_livery_bumper.png";
            };
            {
                description = S("Bumper bar");
                texture_file = "minitram_konstal_105_liveries_normal_livery_bumper_bar.png";
            };
            {
                description = S("Front lights");
                texture_file = "minitram_konstal_105_liveries_normal_livery_lights.png";
            };
        };
        presets = {
            {
                description = S("Warszawa (Tramwaje Warszawskie)");
                livery_stack = {
                    layers = {
                        {
                            component = 1;
                            color = "#ffa200";
                        };
                        {
                            component = 4;
                            color = "#ea0303";
                        };
                        {
                            component = 9;
                            color = "#080809";
                        };
                        {
                            component = 8;
                            color = "#131413";
                        };
                        {
                            component = 2;
                            color = "#0f0f0e";
                        };
                    };
                    active_layer = 1;
                };
            };
            {
                description = S("Gdansk (and many other Polish cities)");
                livery_stack = {
                    layers = {
                        {
                            component = 1;
                            color = "#fafad2";
                        };
                        {
                            component = 4;
                            color = "#fa0d03";
                        };
                        {
                            component = 9;
                            color = "#fa0d03";
                        };
                        {
                            component = 8;
                            color = "#0c0d0c";
                        };
                        {
                            component = 2;
                            color = "#fa0d03";
                        };
                    };
                    active_layer = 1;
                };
            };
            {
                description = S("Katowice (Tramwaje Śląskie)");
                livery_stack = {
                    layers = {
                        {
                            component = 1;
                            color = "#fb0404";
                        };
                        {
                            component = 4;
                            color = "#fdf6ec";
                        };
                        {
                            component = 9;
                            color = "#080809";
                        };
                        {
                            component = 2;
                            color = "#fdf6ec";
                        };
                        {
                            component = 3;
                            color = "#fdf6ec";
                        };
                        {
                            component = 10;
                            color = "#131313";
                        };
                    };
                    active_layer = 1;
                };
            };
            {
                description = S("Kraków (MPK Kraków)");
                livery_stack = {
                    layers = {
                        {
                            component = 1;
                            color = "#070bfd";
                        };
                        {
                            component = 2;
                            color = "#f5f6f7";
                        };
                        {
                            component = 9;
                            color = "#151515";
                        };
                        {
                            component = 3;
                            color = "#f5f6f7";
                        };
                        {
                            component = 4;
                            color = "#070bfd";
                        };
                        {
                            component = 10;
                            color = "#6a6a6a";
                        };
                    };
                    active_layer = 1;
                };
            };
            {
                description = S("Łódź (MPK Łódź)");
                livery_stack = {
                    layers = {
                        {
                            component = 1;
                            color = "#9d160a";
                        };
                        {
                            component = 4;
                            color = "#9d160a";
                        };
                        {
                            component = 9;
                            color = "#ffdf05";
                        };
                        {
                            component = 10;
                            color = "#ffdf05";
                        };
                        {
                            component = 3;
                            color = "#ffdf05";
                        };
                        {
                            component = 8;
                            color = "#111310";
                        };
                        {
                            component = 2;
                            color = "#ffdf05";
                        };
                    };
                    active_layer = 1;
                };
            };
            {
                description = S("Poznań (Yellow) (MPK Poznań)");
                livery_stack = {
                    layers = {
                        {
                            component = 11;
                            color = "#ffff1f";
                        };
                        {
                            component = 9;
                            color = "#f3f211";
                        };
                        {
                            component = 8;
                            color = "#0e0f0e";
                        };
                        {
                            component = 1;
                            color = "#31ff24";
                        };
                        {
                            component = 3;
                            color = "#f3f211";
                        };
                        {
                            component = 4;
                            color = "#f3f211";
                        };
                    };
                    active_layer = 4;
                };
            };
            {
                description = S("Poznań (Beige) (MPK Poznań)");
                livery_stack = {
                    layers = {
                        {
                            component = 1;
                            color = "#177209";
                        };
                        {
                            component = 4;
                            color = "#dfdfa0";
                        };
                        {
                            component = 2;
                            color = "#dfdfa0";
                        };
                        {
                            component = 3;
                            color = "#dfdfa0";
                        };
                    };
                    active_layer = 1;
                };
            };
            {
                description = S("Szczecin (Red) (Tramwaje Szczecińskie)");
                livery_stack = {
                    layers = {
                        {
                            component = 1;
                            color = "#d5000a";
                        };
                        {
                            component = 2;
                            color = "#e9e7eb";
                        };
                        {
                            component = 4;
                            color = "#d5000a";
                        };
                        {
                            component = 9;
                            color = "#181818";
                        };
                        {
                            component = 7;
                            color = "#1c00bf";
                        };
                        {
                            component = 3;
                            color = "#e9e7eb";
                        };
                    };
                    active_layer = 1;
                };
            };
            {
                description = S("Szczecin (Green) (Tramwaje Szczecińskie)");
                livery_stack = {
                    layers = {
                        {
                            component = 2;
                            color = "#e9e7eb";
                        };
                        {
                            component = 7;
                            color = "#0de613";
                        };
                        {
                            component = 9;
                            color = "#0de613";
                        };
                        {
                            component = 1;
                            color = "#e9e7eb";
                        };
                        {
                            component = 4;
                            color = "#e9e7eb";
                        };
                        {
                            component = 8;
                            color = "#101010";
                        };
                        {
                            component = 5;
                            color = "#0de613";
                        };
                    };
                    active_layer = 7;
                };
            };
        };
        base_texture_file = "minitram_konstal_105_normal_base_texture.png";
    };

    local livery_texture_slot = 2;

    multi_component_liveries.setup_advtrains_wagon(wagon_definition, livery_definition, livery_texture_slot);
end
