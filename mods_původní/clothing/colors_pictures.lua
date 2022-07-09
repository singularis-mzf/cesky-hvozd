
local S = clothing.translator;

local basic_colors = {
  white = {
    color = S("white"),
	  hex = "FFFFFF",
  },
  grey = {
    color = S("grey"),
	  hex = "C0C0C0",
  },
  black = {
    color = S("black"),
    hex = "232323",
  },
  red = {
    color = S("red"),
    hex = "FF0000",
  },
  yellow = {
    color = S("yellow"),
    hex = "FFEE00",
  },
  green = {
    color = S("green"),
    hex = "32CD32",
  },
  cyan = {
    color = S("cyan"),
    hex = "00959D",
  },
  blue = {
    color = S("blue"),
    hex = "003376",
  },
  magenta = {
    color = S("magenta"),
    hex = "D80481",
  },
  orange = {
    color = S("orange"),
    hex = "E0601A",
  },
  violet = {
    color = S("violet"),
    hex = "480080",
  },
  brown = {
    color = S("brown"),
    hex = "391A00",
  },
  pink = {
    color = S("pink"),
    hex = "FFA5A5",
  },
  dark_grey = {
    color = S("dark grey"),
    hex = "696969",
  },
  dark_green = {
    color = S("dark green"),
    hex = "154F00",
  },
}

local colors = table.copy(basic_colors);
local colors2 = table.copy(basic_colors);

for color, data in pairs(basic_colors) do
  colors2[color] = nil;
  for color2, data2 in pairs(colors2) do
    if (data2~=nil) then
      key = color.."_"..color2;
      colors[key] = {
          color = data.color.."-"..data2.color;
          alias = color2.."_"..color;
          color1 = data.color,
          color2 = data2.color,
          key1 = color,
          key2 = color2,
          hex = data.hex,
          hex2 = data2.hex,
        }
    end
  end
end

local pictures = {
  minetest = {
    recipe = {"green","CLOTH","dark_green",
              "brown","green","yellow",
              "black","blue","grey",
              },
    production_time = 8*30,
    texture = "clothing_picture_minetest.png",
  },
}

clothing.basic_colors = basic_colors;
clothing.colors = colors;
clothing.pictures = pictures;

