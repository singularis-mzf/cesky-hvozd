# skinsdb

This Minetest mod offers changeable player skins with a graphical interface for multiple inventory mods.

This version is modified for Český hvozd server.

## Features

- Flexible skins API to manage the database
- [character_creator](https://github.com/minetest-mods/character_creator) support for custom skins
- Skin change menu for sfinv (in minetest_game) and [unified_inventory](https://forum.minetest.net/viewtopic.php?t=12767)
- Skins change menu and command line using chat command /skinsdb (set | show | list | list private | list public | ui)
- Supported by [smart_inventory](https://forum.minetest.net/viewtopic.php?t=16597) for the skin selection
- Supported by [i3](https://github.com/minetest-mods/i3) inventory mod
- Skin previews supported in selection
- Additional information for each skin
- Support for different skins lists: public and a per-player list are currently implemented
- Full [3d_armor](https://forum.minetest.net/viewtopic.php?t=4654) support
- Compatible to 1.0 and 1.8 Minecraft skins format
- Skinned hand in 1st person view (1.0 skins only)


## Installing skins

### Download from the [database](http://minetest.fensta.bplaced.net/)

#### Ingame Downloader

1) Get Minetest 5.1.0-dev-cb00632 or newer
2) Start your world
3) Run `/skinsdb_download_skins <skindb start page> <amount of pages>`
4) Wait for the Minetest server to shut down
5) Start the server again

You might want to run `minetest` in a Terminal/Console window to check the log output instantly.

#### Python Download script

**Requirements:**

 * Python 3
 * `requests` library: `pip3 install requests`  
 
Go to the updater folder of this mod and run `python3 update_skins.py`  
The Script will download all the skins from the database for you.

### Manual addition

1) Copy your skin textures to `textures` as documented in `textures/readme.txt`
2) Create `meta/character_<name>.txt` with the following fields (separated by new lines):
    * Skin name
    * Author
    * Skin license


## License:
- GPLv3
- skin texture licenses: See "meta" folder (except character\_A\[ABC\]\*.png textures)
- hand model: CC0

Skin texture license:

character\_AA\_\*.png:

Author: Singularis
License: CC BY-SA 3.0
Based on:
- clothing\_character\_male.png by SFENCE (CC BY-SA 3.0) from Clothing mod, that was based on Sachou205 character by Sachour205 (http://minetest.fensta.bplaced.net/#author=Sachou205) and shorts from ts\_skins mod by Thomas S. ([https://github.com/Thomas--S/ts\_skins](https://github.com/Thomas--S/ts\_skins))
- character.png from player\_api mod of Minetest Game (CC BY-SA 3.0) {
Copyright (C) 2011 celeron55, Perttu Ahola &lt;celeron55@gmail.com&gt;
Copyright (C) 2012 MirceaKitsune
Copyright (C) 2012 Jordach
Copyright (C) 2015 kilbith
Copyright (C) 2016 sofar
Copyright (C) 2016 xunto
Copyright (C) 2016 Rogier-5
Copyright (C) 2017 TeTpaAka
Copyright (C) 2017 Desour
Copyright (C) 2018 stujones11
Copyright (C) 2019 An0n3m0us
}

character\_AB\_\*.png and character\_AC\_\*.png:
Author: Singularis
License: CC BY-SA 4.0
Based on:
- clothing\_character\_female.png by SFENCE (CC BY-SA 4.0), that was based on dcbl\_female character by jas (http://minetest.fensta.bplaced.net/#name=dcbl_female) and shorts from ts_skins mod by Thomas S. ([https://github.com/Thomas--S/ts\_skins](https://github.com/Thomas--S/ts\_skins))

### Credits

- RealBadAngel (unified_inventory)
- Zeg9 (skinsdb)
- cornernote (source code)
- Krock (source code)
- bell07 (source code)
- stujones11 (player models)
- jordan4ibanez (1st person view hand)
