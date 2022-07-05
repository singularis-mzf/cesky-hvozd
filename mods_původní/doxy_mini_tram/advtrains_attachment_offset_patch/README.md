<!--
SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>

SPDX-License-Identifier: MIT OR CC-BY-SA-4.0
-->

# advtrains attachment offset patch

Attaching a player to an advtrains wagon at a position other than the horizontal center does not work because of https://github.com/minetest/minetest/issues/10101.
A workaround has been presented in https://github.com/minetest/minetest/issues/5013, but at that time it didn’t work well because of other bugs.

This mod implements the workaround.
Players are not attached directly to the wagon, but to a dummy entity which is placed at the intended attachment position.
This way, the eye_offset of the player can stay zero, and the bug is not triggered.

Additionally, the rotation of the player entity can be specified per seat.

## Usage

Before registering an advtrains wagon, call `advtrains_attachment_offset_patch.setup_advtrains_wagon()` on its definition table.

To specify player rotation per seat, add a rotation vector called `advtrains_attachment_offset_patch_attach_rotation` to each seat definition.

## How it works

When a player gets on a wagon, advtrains core logic will call the `get_on()` method of the wagon.
This method is usually defined in the advtrains core, but can be overriden by individual wagon definitions.
This mod overrides it this way.
`get_off()` is overriden the same way.

A player “gets on a wagon” when walking into it, rightclicking it, or joining the game after leaving it while being in a wagon.

The overriding methods in this patch call the original methods, and then check whether the player is now/still attached to the wagon.
If so, the player attachment is replaced to a dummy entity, to which the player is attached.

Theoretically, this does not change anything.
But because of the mentioned bug 10101, the player will now see “with the own eyes”. :)
