#!/bin/bash
luacheck init.lua
exec luacheck api.lua nodes.lua machine.lua crafts.lua
