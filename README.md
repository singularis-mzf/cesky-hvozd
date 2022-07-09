# Módy pro Český hvozd

Toto je repozitář módů a úprav pro chystaný český server hry Minetest
„Český hvozd“. Všechny módy jsou lokalizovány do češtiny a přizpůsobeny provozu
na serveru Minetest 5.5; některé úpravy jsou ale specifické či
destruktivní, takže pokud chcete upravený mód použít samostatně,
budete muset projít změny v jeho kódu a vybrat jen ty, které potřebujete.

Každý zde umístěný mód či balík módů je *samostatným dílem s vlastní licencí*,
ve většině z nich se také liší licence a autorství některých souborů,
konkrétní údaje jsou vždy uvedeny přímo v adresářích konkrétních módů.

Drtivá většina módů je pod některou svobodnou licencí, některé módy
mohou obsahovat soubory pod licencí zakazující komerční využití,
všechny však musí umožňovat dílo upravovat a upravené dále šířit.

Po úpravy módů provedené v tomto repozitáři obecně platí,
že podléhají téže licenci jako upravovaný obsah,
resp. upravovaný mód; podrobněji je to rozepsáno níže.

Veškerý kód je poskytován jako pravděpodobně užitečný, ale bez jakékoliv
záruky z mé strany.

Význam adresářů je následující:

* **minetest\_game\_původní** — Minetest Game ve verzi, z níž bylo vycházeno při úpravách.
* **minetest\_game** — Minetest Game upravená pro Český hvozd; nové soubory podléhají licenci LGPLv2.1, úpravy v existujících souborech podléhají téže licenci jako původní soubory.
* **mods\_původní** — Módy a balíky módů v původní (neupravené) podobě, jak byly získány ze zdroje. (Jen adresáře .git a .github byly ze všech módů odstraněny.)
* **mods** — Aktuální kód módů upravených pro Český hvozd. Některé módy (např. „ch\_core“) jsou zde zcela nové.
* **ostatní\_zdroje** — Módy a sady textur, z nichž pochází některé úpravy a části v ostatních módech v adresáři „mods“. (Podrobnosti jsou uvedeny níže.)

Některé licence vyžadují uvést, zda bylo dílo upraveno.
To poznáte srovnáním obsahu módu v adresáři *mods* (resp. *minetest\_game*)
s neupravenou podobou v adresáři *mods\_původní*, *minetest\_game\_původní*,
resp. *ostatní\_zdroje*.

# Balíky modů (modpacks)

## Advanced Trains (advtrains)

* Zdroj: [https://git.bananach.space/advtrains.git](https://git.bananach.space/advtrains.git), revize 744aee2cdd319bc19e83cc9efb52a07ae6adbb06
* Původní licence: AGPL 3 pro kód, CC-BY-SA-3.0 pro média
* Licence úprav: AGPL 3
* [ContentDB](https://content.minetest.net/packages/orwell/advtrains/)

## Advtrains Basic Trains (basic\_trains)

* Zdroj: [http://git.bananach.space/basic\_trains.git/](http://git.bananach.space/basic\_trains.git/), revize 764be1bda4363c7dd1ad60df2e3df0d7f040ae9b
* Původní licence: AGPL v3 (kód), CC-BY-SA-3.0 (média)
* Licence úprav: AGPL v3
* [ContentDB](https://content.minetest.net/packages/orwell/basic\_trains/)

## Cool Trees (cool\_trees)

* Zdroj: [https://github.com/runsy/cool\_trees/](https://github.com/runsy/cool\_trees/), revize af8e445c475efb050c1291da459336812b84591e
* Původní licence: GPL v3
* Licence úprav: GPL v3
* [ContentDB](https://content.minetest.net/packages/runs/cool\_trees/)
* Použity jen některé mody

## Display (display\_modpack)

* Zdroj: [https://github.com/pyrollo/display\_modpack](https://github.com/pyrollo/display\_modpack), revize f5bd6d1046ee81260a99940c201ece5a7630eeaa
* Původní licence: LGPL 3 pro kód, CC-BY-SA-3.0 pro média
* Licence úprav: LGPL 3
* [ContentDB](https://content.minetest.net/packages/Pyrollo/display\_modpack/)

## Doxy's Mini Tram (doxy\_mini\_tram)

* Zdroj: [https://invent.kde.org/davidhurka/doxy\_mini\_tram](https://invent.kde.org/davidhurka/doxy\_mini\_tram), revize f0aa2331419ab85d1b0a7ac01987faffb68eba95
* Původní licence: převážně MIT, jednotlivé soubory pod různými jinými, ale vše svobodné
* Licence úprav: uvedeny u jednotlivých souborů stejným způsobem jako v původním módu
* [ContentDB](https://content.minetest.net/packages/doxygen\_spammer/doxy\_mini\_tram/)

## Homedecor (homedecor)

* Zdroj: [https://content.minetest.net/packages/VanessaE/homedecor\_modpack/](https://content.minetest.net/packages/VanessaE/homedecor\_modpack/), revize 5ffdc26673169e05492141709fbb18e8fb6e5937
* Původní licence: LGPL 3 pro kód, CC-BY-SA-4.0 pro ostatní
* Licence úprav: LGPL 3 pro kód, CC-BY-SA-4.0 pro ostatní
* [ContentDB](https://content.minetest.net/packages/VanessaE/homedecor\_modpack/)

## Mesecons (mesecons)

* Zdroj: [https://github.com/minetest-mods/mesecons](https://github.com/minetest-mods/mesecons), revize 27c3c515b49af91c1dbc427f31a820722854eb24
* Původní licence: LGPL 3 pro kód, CC-BY-SA-3.0 pro média
* Licence úprav: LGPL 3
* [ContentDB](https://content.minetest.net/packages/Jeija/mesecons/)

## Morelights (morelights)

* Zdroj: [https://github.com/random-geek/morelights](https://github.com/random-geek/morelights), revize 717553c9cb5faf779dae6df5d9aea2e1674fc242
* Původní licence: LGPL 3 pro kód, CC-BY-SA-4.0 pro vše ostatní
* Licence úprav: LGPL 3 pro kód, CC-BY-SA-4.0 pro vše ostatní
* [ContentDB](https://content.minetest.net/packages/random\_geek/morelights/)

## Morelights\_dim (doxy\_morelights\_dim)

* Zdroj: [https://invent.kde.org/davidhurka/doxy\_morelights\_dim](https://invent.kde.org/davidhurka/doxy\_morelights\_dim), revize be702240e72b1406f4e8feba8e07297c55e28f11
* Původní licence: CC0 a MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/doxygen\_spammer/morelights\_dim/)

## Plantlife (plantlife)

* Zdroj: [https://github.com/mt-mods/plantlife\_modpack](https://github.com/mt-mods/plantlife\_modpack), revize d33907ca75383598ba47fc97942575d816c81eee
* Původní licence: LGPL 3 pro kód, CC-BY-SA-4.0 pro média
* Licence úprav: LGPL 3
* [ContentDB](https://content.minetest.net/packages/VanessaE/plantlife\_modpack/)
* Z balíku jsou použity jen vybrané mody a jsou upraveny tak, aby nezávisely na Biome Lib.

## Simple Arcs (pkarcs)

* Zdroj: [https://github.com/TumeniNodes/pkarcs](https://github.com/TumeniNodes/pkarcs), revize cb850cb5c73842dd09a7bd35d16e7bbc42d05d70
* Původní licence: LGPLv2.1
* Licence úprav: LGPLv2.1
* [ContentDB](https://content.minetest.net/packages/TumeniNodes/pkarcs/)

## Sky Mobs (mobs\_sky)

* Zdroj: [https://notabug.org/TenPlus1/mobs\_sky](https://notabug.org/TenPlus1/mobs\_sky), revize fdcaf298720e1007dc19e282872d83b66cc4ced5
* Původní licence: mobs\_bat: kód GPL, model a textury CC-BY-SA-3.0, zvuky WTFPL; mobs\_birds: kód MIT, model a textury CC-BY-SA-3.0; mobs\_butterfly: kód MIT, model a textury: CC-BY-SA-3.0
* Licence úprav: kód: { mobs\_bat: GPL, ostatní módy: MIT }; modely a textury: CC-BY-SA-3.0
* [ContentDB](https://content.minetest.net/packages/TenPlus1/mobs\_sky/)

## Some More Trains (some\_more\_trains)

* Zdroj: [https://github.com/APercy/some\_more\_trains](https://github.com/APercy/some\_more\_trains), revize 326f7e73a73e05e26a4cc25c8cc5acc777429443
* Původní licence: AGPLv3
* Licence úprav: AGPLv3

## Technic (technic)

* Zdroj: [https://github.com/minetest-mods/technic](https://github.com/minetest-mods/technic), revize d2b68a6bef53e34e166deadd64e02b58bcae59a1
* Původní licence (není-li uvedeno jinak v README.md): concrete, extranodes, technic, technic\_worldgen: WTFPL; technic\_cnc, technic\_chests, wrench: LGPLv2+
* Zdrojový kód byl sloučen s balíkem Technic Plus a z módu Improve Technic CNC Machine byly implantovány některé modely, textury a kód do technic\_cnc (vše pod LGPL-2.1).
* Licence úprav: concrete, extranodes, technic, technic\_worldgen: WTFPL; technic\_cnc, technic\_chests, wrench: LGPL-2.1
* [ContentDB](https://content.minetest.net/packages/RealBadAngel/technic/)

## World Edit (Minetest-WorldEdit)

* Zdroj: [https://github.com/Uberi/Minetest-WorldEdit](https://github.com/Uberi/Minetest-WorldEdit), revize abc9efeeb8cccb3e23c055414941fed4a9871b9a
* Původní licence: AGPLv3
* Licence úprav: AGPLv3
* [ContentDB](https://content.minetest.net/packages/sfan5/worldedit/)

# Doplňky k balíku Display

## Font Old Wizard (font\_oldwizard)

* Zdroj: [https://github.com/pyrollo/font\_oldwizard](https://github.com/pyrollo/font\_oldwizard), revize 8ca8fed909a48869093b4c69067de4aa2aa50c33
* Původní licence: LGPL 2.1 pro kód, font public domain
* Bez úprav

# Samostatné módy

## Advtrains Construction Train

* Zdroj: [https://git.bananach.space/advtrains\_construction\_train.git/](https://git.bananach.space/advtrains\_construction\_train.git/), revize 2b27b8d8f1a629ff10f295cb8432225a3a9a943b
* Původní licence: AGPLv3
* Licence úprav: AGPLv3

## Agree Rules (agreerules)

* Zdroj: [https://github.com/AiTechEye/agreerules](https://github.com/AiTechEye/agreerules), revize b7064cab5d64f0529e5d14e385d8501741425ed0
* Původní licence: LGPL-2.1 (jeden soubor uvádí LGPL-2.1, druhý CC0; předpokládám, že platí restriktivnější varianta)
* Licence úprav: LGPL-2.1
* [ContentDB](https://content.minetest.net/packages/AiTechEye/agreerules/)

## Anvil (anvil)

* Zdroj: [https://github.com/minetest-mods/anvil](https://github.com/minetest-mods/anvil), revize c9292b4cb3fb03a04638f491abf8b48a59d4c972
* Původní licence: GPLv3
* Licence úprav: GPLv3
* [ContentDB](https://content.minetest.net/packages/FaceDeer/anvil/)

## Appliances API (appliances)

* Zdroj: [https://github.com/sfence/appliances](https://github.com/sfence/appliances), revize 153ce6b72fae3a5062cb14b2480b406afe21a301
* Původní licence: MIT pro kód, CC-BY-SA-3.0 pro média
* Licence úprav: MIT pro kód, CC-BY-SA-3.0 pro média
* [ContentDB](https://content.minetest.net/packages/SFENCE/appliances/)

## Areas (areas)

* Zdroj: [https://github.com/minetest-mods/areas/](https://github.com/minetest-mods/areas/), revize 4018c0d20450a106b3bda6627894b130595a7cd6
* Původní licence: LGPL 2.1+
* Licence úprav: LGPL 2.1+
* [ContentDB](https://content.minetest.net/packages/ShadowNinja/areas/)

## Auroras (auroras)

* Zdroj: [https://github.com/random-geek/auroras](https://github.com/random-geek/auroras), revize 52f6b3eda55c67494ff132e0696cade4236a2795
* Původní licence: GPLv3
* Licence úprav: GPLv3
* [ContentDB](https://content.minetest.net/packages/random\_geek/auroras/)

## Baked Clay (bakedclay)

* Zdroj: [https://notabug.org/tenplus1/bakedclay](https://notabug.org/tenplus1/bakedclay), revize 975bee989893aa25d5627a45be3801c658905f1d
* Původní licence: MIT (část textur pod licencí, která je pravděpodobně CC-BY-NC)
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/bakedclay/)

## Basic materials (basic\_materials)

* Zdroj: [https://github.com/mt-mods/basic\_materials](https://github.com/mt-mods/basic\_materials), revize 8b681d9755a16efeca8d0b9f81f5a267cf93fa44
* Původní licence: LGPL 3.0 pro kód a CC-BY-SA 4.0 pro vše ostatní
* Licence úprav: CC-BY-SA 4.0
* [ContentDB](https://content.minetest.net/packages/VanessaE/basic\_materials/)

## Basic signs (basic\_signs)

* Zdroj: [https://github.com/mt-mods/basic\_signs](https://github.com/mt-mods/basic\_signs), revize 275d3e720707f3614a5ca54430fe2a21f7bffa52
* Původní licence: LGPL 3.0 pro kód a CC-BY-SA 4.0 pro vše ostatní
* Licence úprav: CC-BY-SA 4.0

## Beautiful Flowers (beautiflowers)

* Zdroj: [https://github.com/minefaco/beautiflowers](https://github.com/minefaco/beautiflowers), revize a9c4f740cc6ddff4e71f0a3749753ed9d76bca00
* Původní licence: GPLv3 pro kód, CC0 pro média
* Licence úprav: GPLv3
* [ContentDB](https://content.minetest.net/packages/1faco/beautiflowers/)

## Bell (bell)

* Zdroj: [https://github.com/FaceDeer/bell](https://github.com/FaceDeer/bell), revize fbc13a7566e9787b5f05d8c8eb3ec989ba5792b2
* Původní licence: GPLv3, zvuk CC-BY-SA-3.0
* Licence úprav: GPLv3
* [ContentDB](https://content.minetest.net/packages/Sokomine/bell/)

## Bike (bike)

* Zdroj: [https://gitlab.com/h2mm/bike/](https://gitlab.com/h2mm/bike/), revize c5b287c3ce20ad5c4cb5eba67e47d68ce04c046c
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/Hume2/bike/)

## Bonemeal (bonemeal)

* Zdroj: [https://notabug.org/tenplus1/bonemeal](https://notabug.org/tenplus1/bonemeal), revize 804343f7c02fe554a8c652ea90a56528c8237833
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/bonemeal/)

## Bridger (bridger)

* Zdroj: [https://github.com/v-rob/bridger](https://github.com/v-rob/bridger), revize f6c5c396055a5cf8cfb0334b0f1053bd4fc65822
* Původní licence: MIT pro kód, CC-BY-SA 3.0 pro média
* Licence úprav: MIT pro kód, CC-BY-SA 3.0 pro média
* [ContentDB](https://content.minetest.net/packages/v-rob/bridger/)

## Bucket Wooden (bucket\_wooden)

* Zdroj: [https://gitlab.com/h2mm/wooden_bucket](https://gitlab.com/h2mm/wooden\_bucket), revize 50b0d4e6332286a76fe88f642d8e6dc79fbed99a
* Původní licence: LGPL-2.1 pro kód, CC-BY-SA-3.0 pro textury
* Licence úprav: LGPL-2.1
* [ContentDB](https://content.minetest.net/packages/Hume2/bucket\_wooden/)

## Bushy Leaves (bushy\_leaves)

* Zdroj: [https://git.minetest.land/erlehmann/bushy\_leaves](https://git.minetest.land/erlehmann/bushy\_leaves), revize 9be33ef9c37836414fac7a9dd78125efed77b581
* Původní licence: AGPLv3+
* Licence úprav: AGPLv3+
* [ContentDB](https://content.minetest.net/packages/erlehmann/bushy\_leaves/)

## Charcoal (charcoal)

* Zdroj: [https://content.minetest.net/packages/X17/charcoal/](https://content.minetest.net/packages/X17/charcoal/), verze 0.2
* Původní licence: GPLv3
* Licence úprav: GPLv3

## ch\_core (ch\_core)

* Moje vlastní práce
* Licence: LGPL-2.1 pro kód, textury: různé licence (viz license.txt)

## Chess Mod (chess\_mod)

* Zdroj: [https://github.com/bas080/chess-mod](https://github.com/bas080/chess-mod), revize 9d9e032f1be3c4e24a42751ccd8a8bf4f2d6c8d3 (textury z revize 9fc9ac2ded011b6ec834f015ea389a85cda3fc81, viz ostatní-zdroje/chess-mod-textures)
* Původní licence: WTFPL
* Licence úprav: WTFPL

## Christmass Tree (christmastree)

* Zdroj: [https://forum.minetest.net/viewtopic.php?t=10701](https://forum.minetest.net/viewtopic.php?t=10701), verze 1.0.2
* Původní licence: WTFPL
* Licence úprav: WTFPL
* [ContentDB](https://content.minetest.net/packages/ExeterDad/christmastree/)

## Climatez (climatez)

* Zdroj: [https://github.com/runsy/climatez](https://github.com/runsy/climatez), revize 57d7f4ea41fcede9e4435e3521c3ece94cab559d
* Původní licence: GPLv3 pro kód, CC BY-SA-4.0 pro textury, CC0 pro zvuky.
* Licence úprav: GPLv3
* [ContentDB](https://content.minetest.net/packages/runs/climatez/)

## Clothing 2 (clothing)

* Zdroj: [https://github.com/sfence/clothing](https://github.com/sfence/clothing), revize dabac3f5ece2766a570c39b0885c776879d81903
* Původní licence: LGPLv2.1 pro kód, převážně CC-BY-SA-3.0 pro média (také CC-BY-SA-4.0 a CC0)
* Licence úprav: LGPLv2.1 pro kód, CC-BY-SA-3.0 pro média
* [ContentDB](https://content.minetest.net/packages/SFENCE/clothing/)

## Cottages (cottages)

* Zdroj: [https://github.com/Sokomine/cottages](https://github.com/Sokomine/cottages), revize 2b10e6f6791198edb9ad0fd3b2e12ce3a00a1142
* Původní licence: GPLv3 pro kód, textury různé licence, převážně CC BY-SA-3.0.
* Licence úprav: GPLv3
* [ContentDB](https://content.minetest.net/packages/Sokomine/cottages/)

## Dark Age (darkage)

* Zdroj: [https://github.com/kakalak-lumberJack/darkage](https://github.com/kakalak-lumberJack/darkage), revize 34d5ddd21b57fe73eeaf2b2d83324ff526cd7c1f
* Původní licence: WTFPL
* Licence úprav: WTFPL
* [ContentDB](https://content.minetest.net/packages/addi/darkage/)

## Default (default)

* Z Minetest Game, upraveno. Odnož byla nutná kvůli úpravě hustoty výchozích lesů.
* Zdroj: [https://github.com/minetest/minetest\_game](https://github.com/minetest/minetest\_game), revize ???
* Původní licence: LGPL 2.1+
* Licence úprav: LGPL 2.1+

## Dense Ores (denseores)

* Zdroj: [https://notabug.org/Oswald/denseores.git](https://notabug.org/Oswald/denseores.git), revize 7a9a7134e53cac55c40c1e1d749c69be8b4c006d
* Původní licence: GPLv3+
* Licence úprav: GPLv3+
* [ContentDB](https://content.minetest.net/packages/benedict424/denseores/)

## Digtron (digtron)

* Zdroj: [https://github.com/minetest-mods/digtron](https://github.com/minetest-mods/digtron), revize 8cd481daeacddcd60689239bed5455e7db53f34f
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/FaceDeer/digtron/)

## Dreambuilder hotbar expander (dreambuilder\_hotbar)

* Zdroj: [https://github.com/mt-mods/dreambuilder\_hotbar](https://github.com/mt-mods/dreambuilder\_hotbar), revize 41432618a0c41e2fd762ccb1f4cb9a2db329806e
* Původní licence: LGPL 3.0 a CC-BY-SA 4.0
* Licence úprav: LGPL 3.0
* [ContentDB](https://content.minetest.net/packages/VanessaE/dreambuilder\_hotbar/)

## Extra Doors (extra\_doors)

* Zdroj: [https://bitbucket.org/sorcerykid/extra\_doors](https://bitbucket.org/sorcerykid/extra\_doors), revize 76bca11478fd59adbe6c615de1189e12c75bd32b
* Původní licence: LGPLv3+ (kód), CC-BY-SA-3.0 (textury)
* Licence úprav: LGPLv3+ (kód), CC-BY-SA-3.0 (textury)
* [ContentDB](https://content.minetest.net/packages/sorcerykid/extra\_doors/)

## Factory Bridges (factory\_bridges)

* Zdroj: [https://github.com/pandorabox-io/factory_bridges](https://github.com/pandorabox-io/factory_bridges), revize d1f7d6b3784053b87258a8636f7ed42d3f2ff54b
* Původní licence: LGPL 2.1
* Licence úprav: LGPL 2.1
* [ContentDB](https://content.minetest.net/packages/narrnika/factory\_bridges/)

## Farming Redo (farming)

* Zdroj: [https://notabug.org/tenplus1/farming](https://notabug.org/tenplus1/farming), revize 0b06c7cd450c5ec9a76b3c22a9c57f06e4f8a7c2
* Původní licence: MIT a další (včetně CC-BY-ND-SA)
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/farming/)
* Implantovány jahody z módu Ethereal NG (licence: MIT).

## Funny Shadows (shadows)

* Zdroj: [https://github.com/x2048/shadows](https://github.com/x2048/shadows), revize d001680bb8af00ba0c78ee74c6dcc3b31d02cd25
* Původní licence: GNU Affero GPLv3
* Licence úprav: GNU Affero GPLv3
* [ContentDB](https://content.minetest.net/packages/x2048/shadows/)

## Guinea Pig (guinea\_pig)

* Zdroj: [https://github.com/DrPlamsa/guinea\_pig](https://github.com/DrPlamsa/guinea\_pig), revize 281739351ee06fa5eb5e0146113920d846a22aeb
* Původní licence: MIT, textura CC-BY-3.0
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/DrPlamsa/guinea\_pig/)

## Hiking Redo (hiking)

* Zdroj: [https://gitlab.com/h2mm/hiking](https://gitlab.com/h2mm/hiking), revize e2fad69f04e7533a4dd25b3946d9ddee77433ab9
* Původní licence: CC0
* Licence úprav: CC0
* [ContentDB](https://content.minetest.net/packages/Hume2/hiking/)

## Itemshelf (itemshelf)

* Zdroj: [https://github.com/hkzorman/itemshelf](https://github.com/hkzorman/itemshelf), revize 8d4e24717cc1392cd370bc700dae56dae29afb42
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/zorman2000/itemshelf/)

## Jumping (jumping)

* Zdroj: [https://github.com/minetest-mods/jumping](https://github.com/minetest-mods/jumping), revize b5205e4e7d651306d31e2ea100ad75abb1856401
* Původní licence: GPLv3
* Licence úprav: GPLv3

## Koruna československá (kcs)

* Kód: vlastní práce; textury: vlastní práce založená na fotografiích (CC-BY-SA-4.0)
* Licence: kód MIT, textury CC-BY-SA-4.0

## Localized Server News (minenews)

* Zdroj: [https://github.com/ronoaldo/minenews](https://github.com/ronoaldo/minenews), revize e4346dc6c666a52039c33bb2c62ee9ad85655820
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/ronoaldo/minenews/)

## Mail Mod (mail\_mod)

* Zdroj: [https://github.com/minetest-mail/mail\_mod](https://github.com/minetest-mail/mail\_mod), revize d9771ded2a01c8707033760478df482311abe4c6
* Původní licence: MIT
* Licence úprav: MIT

## Markdown2Formspec (markdown2formspec)

* Zdroj: [https://github.com/ExeVirus/markdown2formspec](https://github.com/ExeVirus/markdown2formspec), revize 4cd2a8b45a639378bba9dc56eb347ebfe94471e6
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/Just\_Visiting/markdown2formspec/)

## Matrix Math Library (lua-matrix)

* Zdroj: [https://github.com/entuland/lua-matrix](https://github.com/entuland/lua-matrix), revize b7322ea304ecf05f4dff9f230a3930168c204037
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/entuland/matrix/)

## Minor Redefinitions (redef)

* Zdroj: [https://gitlab.com/4w/redef](https://gitlab.com/4w/redef), revize 20b57de8f7b649ed142ee92ae876c15e65e182cc
* Původní licence: GPLv3
* Licence úprav: GPLv3
* [ContentDB](https://content.minetest.net/packages/Linuxdirk/redef/)

## Mobs Animal (mobs\_animal)

* Zdroj: [https://notabug.org/TenPlus1/mobs\_animal](https://notabug.org/TenPlus1/mobs\_animal), revize cca7169b9e88c4795ce69dd4282ebea9f921c6b1
* Původní licence: MIT (některá média CC0)
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/mobs\_animal/)

## Mobs Horse (mob\_horse)

* Zdroj: [https://notabug.org/TenPlus1/mob\_horse](https://notabug.org/TenPlus1/mob\_horse), revize 4022ae9a0225f0971a48fd7535eab709f1b6aa32
* Původní licence: MIT (textury CC-BY-SA-3.0)
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/mob\_horse/)

## Mobs NPC (mobs\_npc)

* Zdroj: [https://notabug.org/TenPlus1/mobs\_npc](https://notabug.org/TenPlus1/mobs\_npc), revize 5ca55f49ce74d97dbf6c099e87ac22377d0ffd98
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/mobs\_npc/)

## Mobs Redo (mobs\_redo)

* Zdroj: [https://notabug.org/TenPlus1/mobs\_redo](https://notabug.org/TenPlus1/mobs\_redo), revize ca34cc2274082bd4a3cf4843f7f5ff939d659e1e
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/mobs/)

## Mobs Water (mobs\_water)

* Zdroj: [https://notabug.org/TenPlus1/mobs\_water](https://notabug.org/TenPlus1/mobs\_water), revize 6aa05dff220a2b37c0b701ae6cef9fbc51c359da
* Původní licence: kód MIT, textury různé (GPLv3, CC-BY-SA-3.0, WTFPL)
* Licence úprav: MIT
* Odstraněni žraloci (protože se mi nelíbí) a želvy (ty se mi líbí, ale model a textura mají neznámou licenci)

## More Blocks (moreblocks)

* Zdroj: [https://github.com/minetest-mods/moreblocks](https://github.com/minetest-mods/moreblocks), revize dce587cf3397dca7e242455cd017cba50ee28a5b
* Původní licence: zlib license (kompatibilní s GPL)
* Licence úprav: zlib license
* [ContentDB](https://content.minetest.net/packages/Calinou/moreblocks/)

## More Ores (moreores)

* Zdroj: [https://github.com/minetest-mods/moreores](https://github.com/minetest-mods/moreores), revize fb2d58d8c843aa9512f37b12436a2bb5166585f4
* Původní licence: zlib license
* Licence úprav: zlib license
* [ContentDB](https://content.minetest.net/packages/Calinou/moreores/)

## More Trees! (moretrees)

* Zdroj: [https://github.com/mt-mods/moretrees](https://github.com/mt-mods/moretrees), revize 62cab1b1d9d40a73b2f304650951d4659d86e391
* Původní licence: LGPL 3.0 pro kód, CC-BY-SA 4.0 pro média
* Licence úprav: LGPL 3.0 pro kód, CC-BY-SA 4.0 pro média
* [ContentDB](https://content.minetest.net/packages/VanessaE/moretrees/)

## Pillars (pillars)

* Zdroj: [https://github.com/CivtestGame/Pillars](https://github.com/CivtestGame/Pillars), revize 43e9b355ed1843e596331433b29926e20206055e
* Původní licence: GPLv3.0, část kódu současně pod MIT
* Licence úprav: GPLv3.0
* [ContentDB](https://content.minetest.net/packages/citorva/pillars/)

## Pipeworks (pipeworks)

* Zdroj: [https://github.com/mt-mods/pipeworks](https://github.com/mt-mods/pipeworks), revize 7b15bdbd1f46f4a804dfb0c5a3570081a70b8db0
* Původní licence: LGPL 3 pro kód, CC-BY-SA-4.0 pro média
* Licence úprav: LGPL 3 pro kód, CC-BY-SA 4.0 pro média
* [ContentDB](https://content.minetest.net/packages/VanessaE/pipeworks/)

## Placeable Ingots (ingots)

* Zdroj: [https://github.com/Skamiz/ingots](https://github.com/Skamiz/ingots), revize 388366355cdce66958390f986334b77f3c6d99e9
* Původní licence: LGPL 2.1 pro kód, CC-BY-SA-4.0 pro média
* Licence úprav: LGPL 2.1

## Powerbanks (powerbanks)

* Zdroj: [https://github.com/OgelGames/powerbanks](https://github.com/OgelGames/powerbanks), revize efd27fb551b0dd4977bf2b6b834e2ec210282114
* Původní licence: MIT pro kód, CC-BY-SA-4.0 pro média
* Licence úprav: MIT pro kód, CC-BY-SA 4.0 pro média
* [ContentDB](https://content.minetest.net/packages/OgelGames/powerbanks/)

## Realtime Elevator (elevator)

* Zdroj: [https://github.com/shacknetisp/elevator](https://github.com/shacknetisp/elevator), revize ef9ae22b81e7227bee627089f4e7c8c2b608fcb9
* Původní licence: ISC
* Licence úprav: ISC
* [ContentDB](https://content.minetest.net/packages/shacknetisp/realtime\_elevator/)

## Real Torch (real\_torch)

* Zdroj: [https://notabug.org/tenplus1/real\_torch](https://notabug.org/tenplus1/real\_torch), revize 3d23991d014ea078b86f7c70b6cf8d88b2f10258
* Původní licence: MIT pro kód, CC0 a CC-BY-3.0 pro média
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/real\_torch/)

## Replacer (replacer)

* Zdroj: [https://github.com/Sokomine/replacer](https://github.com/Sokomine/replacer), revize d69fcb319810caf560d274d81801bb13d1d2c850
* Původní licence: GPLv3+
* Licence úprav: GPLv3+
* [ContentDB](https://content.minetest.net/packages/Sokomine/replacer/)

## Rhotator (rhotator)

* Zdroj: [https://github.com/entuland/rhotator](https://github.com/entuland/rhotator), revize e2a928349e5896b438c0ab779ef3a632884d90b8
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/entuland/rhotator/)

## Round Tree Trunks (round\_trunks)

* Zdroj: [https://codeberg.org/Hamlet/round\_trunks](https://codeberg.org/Hamlet/round\_trunks), revize b8de39e76c8c958f46ce5a6a40ff0c72aa8c0606
* Původní licence: EUPL-1.2+ (kód), CC-BY-SA-4.0 (textury), GPLv3 (model)
* Licence úprav: EUPL-1.2+ (kód)
* [ContentDB](https://content.minetest.net/packages/Hamlet/round\_trunks/)

## Signs Lib (signs\_lib)

* Zdroj: [https://github.com/mt-mods/signs\_lib](https://github.com/mt-mods/signs\_lib), revize 60d67afab3d78ece7e9b4a61b50c60903e8c72a9
* Původní licence: LGPL 3 pro kód, CC-BY-SA-4.0 pro média
* Licence úprav: LGPL 3 pro kód, CC-BY-SA 4.0 pro ostatní
* [ContentDB](https://content.minetest.net/packages/VanessaE/signs\_lib/)

## Skins DB (skinsdb)

* Zdroj: [https://github.com/minetest-mods/skinsdb](https://github.com/minetest-mods/skinsdb), revize b769824d249b432a4f4f6a659aa6dae1a09071a8
* Původní licence: GPLv3 pro kód, různé licence pro textury
* Licence úprav: GPLv3 pro kód, různé licence pro ostatní
* [ContentDB](https://content.minetest.net/packages/bell07/skinsdb/)
* K módu bez úprav přidány textury z módu Wardrobe Outfits, podléhající licenci CC-BY-SA-3.0.

## Smart Shop (smartshop)

* Zdroj: [https://github.com/AiTechEye/smartshop](https://github.com/AiTechEye/smartshop), revize dd7bf29dea77f5728d88279d71f175693a1d6a18
* Původní licence: LGPL 2.1 pro kód, CC-BY-SA-4.0 pro média
* Licence úprav: LGPL 2.1 pro kód, CC-BY-SA 4.0 pro ostatní
* [ContentDB](https://content.minetest.net/packages/AiTechEye/smartshop/)

## Solid Color (solidcolor)

* Zdroj: [https://cheapiesystems.com/git/solidcolor/](https://cheapiesystems.com/git/solidcolor/), revize 0450d8f82bb7c70c164a802730b99c2829791ebd
* Původní licence: Unlicense (ale z původního kódu už nezůstalo prakticky nic)
* Licence úprav: Unlicense pro kód, různé licence pro přidané textury
* [ContentDB](https://content.minetest.net/packages/cheapie/solidcolor/)

## Spawn Command (spawn\_command)

* Zdroj: [https://github.com/minetest-mods/spawn\_command](https://github.com/minetest-mods/spawn\_command), revize 2d418e2ab800f6565c828cf5c30642e9dfd6da28
* Původní licence: LGPL 2.1
* Licence úprav: LGPL 2.1
* [ContentDB](https://content.minetest.net/packages/lag01/spawn\_command/)

## Stamina (stamina)

* Zdroj: [https://github.com/minetest-mods/stamina](https://github.com/minetest-mods/stamina), revize 1a6e893f096dd0c120719e918fc1998e9a6175f8
* Původní licence: LGPL 2.1+ pro kód, média různě (CC-BY-3.0 a WTFPL)
* Licence úprav: LGPL 2.1
* [ContentDB](https://content.minetest.net/packages/sofar/stamina/)

## Stairs (stairs)

* Z Minetest Game, upraveno. Odnož byla nutná, protože původní mod neposkytuje dostatečné možnosti lokalizace.
* Zdroj: [https://github.com/minetest/minetest\_game](https://github.com/minetest/minetest\_game), revize ???
* Původní licence: LGPL 2.1+
* Licence úprav: LGPL 2.1+

## Technic HV Extend (technic\_hv\_extend)

* Zdroj: [https://github.com/Emojigit/technic\_hv\_extend](https://github.com/Emojigit/technic\_hv\_extend), revize b16a76d607cc7df2b2aca25ca1b76d079727290c
* Původní licence: LGPL 2.1
* Licence úprav: LGPL 2.1
* [ContentDB](https://content.minetest.net/packages/Emojiminetest/technic\_hv\_extend/)

## Trash Can (trash\_can)

* Zdroj: [https://github.com/minetest-mods/trash\_can](https://github.com/minetest-mods/trash\_can), revize 423b0f26a827fd3b0092d29d859199ff6776b212
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/Evergreen/trash\_can/)

## Travelnet (travelnet)

* Zdroj: [https://github.com/mt-mods/travelnet](https://github.com/mt-mods/travelnet), revize a436c1b106beafbca6fe7279eb9359e88e025ab0
* Původní licence: GPL-3
* Licence úprav: GPL-3
* [ContentDB](https://content.minetest.net/packages/mt-mods/travelnet/)

## ts\_furniture (ts\_furniture)

* Zdroj: [https://github.com/minetest-mods/ts\_furniture](https://github.com/minetest-mods/ts\_furniture), revize 6cdb584c8513b862b812ba855fd780483770abce
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/Thomas-S/ts\_furniture/)

## Unified Dyes (unified\_dyes)

* Zdroj: [https://github.com/mt-mods/unifieddyes](https://github.com/mt-mods/unifieddyes), revize 878377301f376b21d4d4529da2a5c082f49792fe
* Původní licence: GPLv2+
* Licence úprav: GPLv2+
* [ContentDB](https://content.minetest.net/packages/VanessaE/unifieddyes/)

## Unified Inventory (unified\_inventory)

* Zdroj: [https://github.com/minetest-mods/unified\_inventory](https://github.com/minetest-mods/unified\_inventory), revize 14da1a3dd0e9f93703cf668c7095e2e8974d668d
* Původní licence: LGPLv2+
* Licence úprav: LGPLv2+
* [ContentDB](https://content.minetest.net/packages/RealBadAngel/unified\_inventory/)

## Wield 3D (wield3d)

* Zdroj: [https://github.com/stujones11/wield3d](https://github.com/stujones11/wield3d), revize 668ea2682a89d6f6a6a6fdc2326b1db6d69257ac
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/stu/wield3d/)

## Wielded Light (wielded\_light)

* Zdroj: [https://github.com/minetest-mods/wielded\_light](https://github.com/minetest-mods/wielded\_light), revize 1646439ac4924f534af05d639af900d1d44506cd
* Původní licence: GPL-3
* Licence úprav: (mod je zatím bez úprav)
* [ContentDB](https://content.minetest.net/packages/bell07/wielded\_light/)

# Ostatní použité zdroje

## Your Dad's BBQ Mod (BBQ)

* Zdroj: [https://github.com/Grizzly-Adam/BBQ](https://github.com/Grizzly-Adam/BBQ), revize 1a72f7c2baacc6798033a7973545ab74cc52341e
* Původní licence: LGPLv2.1+ (kód), CC-BY-SA-3.0 (textury), CC-BY-3.0 (zvuky)
* [ContentDB](https://content.minetest.net/packages/Grizzly%20Adam/bbq/)

## Ethereal NG (ethereal)

* Zdroj: [https://notabug.org/tenplus1/ethereal](https://notabug.org/tenplus1/ethereal), revize 769fb8111edd0a895514db3a2df316c0b49b0252
* Původní licence: kód MIT, textury různé, ale neoznačené také MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/ethereal/)

## Technic CNC Improve Machine (technic\_cnc\_improve)

* Zdroj: [https://github.com/Emojigit/technic\_cnc\_improve](https://github.com/Emojigit/technic\_cnc\_improve), revize 769fb8111edd0a895514db3a2df316c0b49b0252
* Původní licence: LGPL 2.1
* [ContentDB](https://content.minetest.net/packages/Emojiminetest/technic\_cnc\_improve/)

## Technic Plus (technic\_plus)

* Zdroj: [https://github.com/mt-mods/technic](https://github.com/mt-mods/technic), revize be5b7cf56eafd45fdf5ef816693581bc59742ea0
* Původní licence (není-li uvedeno jinak v README.md): concrete, extranodes, technic, technic\_worldgen: WTFPL; technic\_cnc, technic\_chests, wrench: LGPLv2+
* [ContentDB](https://content.minetest.net/packages/mt-mods/technic\_plus/)

## Tool Tweaks (tool\_tweaks)

* Zdroj: [https://github.com/wsor4035/tool\_tweaks](https://github.com/wsor4035/tool\_tweaks), revize 72e180102e84879bee9f00e5f0b47fb1691b0723
* Původní licence:CC-BY-SA-3.0
* [ContentDB](https://content.minetest.net/packages/wsor4035/tool\_tweaks/)

## Wardrobe Outfits (wardrobe\_outfits)

* Mod není použit na serveru přímo, ale textury z něj jsou vloženy do modu SkinsDB.
* Zdroj: [https://github.com/AntumMT/mod-wardrobe\_outfits](https://github.com/AntumMT/mod-wardrobe\_outfits), revize 7a874cf83d7109ea4cd81f1b15506f7bdb331d71
* Původní licence: kód MIT, textury postav všechny CC-BY-SA-3.0
* [ContentDB](https://content.minetest.net/packages/AntumDeluge/wardrobe\_outfits/)
