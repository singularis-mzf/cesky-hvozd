#!/bin/bash
luacheck init.lua
exec luacheck trade_inv.lua bank_archive.lua bank_accounts.lua formspec.lua formspec_callback.lua trade.lua payment_method.lua
