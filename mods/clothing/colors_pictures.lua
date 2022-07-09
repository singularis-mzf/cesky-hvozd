
local S = clothing.translator;

local basic_colors = {
  white = {
	color = "bíl",
	hex = "FFFFFF",
  },
  grey = {
    color = "šed",
	  hex = "C0C0C0",
  },
  black = {
    color = "čern",
    hex = "232323",
  },
  red = {
    color = "červen",
    hex = "FF0000",
  },
  yellow = {
    color = "žlut",
    hex = "FFEE00",
  },
  green = {
    color = "zelen",
    hex = "32CD32",
  },
  cyan = {
    color = "tyrkysov",
    hex = "00959D",
  },
  blue = {
    color = "modr",
    hex = "003376",
  },
  magenta = {
    color = "magentov",
    hex = "D80481",
  },
  orange = {
    color = "oranžov",
    hex = "E0601A",
  },
  violet = {
    color = "fialov",
    hex = "480080",
  },
  brown = {
    color = "hněd",
    hex = "391A00",
  },
  pink = {
    color = "růžov",
    hex = "FFA5A5",
  },
  dark_grey = {
    color = "tmavošed",
    hex = "696969",
  },
  dark_green = {
    color = "tmavozelen",
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
          color = data.color.."o"..data2.color;
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

colors["white"].in_creative_inventory = 1
local tmp = colors["white_red"] or colors["red_white"]
if tmp then
	tmp.in_creative_inventory = 1
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

