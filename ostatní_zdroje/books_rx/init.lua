--------------------------------------------------------
-- Minetest :: Books Redux Mod (books_rx)
--
-- See README.txt for licensing and other information.
-- Copyright (c) 2019-2020, Leslie E. Krause
--
-- ./games/minetest_game/mods/books_rx/init.lua
--------------------------------------------------------

local config = minetest.load_config( )

local fs = minetest.formspec_escape
local open_book_viewer, open_book_editor, open_paper_viewer, open_paper_editor

-----------------------

function open_defbook_viewer( player_name, owner, title, text )

	local function get_formspec( )
		local formspec = "size[8.0,8.5]" .. 
			default.gui_bg ..
			default.gui_bg_img ..
			"label[0.3,0.2;Title:]" ..
			"label[1.5,0.2;" .. title .. "]" ..
			"label[0.3,0.8;By:]" ..
			"label[1.5,0.8;" .. owner .. "]" ..
			"textarea[0.5,1.5;7.6,7.0;content;;" .. minetest.formspec_escape( text ) .. "]" ..
			"button_exit[3.0,7.8;2.0,0.8;close;Close]"

		return formspec
	end

	minetest.create_form( nil, player_name, get_formspec( ) )
end

function open_book_viewer( player_name, oldtime, owner, title, scale, style, color, pages, marks, page_idx, vars, is_preview )

	local book_scales = {
                small = { width = 12.0, height = 8.5 },
                tall = { width = 12.0, height = 11.0 },
                large = { width = 15.5, height = 11.0 },
                wide = { width = 15.5, height = 8.5 },
	}
	local book_colors = {
		gray = "#333333",
		brown = "#663300",
		teal = "#006633",
		purple = "#330066",
		olive = "#336600",
		indigo = "#003366",
		maroon = "#660033",
		red = "#660000",
		green = "#006600",
		blue = "#000066",
	}
	local mark_ver = 1

	local function add_bookmark( )
		if not table.get_index( marks, page_idx ) then
			table.insert( marks, page_idx )
			table.sort( marks )
		end
	end

	local function del_bookmark( )
		local idx = table.get_index( marks, page_idx )
		if idx then
			table.remove( marks, idx )
		end
	end

	local function get_formspec( )
		local page_width = book_scales[ scale ].width / 2
		local page_height = book_scales[ scale ].height

		local foot_x1 = ( page_width - 4.5 ) / 2 + 0.3			-- horz pos of left-hand footer
		local foot_x2 = page_width + ( page_width - 4.5 ) / 2 - 0.3	-- horz pos of right-hand footer
		local foot_y = page_height - 1.3				-- vert pos of both footers

		if page_idx == 1 then
			-- render background and controls of front cover
			local formspec =
				string.format( "size[%0.2f,%0.2f]", page_width, page_height ) ..
				default.gui_bg ..
				string.format( "background[0.0,0.0;%0.2f,%0.2f;%s;false]", page_width, page_height,
					fs( "book_" .. style .. "_front.png^[colorize:" .. book_colors[ color ] .. "66^[noalpha" ) ) ..

				string.format( "%s[%0.2f,%0.2f;2.0,1.0;close;Close]",
					is_preview and "button" or "button_exit", foot_x1 + 0.8, foot_y ) ..
				string.format( "button[%0.2f,%0.2f;1.0,1.0;next_page;>>]",
					foot_x1 + 2.7, foot_y )

			-- render front cover content
        		local page_x1 = 0.8
		        local page_y1 = 0.5
        		local page_x2 = page_x1 + page_width - 1.4
	        	local page_y2 = page_y1 + page_height - 1.5

			formspec = formspec ..
				markup.get_formspec_string( markup.parse_message( pages[ page_idx ], vars ),
					page_x1, page_y1, page_x2, page_y2, "#666666", "#CCCCCC" )

			return formspec
		else
			-- render background and controls of page
			local mark_idx = table.get_index( marks, page_idx )

			local formspec =
				string.format( "size[%0.2f,%0.2f]", page_width * 2, page_height ) ..
				default.gui_bg ..
				string.format( "background[0.0,0.0;%0.2f,%0.2f;%s;false]", page_width, page_height,
					fs( "book_" .. style .. "_cover.png^[colorize:" .. book_colors[ color ] .. "66^[noalpha" ) ) ..

				string.format( "background[%0.2f,0.0;%0.2f,%0.2f;%s;false]", page_width, page_width, page_height,
					fs( "book_" .. style .. "_cover.png^[transformFX^[colorize:" .. book_colors[ color ] .. "66^[noalpha" ) ) ..

				string.format( "button[%0.2f,%0.2f;1.0,1.0;prev_page;<<]", foot_x2, foot_y ) ..
				string.format( "button[%0.2f,%0.2f;1.0,1.0;next_page;>>]", foot_x2 + 1.0, foot_y ) ..
				string.format( "%s[%0.2f,%0.2f;2.0,1.0;close;Close]",
					is_preview and "button" or "button_exit", foot_x2 + 2.5, foot_y ) ..

				string.format( "label[%0.2f,%0.2f;Bookmarks:]", foot_x1, foot_y + 0.2 )

			if #marks > 0 then
				formspec = formspec ..
					string.format( "dropdown[%0.2f,%0.2f;1.8,1.0;marks_%d;,%s;%d;true]", foot_x1 + 1.5, foot_y + 0.1, mark_ver,
						table.join( marks, ",", function ( a, b ) return "Page " .. b - 1 end ),
						mark_idx and mark_idx + 1 or 1 )
			else
				formspec = formspec ..
					string.format( "dropdown[%0.2f,%0.2f;1.8,1.0;marks;;1;true]", foot_x1 + 1.5, foot_y + 0.1 )
			end
			if mark_idx then
				formspec = formspec ..
					string.format( "button[%0.2f,%0.2f;1.2,1.0;del_mark;Del]", foot_x1 + 3.3, foot_y )
			else
				formspec = formspec ..
					string.format( "button[%0.2f,%0.2f;1.2,1.0;add_mark;Add]", foot_x1 + 3.3, foot_y )
			end

			-- render left-hand page content
        		local page_x1 = 1.0
		        local page_y1 = 0.5
        		local page_x2 = page_x1 + page_width - 1.4
	        	local page_y2 = page_y1 + page_height - 1.8

			local text_colors = {
			        gray = "#999999",
			        cyan = "#00EEEE",
			        magenta = "#EE00EE",
			        yellow = "#EEEE00",
			        red = "#CC0000",
			        green = "#00CC00",
			        blue = "#0000CC",
				brown = "#CC9900",
				teal = "#00CC99",
				purple = "#9900CC",
				olive = "#99CC00",
				indigo = "#0099CC",
				maroon = "#CC0099",
			}

			formspec = formspec ..
				markup.get_formspec_string( markup.parse_message( pages[ page_idx ], vars, { colors = text_colors } ),
					page_x1, page_y1, page_x2, page_y2, "#666666", "#CCCCCC" )

			if pages[ page_idx + 1 ] then
				-- render right-hand page content, if it exists
				page_x1 = page_x1 + page_width - 0.6
				page_x2 = page_x2 + page_width - 0.6

				formspec = formspec .. markup.get_formspec_string( markup.parse_message( pages[ page_idx + 1 ], vars ),
					page_x1, page_y1, page_x2, page_y2, "#666666", "#CCCCCC" )
			end

			return formspec
                end
	end

	local function on_close( meta, player, fields )
		local fields_marks = fields[ "marks_" .. mark_ver ]

		if fields.close then
			if is_preview then
	                        open_book_editor( player_name, oldtime, owner, title, scale, style, color, pages, page_idx, vars )

			elseif mark_ver > 1 then
				local itemstack = player:get_wielded_item( )
				local player_inv = player:get_inventory( )
				local data = {
					oldtime = oldtime,
					owner = owner,
					title = title,
					scale = scale,
					style = style,
					color = color,
					pages = pages,
					marks = marks,
				}
				safety_deposit.encrypt_metadata( itemstack, data )
				player:set_wielded_item( itemstack )

				minetest.chat_send_player( player_name, "Your bookmarks were updated!" )
			end

		elseif fields.next_page then
			if page_idx < #pages then
				page_idx = page_idx + 1
				minetest.update_form( player_name, get_formspec( ) )
			end

		elseif fields.prev_page then
			if page_idx > 1 then
				page_idx = page_idx - 1
				minetest.update_form( player_name, get_formspec( ) )
			end

		elseif fields.add_mark then
			mark_ver = mark_ver + 1
			add_bookmark( page_idx )
			minetest.update_form( player_name, get_formspec( ) )

		elseif fields.del_mark then
			mark_ver = mark_ver + 1
			del_bookmark( page_idx )
			minetest.update_form( player_name, get_formspec( ) )

		elseif fields_marks then	-- overcome bug with dropdowns not updating values in older clients
			page_idx = marks[ fields_marks - 1 ] or 1
			minetest.update_form( player_name, get_formspec( ) )
		end
	end

	-- basic sanity check for proper inputs
	if not book_scales[ scale ] then scale = config.default_book_scale end
	if not book_colors[ color ] then color = config.default_book_color end
	if page_idx < 1 or page_idx > #pages then page_idx = 1 end

	minetest.create_form( nil, player_name, get_formspec( ), on_close, is_preview and minetest.FORMSPEC_SIGSTOP or nil )
end

function open_book_editor( player_name, oldtime, owner, title, scale, style, color, pages, page_idx, vars )

	local function sanitize( buf )
		return string.trim( string.gsub( buf, ".", { ["\r"] = "\n", ["\t"] = " ", ["\f"] = "?", ["\b"] = "?" } ) ) .. "\n"
	end

	local function get_formspec( )
		local book_scales = { "small", "large", "tall", "wide" }
		local book_colors = { "gray", "brown", "teal", "purple", "olive", "indigo", "maroon", "red", "green", "blue" }
		local book_styles = { "plain", "fancy", "classic", "vintage" }

		-- book texture filenames:
		-- books_cover_<style>_<scale>.png
		-- books_pages_<style>_<scale>.png

		local message = pages[ page_idx ]

		local formspec =
			"size[10.5,10.0]" ..
			default.gui_bg ..
			default.gui_bg_img ..

			"label[0.0,0.1;Book Title:]" ..
			"field[1.7,0.2;9.1,1.0;title;;" .. fs( title ) .. "]" ..
			"textarea[0.3,1.2;10.5,6.7;message;Enter the message to display on the page (" .. config.max_book_content_length .. " character limit per book);" .. fs( message ) .. "]" ..

			"label[0.0,7.3;Book Color:]" ..
			"dropdown[1.6,7.2;1.8,1.0;color;" .. table.concat( book_colors, "," ) .. ";" .. table.get_index( book_colors, color, 1 ) .. ";false]" ..

			"label[3.5,7.3;Book Style:]" ..
			"dropdown[5.1,7.2;1.8,1.0;style;" .. table.concat( book_styles, "," ) .. ";" .. table.get_index( book_styles, style, 1 ) .. ";false]" ..

			"label[7.0,7.3;Book Scale:]" ..
			"dropdown[8.6,7.2;1.8,1.0;scale;" .. table.concat( book_scales, "," ) .. ";" .. table.get_index( book_scales, scale, 1 ) .. ";false]" ..

			"button[0.0,8.3;1.0,0.3;cover_page;|<<]" ..
			"button[1.0,8.3;1.0,0.3;prev_page;<<]" ..
			"button[2.0,8.3;1.0,0.3;next_page;>>]" ..
			"button[3.0,8.3;1.0,0.3;final_page;>>|]" ..
			"button[8.5,8.3;2.0,0.3;add_page;Add Page]" 

		if page_idx == 1 then
			formspec = formspec ..
				string.format( "label[4.5,8.2;Front Cover]", page_idx == 1 and "Cover" or ( "Page " .. page_idx - 1 ) )
		else
			formspec = formspec ..
				"button[6.5,8.3;2.0,0.3;del_page;Del Page]" ..
				string.format( "label[4.5,8.2;Page %d of %d]", page_idx - 1, #pages - 1 )
		end

		formspec = formspec ..
			"box[0.0,9.0;10.3,0.1;#111111]" ..
                        "button_exit[0.0,9.3;2.0,1.0;cancel;Cancel]" ..
                        "button[6.5,9.3;2.0,1.0;preview;Preview]" ..
                        "button_exit[8.5,9.3;2.0,1.0;publish;Publish]"

		return formspec
	end

	local function on_close( meta, player, fields )
		if fields.cancel or fields.quit then return end		-- no-op when quitting form

		if fields.preview or fields.publish then
			if not fields.message or not fields.title or not fields.color or not fields.scale or not fields.style then
				return
			elseif string.len( fields.message ) > config.max_book_message_length then
				minetest.chat_send_player( player_name, "The specified message is too long." )
				return
			elseif string.len( fields.title ) > config.max_book_title_length then
				minetest.chat_send_player( player_name, "The specified title too long." )
				return
			end
			pages[ page_idx ] = sanitize( fields.message )	-- update the respective page content before previewing
		end

		if fields.preview then
                        open_book_viewer( player_name, oldtime, owner, fields.title, fields.scale, fields.style, fields.color, pages, { }, page_idx, vars, true )

		elseif fields.publish then
			-- check that book content is within range
			local length = 0

			for i, v in ipairs( pages ) do
				length = length + string.len( v )
			end

			if length > config.max_book_content_length then
				minetest.chat_send_player( player_name, "The content is too long." )
			end

			-- save all changes to the itemstack meta
			local itemstack = player:get_wielded_item( )
			local player_inv = player:get_inventory( )
			local data = {
				oldtime = oldtime,
				owner = owner,
				scale = scale,
				style = style,
				color = color,
				title = title,
				pages = pages,
				marks = { },	-- editing clears bookmarks
			}

			if itemstack:get_name( ) == "default:book" then
				itemstack:take_item( 1 )	-- take from unwritten books
				player:set_wielded_item( itemstack )					

				itemstack = ItemStack( "default:book_written" )		-- get reference to new stack
				safety_deposit.encrypt_metadata( itemstack, data )

				if player_inv:room_for_item( "main", itemstack ) then
					player_inv:add_item( "main", itemstack )
				else
					minetest.add_item( player:getpos( ), itemstack )
				end
			else
				safety_deposit.encrypt_metadata( itemstack, data )
				player:set_wielded_item( itemstack )					
			end

			minetest.log( "action", player_name .. " wrote " .. length .. " bytes to a book titled \"" .. string.gsub( fields.title, "[\n\t]", "" ) .. "\"" )
			minetest.chat_send_player( player_name, "Your book was successfully published!" )

		elseif fields.cover_page then
			if page_idx > 1 then
				page_idx = 1
				minetest.update_form( player_name, get_formspec( ) )
			end

		elseif fields.final_page then
			if page_idx < #pages then
				page_idx = #pages
				minetest.update_form( player_name, get_formspec( ) )
			end

		elseif fields.next_page then
			if page_idx < #pages then
				page_idx = page_idx + 1
				minetest.update_form( player_name, get_formspec( ) )
			end

		elseif fields.prev_page then
			if page_idx > 1 then
				page_idx = page_idx - 1
				minetest.update_form( player_name, get_formspec( ) )
			end

		elseif fields.add_page then
			pages[ page_idx ] = fields.message

			table.insert( pages, page_idx + 1, "New Page" )
			page_idx = page_idx + 1
			minetest.update_form( player_name, get_formspec( ) )

		elseif fields.del_page then
			if page_idx > 1 then
				table.remove( pages, page_idx )
				page_idx = page_idx - 1
				minetest.update_form( player_name, get_formspec( ) )
			end

		elseif fields.color then
			color = fields.color

		elseif fields.style then
			style = fields.style

		elseif fields.scale then
			scale = fields.scale
		end
	end

	minetest.create_form( nil, player_name, get_formspec( ), on_close, minetest.FORMSPEC_SIGSTOP )
end

function open_paper_viewer( player_name, oldtime, owner, scale, style, color, subject, message, vars, is_preview )

	local paper_scales = {
		small = { width = 6.5, height = 9.0 },
		tall = { width = 6.5, height = 11.0 },
		large = { width = 8.0, height = 11.0 },
		wide = { width = 8.0, height = 9.0 },
	}
	local paper_colors = {
		gray = "#333333",
		brown = "#663300",
		teal = "#006633",
		purple = "#330066",
		olive = "#336600",
		indigo = "#003366",
		maroon = "#660033",
		red = "#660000",
		green = "#006600",
		blue = "#000066",
	}

	local function get_formspec( )
		local page_width = paper_scales[ scale ].width
		local page_height = paper_scales[ scale ].height

		local foot_x = ( page_width - 2.0 ) / 2			-- horz pos of footer
		local foot_y = page_height - 1.2			-- vert pos of footer

		local formspec =
			string.format( "size[%0.2f,%0.2f]", page_width, page_height ) ..
			default.gui_bg ..
			string.format( "background[0.0,0.0;%0.2f,%0.2f;%s;false]", page_width, page_height,
				fs( "paper_" .. style .. ".png^[colorize:" .. paper_colors[ color ] .. "66^[noalpha" ) ) ..
			string.format( "%s[%0.2f,%0.2f;2.0,1.0;close;Close]",
				is_preview and "button" or "button_exit", foot_x, foot_y )

		if subject ~= "" then
			formspec = formspec ..
				"label[0.5,0.5;From:]" ..
				"label[1.6,0.5;" .. owner .. "]" ..
				"label[0.5,1.0;Date:]" ..
				"label[1.6,1.0;" .. os.date( "%X", oldtime ) .. "]" ..
				"label[0.5,1.5;Subject:]" ..
				"label[1.6,1.5;" .. subject .. "]" ..
				string.format( "box[0.3,2.1;%0.2f,0.05;#FFFFFF]", page_width - 1.0 )
		end

       		local page_x1 = 0.5
	        local page_y1 = subject == "" and 0.5 or 2.4
       		local page_x2 = page_x1 + page_width - 1.0
        	local page_y2 = subject == "" and page_y1 + page_height - 1.3 or page_y1 + page_height - 3.7

		formspec = formspec ..
			markup.get_formspec_string( markup.parse_message( message, vars ),
				page_x1, page_y1, page_x2, page_y2, "#666666", "#CCCCCC" )

		return formspec
	end

	local function on_close( meta, player, fields )
		if fields.close then
			if is_preview then
				open_paper_editor( player_name, oldtime, owner, scale, style, color, subject, message, vars )
			end
		end
	end

	-- basic sanity check for proper inputs
	if not paper_scales[ scale ] then scale = config.default_paper_scale end
	if not paper_colors[ color ] then color = config.default_paper_color end

	minetest.create_form( nil, player_name, get_formspec( ), on_close, is_preview and minetest.FORMSPEC_SIGSTOP or nil )
end

function open_paper_editor( player_name, oldtime, owner, scale, style, color, subject, message, vars )

	local function sanitize( buf )
		return string.trim( string.gsub( buf, ".", { ["\r"] = "\n", ["\t"] = " ", ["\f"] = "?", ["\b"] = "?" } ) ) .. "\n"
	end

	local function get_formspec( )
		local paper_scales = { "small", "large", "tall", "wide" }
		local paper_colors = { "gray", "brown", "teal", "purple", "olive", "indigo", "maroon", "red", "green", "blue" }
		local paper_styles = { "plain1", "plain2", "fancy1", "fancy2", "fancy3", "fancy4", "classic1", "classic2", "vintage1", "vintage2", "vintage3", "vintage4" }

		local formspec =
			"size[10.5,9.5]" ..
			default.gui_bg ..
			default.gui_bg_img ..

			"label[0.0,0.1;Subject:]" ..
			"field[1.5,0.2;9.3,1.0;subject;;" .. fs( subject ) .. "]" ..
			"textarea[0.3,1.2;10.5,7.0;message;Enter the message to display on the page (" .. config.max_paper_message_length .. " character limit per paper);" .. fs( message ) .. "]" ..

			"label[0.0,7.6;Paper Color:]" ..
			"dropdown[1.6,7.5;1.8,1.0;color;" .. table.concat( paper_colors, "," ) .. ";" .. table.get_index( paper_colors, color, 1 ) .. ";false]" ..

			"label[3.5,7.6;Paper Style:]" ..
			"dropdown[5.1,7.5;1.8,1.0;style;" .. table.concat( paper_styles, "," ) .. ";" .. table.get_index( paper_styles, style, 1 ) .. ";false]" ..

			"label[7.0,7.6;Paper Scale:]" ..
			"dropdown[8.6,7.5;1.8,1.0;scale;" .. table.concat( paper_scales, "," ) .. ";" .. table.get_index( paper_scales, scale, 1 ) .. ";false]" ..

			"box[0.0,8.5;10.3,0.1;#111111]" ..
                        "button_exit[0.0,8.8;2.0,1.0;cancel;Cancel]" ..
                        "button[6.5,8.8;2.0,1.0;preview;Preview]" ..
                        "button_exit[8.5,8.8;2.0,1.0;publish;Publish]"

		return formspec
	end

	local function on_close( meta, player, fields )
		if fields.cancel then
			return

		elseif fields.preview or fields.publish then
			if not fields.message or not fields.subject or not fields.color or not fields.scale or not fields.style then
				return
			elseif string.len( fields.message ) > config.max_paper_message_length then
				minetest.chat_send_player( player_name, "The specified message is too long." )
				return
			elseif string.len( fields.subject ) > config.max_paper_subject_length then
				minetest.chat_send_player( player_name, "The specified subject is too long." )
				return
			end
			message = sanitize( fields.message )
		end

		if fields.preview then
                        open_paper_viewer( player_name, oldtime, owner, fields.scale, fields.style, fields.color, fields.subject, message, vars, true )

		elseif fields.publish then
			-- save all changes to the itemstack meta
			local itemstack = player:get_wielded_item( )
			local player_inv = player:get_inventory( )
			local data = {
				oldtime = oldtime,
				owner = owner,
				scale = scale,
				style = style,
				color = color,
				subject = subject,
				message = message,
				marks = { },	-- editing clears bookmarks
			}

			if itemstack:get_name( ) == "default:paper" then
				itemstack:take_item( 1 )	-- take from unwritten books
				player:set_wielded_item( itemstack )					

				itemstack = ItemStack( "default:paper_written" )		-- get reference to new stack
				safety_deposit.encrypt_metadata( itemstack, data )

				if player_inv:room_for_item( "main", itemstack ) then
					player_inv:add_item( "main", itemstack )
				else
					minetest.add_item( player:getpos( ), itemstack )
				end
			else
				safety_deposit.encrypt_metadata( itemstack, data )
				player:set_wielded_item( itemstack )					
			end

			minetest.log( "action", player_name .. " wrote " .. #message .. " bytes to a paper titled \"" .. string.gsub( fields.subject, "[\n\t]", "" ) .. "\"" )
			minetest.chat_send_player( player_name, "Your paper was successfully published!" )

		elseif fields.color then
			color = fields.color

		elseif fields.style then
			style = fields.style

		elseif fields.scale then
			scale = fields.scale
		end
	end

	minetest.create_form( nil, player_name, get_formspec( ), on_close, minetest.FORMSPEC_SIGSTOP )
end

local function open_default_book_editor( player_name, vars )
	local title = config.default_book_title
	local scale = config.default_book_scale
	local style = config.default_book_style
	local color = config.default_book_color

	open_book_editor( player_name, os.time( ), player_name, title, style, scale, color, { "" }, 1, vars )
end

local function open_default_paper_editor( player_name, vars )
	local subject = config.default_paper_subject
	local color = config.default_paper_color
	local style = config.default_paper_style
	local scale = config.default_paper_scale

	open_paper_editor( player_name, os.time( ), player_name, scale, style, color, subject, "", vars )
end

-----------------------

minetest.register_craftitem( ":default:book", {
	description = "Book",
	inventory_image = "default_book.png",
	groups = { book = 1, flammable = 3 },
	on_use = function ( itemstack, player )
		local player_name = player:get_player_name( )
		local vars = markup.get_builtin_vars( player_name )

		open_default_book_editor( player_name, vars )
		return itemstack
	end,
} )

minetest.register_craftitem( ":default:book_written", {
	description = "Book With Text (Sneak and Use to Edit)",
	inventory_image = "default_book_written.png",
	groups = { book = 1, not_in_creative_inventory = 1, flammable = 3 },
	stack_max = 1,
	on_use = function ( itemstack, player )
		local player_name = player:get_player_name( )
		local data = safety_deposit.decrypt_metadata( itemstack )
		local vars = markup.get_builtin_vars( player_name )

		if not data then
			-- apparently book is empty, so let's start fresh
			open_default_book_editor( player_name, vars )
			return itemstack
		end

		local oldtime = data.oldtime
		local owner = data.owner
		local title = data.title
		local scale = data.scale
		local style = data.style
		local color = data.color
		local pages = data.pages
		local marks = data.marks

		-- if book format is obsolete, then open the compatibility viewer
		if not pages and data.owner and data.title and data.text then
			open_defbook_viewer( player_name, data.owner, data.title, data.text, data.page, data.page_max )
			return itemstack

		elseif not oldtime or not owner or not title or not scale or not style or not color or not pages or not marks then
			minetest.chat_send_player( player_name, "This book is corrupted and cannot be opened." )
			return itemstack
		end

		if player:get_player_control( ).sneak and owner == player_name then
			open_book_editor( player_name, oldtime, owner, title, scale, style, color, pages, 1, vars )
		else
			open_book_viewer( player_name, oldtime, owner, title, scale, style, color, pages, marks, 1, vars )
		end

		return itemstack
	end,
} )

minetest.register_craftitem( ":default:paper", {
	description = "Paper",
	inventory_image = "default_paper.png",
	groups = { flammable = 3 },

	on_use = function ( itemstack, player )
		local player_name = player:get_player_name( )
		local vars = markup.get_builtin_vars( player_name )

		open_default_paper_editor( player_name, vars )
		return itemstack
	end,
} )

minetest.register_craftitem( ":default:paper_written", {
	description = "Paper With Text (Sneak and Use to Edit)",
	inventory_image = "default_paper.png^default_paper_written.png",
	groups = { book = 1, not_in_creative_inventory = 1, flammable = 3 },
	stack_max = 1,
	on_use = function ( itemstack, player )
		local player_name = player:get_player_name( )
		local data = safety_deposit.decrypt_metadata( itemstack )
		local vars = markup.get_builtin_vars( player_name )

		if not data then
			-- apparently paper is empty, so let's start fresh
			open_default_paper_editor( player_name, vars )
			return itemstack
		end

		local oldtime = data.oldtime
		local owner = data.owner
		local scale = data.scale
		local style = data.style
		local color = data.color
		local subject = data.subject
		local message = data.message

		if not oldtime or not owner or not scale or not style or not color or not subject or not message then
			minetest.chat_send_player( player_name, "This paper is corrupted and cannot be opened." )
			return itemstack
		end

		if player:get_player_control( ).sneak and owner == player_name then
			open_paper_editor( player_name, oldtime, owner, scale, style, color, subject, message, vars )
		else
			open_paper_viewer( player_name, oldtime, owner, scale, style, color, subject, message, vars )
		end

		return itemstack
	end,
} )
