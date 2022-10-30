
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
    hex = "D11618",
  },
  yellow = {
    color = "žlut",
    hex = "DBDB19",
  },
  green = {
    color = "zelen",
    hex = "17DB19",
  },
  cyan = {
    color = "tyrkysov",
    hex = "16D1E7",
  },
  blue = {
    color = "modr",
    hex = "1717F1",
  },
  magenta = {
    color = "purpurov",
    hex = "DB17F1",
  },
  orange = {
    color = "oranžov",
    hex = "CF7218",
  },
  violet = {
    color = "fialov",
    hex = "7917F1",
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
    hex = "05430D",
  },

-- low saturation colors:
  red_s50 = {
    color = "pastelově červen",
    hex = "D26D6D",
  },
  yellow_s50 = {
    color = "pastelově žlut",
    hex = "F9F995",
  },
  green_s50 = {
    color = "pastelově zelen",
    hex = "83E783",
  },
  cyan_s50 = {
    color = "pastelově tyrkysov",
    hex = "8AEFEF",
  },
  blue_s50 = {
    color = "pastelově modr",
    hex = "5959BC",
  },
  magenta_s50 = {
    color = "pastelově purpurov",
    hex = "DB77DB",
  },
  orange_s50 = {
    color = "pastelově oranžov",
    hex = "DDAC7A",
  },
  violet_s50 = {
    color = "pastelově fialov",
    hex = "9462C6",
  },
  dark_green_s50 = {
    color = "pastelově tmavozelen",
    hex = "567F56",
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

for color, data in pairs(colors) do
	data.in_creative_inventory = 0
end
colors.white.in_creative_inventory = 1
local tmp = colors.white_red or colors.red_white
if tmp then
	tmp.in_creative_inventory = 1
end
colors.black.in_creative_inventory = 1

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

