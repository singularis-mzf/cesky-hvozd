allow_defined_top = true
max_line_length = 1024
ignore = {"212"}

globals = {
	builtin_overrides = {fields = {"login_to_viewname"}},
	"ch_bank",
	ch_core = {fields = {
		"aktualni_cas",
		"formspec_header",
		"cancel_ch_timer",
		"close_formspec",
		"get_player_role",
		"hotovost",
		"ifthenelse",
		"je_pryc",
		"je_ve_vykonu_trestu",
		"jmeno_na_prihlasovaci",
		"precist_hotovost",
		"prihlasovaci_na_zobrazovaci",
		"set_temporary_titul",
		"show_formspec",
		"soukroma_zprava",
		"start_ch_timer",
		"systemovy_kanal",
		"update_formspec",
	}},
	ch_data = {fields = {
		"correct_player_name_casing",
		"delete_offline_charinfo",
		"get_joining_online_charinfo",
		"get_leaving_online_charinfo",
		"get_offline_charinfo",
		"get_or_add_offline_charinfo",
		"save_offline_charinfo",
		"should_show_help",
		initial_offline_charinfo = {
			read_only = false,
			other_fields = true,
		},
		is_acceptable_name = {
			read_only = false,
		},
		online_charinfo = {
			read_only = false,
			other_fields = true,
		}, offline_charinfo = {
			read_only = false,
			other_fields = true,
		},
	}},
	doors = {fields = {
		"get", "login_to_viewname", "register_fencegate"
	}},
	player_api = {fields = {"player_attached"}},
}


read_globals = {
	ch_base = {fields = {
		"open_mod", "close_mod"
	}},
	ch_time = {fields = {
		"aktualni_cas",
		"get_time_speed_during_day",
		"get_time_speed_during_night",
		"herni_cas_nastavit",
		"set_time_speed_during_day",
		"set_time_speed_during_night",
	}},
	default = {fields = {
		"can_interact_with_node",
		"register_fence",
		"register_fence_rail",
		"register_mesepost",
		"node_sound_stone_defaults",
	}},
	screwdriver = {fields = {"ROTATE_FACE", "ROTATE_AXIS", handler = {read_only = false}}},
	math = {fields = {"ceil", "floor", "round"}},
	minetest = {
		fields = {
			"CONTENT_AIR", "CONTENT_IGNORE", "CONTENT_UNKNOWN", "EMERGE_CANCELLED", "EMERGE_ERRORED", "EMERGE_FROM_DISK", "EMERGE_FROM_MEMORY", "EMERGE_GENERATED", "LIGHT_MAX", "MAP_BLOCKSIZE",
			"PLAYER_MAX_BREATH_DEFAULT", "PLAYER_MAX_HP_DEFAULT", "add_entity", "add_item", "add_node", "add_node_level", "add_particle", "add_particlespawner", "after", "async_event_handler",
			"async_jobs", "auth_reload", "ban_player", "builtin_auth_handler", "bulk_set_node", "calculate_knockback", "callback_origins", "cancel_shutdown_requests", "chat_send_all",
			"chat_send_player", "chatcommands", "check_for_falling", "check_password_entry", "check_player_privs", "check_single_for_falling", "clear_craft", "clear_objects",
			"clear_registered_biomes", "clear_registered_decorations", "clear_registered_ores", "clear_registered_schematics", "close_formspec", "colorize", "colorspec_to_bytes",
			"colorspec_to_colorstring", "compare_block_status", "compress", "cpdir", "craft_predict", "craftitemdef_default", "create_detached_inventory", "create_detached_inventory_raw",
			"create_schematic", "debug", "decode_base64", "decompress", "delete_area", "delete_particlespawner", "deserialize", "detached_inventories", "dig_node", "dir_to_facedir",
			"dir_to_fourdir", "dir_to_wallmounted", "dir_to_yaw", "disconnect_player", "do_async_callback", "do_item_eat", "dynamic_add_media", "dynamic_media_callbacks",
			"emerge_area", "encode_base64", "encode_png", "env", "error_handler", "explode_scrollbar_event", "explode_table_event", "explode_textlist_event", "facedir_to_dir",
			"features", "find_node_near", "find_nodes_in_area", "find_nodes_in_area_under_air", "find_nodes_with_meta", "find_path", "fix_light", "forceload_block",
			"forceload_free_block", "format_chat_message", "formspec_escape", "fourdir_to_dir", "generate_decorations", "generate_ores", "get_all_craft_recipes",
			"get_artificial_light", "get_auth_handler", "get_background_escape_sequence", "get_ban_description", "get_ban_list", "get_biome_data", "get_biome_id",
			"get_biome_name", "get_builtin_path", "get_color_escape_sequence", "get_connected_players", "get_content_id", "get_craft_recipe", "get_craft_result",
			"get_current_modname", "get_day_count", "get_decoration_id", "get_dig_params", "get_dir_list", "get_game_info", "get_gametime", "get_gen_notify",
			"get_globals_to_transfer", "get_heat", "get_hit_params", "get_humidity", "get_inventory", "get_item_group", "get_last_run_mod", "get_mapgen_edges",
			"get_mapgen_object", "get_mapgen_params", "get_mapgen_setting", "get_mapgen_setting_noiseparams", "get_meta", "get_mod_storage", "get_modnames",
			"get_modpath", "get_name_from_content_id", "get_natural_light", "get_node", "get_node_drops", "get_node_group", "get_node_level", "get_node_light",
			"get_node_max_level", "get_node_or_nil", "get_node_timer", "get_noiseparams", "get_objects_in_area", "get_objects_inside_radius", "get_password_hash",
			"get_perlin", "get_perlin_map", "get_player_by_name", "get_player_information", "get_player_ip", "get_player_privs", "get_player_radius_area",
			"get_player_window_information", "get_pointed_thing_position", "get_position_from_hash", "get_server_max_lag", "get_server_status",
			"get_server_uptime", "get_spawn_level", "get_timeofday", "get_tool_wear_after_use", "get_translated_string", "get_translator",
			"get_us_time", "get_user_path", "get_version", "get_voxel_manip", "get_worldpath", "global_exists", "handle_async", "handle_node_drops",
			"has_feature", "hash_node_position", "hud_replace_builtin", "inventorycube", "is_area_protected", "is_colored_paramtype", "is_creative_enabled",
			"is_nan", "is_player", "is_protected", "is_singleplayer", "is_yes", "item_eat", "item_pickup", "item_place", "item_place_node",
			"item_place_object", "item_secondary_use", "itemstring_with_color", "itemstring_with_palette", "kick_player", "line_of_sight", "load_area",
			"log", "luaentities", "mkdir", "mod_channel_join", "mvdir", "node_dig", "node_punch", "nodedef_default", "noneitemdef_default",
			"notify_authentication_modified", "object_refs", "on_craft", "override_chatcommand", "override_item", "parse_coordinates", "parse_json",
			"parse_relative_number", "place_node", "place_schematic", "place_schematic_on_vmanip", "player_exists", "pointed_thing_to_face_pos",
			"pos_to_string", "privs_to_string", "punch_node", "raillike_group", "raycast", "read_schematic", "record_protection_violation",
			"register_abm", "register_alias", "register_alias_force", "register_allow_player_inventory_action", "register_async_dofile",
			"register_authentication_handler", "register_biome", "register_can_bypass_userlimit", "register_chatcommand", "register_craft",
			"register_craft_predict", "register_craftitem", "register_decoration", "register_entity", "register_globalstep", "register_item",
			"register_lbm", "register_node", "register_on_auth_fail", "register_on_authplayer", "register_on_chat_message", "register_on_chatcommand",
			"register_on_cheat", "register_on_craft", "register_on_dieplayer", "register_on_dignode", "register_on_generated", "register_on_item_eat",
			"register_on_item_pickup", "register_on_joinplayer", "register_on_leaveplayer", "register_on_liquid_transformed", "register_on_mapblocks_changed",
			"register_on_mapgen_init", "register_on_modchannel_message", "register_on_mods_loaded", "register_on_newplayer", "register_on_placenode",
			"register_on_player_hpchange", "register_on_player_inventory_action", "register_on_player_receive_fields", "register_on_prejoinplayer",
			"register_on_priv_grant", "register_on_priv_revoke", "register_on_protection_violation", "register_on_punchnode", "register_on_punchplayer",
			"register_on_respawnplayer", "register_on_rightclickplayer", "register_on_shutdown", "register_ore", "register_playerevent", "register_privilege",
			"register_schematic", "register_tool", "registered_abms", "registered_aliases", "registered_allow_player_inventory_actions", "registered_biomes",
			"registered_can_bypass_userlimit", "registered_chatcommands", "registered_craft_predicts", "registered_craftitems", "registered_decorations",
			"registered_entities", "registered_globalsteps", "registered_items", "registered_lbms", "registered_nodes", "registered_on_authplayers",
			"registered_on_chat_messages", "registered_on_chatcommands", "registered_on_cheats", "registered_on_crafts", "registered_on_dieplayers",
			"registered_on_dignodes", "registered_on_generateds", "registered_on_item_eats", "registered_on_item_pickups", "registered_on_joinplayers",
			"registered_on_leaveplayers", "registered_on_liquid_transformed", "registered_on_mapblocks_changed", "registered_on_modchannel_message",
			"registered_on_mods_loaded", "registered_on_newplayers", "registered_on_placenodes", "registered_on_player_hpchange",
			"registered_on_player_hpchanges", "registered_on_player_inventory_actions", "registered_on_player_receive_fields",
			"registered_on_prejoinplayers", "registered_on_priv_grant", "registered_on_priv_revoke", "registered_on_protection_violation",
			"registered_on_punchnodes", "registered_on_punchplayers", "registered_on_respawnplayers", "registered_on_rightclickplayers",
			"registered_on_shutdown", "registered_ores", "registered_playerevents", "registered_privileges", "registered_tools",
			"remove_detached_inventory", "remove_detached_inventory_raw", "remove_node", "remove_player", "remove_player_auth",
			"request_http_api", "request_insecure_environment", "request_shutdown", "rgba", "rmdir", "rollback_get_last_node_actor",
			"rollback_get_node_actions", "rollback_punch_callbacks", "rollback_revert_actions_by", "rotate_and_place", "rotate_node",
			"run_callbacks", "run_priv_callbacks", "safe_file_write", "serialize",
			"serialize_roundtrip", "serialize_schematic", "set_gen_notify", "set_last_run_mod", "set_mapgen_params", "set_mapgen_setting",
			"set_mapgen_setting_noiseparams", "set_node", "set_node_level", "set_noiseparams", "set_player_password", "set_player_privs",
			"set_timeofday", "setting_get", "setting_get_pos", "setting_getbool", "setting_save", "setting_set", "setting_setbool",
			"settings", "sha1", "show_formspec", "show_general_help_formspec", "show_privs_help_formspec", "sound_fade",
			"sound_play", "sound_stop", "spawn_falling_node", "spawn_item", "spawn_tree", "string_to_area", "string_to_pos",
			"string_to_privs", "strip_background_colors", "strip_colors", "strip_foreground_colors", "strip_param2_color",
			"swap_node", "tooldef_default", "transforming_liquid_add", "translate", "unban_player_or_ip", "unregister_biome",
			"unregister_chatcommand", "unregister_item", "urlencode", "wallmounted_to_dir", "wrap_text", "write_json", "yaw_to_dir",
			item_drop = {read_only = false},
			send_join_message = {read_only = false},
			send_leave_message = {read_only = false},
		},
	},
	string = {fields = {"split", "sub"}},
	table = {fields = {"copy", "indexof", "insert_all", "key_value_swap"}},
	vector = {fields = {"angle", "copy", "distance", "equals", "multiply", "new", "offset", "rotate", "round", "subtract", "to_string", "zero"}},

	"AreaStore", "dump2", "emote", "hb", "ItemStack", "player_api", "wielded_light"
}
read_globals.core = read_globals.minetest

files["ap.lua"].ignore = {"_max_xp"}
files["data.lua"].ignore = {"past_playtime"}
files["trade.lua"].ignore = {"_trade_state"}
files["teleportace.lua"].ignore = {"_old_pos"}
