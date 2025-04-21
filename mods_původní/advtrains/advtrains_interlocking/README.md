# Interlocking for Advtrains

The `advtrains_interlocking` mod provides various interlocking and signaling features for Advtrains.

## Signal aspect tables

Signal aspects are represented using tables with the following (optional) fields:

* `main`: The main signal aspect. It provides information on the permitted speed after passing the signal.
* `dst`: The distant signal aspect. It provides information on the permitted speed after passing the next signal.
* `shunt`: Whether the train may proceed in shunt mode and, if the main aspect is danger, proceed in shunt mode.
* `proceed_as_main`: Whether the train should exit shunt mode when proceeding.
* `group`: The name of the signal group.
* `name`: The name of the signal aspect.

The `main` and `dst` fields may be:

* An positive number indicating the permitted speed,
* The number 0, indicating that the train should expect to stop at the current signal (or, for the `dst` field, the next signal),
* The number -1, indicating that the train can proceed (or, for the `dst` field, expect to proceed) at maximum speed,
* The constant `false`, indicating no change to the speed restriction, or
* The constant `nil`, indicating that the default value for the name aspect (if present) is used. If no valid signal aspect is named, or the signal aspect does not provide a default value, the value is assumed to be `false`.

### Node definitions

Signals should belong the following node groups:

* `advtrains_signal`: `1` for static signals, `2` for signals with variable aspects.
* `save_in_at_nodedb`: This should be set to `1` to make sure that Advtrains always has access to the signal.
* `not_blocking_trains`: Setting this to `1` prevents trains from colliding with the signal. Setting this is not necessary, but recommended.

The node definition should contain an `advtrains` field.

The `advtrains` field of the node definition should contain a `supported_aspects` table for signals with variable aspects.

The `supported_aspects` table should contain the following fields:

* `main`: A list of values supported for the main aspect.
* `dst`: A list of values supported for the distant aspect.
* `shunt`: The value for the `shunt` field of the signal aspect or `nil` if the value is variable.
* `proceed_as_main`: The value for the `proceed_as_main` field of the signal aspect.
* `group`: The name of the signal group.
* `name`: A list of supported (named) aspects.
* `dst_shift`: The phase shift for distant/repeater signals. This field should not be set for main signals.

The `advtrains` field of the node definition should contain a `get_aspect` function. This function is given the position of the signal and the node at the position. It should return the signal aspect table or, in the case of type 2 signals, the name of the signal aspect.

For signals with variable aspects, a corresponding `set_aspect` function should also be defined. This function is given the position of the signal, the node at the position, and the new aspect. The new aspect is not guaranteed to be supported by the signal itself.

Signals should also have the following callbacks set:

* `on_rightclick` should be set to `advtrains.interlocking.signal_rc_handler`
* `can_dig` should be set to `advtrains.interlocking.signal_can_dig`
* `after_dig_node` should be set to `advtrains.interlocking.signal_after_dig`

Alternatively, custom callbacks should call the respective functions.

## Signal groups

Signals may belong to signal groups are registered using `advtrains.interlocking.aspect.register_group`.

Signal group definitions include the following fields:

* `name`: The internal name of the signal group. It is recommended to use the mod name as a prefix to avoid name collisions.
* `label`: The description of the signal group.
* `aspects`: A table of signal aspects. Entries with string indices define the signal aspect with the name. Entries with numeric indices (starting from 1, counting upward) contain a list of corresponding aspect names (the first entry is preferred) and are mainly used for routing, where larger indices indicate that the signal with the aspect is closer to the signal with the "danger" (or similar) aspect.

Each aspect in the signal group definition table should contain the following fields:

* `label`: The description of the signal aspect.
* `main`, `shunt`, `proceed_as_main`: The default values for the aspect. Note that the `dst` field has no default value as it is automatically adjusted.

## Notes

It is allowed to provide other methods of setting the signal aspect. However:

* These changes are ignored by the routesetting system.
* Please call `advtrains.interlocking.signal_readjust_aspect` after the signal aspect has changed.

## Examples
An example of speed signals can be found in `advtrains_signals_ks`, which provides a subset of German signals.

An example of route signals can be found in `advtrains_signals_japan`, which provides a subset of Japanese signals.

The mods mentioned above are also used for demonstation purposes and can also be used for testing.
