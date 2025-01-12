---------------------------------------------------------------------------------------------------
-- metrosigns mod for minetest by A S Lewis
--      https://github.com/axcore/metrosigns
--      Licence: GNU Affero GPL
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Signs with customisable text (designed to be used alongside the map nodes). Requires signs_api
--      from display_modpack
---------------------------------------------------------------------------------------------------

if HAVE_SIGNS_API_FLAG and (metrosigns.create_all_flag or metrosigns.create_text_flag) then

    local category = "cedule do metra"
    metrosigns.register_category(category)

    local width_table = {
        [1] = "short",
        [2] = "medium",
        [3] = "long",
    }

    for width, width_descrip in pairs(width_table) do

        -- Default sign: text on a white background
        signs_api.register_sign(
            ":signs_road",
            "metrosigns_text_" .. width_descrip,
            {
                depth = 2/16,
                width = width,
                height = 1,

                entity_fields = {
                    size = {x = width, y = 12 / 16},
                    maxlines = 5,
                    meta_lines_default = 3,
                    color = "#000",
                    meta_color = "sign_text_color",
                    meta_lines = "sign_lines",
                    meta_halign = "sign_halign",
                    meta_valign = "sign_valign",
                },
                node_fields = {
                    description = "cedule do metra (šířka " .. width .. " m)",
                    tiles = {
                        "metrosigns_text_side.png",
                        "metrosigns_text_side.png",
                        "metrosigns_text_side.png",
                        "metrosigns_text_side.png",
                        "metrosigns_text_side.png",
                        "metrosigns_text_front.png",
                    },
                    inventory_image = "metrosigns_text_width_" .. width_descrip .. "_inv.png",
                },
            }
        )
        metrosigns.register_sign(
            category,
            "signs_road:metrosigns_text_" .. width_descrip,
            (metrosigns.writer.text_units * width)
        )

        minetest.override_item("signs_road:metrosigns_text_" .. width_descrip, {light_source = 5})

        -- "You are here sign": text on a reddish background
        signs_api.register_sign(
            ":signs_road",
            "metrosigns_here_" .. width_descrip,
            {
                depth = 2/16,
                width = width,
                height = 1,

                entity_fields = {
                    size = {x = width, y = 12 / 16},
                    maxlines = 5,
                    meta_lines_default = 3,
                    color = "#000",
                    meta_color = "sign_text_color",
                    meta_lines = "sign_lines",
                    meta_halign = "sign_halign",
                    meta_valign = "sign_valign",
                },
                node_fields = {
                    description = "zvýrazněná cedule do metra (šířka " .. width .. " m)",
                    tiles = {
                        "metrosigns_text_side.png",
                        "metrosigns_text_side.png",
                        "metrosigns_text_side.png",
                        "metrosigns_text_side.png",
                        "metrosigns_text_side.png",
                        "metrosigns_here_front.png",
                    },
                    inventory_image = "metrosigns_here_width_" .. width_descrip .. "_inv.png",
                },
            }
        )
        metrosigns.register_sign(
            category,
            "signs_road:metrosigns_here_" .. width_descrip,
            (metrosigns.writer.text_units * width)
        )

        minetest.override_item(
            "signs_road:metrosigns_here_" .. width_descrip,
            {light_source = 5}
        )
    end

	for _, prefix in pairs({"signs_road:metrosigns_here_", "signs_road:metrosigns_text_"}) do
		minetest.register_craft({
			output = prefix.."medium",
			recipe = {
				{prefix.."short", prefix.."short"},
				{"", ""}
			},
		})
		minetest.register_craft({
			output = prefix.."long",
			recipe = {{prefix.."short", prefix.."short", prefix.."short"}, {"", "", ""}, {"", "" , ""}},
		})
		minetest.register_craft({
			output = prefix.."short 2",
			recipe = {{prefix.."medium"}},
		})
		minetest.register_craft({
			output = prefix.."short 3",
			recipe = {{prefix.."long"}},
		})
	end
end
