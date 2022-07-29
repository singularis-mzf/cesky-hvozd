
if clothing.have_skinsdb then
  minetest.register_on_mods_loaded(function()
      -- if minetest.settings:get_bool("clothing_character", true) then
        -- local default_skin_obj = skins.get(skins.default)
        -- default_skin_obj:set_texture("clothing_character_male.png")
      -- end
      -- unclothed male
      local clothing_skin = skins.new("clothing_skin")
      clothing_skin:set_texture("clothing_character_male.png")
      clothing_skin:set_meta("format", '1.0')
      clothing_skin:set_meta("_sort_id", 0)
      clothing_skin:set_meta("name", "výchozí nahé tělo mužského pohlaví")
      
      -- unclothed female
      local clothing_skin = skins.new("clothing_skin_female")
      clothing_skin:set_texture("clothing_character_female.png")
      clothing_skin:set_meta("format", '1.0')
      clothing_skin:set_meta("_sort_id", 0)
      clothing_skin:set_meta("name", "výchozí nahé tělo ženského pohlaví")
    end)
end
