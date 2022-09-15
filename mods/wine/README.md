Wine mod for Minetest

by TenPlus1

Depends: Farming Redo

This mod adds a barrel used to ferment grapes into glasses of wine, 9 of which can then be crafted into a bottle of wine.  It can also ferment honey into mead, barley into beer, wheat into weizen (wheat beer), corn into bourbon and apples into cider.

Change log:

- 0.1 - Initial release
- 0.2 - Added protection checks to barrel
- 0.3 - New barrel model from cottages mod (thanks Napiophelios), also wine glass can be placed
- 0.4 - Added ability to ferment barley from farming redo into beer and also honey from mobs redo into honey mead
- 0.5 - Added apple cider
- 0.6 - Added API so drinks can easily be added, also added wheat beer thanks to h-v-smacker and support for pipeworks/tubelib
- 0.7 - Blue Agave now appears in desert areas and spreads very slowly, can me fermented into tequila
- 0.8 - Barrel and Agave both use node timers now thanks to h-v-smacker, added sake
- 0.9 - Added Glass of Rum and Bottle of Rum thanks to acm :) Added {alcohol=1} groups
- 1.0 - Added glass and bottle or Bourbon made by fermenting corn
- 1.1 - Added glass and bottle of Vodka made by fermenting baked potato, Added MineClone2 support and spanish translation
- 1.2 - Added Unified Inventory support for barrel recipes (thanks to realmicu)
- 1.3 - Translations updated and French added thanks to TheDarkTiger
- 1.4 - Added bottle of beer and bottle of wheat beer (thanks Darkstalker for textures)
- 1.5 - Added bottle of sake (texture by Darkstalker), code tidy & tweaks, resized bottles and glasses, added some new lucky blocks, support for Thirst mod
- 1.6 - Added bottle of Mead, Cider and Mint-Julep (textures by Darkstalker),
re-arranged code, tweaked lucky blocks, updated translations
- 1.7 - Added more uses for blue agave (fuel, paper, food, agave syrup)
- 1.8 - Added glass and bottles for Champagne, Brandy and Coffee Liquor (thanks Felfa)
- 1.9 - Added wine:add_drink() function to create drink glasses and bottles
- 1.95 - Tweaked code to accept 2 item recipes, fixed mineclone2 rum recipe and ui recipes
- 1.98 - New formspec textures and Kefir drink by Sirrobzeroone
- 1.99 - Barrel now has 4 slots for recipe items (and drinking glasses) and a water slot to fill up barrel with water buckets ready for fermenting, fix mineclone2 compatibility, added translations, added cointreau and margarita (thx Ethace10 for idea)

Lucky Blocks: 24


Wine Mod API
------------

wine:add_item(item_table)

e.g.

wine:add_item({
		-- simple recipe automatically add drinking glasses
	{"farming:barley", "wine:glass_beer"},
		-- 2x apples make 1x glass cider
	{"default:apple 2", "wine:glass_cider"},
		-- specific recipe has to include drinking glass if needed
	{{"default:apple", "farming:sugar", "vessels:drinking_glass"}, "wine:glass_sparkling_apple},
})


wine:add_drink(name, desc, has_bottle, num_hunger, num_thirst, alcoholic)

e.g.

wine:add_drink("beer", "Beer", true, 2, 8, 1)
wine:add_drink("cider", "Cider", true, 2, 6, 1)
wine:add_drink("kefir", "Kefir", true, 4, 4, 0) -- non alcoholic


Note:

Textures used will be wine_beer_glass.png wine_beer_bottle.png and num_thirst is only
used if thirst mod is active, alcoholic is used if stamina mod is active for drunk effect.
