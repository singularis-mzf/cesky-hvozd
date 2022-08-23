minetest mod ambience
=====================

Provides ambience sounds and ambience music environment

Information
-----------

This mod is named `ambience` and add music and sound depending of the environment and eye sing of player.

#### Usage 

Two volume commands have been added to set sound and music volume to players

| command   | need privs | arg values | default | description |
| ------------- | ------ | ---------- | ------- | ----------------------------------- |
| `/svol <arg>` | server | 0.1 to 1.0 | 1.0     | Set the volume of the sound effects |
| `/mvol <arg>` | server | 0.1 to 1.0 | 0.6     | Set the volume of the music of the game 0 can be used to stop music from playing when it begins |

#### Music

If you have installed locally will play music from your local mod, but when play server, 
will play music from server using media donwload way.


Technical information
----------------

This is a fork from original https://notabug.org/TenPlus1/ambience if still exits.

The main differences are:

* It provides the music wich is free to use, but honoring its author Dark Raven Music, 
who made it especially for minetest, check https://www.youtube.com/channel/UCrJvUcP_dEqLSbODiWFv3gw
* It provides the documentation that is not present, important so that 
users can know what to do.
* It ensure backwards compatibility for older engines and versions, also reduces 
the media files size

For servers, this mod means your server can have a high traffic of media.
Local there's no such problem due the local link.

### Depends

* default
* fire (optional
* playerplus (optional)

### Download

This is a fork to mantain up to date and in sync with backguard compatibilty, 
can be downloaded from https://codeberg.org/minenux/minetest-mod-ambience and 
must be named as `ambience`.

Original work can be downloaded from https://notabug.org/TenPlus1/ambience if still exits.

### Configuration

You can set those configurations in the mod tab at the gui, or added those option 
to the minetest config file at game directory, to the main global config file.

| config option       | type | default | description |
| ------------------- | ---- | ------- | ----------- |
| ambience_music      | bool | true    | If enabled will play a random music file from ./minetest/sounds at midnigh. |
| ambience_water_move | bool | true    | If enabled then ambience will take over sounds when moving in water. |

For more info check https://codeberg.org/venenux/venenux-minetest/src/branch/master/tutorials/manage-minetest-configuration.md

### Files

Music can be stored in the sounds folder either on server or locally (if client have the mod also) 
and so long as it is named 'ambience_music.1', 'ambience_music.2' etc. then it will select
a song randomly at midnight and play player.

Original mod does not provide the music files, you must download from https://notabug.org/TenPlus1/ambience_music, 
**this fork provides free CC-BY-SA music from Dark Reaven Music** (https://www.youtube.com/channel/UCrJvUcP_dEqLSbODiWFv3gw).

These can be stored in ambience directory `/sounds` for all to share, or on a local client in `.minetest/sounds`
for singleplayer custom music.

Order is very important when adding a sound set so it will play a certain set of sounds before 
any another.

It will overrides default water sounds, then will check for `env_sounds` mod, if not found enable water 
flowing and lava sounds, water sound plays when near flowing water.

Fire sounds will be detected if `fire_redo/fire` lite mod is detected and `flame_sound` setting is enabled.

## License

Code license: MIT

Sounds check [sounds/SoundLicenses.txt](sounds/SoundLicenses.txt) file

Music licence ©️ CC BY 4.0 Dark Reaven Music https://www.youtube.com/channel/UCrJvUcP_dEqLSbODiWFv3gw
