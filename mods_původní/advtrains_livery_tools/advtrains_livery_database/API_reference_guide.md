# AdvTrains Livery Database API Reference Guide

**NOTE: This document is still in development.**

The **AdvTrains Livery Database** is a key technical component for sharing livery information between mods for AdvTrains.  Mods that register their wagons and livery information with the database can benefit from other mods that extend the livery options for their wagons as will as allow other mods, such as the **AdvTrains Livery Designer**, to provide in-game livery customization options to players.  It also opens the possibility for mods to enhance or create new nodes and tools that can update a wagon's appearance in-game.

It is important to note that it is impossible to create a livery database that can accommodate all current and future livery customization schemes.  Although the **AdvTrains Livery Database** attempts to accommodate some of the more complex livery implementations in existing mods, it relies on those mods providing callback functions to help support their implementations.  Even that approach has limitations, however, so enhancements to this library will likely be needed over time.

## Concepts
### A non-persistent, in-game database
The AdvTrains Livery Database is intended to be initialized during the startup phase of a Minetest game. Participating mods will call the applicable livery database functions to register themselves, their wagons, their livery templates and any predefined liveries during their respective initialization phases.

### Write once, read-many
The AdvTrains Livery Database currently implements a write once, read-many interface. This is intended to prevent mods from accidentally interfering with the liveries and templates of other mods.

### Livery Templates
A livery template defines a family of one or more possible livery designs. The template is defined by the mod creator and cannot be modified in-game by the player. Depending on the template design, however, the player may be able to modify the colors and/or appearance of visual elements of the livery while in game in order to create a customized livery design based on the template. The designer of the template defines which parameters the player will be able to modify. A livery template is specific to one wagon type.
#### Overlays
An overlay defines a customization option for a portion of a livery. A livery template can have zero or more overlays as part of its definition.  Multiple overlays can be applied to the same base texture, or, if the wagon uses multiple texture slots, each overlay can specify to which texture slot it applies.

### Livery Designs
A livery design can be thought of as a livery template plus the values, if any, for the adjustable parameters of that template.  Currently, these adjustable parameters are related to overlays and their color overrides.  Other parameters are being considered for future enhancements.

### Predefined Livery Designs
Generally, livery designs are not stored in the AdvTrains Livery Database. The exception is that a mod may optionally define one or more livery designs and register them with the database, typically as a way to showcase a few possibilities of how a livery template might be used. Unless done for a specific type of game or under well managed conditions, a mod should not register a player's in-game defined livery designs so as to avoid potential abuse of the server. Moreover, such registered livery designs are not saved when the game exits.

### Livery Packs
A mod that does not define any wagons of its own but instead only defines livery templates and possibly predefined livery designs for wagons defined in other mods is considered to be a "livery pack".  A mod that does not define any wagons or livery templates but only predefined livery designs for livery templates defined in other mods is considered to be a light-weight "livery pack".  Light-weight livery packs can be safely removed from a game without adversely affecting any wagons that have liveries from such mods.

## Registering Wagons and Livery Information
The following pseudo code shows the sequence of API calls that should be made by a mod during its initialization phase to register its wagons and livery information with the database:

### Step 1: Register the mod

Each mod that adds data to the database should first register itself:
```
advtrains_livery_database.register_mod(...)
```

> **NOTE:** If the mod is defining new wagons and that can be customized with the **AdvTrains Livery Designer** mod, it should instead call the Advtrains Livery Designer's registration function which in turn will call this mod's `register_mod()` function.  The mod should not call both **`advtrains_livery_designer.register_mod()`** and  **`advtrains_livery_database.register_mod()`** since the second call will fail.
> 
> ```
> advtrains_livery_designer.register_mod(...)
>```
> 
> Registering with the **Advtrains Livery Designer** mod allows the livery designer tool to update a wagon's livery.  See the **Advtrains Livery Designer** mod for more information.

Of course, be sure to also update the mod's dependencies to include **AdvTrains Livery Database** or **AdvTrains Livery Designer** as appropriate.  (**AdvTrains Livery Designer** depends on **AdvTrains Livery Database** so there is no need to specify both.)

### Step 2: Register each of the mod's wagons

If the mod is defining new wagons it should register any wagons that will have livery templates in the database.  If the mod is only adding new livery templates for wagons defined and registered in a different mod it can skip this step:

```
for each wagon do
    advtrains_livery_database.register_wagon(...)
end
```

### Step 3: Add livery templates

If the mod is defining new livery templates, it should next add them to the database.  If a livery template has any overlays they should also be added:

```
for each livery template do
    advtrains_livery_database.add_livery_template(...)
    for each overlay in livery template do
        advtrains_livery_database.add_livery_template_overlay(...)
    end
end
```

Note that the database currently limits the number of overlays that can be added for a given template.  Use `advtrains_livery_database.get_overlays_per_template_limit()` to determine that number if needed.

> **A suggested naming convention for livery templates**
>
> As a convenience for players when viewing the list of livery templates for a wagon type, the following naming convention is recommended:
> 
> 	`"mod_name - logo_abbreviation name"`
> 
> where the `"mod_name - "` portion is only used by livery packs in order to keep their templates grouped together.  In that case a shortened version of the the mod's full name can be used for mod_name.  The `"logo_abbreviation "` portion is only used if a logo is visible when the livery template is in its default state.

### Step 4: Add predefined liveries

If the mod is adding any predefined liveries, it can now add them to the database.  Predefined liveries must reference a livery template that has already been added to the database.

```
for each predefined livery do
    advtrains_livery_database.add_predefined_livery(...)
end
```

### Step 5: Update wagon definitions to include an implementation for custom_may_destroy()

Although not relevant to the database, if the mod registered any wagons there is one final step needed.  In order for the **AdvTrains Livery Designer** tool to be used on a wagon, the `advtrains.register_wagon()` function call should include an implementation for the optional `custom_may_destroy` function that validates that the player is punching the wagon with the designer tool and, if so, activate the tool.  See the implementation of the **Classic Coaches** mod for an example of how this can be done.


### Example Code
For an example of all the changes needed to make an existing mod compatible with the database and designer mods, see the git history of the **Classic Coaches** mod.  The first update after the initial version shows all of the changes that were made to adapt it for using the database and designer mods.  Some of the code added to init.lua in that update could be used as boilerplate in other mods.

## API Reference
The following is a high level overview of the API.

### Primary Functions
The following functions form the access points to the AdvTrains Livery Database. The **`register_`** and **`add_`** functions allow data to be added to the database and should called once per object instance. The **`get_`** functions can be called as often as needed.
* **`register_mod()`** - Each mod that adds data to the database should call this once before calling any of the other primary functions.  Mods can also optionally specify callback functions here that need to be called to support the specific needs of their livery implementation.
* **`register_wagon()`** - This should be called once (by the mod that defines the wagon) for each wagon type that is will have livery templates in the database.
* **`get_wagon_mod_name()`** - Gets the name of the mod that that registered a given wagon type.
* **`add_livery_template()`** - Adds a livery template for a given wagon type. The wagon type must have been previously added via the register_wagon() function.
* **`add_livery_template_overlay()`** - Adds an overlay for a given livery template. It should be called once for each overlay in the template.
* **`add_predefined_livery()`** - Adds a predefined livery design for a given wagon type. Predefined liveries are optional. Note that predefined livery names must be unique per wagon type.
* **`get_predefined_livery_names()`** - Gets the list of names of predefined liveries for a given wagon type.
* **`get_predefined_livery()`** - Gets the predefined livery given a wagon type and livery name. Note that predefined livery names are unique per wagon type.
* **`get_wagon_livery_overlay_name()`** - Gets the name of an overlay for a given wagon type, template and overlay sequence number.
* **`get_wagon_livery_template()`** - Gets the livery template for a given wagon type and template name.
* **`get_livery_template_names_for_wagon()`** -  Gets the list of names of livery templates for a given wagon type.
* **`get_livery_design_from_textures()`** - Attempts to determine the livery_design for a given wagon_type from its livery textures. Note that if the livery textures were modified by the owning mod due to weathering, loads, etc. then this function could fail. The mod that defined the wagon should provide applicable callback functions to handle such cases.
* **`get_livery_textures_from_design()`** - Given a livery design and an optional wagon id, this function should return livery texture strings suitable for updating a wagon. If specified, the wagon id parameter is used in case the base texture varies by instance of the wagon due to weathering, load, etc. The mod that defined the wagon will need to provide applicable callback functions to handle such cases.

### Utility Functions
The following functions do not interact with the livery database but may be helpful when used in conjunction with the functions that do.
* **`clone_livery_design()`** - Creates a deep copy of a given livery design.
* **`clone_textures()`** - Creates a deep copy of a given list of textures.
* **`get_overlays_per_template_limit()`** - Gets the maximum number of overlays that can be specified for a given livery template.  This is currently a relatively small number until the impact on performance is evaluated.

## Remaining Documentation Work
The following is an incomplete list of the items still needing to be updated or addressed in future revisions of this document:
* Add function parameter information to API reference
* Add information about using callback functions for supporting more complex livery  implementations.
## Licenses

Copyright © 2023 Marnack

- AdvTrains Livery Database is licensed under the GNU AGPL version 3 license.
- Unless otherwise specified, AdvTrains Livery Database media (textures and sounds) are licensed under [CC BY-SA 3.0 Unported](https://creativecommons.org/licenses/by-sa/3.0/).

