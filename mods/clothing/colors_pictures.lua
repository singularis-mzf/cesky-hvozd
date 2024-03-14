
local S = clothing.translator;

local basic_colors = {
	white = {
		color = "bíl",
		hex = "f8f7f3",
	},
	grey = {
		color = "šed",
		hex = "afada6",
	},
	black = {
		color = "čern",
		hex = "161517",
	},
	red = {
		color = "červen",
		hex = "bc1934",
	},
	yellow = {
		color = "žlut",
		hex = "eddf9b",
	},
	green = {
		color = "zelen",
		hex = "98cd61",
	},
	cyan = {
		color = "tyrkysov",
		hex = "048fbe",
	},
	blue = {
		color = "modr",
		hex = "273e85",
	},
	magenta = {
		color = "vínov",
		hex = "7b0128",
	},
	orange = {
		color = "oranžov",
		hex = "e2542a",
	},
	violet = {
		color = "fialov",
		hex = "822577",
	},
	brown = {
		color = "hněd",
		hex = "874133",
	},
	pink = {
		color = "růžov",
		hex = "eeaeb2",
	},
	dark_grey = {
		color = "tmavošed",
		hex = "515056",
	},
	dark_green = {
		color = "tmavozelen",
		hex = "4c754c",
	},

-- low saturation colors:
  --[[ red_s50 = {
    color = "pastelově červen",
    hex = "D26D6D",
  },
  yellow_s50 = {
    color = "pastelově žlut",
    hex = "F9F995", -- [ ]
  }, ]]
	green_s50 = {
		color = "pastelově zelen",
		hex = "b3dab9",
	},
	cyan_s50 = {
		color = "pastelově tyrkysov",
		hex = "8bd3e8",
	},
  --[[ blue_s50 = {
    color = "pastelově modr",
    hex = "5959BC", -- [ ]
  }, ]]
	magenta_s50 = {
		color = "pastelově purpurov",
		hex = "9e5e62",
	},
	orange_s50 = {
		color = "béžov",
		hex = "dacab4",
	},
	violet_s50 = {
		color = "pastelově fialov",
		hex = "c8adc0",
	},
	dark_green_s50 = {
		color = "khakiov",
		hex = "6f725f",
	},
	-- new colors:
	medium_blue = {
		color = "džínov",
		hex = "293d5a",
	},
	medium_blue_s50 = {
		color = "světle džínov",
		hex = "6684a0",
	},
	bright_rose = {
		color = "křiklavě růžov",
		hex = "fd6ca9",
	},
	bright_cyan = {
		color = "křiklavě azurov",
		hex = "00b4e8",
	},
}

local colors = table.copy(basic_colors);

for color, data in pairs(basic_colors) do
	for color2, data2 in pairs(basic_colors) do
		if color < color2 then
			key = color.."_"..color2
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

--[[
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
]]

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

