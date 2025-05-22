# Zdrojové kódy Českého hvozdu

Toto je kompletní repozitář módů a úprav pro server „Český hvozd“.
Všechny módy jsou lokalizovány do češtiny a přizpůsobeny provozu
na serveru Luanti 5.10.0; některé úpravy jsou ale specifické či
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
* **ostatní\_zdroje\_sha256** – Totéž, co ostatní\_zdroje, ale namísto souborů jsou uvedeny soupisy jejich SHA256 heší. Důvodem je, že tyto zdroje jsou obzvlášť objemné a byla z nich použita jen malá část.

Některé licence vyžadují uvést, zda bylo dílo upraveno.
To poznáte srovnáním obsahu módu v adresáři *mods* (resp. *minetest\_game*)
s neupravenou podobou v adresáři *mods\_původní*, *minetest\_game\_původní*,
resp. *ostatní\_zdroje*.

Ke zprovoznění serveru je kromě adresářů „mods“ a „minetest\_game“ z tohoto repozitáře potřeba také:

* herní svět
* minetest.conf
* Luanti Server 5.10.0 (verze se může v budoucnu změnit)

# Hra

## Minetest Game

* Zdroj: [https://github.com/minetest/minetest\_game](https://github.com/minetest/minetest\_game), revize 08057e8e0f01b443515ff81423215e4367f84872 (mód default z revize 9875ef62403b3f0113633fc5c88186c983030b34)
* Původní licence: LGPLv2.1 pro kód, různé pro média
* Licence úprav: LGPLv2.1 (není-li uvedeno jinak)
* [ContentDB](https://content.minetest.net/packages/Minetest/minetest\_game/)

# Balíky modů (modpacks)

## Advanced Trains (advtrains)

* Zdroj: [https://git.bananach.space/advtrains.git](https://git.bananach.space/advtrains.git), revize c974e70fde21cb5484e1b19c1f60b82c3ac7f3eb (verze 2.5.0)
* Původní licence: AGPL 3 pro kód, CC-BY-SA-3.0 pro média
* Licence úprav: AGPL 3
* [ContentDB](https://content.minetest.net/packages/orwell/advtrains/)

## Church Modpack (church)

* Zdroj: [https://github.com/mootpoint/church](https://github.com/mootpoint/church), revize 066001b8586f25edb609fb166ef582ac963ae23f
* Původní licence: GPL v3
* Licence úprav: GPL v3
* [ContentDB](https://content.minetest.net/packages/SFENCE/church/)

## Display (display\_modpack)

* Zdroj: [https://github.com/pyrollo/display\_modpack](https://github.com/pyrollo/display\_modpack), revize f5bd6d1046ee81260a99940c201ece5a7630eeaa
* Původní licence: LGPL 3 pro kód, CC-BY-SA-3.0 pro média
* Licence úprav: LGPL 3
* [ContentDB](https://content.minetest.net/packages/Pyrollo/display\_modpack/)

## Home Decor (homedecor)

* Zdroj: [https://content.minetest.net/packages/VanessaE/homedecor\_modpack/](https://content.minetest.net/packages/VanessaE/homedecor\_modpack/), revize 5ffdc26673169e05492141709fbb18e8fb6e5937
* Původní licence: LGPL 3 pro kód, CC-BY-SA-4.0 pro ostatní
* Licence úprav: LGPL 3 pro kód, CC-BY-SA-4.0 pro ostatní
* [ContentDB](https://content.minetest.net/packages/VanessaE/homedecor\_modpack/)

## Home Workshop Modpack (home\_workshop\_modpack)

* Zdroj: [https://github.com/mt-mods/home\_workshop\_modpack](https://github.com/mt-mods/home\_workshop\_modpack), revize 40b911e18426a78ba9c4d07363a31b6cfebaec86
* Původní licence: LGPL 3 pro kód, CC-BY-SA-4.0 pro média (není-li uvedeno jinak)
* Licence úprav: v módu „computers“ kód i média MIT, v ostatních módech balíku LGPL 3 pro kód a CC-BY-SA-4.0 pro média

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

# Doplňky k balíku Advtrains (včetně balíků)

## Advtrains Basic Trains (basic\_trains)

* Zdroj: [http://git.bananach.space/basic\_trains.git/](http://git.bananach.space/basic\_trains.git/), revize 764be1bda4363c7dd1ad60df2e3df0d7f040ae9b
* Původní licence: AGPL v3 (kód), CC-BY-SA-3.0 (média)
* Licence úprav: AGPL v3
* [ContentDB](https://content.minetest.net/packages/orwell/basic\_trains/)

## advtrains\_bboe\_1080

* Zdroj: [https://notabug.org/advtrains\_supplemental/advtrains\_bboe\_1080](https://notabug.org/advtrains\_supplemental/advtrains\_bboe\_1080), revize 9c3b2da02ca27b3db14f2951fc53313ca313ced5
* Původní licence: CC BY-SA 3.0
* Licence úprav: CC BY-SA 3.0
* [ContentDB](https://content.minetest.net/packages/advtrains\_supplemental/advtrains\_bboe\_1080/)

## Advtrains Construction Train (advtrains\_construction\_train)

* Zdroj: [https://git.bananach.space/advtrains\_construction\_train.git/](https://git.bananach.space/advtrains\_construction\_train.git/), revize 2b27b8d8f1a629ff10f295cb8432225a3a9a943b
* Původní licence: AGPLv3
* Licence úprav: AGPLv3

## Advtrains Livery Tools (advtrains\_livery\_tools)

* Zdroj: [https://github.com/Marnack/advtrains\_livery\_tools](https://github.com/Marnack/advtrains\_livery\_tools), revize c3dfc0787dd556337b579284168a51db8a8971f6
* Původní licence: AGPLv3 pro kód, CC BY-SA 3.0 Unported pro obrázky, textury a zvuky
* Licence úprav: AGPLv3 pro kód, CC BY-SA 3.0 Unported pro obrázky, textury a zvuky
* [ContentDB](https://content.luanti.org/packages/Marnack/advtrains\_livery\_tools/)

## advtrains\_train\_zugspitzbahn

* Zdroj: [https://notabug.org/advtrains_supplemental/advtrains\_train\_zugspitzbahn](https://notabug.org/advtrains_supplemental/advtrains\_train\_zugspitzbahn), revize 8ba8b04709deb7d433f7357d65400aed75bd252a
* Původní licence: CC BY-SA 3.0
* Licence úprav: CC BY-SA 3.0
* [ContentDB](https://content.minetest.net/packages/advtrains\_supplemental/advtrains\_train\_zugspitzbahn/)

## advtrains\_transib

* Zdroj: [https://notabug.org/advtrains\_supplemental/advtrains\_transib](https://notabug.org/advtrains\_supplemental/advtrains\_transib), revize 7cbcb5bb995591f8e4016c350db36e9905c23b31
* Původní licence: CC BY-SA 3.0
* Licence úprav: CC BY-SA 3.0
* [ContentDB](https://content.minetest.net/packages/advtrains\_supplemental/advtrains\_transib/)

## Classic Coaches (classic\_coaches)

* Zdroj: [https://github.com/Marnack/classic\_coaches](https://github.com/Marnack/classic\_coaches), revize b2833751b2172e5a0e67249f87fbdeaaa41fc5f9
* Původní licence: AGPLv3 pro kód, CC BY-SA 3.0 Unported pro média
* Licence úprav: AGPLv3 pro kód i média, CC BY-SA 3.0 pro média
* [ContentDB](https://content.luanti.org/packages/Marnack/classic\_coaches/)

## Classic Coaches Generic Livery Pack (classic\_coaches\_generic\_livery\_pack)

* Zdroj: [https://github.com/Marnack/classic\_coaches\_generic\_livery\_pack](https://github.com/Marnack/classic\_coaches\_generic\_livery\_pack), revize 5814d84f6c640b77b633629b6a86867aedf206ba
* Původní licence: AGPLv3 pro kód, CC BY-SA 3.0 Unported pro média
* Licence úprav: AGPLv3 pro kód i média, CC BY-SA 3.0 pro média
* [ContentDB](https://content.luanti.org/packages/Marnack/classic\_coaches\_generic\_livery\_pack/)

## DLX Trains (dlxtrains\_modpack)

* Zdroj: [https://github.com/Marnack/dlxtrains\_modpack](https://github.com/Marnack/dlxtrains\_modpack), revize 1561c547827248d7085856a03706c3a66a20a0bd
* Původní licence: AGPLv3 pro kód, média CC BY-SA 3.0 Unported
* Licence úprav: AGPLv3, média také CC BY-SA 3.0 Unported
* [ContentDB](https://content.luanti.org/packages/Marnack/dlxtrains/)

## Doxy's Mini Tram (doxy\_mini\_tram)

* Zdroj: [https://invent.kde.org/davidhurka/doxy\_mini\_tram](https://invent.kde.org/davidhurka/doxy\_mini\_tram), revize 3cfebc01254b5f93d59ec707cb5dda17c6b7be1d
* Původní licence: převážně MIT, jednotlivé soubory pod různými jinými, ale vše svobodné
* Licence úprav: uvedeny u jednotlivých souborů stejným způsobem jako v původním módu
* [ContentDB](https://content.minetest.net/packages/doxygen\_spammer/doxy\_mini\_tram/)

## JR E231series (JR\_E231series\_modpack)

* Zdroj: [https://github.com/h-v-smacker/JR\_E231series\_modpack](https://github.com/h-v-smacker/JR\_E231series\_modpack), revize 8d6401907722ec64029cb6928ccbe559209796a3
* Původní licence: LGPLv2.1 pro kód, CC BY-SA 3.0 pro média
* Licence úprav: LGPLv2.1 pro kód, CC BY-SA 3.0 pro média

## Linetrack

* Zdroj: [https://github.com/C-C-Minetest-Server/linetrack](https://github.com/C-C-Minetest-Server/linetrack), revize 2ee1f34fc46b0ed4b49d5510d4eb51e38e6dc498
* Původní licence: kód LGPLv2.1, zvuky CC BY 3.0 (jeden public domain), modely a textury pravděpodobně LGPLv2.1
* Licence úprav: kód LGPLv2.1, zvuky CC BY 3.0, ostatní LGPLv2.1
* [ContentDB](https://content.luanti.org/packages/Emojiminetest/linetrack/)

## Tieless Tracks (minetest\_tieless\_tracks)

* Zdroj: [https://github.com/SamMatzko/minetest\_tieless\_tracks](https://github.com/SamMatzko/minetest\_tieless\_tracks), revize 0424a3408af080a6f74246fd684227470f9a41c3
* Původní licence: AGPLv3 pro veškerý kód, CC BY-SA 3.0 pro média
* Licence úprav: AGPLv3 pro úpravy v kódu, CC BY-SA 3.0 pro úpravy v médiích
* [ContentDB](https://content.minetest.net/packages/sylvester\_kruin/tieless\_tracks/)

## Mese Trains (mese\_trains)

* Zdroj: [https://gitlab.com/xenonca/mese\_trains](https://gitlab.com/xenonca/mese\_trains), revize a4ff9a793e227df93bc6f8b35ab452d3b1507d89
* Původní licence: LGPLv2.1 (only) pro kód, CC BY-SA 3.0 pro modely a textury, CC0 pro zvuky
* Licence úprav: LGPLv2.1 (only) pro kód, CC BY-SA 3.0 pro modely a textury, CC0 pro zvuky
* [ContentDB](https://content.minetest.net/packages/xenonca/mese\_trains/)

## Moretrains (moretrains)

* Zdroj: [https://git.bananach.space/moretrains.git/](https://git.bananach.space/moretrains.git/), revize 59ee0e4f1577b75ab8736c8a8115c774eeaea3c7
* Původní licence: LGPLv2.1 pro kód, CC-BY-SA 3.0 pro média
* Licence úprav: LGPLv2.1 pro kód, CC-BY-SA 3.0 pro média
* [ContentDB](https://content.minetest.net/packages/gpcf/moretrains/)

## railroad_paraphernalia

* Zdroj: [https://github.com/h-v-smacker/railroad\_paraphernalia](https://github.com/h-v-smacker/railroad\_paraphernalia), revize 520fcb1366259c277ae6d966c0a6d5148bb89c98
* Původní licence: AGPLv3
* Licence úprav: AGPLv3

## Some More Trains (some\_more\_trains)

* Zdroj: [https://github.com/APercy/some\_more\_trains](https://github.com/APercy/some\_more\_trains), revize 326f7e73a73e05e26a4cc25c8cc5acc777429443
* Původní licence: AGPLv3
* Licence úprav: AGPLv3

# Doplňky k balíku Mesecons

## Mesecon Register Circuits (mesecons\_regs)

* Zdroj: [https://gitlab.com/deetmit/mesecons\_regs](https://gitlab.com/deetmit/mesecons\_regs), revize fc772a32999fd2c70b2f09e28d43580e9a0b6ca2
* Původní licence: kód LGPLv3, vše ostatní CC BY-SA 3.0
* Licence úprav: kód LGPLv3, vše ostatní CC BY-SA 3.0
* [ContentDB](https://content.minetest.net/packages/marek/mesecons\_regs/)

## Wireless Mesecons (mesecons\_wireless)

* Zdroj: [https://github.com/GreenXenith/mesecons\_wireless](https://github.com/GreenXenith/mesecons\_wireless), revize 8ca249c10bcef8f2a9304fe6ef0e68a7d2910bd8
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/GreenXenith/mesecons\_wireless/)

# Samostatné módy

## 3D Armor Fly & Swim (3d\_armor\_flyswim)

* Zdroj: [https://github.com/sirrobzeroone/3d\_armor\_flyswim](https://github.com/sirrobzeroone/3d\_armor\_flyswim), revize 586d4501c0e5f700c3055c6bf0820856fe37036c
* Původní licence: kód LGPLv2.1 (malá část MIT), modely CC BY-SA 3.0, textury různé
* Licence úprav: LGPLv2.1
* [ContentDB](https://content.minetest.net/packages/sirrobzeroone/3d\_armor\_flyswim/)

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

## Art Deco (artdeco)

* Zdroj: [https://github.com/mt-historical/artdeco](https://github.com/mt-historical/artdeco), revize 530485093cdbd721cf173387958e2691b97696f3
* Původní licence: Unlicense
* Licence úprav: Unlicense
* [ContentDB](https://content.minetest.net/packages/TumeniNodes/artdeco/)

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

## Birds (birds)

* Zdroj: [https://gitgud.io/blut/birds](https://gitgud.io/blut/birds), revize dd90b4a0d03cf3f09b986e8993767141bfb719f5
* Původní licence: kód a model CC0, textury CC-BY 4.0
* Licence úprav: CC0
* [ContentDB](https://content.luanti.org/packages/shaft/birds/)

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

* Zdroj: [https://gitlab.com/h2mm/wooden\_bucket](https://gitlab.com/h2mm/wooden\_bucket), revize 50b0d4e6332286a76fe88f642d8e6dc79fbed99a
* Původní licence: LGPL-2.1 pro kód, CC-BY-SA-3.0 pro textury
* Licence úprav: LGPL-2.1
* [ContentDB](https://content.minetest.net/packages/Hume2/bucket\_wooden/)

## Builtin Overrides (minetest-builtin\_overrides)

* Zdroj: [https://github.com/fluxionary/minetest-builtin\_overrides](https://github.com/fluxionary/minetest-builtin\_overrides), revize aa99c681e6adb964bb5ff7dbb2767f11b8e8e4b7
* Původní licence: AGPLv3
* Licence úprav: AGPLv3
* [ContentDB](https://content.minetest.net/packages/rheo/builtin\_overrides/)

## Global Bulletin Boards (bulletin\_boards)

* Zdroj: [https://github.com/minetest-mods/bulletin\_boards](https://github.com/minetest-mods/bulletin\_boards), revize 02951241def2ed8d162bfa1f4b0fd8e6192dd640
* Původní licence: MIT pro kód, různé pro média
* Licence úprav: MIT pro kód, různé pro média
* [ContentDB](https://content.minetest.net/packages/FaceDeer/bulletin\_boards/)

## Charcoal (charcoal)

* Zdroj: [https://content.minetest.net/packages/X17/charcoal/](https://content.minetest.net/packages/X17/charcoal/), verze 0.2
* Původní licence: GPLv3
* Licence úprav: GPLv3

## Cheese (cheese)

* Zdroj: [https://github.com/AnnalysaTheMinetester/cheese](https://github.com/AnnalysaTheMinetester/cheese), revize 2f79610a641a9188a666c89c76cca016ea92ed43
* Původní licence: kód LGPLv2.1, textury CC BY-SA-3.0, zvuky CC0.
* Licence úprav: LGPLv2.1
* [ContentDB](https://content.minetest.net/packages/Annalysa/cheese/)

## Chess Mod (chess\_mod)

* Zdroj: [https://github.com/bas080/chess-mod](https://github.com/bas080/chess-mod), revize 9d9e032f1be3c4e24a42751ccd8a8bf4f2d6c8d3 (textury z revize 9fc9ac2ded011b6ec834f015ea389a85cda3fc81, viz ostatní-zdroje/chess-mod-textures)
* Původní licence: WTFPL
* Licence úprav: LGPLv2.1

## Christmas Decor (christmas\_decor)

* Zdroj: [https://github.com/GreenXenith/christmas\_decor](https://github.com/GreenXenith/christmas\_decor), revize b5aa1f0ad4d8ce4944ece8f6ec47b4442d312a46
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/GreenXenith/christmas\_decor/)

## Christmas Tree (christmastree)

* Zdroj: [https://forum.minetest.net/viewtopic.php?t=10701](https://forum.minetest.net/viewtopic.php?t=10701), verze 1.0.2
* Původní licence: WTFPL
* Licence úprav: WTFPL
* [ContentDB](https://content.minetest.net/packages/ExeterDad/christmastree/)

## Clothing 2 (clothing)

* Zdroj: [https://github.com/sfence/clothing](https://github.com/sfence/clothing), revize 3e27fdbf737f02eb20f66d0a9a009e415e50e584
* Původní licence: LGPLv2.1 pro kód, převážně CC-BY-SA-3.0 pro média (také CC-BY-SA-4.0 a CC0)
* Licence úprav: LGPLv2.1 pro kód, CC-BY-SA-3.0 pro média
* [ContentDB](https://content.minetest.net/packages/SFENCE/clothing/)

## Comboblock (comboblock)

* Zdroj: [https://github.com/sirrobzeroone/comboblock](https://github.com/sirrobzeroone/comboblock), revize e93007648159ebbe8178fa85f28bde1ce4326126
* Původní licence: Unlicense
* Licence úprav: Unlicense
* [ContentDB](https://content.minetest.net/packages/sirrobzeroone/comboblock/)

## Compactor (compactor)

* Zdroj: [https://gitlab.com/alerikaisattera/compactor](https://gitlab.com/alerikaisattera/compactor), revize d1482d303108f64409bab62832945279a1790b7b
* Původní licence: GPLv3 pro kód, CC-BY-SA-3.0 pro textury
* Licence úprav: GPLv3 pro kód, CC-BY-SA-3.0 pro média
* [ContentDB](https://content.minetest.net/packages/alerikaisattera/compactor/)

## Confetti (confetti)

* Zdroj: [https://github.com/Krunegan/confetti](https://github.com/Krunegan/confetti), revize 77f4c684cbbb353b3978251448b87fa3b9752ae5
* Původní licence: MIT pro kód, CC-BY-4.0 pro textury
* Licence úprav: MIT pro kód, CC-BY-4.0 pro textury
* [ContentDB](https://content.minetest.net/packages/Krunegan/confetti/)

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

## Cucina Vegana (cucina\_vegana)

* Zdroj: [https://github.com/acmgit/cucina\_vegana](https://github.com/acmgit/cucina\_vegana), revize a456da616bbd17ccf3736b8f8cf771c32affe093
* Původní licence: LGPLv3
* Licence úprav: LGPLv3
* [ContentDB](https://content.minetest.net/packages/Clyde/cucina\_vegana/)

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

## Dense Ores (denseores)

* Zdroj: [https://notabug.org/Oswald/denseores.git](https://notabug.org/Oswald/denseores.git), revize 7a9a7134e53cac55c40c1e1d749c69be8b4c006d
* Původní licence: GPLv3+
* Licence úprav: GPLv3+
* [ContentDB](https://content.minetest.net/packages/benedict424/denseores/)

## Digiterms (digiterms)

* Zdroj: [https://github.com/pyrollo/digiterms](https://github.com/pyrollo/digiterms), revize 04d32581d37cb5ff060f93228059e57cfc96b653
* Původní licence: LGPLv3+ pro kód, CC BY-SA 3.0 pro textury
* Licence úprav: LGPLv3+ pro kód, CC BY-SA 3.0 pro textury
* [ContentDB](https://content.minetest.net/packages/Pyrollo/digiterms/)

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

## Emoji (emoji)

* Zdroj: [https://github.com/bosapara/emoji](https://github.com/bosapara/emoji), revize 5aee8ace758cd368a0f56011258b370c8dacf7da
* Původní licence: LGPLv3+
* Licence úprav: LGPLv3+
* [ContentDB](https://content.minetest.net/packages/bosapara/emoji/)

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

* Zdroj: [https://notabug.org/tenplus1/farming](https://notabug.org/tenplus1/farming), revize 0b06c7cd450c5ec9a76b3c22a9c57f06e4f8a7c2; některé soubory z revize 3992a40123e1fd0803c96dd235bdf477b619aa5d (viz ostatní_zdroje/farming\_202210)
* Původní licence: MIT a další (včetně CC-BY-ND-SA)
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/farming/)
* Implantovány jahody z módu Ethereal NG (licence: MIT) a další plodiny z módu Cucina Vegana (licence textur: LGPLv3).

## Fireworks Reimagined (fireworks\_reimagined)

* Zdroj: [https://github.com/DragonWrangler1/fireworks\_reimagined](https://github.com/DragonWrangler1/fireworks\_reimagined), revize 9ff34239215f4459b63329805534c0fe48c5b406
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.luanti.org/packages/DragonWrangler/fireworks\_reimagined/)

## Fumo Plushies (fumoplushies)

* Zdroj: [https://git.minetest.land/aSliceOfCake/Plushfumos](https://git.minetest.land/aSliceOfCake/Plushfumos), revize daf783e473637868e48fa416f9e2b76902d2da38
* Původní licence: GNU Affero GPLv3
* Licence úprav: GNU Affero GPLv3
* [ContentDB](https://content.minetest.net/packages/aSliceOfCake/fumoplushies/)

## Funny Shadows (shadows)

* Zdroj: [https://github.com/x2048/shadows](https://github.com/x2048/shadows), revize d001680bb8af00ba0c78ee74c6dcc3b31d02cd25
* Původní licence: GNU Affero GPLv3
* Licence úprav: GNU Affero GPLv3
* [ContentDB](https://content.minetest.net/packages/x2048/shadows/)

## futil (minetest-futil)

* Zdroj: [https://github.com/fluxionary/minetest-futil](https://github.com/fluxionary/minetest-futil), revize fed3091f0884e8c84472f5a26cb3998db69c6cce
* Původní licence: GNU Affero GPLv3
* Licence úprav: GNU Affero GPLv3
* [ContentDB](https://content.minetest.net/packages/rheo/futil/)

## Generic Inoffensive Flags (generic\_flags)

* Zdroj: [https://content.minetest.net/packages/AwesomeDragon97/generic\_flags/](https://content.minetest.net/packages/AwesomeDragon97/generic\_flags/), verze Generic Inoffensive Flags 1.2
* Původní licence: LGPLv3 pro kód, CC BY-SA 3.0 pro média
* Licence úprav: LGPLv3 pro kód, CC BY-SA 3.0 pro média
* [ContentDB](https://content.minetest.net/packages/AwesomeDragon97/generic\_flags/)

## GGraffiti (ggraffiti)

* Zdroj: [https://github.com/grorp/ggraffiti](https://github.com/grorp/ggraffiti), revize 6821a2fcb181b840ca2b180aac86ebe070923aea
* Původní licence: GNU Affero GPLv3
* Licence úprav: GNU Affero GPLv3
* [ContentDB](https://content.minetest.net/packages/grorp/ggraffiti/)

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

## Hand Dryer (handdryer)

* Zdroj: [https://cheapiesystems.com/git/handdryer/](https://cheapiesystems.com/git/handdryer/), revize 21868b05ee0677736bc9d9611994905d95faf2af
* Původní licence: public domain prohlášením autora v USA
* Licence úprav: CC0
* [ContentDB](https://content.minetest.net/packages/cheapie/handdryer/)

## Hang-Gliders (hangglider)

* Zdroj: [https://github.com/mt-mods/hangglider](https://github.com/mt-mods/hangglider), revize 2c708abd8816b08679b61068446259101f66abbc
* Původní licence: GPLv3 pro kód (část LGPLv2.1+), CC-BY-SA-3.0 nebo CC-BY-SA-4.0 pro ostatní
* Licence úprav: GPLv3 pro kód, CC-BY-SA-4.0 pro ostatní
* [ContentDB](https://content.minetest.net/packages/mt-mods/hangglider/)

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

## Item Physics (item\_physics)

* Zdroj: [https://codeberg.org/SumianVoice/item\_physics](https://codeberg.org/SumianVoice/item\_physics), revize e44d1d4dde22dd071d4d97038418cc303063151d
* Původní licence: 0BSD
* Licence úprav: 0BSD
* [ContentDB](https://content.minetest.net/packages/Sumianvoice/item\_physics/)

## Itemshelf (itemshelf)

* Zdroj: [https://github.com/hkzorman/itemshelf](https://github.com/hkzorman/itemshelf), revize 8d4e24717cc1392cd370bc700dae56dae29afb42
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/zorman2000/itemshelf/)

## JIT Profiler (jitprofiler)

* Zdroj: [https://forum.minetest.net/viewtopic.php?t=28135](https://forum.minetest.net/viewtopic.php?t=28135), jitprofiler.zip (SHA-256: 405ae916661cad32fff911a8e54e3c1d59b889b4ff909b0f9d11b7ab95ee35d5)
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/jwmhjwmh/jitprofiler/)

## Jumping (jumping)

* Zdroj: [https://github.com/minetest-mods/jumping](https://github.com/minetest-mods/jumping), revize b5205e4e7d651306d31e2ea100ad75abb1856401
* Původní licence: GPLv3
* Licence úprav: GPLv3

## Leads (leads)

* Zdroj: [https://content.minetest.net/packages/SilverSandstone/leads/](https://content.minetest.net/packages/SilverSandstone/leads/), verze 0.1.0
* Původní licence: kód MIT, ostatní různé (CC BY-SA, CC BY, CC0)
* Licence úprav: kód MIT; ostatní: stejná jako u původního souboru, nové soubory CC0
* [ContentDB](https://content.minetest.net/packages/SilverSandstone/leads/)

## Letters (letters)

* Zdroj: [https://github.com/minetest-mods/letters](https://github.com/minetest-mods/letters), revize d44b88fa908682d5f68a27b491f6d0e57e66fa4c
* Původní licence: zlib license (kompatibilní s GPL) pro kód a CC BY-SA neznámé verze pro textury (ale snad lze předpokládat CC BY-SA 4.0).
* Licence úprav: zlib license pro kód a CC BY-SA pro textury
* [ContentDB](https://content.minetest.net/packages/Amaz/letters/)

## Mail Mod (mail)

* Zdroj: [https://github.com/mt-mods/mail](https://github.com/mt-mods/mail), revize 721d882c26b2d026289c4f9c30f46b8c83511c41
* Původní licence: MIT (s výjimkou jednoho souboru, který je WTFPL)
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/mt-mods/mail/)

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

## Metrosigns (metrosigns)

* Zdroj: [https://github.com/axcore/metrosigns](https://github.com/axcore/metrosigns), revize 0402258e41852c25e54bde09a02889731bd7af36
* Původní licence: AGPL pro vše kromě sign writeru a ink cartridges; CC BY-SA 3.0 Unported pro sign writer a ink cartridges.
* Licence úprav: AGPL pro vše; pro úpravy v sign writeru a ink cartridges navíc CC BY-SA 3.0 Unported.

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

## Mobs Redo (mobs\_redo)

* Zdroj: [https://notabug.org/TenPlus1/mobs\_redo](https://notabug.org/TenPlus1/mobs\_redo), revize 527fe8c2d5136f49aedb5d4cbc94f760fcea74e5
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/mobs/)

## Mobs Water (mobs\_water)

* Zdroj: [https://notabug.org/TenPlus1/mobs\_water](https://notabug.org/TenPlus1/mobs\_water), revize 6aa05dff220a2b37c0b701ae6cef9fbc51c359da
* Původní licence: kód MIT, textury různé (GPLv3, CC-BY-SA-3.0, WTFPL)
* Licence úprav: MIT
* Odstraněni žraloci (protože se mi nelíbí) a želvy (ty se mi líbí, ale model a textura mají neznámou licenci)

## Modding Library (modlib)

* Zdroj: [https://github.com/appgurueu/modlib](https://github.com/appgurueu/modlib), revize 5f0dea2780b88d44d85b9704e0e81348c459404d
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/LMD/modlib/)

## More Blocks (moreblocks)

* Zdroj: [https://github.com/minetest-mods/moreblocks](https://github.com/minetest-mods/moreblocks), revize dce587cf3397dca7e242455cd017cba50ee28a5b
* Původní licence: zlib license (kompatibilní s GPL)
* Licence úprav: zlib license
* [ContentDB](https://content.minetest.net/packages/Calinou/moreblocks/)

## More Boats (more\_boats)

* Zdroj: [https://content.minetest.net/packages/SkyBuilder1717/more\_boats/](https://content.minetest.net/packages/SkyBuilder1717/more\_boats/), verze z 2023-10-23
* Původní licence: MIT pro kód, CC BY-SA 3.0 pro ostatní
* Licence úprav: MIT pro kód, CC BY-SA 3.0 pro ostatní
* [ContentDB](https://content.minetest.net/packages/SkyBuilder1717/more\_boats/)

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

## Paintings (paintings)

* Zdroj: [https://forum.minetest.net/viewtopic.php?p=218265&sid=fe7e889d98bce875ef40a65d735ecced#p218265](https://forum.minetest.net/viewtopic.php?p=218265&sid=fe7e889d98bce875ef40a65d735ecced#p218265), příloha „paintings.zip“
* Původní licence: CC0
* Licence úprav: CC0

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

## Punch and Place Particles (p\_particles)

* Zdroj: [https://github.com/epCode/p\_particles](https://github.com/epCode/p\_particles), revize 651bc97b0c90fd2097e92e2cce974e3f2677c78a
* Původní licence: LGPLv3 pro kód, bez licence pro ostatní
* Licence úprav: LGPLv3 pro kód
* [ContentDB](https://content.minetest.net/packages/epCode/punch\_and\_place\_particles/)

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

## Rotate: Wrench - node rotation tool (minetest-mod-rotate)

* Zdroj: [https://github.com/Rogier-5/minetest-mod-rotate](https://github.com/Rogier-5/minetest-mod-rotate), revize 65125539e1d79464d168f9cd0b3ebf77463379a4
* Původní licence: LGPLv2.1 pro kód, CC BY-SA-3.0 pro obrázky
* Licence úprav: LGPLv2.1 pro kód, CC BY-SA-3.0 pro obrázky
* [ContentDB](https://content.minetest.net/packages/Argos/rotate/)

## Round Tree Trunks (round\_trunks)

* Zdroj: [https://codeberg.org/Hamlet/round\_trunks](https://codeberg.org/Hamlet/round\_trunks), revize b8de39e76c8c958f46ce5a6a40ff0c72aa8c0606
* Původní licence: EUPL-1.2+ (kód), CC-BY-SA-4.0 (textury), GPLv3 (model)
* Licence úprav: EUPL-1.2+ (kód)
* [ContentDB](https://content.minetest.net/packages/Hamlet/round\_trunks/)

## Sandwiches (sandwiches)

* Zdroj: [https://notabug.org/Annalysa/sandwiches.git](https://notabug.org/Annalysa/sandwiches.git), revize 399d79ef1052f9caec75bdf4abe3f33b2472322c
* Původní licence: LGPLv2.1+ (kód), CC BY-SA 3.0 (textury)
* Licence úprav: LGPLv2.1+ (kód), CC BY-SA 3.0 (textury)
* [ContentDB](https://content.minetest.net/packages/Annalysa/sandwiches/)

## Sausages (sausages)

* Zdroj: [https://github.com/C-C-Minetest-Server/sausages](https://github.com/C-C-Minetest-Server/sausages), revize c7157db243bddf8ec180e0190179c2153cc86de1
* Původní licence: MIT (kód), CC BY-SA-4.0 (textury)
* Licence úprav: MIT (kód), CC BY-SA-4.0 (textury)
* [ContentDB](https://content.minetest.net/packages/Emojiminetest/sausages/)

## Superimposed Window Frames (si\_frames)

* Zdroj: [https://github.com/C-C-Minetest-Server/si\_frames](https://github.com/C-C-Minetest-Server/si\_frames), revize d0730f4c43d9a6a96d34ea4ba1612fc239f2e637
* Původní licence: AGPLv3
* Licence úprav: AGPLv3
* [ContentDB](https://content.luanti.org/packages/Emojiminetest/si\_frames/)

## Signs Lib (signs\_lib)

* Zdroj: [https://github.com/mt-mods/signs\_lib](https://github.com/mt-mods/signs\_lib), revize 60d67afab3d78ece7e9b4a61b50c60903e8c72a9
* Původní licence: LGPL 3 pro kód, CC-BY-SA-4.0 pro média
* Licence úprav: LGPL 3 pro kód, CC-BY-SA 4.0 pro ostatní
* [ContentDB](https://content.minetest.net/packages/VanessaE/signs\_lib/)

## Simple Dialogs (simple\_dialogs)

* Zdroj: [https://github.com/Kilarin/simple\_dialogs](https://github.com/Kilarin/simple\_dialogs), revize 9c4ab1d3c2911378fa57771c381bc40179eb2d8b
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/Kilarin/simple\_dialogs/)

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

## Snow Song (snowsong)

* Zdroj: [https://github.com/tacotexmex/snowsong](https://github.com/tacotexmex/snowsong), revize 62a8bfffb8c562f3d3b613c8a02a38c076ee9f97
* Původní licence: LGPLv2.1 pro kód, CC BY-SA 4.0 pro zvuky
* Licence úprav: LGPLv2.1 pro kód, CC BY-SA 4.0 pro zvuky
* [ContentDB](https://content.minetest.net/packages/texmex/snowsong/)

## Stamina (stamina)

* Zdroj: [https://notabug.org/TenPlus1/stamina](https://notabug.org/TenPlus1/stamina), revize 96570a558e165f23b42389a501ceebaf20e0f3a8
* Původní licence: LGPL 2.1+ pro kód, média různě (CC-BY-3.0 a WTFPL)
* Licence úprav: LGPL 2.1
* [ContentDB](https://content.minetest.net/packages/TenPlus1/stamina/)

## Streets 2.0 (streets)

* Zdroj: [https://github.com/minetest-streets/streets](https://github.com/minetest-streets/streets), revize 7cd17420d37a7d511eb513922b68611325a05e72
* Původní licence: MIT pro kód, CC-BY-SA 3.0 pro média
* Licence úprav: MIT pro kód, CC-BY-SA 3.0 pro média
* [ContentDB](https://content.minetest.net/packages/webdesigner97/streets/)

## Summer (summer\_22\_08\_15)

* Zdroj: [https://github.com/IIIullaIII/summer\_22\_08\_15](https://github.com/IIIullaIII/summer\_22\_08\_15), revize e4d147fbbaa6d5b9d32d8a168c1eb195e33b89d9
* Původní licence (pozor!): CC-BY-SA 3.0 pro kód, MIT pro média
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/ulla/summer/)

## Technic Recipes (technic\_recipes)

* Zdroj: [https://gitlab.com/alerikaisattera/technic\_recipes](https://gitlab.com/alerikaisattera/technic\_recipes), revize 5e77fa4bfbf8e42140e2dde9f9ade14d1fb49161
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/alerikaisattera/technic\_recipes/)

## TechPack Stairway (techpack\_stairway)

* Zdroj: [https://github.com/joe7575/techpack\_stairway](https://github.com/joe7575/techpack\_stairway), revize 7b3deb474df44344677b59f8050e5cfe81d19db9
* Původní licence: LGPL 2.1+ pro kód, textury, zvuk a dokumentace CC BY-SA 3.0
* Licence úprav: LGPL 2.1+ pro kód, ostatní CC BY-SA 3.0
* [ContentDB](https://content.minetest.net/packages/joe7575/techpack\_stairway/)

## Tomb Stones (tombs)

* Zdroj: [https://github.com/NathanSalapat/tombs](https://github.com/NathanSalapat/tombs), revize 1e88b4a878566c1587a8d52835128c2b9b8d8b41
* Původní licence: GPLv3 pro kód, CC BY-SA 4.0 ostatní (s výjimkou jednoho CC0)
* Licence úprav: GPLv3 pro vše; pro vše kromě kódu alernativně také CC BY-SA 4.0
* [ContentDB](https://content.minetest.net/packages/Nathan.S/tombs/)

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

## Unified Inventory Plus (unified\_inventory\_plus)

* Zdroj: [https://github.com/bousket/unified\_inventory\_plus](https://github.com/bousket/unified\_inventory\_plus), revize 63b14909888ab9a5799553ae674a52a161ee4539
* Původní licence: AGPLv3
* Licence úprav: AGPLv3

## Visible Wielditem (visible\_wielditem)

* Zdroj: [https://github.com/appgurueu/visible\_wielditem](https://github.com/appgurueu/visible\_wielditem), revize d8ce7ba84eef50fc3994fa516a3c03c8ad58da4b
* Původní licence: MIT (kromě snímku obrazovky)
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/LMD/visible\_wielditem/)

## Watering Can (wateringcan)

* Zdroj: [https://github.com/sfence/wateringcan](https://github.com/sfence/wateringcan), revize a360698809d992decd1117262fd15c8900faa873
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/SFENCE/wateringcan/)

## What is This Uwu (what\_is\_this\_uwu-minetest)

* Zdroj: [https://github.com/Rotfuchs-von-Vulpes/what\_is\_this\_uwu-minetest/](https://github.com/Rotfuchs-von-Vulpes/what\_is\_this\_uwu-minetest/), revize 2ba5e0ed69ada71304d3025d1e54eefba5f44d3d
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.minetest.net/packages/Rotfuchs-von-Vulpes/what_is_this_uwu/)

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

* Zdroj: [https://notabug.org/tenplus1/wine](https://notabug.org/tenplus1/wine), revize 83e1557a342180deddd966f1b70dbe3eda05df0e
* Původní licence: MIT (kód), textury převážně CC-BY-3.0
* Licence úprav: MIT (kód)
* [ContentDB](https://content.minetest.net/packages/TenPlus1/wine/)
* Poznámka: mód obsahuje a používá model sudu z módu Cottages od Sokomine; autorství a licence modelu nejsou spolehlivě známy, protože mód Cottages je nezmiňuje; vycházím však z předpokladu, že model byl považován za součást kódu, a tedy podléhá licenci GPLv3 a autorem/kou je Sokomine.

## Woodcutting (woodcutting)

* Zdroj: [https://github.com/minetest-mods/woodcutting](https://github.com/minetest-mods/woodcutting), revize b265a9707a1ea60e0ecc79ab6da808a300ca2dff
* Původní licence: LGPLv3
* Licence úprav: LGPLv3
* [ContentDB](https://content.minetest.net/packages/bell07/woodcutting/)

## Wrench (wrench)

* Zdroj: [https://github.com/mt-mods/wrench](https://github.com/mt-mods/wrench), revize cc93ad0b541c3fb98c84016d9167424ff7e0aae1
* Původní licence: LGPLv2.1 pro kód, CC BY-SA 4.0 pro média
* Licence úprav: LGPLv2.1 pro kód, CC BY-SA 4.0 pro média
* [ContentDB](https://content.minetest.net/packages/mt-mods/wrench/)

## XBan 2 (xban2)

* Zdroj: [https://github.com/minetest-mods/xban2](https://github.com/minetest-mods/xban2), revize d2cda4f73a3a5372b70ffa63e2a16bf39d734e40
* Původní licence: BSD-2-Clause (podle bower.json)
* Licence úprav: BSD-2-Clause
* [ContentDB](https://content.minetest.net/packages/kaeza/xban2/)

## XCompat (xcompat)

* Zdroj: [https://github.com/mt-mods/xcompat](https://github.com/mt-mods/xcompat), revize X
* Původní licence: MIT
* Licence úprav: MIT
* [ContentDB](https://content.luanti.org/packages/mt-mods/xcompat/)

## YL Canned Food (yl\_canned\_food)

* Zdroj: [https://gitea.your-land.de/your-land/yl\_canned\_food.git](https://gitea.your-land.de/your-land/yl\_canned\_food.git), revize 944c1b5d13dceb88b2aa8bbb9e040ed7ebc05d10
* Původní licence: MIT pro kód, CC0 pro média
* Licence úprav: MIT pro kód, CC0 pro média

## YL Canned Food MTG (yl\_canned\_food\_mtg)

* Zdroj: [https://gitea.your-land.de/your-land/yl\_canned\_food\_mtg.git](https://gitea.your-land.de/your-land/yl\_canned\_food\_mtg.git), revize 5fbda3589ff9d49d13c38bcf11eb58ce69ae1a14
* Původní licence: MIT pro kód, CC0 pro média
* Licence úprav: MIT pro kód, CC0 pro média

# Ostatní použité zdroje

## Advtrains More Slopes (advtrains\_moreslopes)

* Zdroj: [https://codeberg.org/Nazalassa/advtrains\_moreslopes.git](https://codeberg.org/Nazalassa/advtrains\_moreslopes.git), revize dff2c7466910c9a560dd12b6e86cf8b55301e3b4
* Původní licence: GPLv2 (kód), CC-BY-SA-4.0 International (média)
* [ContentDB](https://content.luanti.org/packages/Nazalassa/advtrains_moreslopes/)
* Author: Nazalassa
* Note: Nazalassa wishes not to upload this work to Github. Please read my stance in mods/advtrains_moreslopes_extract/README.md file.

## Always Greener (Always-Greener)

* Zdroj: [https://github.com/Sneglium/Always-Greener/](https://github.com/Sneglium/Always-Greener/), revize 8d3fee4deda4341784d92cb78d75a4964531d87b
* Původní licence: Apache-2.0 (kód), CC-BY-SA-4.0 International (média a ostatní)
* [ContentDB](https://content.minetest.net/packages/Hagatha/always_greener/)

## Area Containers

* Zdroj: [https://github.com/TurkeyMcMac/area\_containers](https://github.com/TurkeyMcMac/area\_containers), revize 13e0337da7a31da565b9beb4cec1af45072c6f0e
* Původní licence: LGPLv3+ (kód), CC-BY-SA-3.0 (vše ostatní)
* [ContentDB](https://content.minetest.net/packages/jwmhjwmh/area\_containers/)

## Your Dad's BBQ Mod (BBQ)

* Zdroj: [https://github.com/Grizzly-Adam/BBQ](https://github.com/Grizzly-Adam/BBQ), revize 1a72f7c2baacc6798033a7973545ab74cc52341e
* Původní licence: LGPLv2.1+ (kód), CC-BY-SA-3.0 (textury), CC-BY-3.0 (zvuky)
* [ContentDB](https://content.minetest.net/packages/Grizzly%20Adam/bbq/)

## Bonified (Bonified)

* Zdroj: [https://github.com/Shqug/Bonified](https://github.com/Shqug/Bonified), revize 40601c5e95cfcabb48963a6ff81bb0bf150cfad3
* Původní licence: Apache 2.0 (kód), CC-BY-SA-4.0 (média)
* [ContentDB](https://content.luanti.org/packages/Hagatha/bonified/)

## Books Redux (books\_rx)

* Zdroj: [https://bitbucket.org/sorcerykid/books\_rx](https://bitbucket.org/sorcerykid/books\_rx), revize 66f64f90c992dc06493f253237325700281f4e55
* Původní licence: LGPL-3.0 (kód), CC-BY-SA-3.0 (textury, zvuky a modely)

## Chess from Tunneler's Abyss (chess)

* Zdroj: [https://gitlab.com/tunnelers-abyss/chess](https://gitlab.com/tunnelers-abyss/chess), revize 2f518972f9fee3c2cb0efc16ece5069b99226c44
* Původní licence: CC0 (kód a textury), CC-BY-4.0 (modely)

## Extended Circular Saw (circular\_saw\_ext)

* Zdroj: [https://github.com/Andrey2470T/circular\_saw\_ext](https://github.com/Andrey2470T/circular\_saw\_ext), revize 9b97572501b7e6215dc1bd60e4bd994a0da48b29
* Původní licence: zlib
* [ContentDB](https://content.minetest.net/packages/Andrey01/circular\_saw\_ext/)

## Cutepie (cutepie)

* Zdroj: [https://github.com/DonBatman/cutepie](https://github.com/DonBatman/cutepie), revize 55d77d983d7f47eea9a2d61c94229af8e00ab30f
* Původní licence: DWYWPL

## Defaultpack Remastered (defaultpack-remastered)

* Zdroj: [https://gitlab.com/22-42/defaultpack-remastered](https://gitlab.com/22-42/defaultpack-remastered), revize 68672a3fed0826ff05497de34705b4e631a691c2
* Původní licence: část CC BY-SA 4.0, část CC BY-SA 3.0
* [ContentDB](https://content.luanti.org/packages/tinneh/defaultpack\_remastered/)

## Digistuff (digistuff)

* Zdroj: [https://cheapiesystems.com/git/digistuff](https://cheapiesystems.com/git/digistuff), revize 32641893e75f11903489a38a201bd661c8f99b50
* Původní licence: LGPLv2.1+ (kód), CC-BY-SA-3.0 (textury), CC-BY-3.0 (zvuky)
* [ContentDB](https://content.minetest.net/packages/cheapie/digistuff/)

## Dungeon Soup (DungeonSoup)

* Zdroj: [https://github.com/sirrobzeroone/DungeonSoup](https://github.com/sirrobzeroone/DungeonSoup), revize 5259dab8f6ca9b5818bd8279e6c1e6a186eb62e6
* Původní licence: CC0
* [ContentDB](https://content.minetest.net/packages/sirrobzeroone/dungeonsoup/)

## Dwarf Fortress Caverns (dfcaverns)

* Zdroj: [https://github.com/FaceDeer/dfcaverns](https://github.com/FaceDeer/dfcaverns), revize de08a9d481167c0520eae05dc172f12a8c6d40fe
* Původní licence: kód MIT, ostatní různé
* [ContentDB](https://content.minetest.net/packages/FaceDeer/dfcaverns/)

## Ephesus (ephesus)

* Zdroj: [https://content.minetest.net/packages/Clemstriangular/ephesus/](https://content.minetest.net/packages/Clemstriangular/ephesus/), 2023-06-13
* Původní licence: EUPL 1.2
* [ContentDB](https://content.minetest.net/packages/Clemstriangular/ephesus/)

## Ethereal NG (ethereal)

* Zdroj: [https://notabug.org/tenplus1/ethereal](https://notabug.org/tenplus1/ethereal), revize 769fb8111edd0a895514db3a2df316c0b49b0252
* Původní licence: kód MIT, textury různé, ale neoznačené také MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/ethereal/)

## Facade (facade)

* Zdroj: [https://github.com/TumeniNodes/facade](https://github.com/TumeniNodes/facade), revize c5158b49f958cea0a8cf76ba520b8f6a23f01f3f
* Původní licence: LGPL 2.1+
* [ContentDB](https://content.minetest.net/packages/TumeniNodes/facade/)

## Folks (folks)

* Zdroj: [https://gitlab.com/SonoMichele/folks](https://gitlab.com/SonoMichele/folks), revize 4975480eec558307ab94a979b3cc1e5f4b6d0e23
* Původní licence: GPLv3
* [ContentDB](https://content.minetest.net/packages/SonoMichele/folks/)

## Graceful 32x (graceful)

* Zdroj: [https://forum.minetest.net/viewtopic.php?f=4&p=415834](https://forum.minetest.net/viewtopic.php?f=4&p=415834)
* Autor/ka: rudzik8
* Původní licence: CC BY-SA 3.0 pro textury podle Minetest Game (podle prohlášení jsou všechny textury založeny na texturách z Minetest Game a jiných jmenovaných módů)

Prohlášení autora/ky na [fóru](https://forum.minetest.net/viewtopic.php?f=4&p=415834):

``Hello.``

``Some time ago (9 months or so?) I've started doing a 32x texturepack, based on default textures of MTG and mods. Yes, just like Faithful did with MC ones. Did it because all of the previous projects on doing this were abandoned and not really usable on daily. And I've named it "Graceful 32x", just to keep that -ful ending in name and don't repeat namings of abandoned minetest-faithful-alike-texturepack attempts.``
``Drew these textures back then using Windows 7, on Paint.NET. Now using Linux Mint 21 Cinnamon and, well, not having any possibility to open these .PDNs (except using Wine, but it only can run 3.x, and I did it on 4.x) and continue work normally.``

``This texturepack is looking for a maintainer, as you can see from the title. Preferably with Paint.NET installed ofc``
``At the moment it contains parts of default untouched textures (not everything done). I'm just too lazy to delete all of these (and also having everything in one folder is quite good: just open untouched one and go with it!) or trying to license them properly, so saying out loud: "ALL OF THESE TEXTURES ARE BASED ON EXISTING ONES AND ARE DERIVATIVE WORK MADE FROM DEFAULT ONES". I guess some of them already outdated, so update these and don't forget to license each one properly. CC-BY-SA still applies to this pack, because that's what SA does, so you'll need to attribute me and original authors as well in fork.``

``Hope one day Graceful 32x will become as great for Minetest, as Faithful 32x became for Minecraft.``

``Thank you, future maintainer. Will answer any questions I can about this pack``
``~ rudzik8``

## hdx-64-master texture pack by VanessaE (hdx-64)

* Zdroj: [https://gitlab.com/VanessaE/hdx-64/tree/master](https://gitlab.com/VanessaE/hdx-64/tree/master), revize f6d2c003006b296ec974be264a4539ce051614c6
* Původní licence: GFDLv1.3 (vybrané soubory pod jinými svobodnými licencemi)

## Mesh Beds (mesh\_beds)

* Zdroj: [https://forum.minetest.net/viewtopic.php?t=11817](https://forum.minetest.net/viewtopic.php?t=11817), soubor mesh\_beds.zip
* Původní licence: WTFPL (u modelů to není řečeno, ale lze předpokládat, že jsou považovány za kód)

## Mobs NPC (mobs\_npc)

* Zdroj: [https://notabug.org/TenPlus1/mobs\_npc](https://notabug.org/TenPlus1/mobs\_npc), revize 5ca55f49ce74d97dbf6c099e87ac22377d0ffd98
* Původní licence: MIT
* [ContentDB](https://content.minetest.net/packages/TenPlus1/mobs\_npc/)

## My Mesh Nodes (mymeshnodes)

* Zdroj: [https://github.com/DonBatman/mymeshnodes](https://github.com/DonBatman/mymeshnodes), revize 284f0e69e401945bfb4eed4bef4bbb2d70e12570
* Původní licence: DWYWPL (u modelů uvedeni autoři/ky, ale vzhledem k použité formulaci mi nepřipadne jisté, že se uvedená licence vztahuje i na tyto modely)

## Not Wuzzy Dice (not\_wuzzy\_dice)

* Zdroj: [https://github.com/TumeniNodes/not\_wuzzy\_dice](https://github.com/TumeniNodes/not\_wuzzy\_dice), revize 6c2f5eb71297634a09e33ec1254017d404649def
* Původní licence: ? pro kód, CC BY-SA 4.0 pro textury

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

## Skybox Textures (skybox)

* Zdroj: [https://github.com/minetest-mods/skybox](https://github.com/minetest-mods/skybox), revize 740e40e0f2e3d1be6d794dacd10ff2b9c6f01801
* Původní licence textur: CC BY-SA 3.0 (SkyboxSet by Heiko Irrgang (http://gamvas.com)) Based on a work at http://93i.de.
* [ContentDB](https://content.minetest.net/packages/sofar/skybox/)

## Stoneblocks (stoneblocks)

* Zdroj: [https://github.com/homiak/stoneblocks](https://github.com/homiak/stoneblocks), revize 464e7c077045e746f97680192a64825962913180
* Původní licence: MIT
* [ContentDB](https://content.minetest.net/packages/homiak/stoneblocks/)

## Technic CNC Improve Machine (technic\_cnc\_improve)

* Zdroj: [https://github.com/Emojigit/technic\_cnc\_improve](https://github.com/Emojigit/technic\_cnc\_improve), revize 769fb8111edd0a895514db3a2df316c0b49b0252
* Původní licence: LGPL 2.1
* [ContentDB](https://content.minetest.net/packages/Emojiminetest/technic\_cnc\_improve/)

## Technic Plus (technic\_plus)

* Zdroj: [https://github.com/mt-mods/technic](https://github.com/mt-mods/technic), revize be5b7cf56eafd45fdf5ef816693581bc59742ea0
* Původní licence (není-li uvedeno jinak v README.md): concrete, extranodes, technic, technic\_worldgen: WTFPL; technic\_cnc, technic\_chests, wrench: LGPLv2+
* [ContentDB](https://content.minetest.net/packages/mt-mods/technic\_plus/)

## Translocator (minetest-mod-translocator)

* Zdroj: [https://content.minetest.net/packages/Zemtzov7/translocator/](https://content.minetest.net/packages/Zemtzov7/translocator/), revize caad5f4f4ea939ce095dae7f14b515cb69d44651
* Původní licence: GPLv3 pro kód, CC-BY-SA-4.0 pro model a textury
* [ContentDB](https://content.minetest.net/packages/Zemtzov7/translocator/)

## Tool Tweaks (tool\_tweaks)

* Zdroj: [https://github.com/wsor4035/tool\_tweaks](https://github.com/wsor4035/tool\_tweaks), revize 72e180102e84879bee9f00e5f0b47fb1691b0723
* Původní licence:CC-BY-SA-3.0
* [ContentDB](https://content.minetest.net/packages/wsor4035/tool\_tweaks/)

## Underground Challenge (underch)

* Zdroj: [https://gitlab.com/h2mm/underch](https://gitlab.com/h2mm/underch), revize 6e93152e85df684d39392075bcdab765979de6c7
* Původní licence: CC0 pro kód, CC-BY-SA-3.0 pro média
* [ContentDB](https://content.luanti.org/packages/Hume2/underch/)

## Vision Lib (vision\_lib)

* Zdroj: [https://content.minetest.net/packages/mt-mods/vision\_lib/](https://content.minetest.net/packages/mt-mods/vision\_lib/), verze 1.8
* Původní licence: CC BY-SA 4.0
* [ContentDB](https://content.minetest.net/packages/mt-mods/vision\_lib/)

## Wardrobe Outfits (wardrobe\_outfits)

* Zdroj: [https://github.com/AntumMT/mod-wardrobe\_outfits](https://github.com/AntumMT/mod-wardrobe\_outfits), revize 7a874cf83d7109ea4cd81f1b15506f7bdb331d71
* Původní licence: kód MIT, textury postav všechny CC-BY-SA-3.0
* [ContentDB](https://content.minetest.net/packages/AntumDeluge/wardrobe\_outfits/)

## Wilhelmines Texture Pack (Wilhelmines-Texture-Pack)

* Zdroj: [https://github.com/Skandarella/Wilhelmines-Texture-Pack](https://github.com/Skandarella/Wilhelmines-Texture-Pack), revize dd89baf4bfb66a4c249cc18f5f75df0065a6130a
* Původní licence: GPL-3
* [ContentDB](https://content.minetest.net/packages/Liil/12345/)

## X-Decor Libre (xdecor-libre)

* Zdroj: [https://codeberg.org/Wuzzy/xdecor-libre](https://codeberg.org/Wuzzy/xdecor-libre), revize 902674e8db4f324e14e68cb9d9a1eba954220d78
* Původní licence: kód BSD, média různé
* [ContentDB](https://content.minetest.net/packages/Wuzzy/xdecor/)

# Ostatní použité zdroje 2

Z následujících zdrojů jsou v repozitáři pouze kontrolní součty souborů (převážně z kapacitních důvodů), ale mám je uschované pro případ potřeby.

## Real Fantasy (realfantasy)

* Zdroj: [https://content.luanti.org/packages/Fhelron/realfantasy/](https://content.luanti.org/packages/Fhelron/realfantasy/), verze 1.1
* Původní licence: CC BY-SA 4.0
* [ContentDB](https://content.luanti.org/packages/Fhelron/realfantasy/)

## SharpNet Photo Realism (sharpnet\_textures)

* Zdroj: [https://github.com/Sharpik/Minetest-SharpNet-Photo-Realism-Texturespack](https://github.com/Sharpik/Minetest-SharpNet-Photo-Realism-Texturespack), revize a9b3d8805d84b44d1d7cb497ef092cf834bfe61e
* Původní licence: část souborů Unlicense, zbytek GPLv3 nebo CC BY-SA nejasné verze.
* [ContentDB](https://content.minetest.net/packages/Sharpik/sharpnet\_textures/)

# Ostatní soubory

/utils/colors.txt -- mapování barev pro MinetestMapper -- licence: CC0 (automaticky generováno)
