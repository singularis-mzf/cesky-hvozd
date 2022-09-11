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

## Beauty Pack (beauty\_pack)

* Zdroj: [https://github.com/runsy/beauty\_pack](https://github.com/runsy/beauty\_pack), revize 9df3ce21d1c4af542d589ce1c324da188522c451
* Původní licence: GPL v3 (kód), CC-BY-SA-4.0 (textury), ? (modely)
* Licence úprav: GPL v3
* Použity jen vybrané módy

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

## Moretrains (moretrains)

* Zdroj: [https://git.bananach.space/moretrains.git/](https://git.bananach.space/moretrains.git/), revize 59ee0e4f1577b75ab8736c8a8115c774eeaea3c7
* Původní licence: LGPLv2.1 pro kód, CC-BY-SA 3.0 pro média
* Licence úprav: LGPLv2.1 pro kód, CC-BY-SA 3.0 pro média
* [ContentDB](https://content.minetest.net/packages/gpcf/moretrains/)

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

## 3D Armor Fly & Swim (3d\_armor\_flyswim)

* Zdroj: [https://github.com/sirrobzeroone/3d\_armor\_flyswim](https://github.com/sirrobzeroone/3d\_armor\_flyswim), revize 586d4501c0e5f700c3055c6bf0820856fe37036c
* Původní licence: kód LGPLv2.1 (malá část MIT), modely CC BY-SA 3.0, textury různé
* Licence úprav: LGPLv2.1
* [ContentDB](https://content.minetest.net/packages/sirrobzeroone/3d\_armor\_flyswim/)

## Advtrains Construction Train (advtrains\_construction\_train)

* Zdroj: [https://git.bananach.space/advtrains\_construction\_train.git/](https://git.bananach.space/advtrains\_construction\_train.git/), revize 2b27b8d8f1a629ff10f295cb8432225a3a9a943b
* Původní licence: AGPLv3
* Licence úprav: AGPLv3

## Airtanks (airtanks)

* Zdroj: [https://github.com/minetest-mods/airtanks](https://github.com/minetest-mods/airtanks), revize b686694979f0dc007f22038a24a1fc416ec39b9b
* Původní licence: kód a textury MIT, zvuky různé (CC0, CC BY 3.0)
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/FaceDeer/airtanks/)

## Ambience Lite (minetest-mod-ambience)

* Zdroj: [https://notabug.org/minenux/minetest-mod-ambience](https://notabug.org/minenux/minetest-mod-ambience), revize e6ed64b1e518ba6bdd33c306895634b2c9622413 (odnož původního repozitáře)
* Původní licence: kód MIT, zvuky různé (některé nedovolují komerční použití!)
* Licence úprav: kód MIT, zvuky uvedeny individuálně
* [ContentDB](https://content.minetest.net/packages/TenPlus1/ambience/)

## Wilhelmines Animal World (animalworld)

* Zdroj: [https://github.com/Skandarella/animalworld](https://github.com/Skandarella/animalworld), revize d4387aa71167e9534516d20395b4acb0444bc900
* Původní licence: kód, textury, modely a animace MIT; zvuky různé (převážně „Creative Commons“ z freesound.org)
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/Liil/animalworld/)

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

## Books (books)

* Zdroj: [https://github.com/everamzah/books](https://github.com/everamzah/books), revize fa9c5507f5b04f4949d831e0819b5519c2f20208
* Původní licence: LGPLv2.1+
* Licence úprav: LGPLv2.1+

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

* Zdroj: [https://github.com/sfence/clothing](https://github.com/sfence/clothing), revize 3e27fdbf737f02eb20f66d0a9a009e415e50e584
* Původní licence: LGPLv2.1 pro kód, převážně CC-BY-SA-3.0 pro média (také CC-BY-SA-4.0 a CC0)
* Licence úprav: LGPLv2.1 pro kód, CC-BY-SA-3.0 pro média
* [ContentDB](https://content.minetest.net/packages/SFENCE/clothing/)

## Cottages (cottages)

* Zdroj: [https://github.com/Sokomine/cottages](https://github.com/Sokomine/cottages), revize 2b10e6f6791198edb9ad0fd3b2e12ce3a00a1142
* Původní licence: GPLv3 pro kód, textury různé licence, převážně CC BY-SA-3.0.
* Licence úprav: GPLv3
* [ContentDB](https://content.minetest.net/packages/Sokomine/cottages/)

## Craftable Lava (craftable\_lava)

* Zdroj: [https://github.com/MikeRedwood/craftable\_lava](https://github.com/MikeRedwood/craftable\_lava), revize 5d2af72a69d61a8664a4753e73720ec18092ab59
* Původní licence: LGPLv2.1
* Licence úprav: LGPLv2.1
* [ContentDB](https://content.minetest.net/packages/MikeRedwood/craftable\_lava/)

## Currency (currency)

* Zdroj: [https://github.com/mt-mods/currency](https://github.com/mt-mods/currency), revize f74ee653b8f8c60ea4f78e7dd827dcc568649dee
* Původní licence: LGPLv3 pro kód, CC-BY-SA-4.0 pro vše ostatní
* Licence úprav: LGPLv3 pro kód, CC-BY-SA-4.0 pro vše ostatní
* [ContentDB](https://content.minetest.net/packages/VanessaE/currency/)

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

## Drawers (drawers)

* Zdroj: [https://github.com/minetest-mods/drawers](https://github.com/minetest-mods/drawers), revize 7ab68688ed51db80cffa61fc9ce08453aeabb986
* Původní licence: kód MIT, překlady CC0-1.0, média CC-BY-3.0 nebo MIT, vše ostatní MIT
* Licence úprav: kód MIT, překlad CC0-1.0, vše ostatní MIT
* [ContentDB](https://content.minetest.net/packages/LNJ/drawers/)

## Dreambuilder hotbar expander (dreambuilder\_hotbar)

* Zdroj: [https://github.com/mt-mods/dreambuilder\_hotbar](https://github.com/mt-mods/dreambuilder\_hotbar), revize 41432618a0c41e2fd762ccb1f4cb9a2db329806e
* Původní licence: LGPL 3.0 a CC-BY-SA 4.0
* Licence úprav: LGPL 3.0
* [ContentDB](https://content.minetest.net/packages/VanessaE/dreambuilder\_hotbar/)

## Drinks (drinks)

* Zdroj: [https://github.com/minetest-mods/drinks](https://github.com/minetest-mods/drinks), revize 5d117257993e9e8788bbe3b796cae4b423efcdc4
* Původní licence: kód MIT, vše ostatní CC BY-SA 3.0
* Licence úprav: kód MIT, ostatní CC BY-SA 3.0
* [ContentDB](https://content.minetest.net/packages/Nathan.S/drinks/)

## Emote (emote)

* Zdroj: [https://github.com/minetest-mods/emote](https://github.com/minetest-mods/emote), revize 402a6f07f5ace5ca1a072664608ac3ce30f7d84c
* Původní licence: LGPLv2.1
* Licence úprav: LGPLv2.1
* [ContentDB](https://content.minetest.net/packages/sofar/emote/)

## Extra Doors (extra\_doors)

* Zdroj: [https://bitbucket.org/sorcerykid/extra\_doors](https://bitbucket.org/sorcerykid/extra\_doors), revize 76bca11478fd59adbe6c615de1189e12c75bd32b
* Původní licence: LGPLv3+ (kód), CC-BY-SA-3.0 (textury)
* Licence úprav: LGPLv3+ (kód), CC-BY-SA-3.0 (textury)
* [ContentDB](https://content.minetest.net/packages/sorcerykid/extra\_doors/)

## Factory Bridges (factory\_bridges)

* Zdroj: [https://github.com/pandorabox-io/factory\_bridges](https://github.com/pandorabox-io/factory\_bridges), revize d1f7d6b3784053b87258a8636f7ed42d3f2ff54b
* Původní licence: LGPL 2.1
* Licence úprav: LGPL 2.1
* [ContentDB](https://content.minetest.net/packages/narrnika/factory\_bridges/)

## Farming Redo (farming)

* Zdroj: [https://notabug.org/tenplus1/farming](https://notabug.org/tenplus1/farming), revize 0b06c7cd450c5ec9a76b3c22a9c57f06e4f8a7c2
* Původní licence: MIT a další (včetně CC-BY-ND-SA)
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/farming/)
* Implantovány jahody z módu Ethereal NG (licence: MIT) a banány a len z módu Cucina Vegana (licence textur: LGPLv3).

## Fireworkz (fireworkz)

* Zdroj: [https://github.com/runsy/fireworkz](https://github.com/runsy/fireworkz), revize e5b1c06bbb3048645a5fea4e8f6709a9bbfa3345
* Původní licence: LGPL 2.1 pro kód, textury CC BY-SA-4.0, zvuky různé svobodné
* Licence úprav: LGPL 2.1 pro kód, CC-BY-SA-4.0 pro textury
* [ContentDB](https://content.minetest.net/packages/runs/fireworkz/)

## Funny Shadows (shadows)

* Zdroj: [https://github.com/x2048/shadows](https://github.com/x2048/shadows), revize d001680bb8af00ba0c78ee74c6dcc3b31d02cd25
* Původní licence: GNU Affero GPLv3
* Licence úprav: GNU Affero GPLv3
* [ContentDB](https://content.minetest.net/packages/x2048/shadows/)

## Giftbox2 (minetest\_giftbox2)

* Zdroj: [https://repo.or.cz/minetest\_giftbox2.git](https://repo.or.cz/minetest\_giftbox2.git), revize d0c150741f2d6bb840623a5f24c09890a1220aa9
* Původní licence: zdrojový kód LGPL-3.0, ostatní soubory CC BY-SA 3.0
* Licence úprav: ve zdrojovém kódu LGPL-3.0, v ostatních souborech CC BY-SA 3.0
* [ContentDB](https://content.minetest.net/packages/Wuzzy/giftbox2/)

## Guinea Pig (guinea\_pig)

* Zdroj: [https://github.com/DrPlamsa/guinea\_pig](https://github.com/DrPlamsa/guinea\_pig), revize 281739351ee06fa5eb5e0146113920d846a22aeb
* Původní licence: MIT, textura CC-BY-3.0
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/DrPlamsa/guinea\_pig/)

## Hang-Gliders (minetest-hangglider)

* Zdroj: [https://notabug.org/Piezo\_/minetest-hangglider](https://notabug.org/Piezo\_/minetest-hangglider), revize 206704ffabcdddc61150ed798c88add9965a110d
* Původní licence: GPLv3 pro kód, CC-BY-SA-3.0 nebo CC-BY-SA-4.0 pro ostatní
* Licence úprav: GPLv3 pro kód, CC-BY-SA-4.0 pro ostatní
* [ContentDB](https://content.minetest.net/packages/Piezo\_/hangglider/)

## Headlamp (headlamp)

* Zdroj: [https://github.com/OgelGames/headlamp](https://github.com/OgelGames/headlamp), revize 3bda65f4ef099b96d323ef9b815280f7a65ec132
* Původní licence: MIT pro kód, CC-BY-SA-4.0 pro média
* Licence úprav: MIT pro kód, CC-BY-SA-4.0 pro média
* [ContentDB](https://content.minetest.net/packages/OgelGames/headlamp/)

## Hiking Redo (hiking)

* Zdroj: [https://gitlab.com/h2mm/hiking](https://gitlab.com/h2mm/hiking), revize e2fad69f04e7533a4dd25b3946d9ddee77433ab9
* Původní licence: CC0
* Licence úprav: CC0
* [ContentDB](https://content.minetest.net/packages/Hume2/hiking/)

## HUD Bars (minetest\_hudbars)

* Zdroj: [https://codeberg.org/Wuzzy/minetest\_hudbars](https://codeberg.org/Wuzzy/minetest\_hudbars), revize dd2a9a008d63ae0be705903f1c56899f61029e7a
* Původní licence: MIT, dvě textury CC-BY-SA-3.0
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/Wuzzy/hudbars/)

## Ice Cream Mod (minetest\_icecream)

* Zdroj: [https://github.com/Can202/minetest\_icecream](https://github.com/Can202/minetest\_icecream), revize ff9a89b6395dc37e1a4db0106fb2d3321d280ad9
* Původní licence: GPLv3
* Licence úprav: GPLv3
* [ContentDB](https://content.minetest.net/packages/Can202/icecream/)

## Itemshelf (itemshelf)

* Zdroj: [https://github.com/hkzorman/itemshelf](https://github.com/hkzorman/itemshelf), revize 8d4e24717cc1392cd370bc700dae56dae29afb42
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/zorman2000/itemshelf/)

## JIT Profiler (jitprofiler)

* Zdroj: [https://forum.minetest.net/viewtopic.php?t=28135](https://forum.minetest.net/viewtopic.php?t=28135), jitprofiler.zip (SHA-256: 405ae916661cad32fff911a8e54e3c1d59b889b4ff909b0f9d11b7ab95ee35d5)
* Původní licence: MIT
* Licence úprav: MIT

## Jumping (jumping)

* Zdroj: [https://github.com/minetest-mods/jumping](https://github.com/minetest-mods/jumping), revize b5205e4e7d651306d31e2ea100ad75abb1856401
* Původní licence: GPLv3
* Licence úprav: GPLv3

## Letters (letters)

* Zdroj: [https://github.com/minetest-mods/letters](https://github.com/minetest-mods/letters), revize d44b88fa908682d5f68a27b491f6d0e57e66fa4c
* Původní licence: zlib license (kompatibilní s GPL) pro kód a CC BY-SA neznámé verze pro textury (ale snad lze předpokládat CC BY-SA 4.0).
* Licence úprav: zlib license pro kód a CC BY-SA pro textury
* [ContentDB](https://content.minetest.net/packages/Amaz/letters/)

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

## Mask (mask)

* Zdroj: [https://github.com/GenesisMT/mask](https://github.com/GenesisMT/mask), revize 4aac39df7778d855048833fb3295e59573bb32da
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/GenesisMT/mask/)

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

## Mobkit (mobkit)

* Zdroj: [https://github.com/TheTermos/mobkit](https://github.com/TheTermos/mobkit), revize ddea141b081e087900a6acc5a2a90e8d4e564295
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/Termos/mobkit/)

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

## New Campfire (new\_campfire)

* Zdroj: [https://github.com/mt-mods/new\_campfire](https://github.com/mt-mods/new\_campfire), revize 92578c3875730ce0cb79663e1a571e499e64175d
* Původní licence: LGPLv2.1+ pro kód (podle [příspěvku na fóru](https://forum.minetest.net/viewtopic.php?p=250137#p250137), repozitář obsahuje licenci, ale už ne odkaz na ni), CC-BY-SA 3.0 pro textury, CC-BY-SA-?? pro model
* Licence úprav: LGPLv2.1+ pro kód, CC-BY-SA 3.0 pro ostatní
* [ContentDB](https://content.minetest.net/packages/VanessaE/new\_campfire/)

## Orienteering (minetest\_orienteering)

* Zdroj: [https://repo.or.cz/minetest\_orienteering.git](https://repo.or.cz/minetest\_orienteering.git), revize 986b776c90f24f463dc8f88f80344d033826256d
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/Wuzzy/orienteering/)

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

## Rocks (rocks)

* Zdroj: [https://github.com/ExeVirus/Rocks](https://github.com/ExeVirus/Rocks), revize 7b8a47737c7dfe45b47d29b269abb6de673ebd73
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/Just\_Visiting/rocks/)

## Ropes (ropes)

* Zdroj: [https://github.com/minetest-mods/ropes](https://github.com/minetest-mods/ropes), revize b89f6c6a217b9a473bbf5e47896c642b503d507a
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/FaceDeer/ropes/)

## Rotate: Wrench - node rotation tool

* Zdroj: [https://github.com/Rogier-5/minetest-mod-rotate](https://github.com/Rogier-5/minetest-mod-rotate), revize 65125539e1d79464d168f9cd0b3ebf77463379a4
* Původní licence: LGPLv2.1 pro kód, CC BY-SA-3.0 pro obrázky
* Licence úprav: LGPLv2.1 pro kód, CC BY-SA-3.0 pro obrázky
* [ContentDB](https://content.minetest.net/packages/Argos/rotate/)

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

## Smart Shop (minetest-smartshop)

* Zdroj: [https://github.com/fluxionary/minetest-smartshop](https://github.com/fluxionary/minetest-smartshop), revize a16d56427c0795ae6ec02db7030d78deff219df7
* Původní licence: AGPLv3 pro kód, CC BY-SA 3.0 pro textury
* Licence úprav: AGPLv3 pro kód, CC BY-SA 3.0 pro ostatní
* [ContentDB](https://content.minetest.net/packages/rheo/smartshop/)

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

* Zdroj: [https://notabug.org/TenPlus1/stamina](https://notabug.org/TenPlus1/stamina), revize 96570a558e165f23b42389a501ceebaf20e0f3a8
* Původní licence: LGPL 2.1+ pro kód, média různě (CC-BY-3.0 a WTFPL)
* Licence úprav: LGPL 2.1
* [ContentDB](https://content.minetest.net/packages/TenPlus1/stamina/)

## TechPack Stairway (techpack\_stairway)

* Zdroj: [https://github.com/joe7575/techpack\_stairway](https://github.com/joe7575/techpack\_stairway), revize 7b3deb474df44344677b59f8050e5cfe81d19db9
* Původní licence: LGPL 2.1+ pro kód, textury, zvuk a dokumentace CC BY-SA 3.0
* Licence úprav: LGPL 2.1+ pro kód, ostatní CC BY-SA 3.0
* [ContentDB](https://content.minetest.net/packages/joe7575/techpack\_stairway/)

## Technic HV Extend (technic\_hv\_extend)

* Zdroj: [https://github.com/Emojigit/technic\_hv\_extend](https://github.com/Emojigit/technic\_hv\_extend), revize b16a76d607cc7df2b2aca25ca1b76d079727290c
* Původní licence: LGPL 2.1
* Licence úprav: LGPL 2.1
* [ContentDB](https://content.minetest.net/packages/Emojiminetest/technic\_hv\_extend/)

## Technic Recipes (technic\_recipes)

* Zdroj: [https://gitlab.com/alerikaisattera/technic\_recipes](https://gitlab.com/alerikaisattera/technic\_recipes), revize 5e77fa4bfbf8e42140e2dde9f9ade14d1fb49161
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/alerikaisattera/technic\_recipes/)

## Tower Crane (towercrane)

* Zdroj: [https://github.com/minetest-mods/towercrane](https://github.com/minetest-mods/towercrane), revize 3975b970ee7bc33c10237e0e5bd4c84616e70e78
* Původní licence: LGPL 2.1+
* Licence úprav: LGPL 2.1+
* [ContentDB](https://content.minetest.net/packages/joe7575/towercrane/)

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

## Watering Can (wateringcan)

* Zdroj: [https://github.com/sfence/wateringcan](https://github.com/sfence/wateringcan), revize a360698809d992decd1117262fd15c8900faa873
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/SFENCE/wateringcan/)

## Wield 3D (wield3d)

* Zdroj: [https://github.com/stujones11/wield3d](https://github.com/stujones11/wield3d), revize 668ea2682a89d6f6a6a6fdc2326b1db6d69257ac
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/stu/wield3d/)

## Wielded Light (wielded\_light)

* Zdroj: [https://github.com/minetest-mods/wielded\_light](https://github.com/minetest-mods/wielded\_light), revize b5236562af9772dff8522fe2bda5b5f738e81b88
* Původní licence: GPL-3
* Licence úprav: GPL-3
* [ContentDB](https://content.minetest.net/packages/bell07/wielded\_light/)

## Windmill (windmill)

* Zdroj: [https://github.com/Sokomine/windmill](https://github.com/Sokomine/windmill), revize 47b029dc5df9d1ed4ac26561185a31d75c98305c
* Původní licence: WTFPL
* Licence úprav: WTFPL
* [ContentDB](https://content.minetest.net/packages/Sokomine/windmill/)

## Wine (wine)

* Zdroj: [https://notabug.org/tenplus1/wine](https://notabug.org/tenplus1/wine), revize b5f94f49dab6212d46b032cea8ada47abf1ee62e
* Původní licence: MIT (kód), textury převážně CC-BY-3.0
* Licence úprav: MIT (kód)
* [ContentDB](https://content.minetest.net/packages/TenPlus1/wine/)
* Poznámka: mód obsahuje a používá model sudu z módu Cottages od Sokomine; autorství a licence modelu nejsou spolehlivě známy, protože mód Cottages je nezmiňuje; vycházím však z předpokladu, že model byl považován za součást kódu, a tedy podléhá licenci GPLv3 a autorem/kou je Sokomine.

## Wireless Mesecons (mesecons\_wireless)

* Zdroj: [https://github.com/GreenXenith/mesecons\_wireless](https://github.com/GreenXenith/mesecons\_wireless), revize 8ca249c10bcef8f2a9304fe6ef0e68a7d2910bd8
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/GreenXenith/mesecons_wireless/)

# Ostatní použité zdroje

## Your Dad's BBQ Mod (BBQ)

* Zdroj: [https://github.com/Grizzly-Adam/BBQ](https://github.com/Grizzly-Adam/BBQ), revize 1a72f7c2baacc6798033a7973545ab74cc52341e
* Původní licence: LGPLv2.1+ (kód), CC-BY-SA-3.0 (textury), CC-BY-3.0 (zvuky)
* [ContentDB](https://content.minetest.net/packages/Grizzly%20Adam/bbq/)

## Cucina Vegana (cucina\_vegana)

* Zdroj: [https://github.com/acmgit/cucina\_vegana](https://github.com/acmgit/cucina\_vegana), revize 8be3c946ea99d32b2f25a517d938fba26084b930
* Původní licence: LGPLv3
* [ContentDB](https://content.minetest.net/packages/Clyde/cucina\_vegana/)

## Digistuff (digistuff)

* Zdroj: [https://cheapiesystems.com/git/digistuff](https://cheapiesystems.com/git/digistuff), revize 32641893e75f11903489a38a201bd661c8f99b50
* Původní licence: LGPLv2.1+ (kód), CC-BY-SA-3.0 (textury), CC-BY-3.0 (zvuky)
* [ContentDB](https://content.minetest.net/packages/cheapie/digistuff/)

## Ethereal NG (ethereal)

* Zdroj: [https://notabug.org/tenplus1/ethereal](https://notabug.org/tenplus1/ethereal), revize 769fb8111edd0a895514db3a2df316c0b49b0252
* Původní licence: kód MIT, textury různé, ale neoznačené také MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/ethereal/)

## Folks (folks)

* Zdroj: [https://gitlab.com/SonoMichele/folks](https://gitlab.com/SonoMichele/folks), revize 4975480eec558307ab94a979b3cc1e5f4b6d0e23
* Původní licence: GPLv3
* [ContentDB](https://content.minetest.net/packages/SonoMichele/folks/)

## hdx-64-master texture pack by VanessaE (hdx-64)

* Zdroj: [https://gitlab.com/VanessaE/hdx-64/tree/master](https://gitlab.com/VanessaE/hdx-64/tree/master), revize f6d2c003006b296ec974be264a4539ce051614c6
* Původní licence: GFDLv1.3 (vybrané soubory pod jinými svobodnými licencemi)

## Mesh Beds (mesh\_beds)

* Zdroj: [https://forum.minetest.net/viewtopic.php?t=11817](https://forum.minetest.net/viewtopic.php?t=11817), soubor mesh\_beds.zip
* Původní licence: WTFPL (u modelů to není řečeno, ale lze předpokládat, že jsou považovány za kód)

## Wilhelmines People (people)

* Zdroj: [https://github.com/Skandarella/people](https://github.com/Skandarella/people), revize 80147ebe6efd85a88fb8af33476e96dd83ea87c5
* Původní licence: MIT (zvuky zvířat pod „Creative Commons“ — CC-BY-SA-NC-??)
* [ContentDB](https://content.minetest.net/packages/Liil/people/)

## Polygonia (Polygonia\_64px)

* Zdroj: [https://github.com/Lokrates/Polygonia\_64px](https://github.com/Lokrates/Polygonia\_64px), revize f28901e5e990aee6f78fca80dce03129b90d4d6a
* Původní licence: CC BY-SA 4.0

## Scythes & Sickles (sickles)

* Zdroj: [https://github.com/t-affeldt/sickles](https://github.com/t-affeldt/sickles), revize 64f88263e223c0eb22a0721cda0e9680c65f5267
* Původní licence: kód LGPLv3, textury CC BY-SA 3.0 a CC BY-SA 4.0
* [ContentDB](https://content.minetest.net/packages/TestificateMods/sickles/)

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

# Zcela nové módy

## ch\_core

* Licence: kód LGPLv2.1, média: různé svobodné (viz license.txt)

## ch\_overrides

* Licence: kód LGPLv2.1

## Koruna československá (kcs)

* Kód: vlastní práce; textury: vlastní práce založená na fotografiích (CC-BY-SA-4.0)
* Licence: kód MIT, textury CC-BY-SA-4.0
