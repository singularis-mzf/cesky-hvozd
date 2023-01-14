# `generic_flags` API

Programmers can use the following Lua functions to add custom flags,
get a list of all flags, and set and get the flag of flag pole nodes.

## Functions

### `generic_flags.add_flag(name)`

Add a new flag to the game. `name` is the flag identifier.
There *must* exist a texture with the name `flag_<name>.png`.
The texture *should* have an aspect ratio of 1.3.
The recommended size is 78×60, but other sizes are OK
as long the aspect ratio is respected.

The flag name *must not* already exist. This will be checked.

On success, the flag will be appended to the list of flags at the end.

If a flag with the given name already exists, no flag will be
added.

Returns `true` on success and `false` on failure.

### `generic_flags.get_flags()`

Returns a list of all available flag identifiers. The flags
are sorted by selection order.

### `generic_flags.set_flag_at(pos, flag_name)`

Sets the flag at an upper mast node at position `pos` to the flag `flag_name`.
The node at `pos` *must* be `generic_flags:upper_mast`.
Returns `true` on success and `false` otherwise.

### `generic_flags.get_flag_at(pos)`

Returns the currently used flag at the upper mast node at position `pos`.
The node at `pos` *must* be `generic_flags:upper_mast`.
Returns a string on success and `nil` otherwise.

### `generic_flags.get_wind(pos)`

Returns the current wind strength at pos. The wind strength determines how
fast a flag at pos would be waving at the time this function was called.

This function will be called from time to time by the mod to update
the flag waving speed of flags. It is called for every flag once about
every 115 seconds (plusminus 10 seconds).

This function is predefined in this mod by pseudorandomly changing the wind
strength over time using a Perlin noise. By default, the wind strength is
only controlled by the current time; the position is ignored.

This function can be overwritten by mods to define your own wind algorithm.
You can do whatever in this function, you only need to return a number in
the end. The number should be roughly in the range between 0 and 50.

This is how the wind strength affects the flag waving speed:

* wind < 10: slow
* 10 < wind < 20: medium
* 20 < wind < 40: fast
* wind > 40: very fast
