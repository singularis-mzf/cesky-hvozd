local internal = ...

-- local ifthenelse = ch_core.ifthenelse
local F = core.formspec_escape
-- local c_width = assert(internal.container_width)
-- local c_height = assert(internal.container_height)

--[[
    Pokud si daný hráč/ka může dovolit nový kontejner, vrací částku, kterou ho to bude stát.
    (může být 0). Pokud si nový kontejner nemůže dovolit vůbec, vrací: nil, error_message
]]
local function get_container_price(player_name)
    assert(player_name ~= nil and player_name ~= "")
    local player_role = ch_core.get_player_role(player_name)
    if player_role == "new" then
        return nil, "Turistické postavy nemohou zakládat osobní herní kontejnery."
    end
    local offline_charinfo = ch_data.offline_charinfo[player_name]
    if offline_charinfo == nil then
        return nil, "Nejsou dostupná data postavy."
    end
    local level = offline_charinfo.ap_level or 1
    local current_containers = internal.get_containers(player_name)
    if current_containers == nil then
        return nil, "Nejsou dostupná data kontejnerů."
    end
    if #current_containers >= level and player_role ~= "admin" then
        return nil, "Máte úroveň "..level..", a proto můžete mít nejvýše "..level.." kontejnerů. Nyní máte "..#current_containers.." kontejnerů."
    end
    if #current_containers < 4 then
        return 0 -- první čtyři kontejnery jsou zdarma
    end
    return #current_containers * 1000
end

local function generate_container_list(player_name, player_role, only_mine)
    local containers
    if only_mine then
        containers = internal.get_container_list(player_name, false)
    elseif player_role ~= "admin" then
        containers = internal.get_container_list(player_name, true)
    else
        containers = internal.get_container_list()
    end
    local viewname_cache = {}
    local list = {}
    for i, cont in ipairs(containers) do
        local viewname = viewname_cache[cont.owner]
        if viewname == nil then
            viewname = F(ch_core.prihlasovaci_na_zobrazovaci(cont.owner))
            viewname_cache[cont.owner] = viewname
        end
        local comment = "" -- TODO: public containers
        if player_role == "admin" then
            local info = internal.get_basic_info(cont.id)
            comment = core.pos_to_string(info.pos).." "..comment
        end
        list[i] = {
            index = assert(cont.index),
            id = assert(cont.id),
            fs_name = F(assert(cont.name)),
            owner = cont.owner,
            fs_owner_viewname = viewname,
            color = "#ffffff", -- TODO: barvy
            fs_comment = F(comment),
        }
    end
    return list
end

local get_list_formspec, get_control_formspec, get_create_formspec
local list_formspec_callback, control_formspec_callback, create_formspec_callback

get_list_formspec = function(custom_state)
    assert(custom_state.player_name)
    assert(custom_state.selected_id)
    assert(custom_state.message)
    assert(custom_state.only_mine)
    local player_name = custom_state.player_name
    local player = core.get_player_by_name(player_name)
    if player == nil then return "" end
    local player_role = ch_core.get_player_role(player_name)

    local list = custom_state.list

    if list == nil then
        list = generate_container_list(player_name, player_role, custom_state.only_mine == "true")
        custom_state.list = list
    end

    local formspec = {
        ch_core.formspec_header({formspec_version = 6, size = {20, 11.5}, auto_background = true}),
        "label[0.5,0.6;Osobní herní kontejnery]"..
        "tablecolumns[color,span=4;text;text,width=12;text;text]"..
        "table[0.5,1.25;19,5;containers;#ffffff,POŘ.,NÁZEV,VLASTNÍ,POZNÁMKA",
    }
    local selected_index, selected_container
    for i, record in ipairs(list) do
        table.insert(formspec, ","..record.color..","..record.index..","..record.fs_name..","..record.fs_owner_viewname..","..record.fs_comment)
        if record.id == custom_state.selected_id then
            selected_index = i
        end
    end
    if selected_index ~= nil then
        table.insert(formspec, ";"..(selected_index + 1).."]")
        selected_container = list[selected_index]
    else
        table.insert(formspec, ";]")
    end
    table.insert(formspec,
        "button_exit[18.75,0.3;0.75,0.75;close;X]"..
        "checkbox[6.25,0.75;only_mine;jen moje kontejnery;"..custom_state.only_mine.."]"
    )
    if get_container_price(player_name) then
        table.insert(formspec, "button[14.5,0.3;3.5,0.75;create;nový kontejner...]")
    end

    if selected_container ~= nil then
        if player_role == "admin" or custom_state.player_name == selected_container.owner then
            table.insert(formspec,
                "field[0.5,7;6.75,0.75;name;název:;"..selected_container.fs_name.."]"..
                "button[7.5,7;3.25,0.75;savename;uložit název]"..
                "button[7.5,8;3.25,1.25;public;veřejný vstup\nna minutu]"..
                "button[11,6.5;3.5,0.75;upup;jako první (^^)]"..
                "button[11,7.25;3.5,0.75;up;posunout výš (^)]"..
                "button[11,8;3.5,0.75;down;posunout níž (v)]"..
                "button[11,8.75;3.5,0.75;downdown; jako poslední (vv)]"..
                "button[11,8;3.5,0.75;down;posunout níž (v)]")
        else
            table.insert(formspec,
                "label[0.5,7;název:\n"..selected_container.fs_name.."]")
        end
        if player_role == "admin" then
            table.insert(formspec,
                "button[10.5,0.3;3.5,0.75;set_free;uvolnit kontejner]"..
                "field[0.5,8.5;4,0.75;owner;spravuje:;"..selected_container.fs_owner_viewname.."]")
        else
            table.insert(formspec,
                "label[0.5,8.5;spravuje:\n"..selected_container.fs_owner_viewname.."]")
        end
        if
            player_role == "admin" or
            custom_state.player_name == selected_container.owner or
            internal.is_public_container(selected_container.id, 1)
        then -- nebo je kont. veřejný
            table.insert(formspec, "button[15,7;4.5,0.75;enter_container;vstoupit do kontejneru]")
        end
    end
    if player ~= nil and internal.get_container_id(player:get_pos()) ~= nil then
        table.insert(formspec, "button_exit[15,8;4.5,0.75;return;vrátit se na hlavní nádraží]")
    end
    if custom_state.message ~= "" then
        table.insert(formspec, "label[0.5,10;"..F(custom_state.message).."]")
    end
    return table.concat(formspec)
end



get_control_formspec = function(custom_state)
    assert(custom_state.player_name)
    assert(custom_state.container_id)
    assert(custom_state.message ~= nil)
    local info = internal.get_basic_info(custom_state.container_id)
    if info == nil then
        return "" -- ERROR!
    end
    local formspec = {
        ch_core.formspec_header({formspec_version = 6, size = {20, 11.5}, auto_background = true}),
        "label[0.5,0.6;Ovládací panel kontejneru: "..F(info.name).."]"..
        "button[14,0.3;4,0.75;tolist;moje kontejnery...]"..
        "button_exit[18.75,0.3;0.75,0.75;close;X]"..
        "field[0.5,1.75;6.75,0.75;name;název:;"..F(info.name).."]"..
        "button[7.5,1.75;3.25,0.75;savename;uložit název]",
    }
    -- admin, owner or other?
    local is_admin = ch_core.get_player_role(custom_state.player_name) == "admin"
    -- local is_owner = info.owner == custom_state.player_name

    if is_admin then
        table.insert(formspec, "field[11,1.75;4,0.75;owner;spravuje:;"..ch_core.prihlasovaci_na_zobrazovaci(info.owner).."]")
    else
        table.insert(formspec, "label[11,1.75;spravuje:\n"..ch_core.prihlasovaci_na_zobrazovaci(info.owner).."]")
    end

    --[[
    if is_admin or is_owner then
        table.insert(formspec, "button[16,7.75;3.5,0.75;dig;vyklidit kontejner]")
    end
    ]]

    table.insert(formspec, "button_exit[0.5,10.25;19,1;return;vrátit se na hlavní nádraží]")

    if custom_state.message ~= "" then
        table.insert(formspec, "label[0.5,9;"..F(custom_state.message).."]")
    end
    return table.concat(formspec)
end



get_create_formspec = function(custom_state)
    local player_name = assert(custom_state.player_name)
    local formspec = {
        ch_core.formspec_header({formspec_version = 6, size = {12.25, 5.25}, auto_background = true}),
        "label[0.5,0.6;Nový kontejner]"..
        "button_exit[11,0.3;0.75,0.75;close;X]"..
        "field[0.5,1.75;6.75,0.75;name;název:;]"..
        "button[0.5,4;4,0.75;create;vytvořit]"..
        "button[5,4;4,0.75;cancel;zrušit]",
    }
    if ch_core.get_player_role(player_name) == "admin" then
        table.insert(formspec, "field[7.5,1.75;4.25,0.75;owner;spravuje:;"..
            ch_core.prihlasovaci_na_zobrazovaci(player_name).."]")
    else
        table.insert(formspec, "label[7.5,1.75;spravuje:\n"..ch_core.prihlasovaci_na_zobrazovaci(player_name).."]")
    end
    local price, error_message = get_container_price(player_name)
    if not price then
        table.insert(formspec, "label[0.5,3;Chyba: "..F(error_message or "Neznámá chyba").."]")
    elseif price == 0 then
        table.insert(formspec, "label[0.5,3;Cena: zdarma (první čtyři kontejnery jsou zdarma)]")
    else
        table.insert(formspec, "label[0.5,3;Cena: "..F(ch_core.formatovat_castku(price)).."]")
    end
    return table.concat(formspec)
end



local function find_selected_container(custom_state)
    --[[
        pro list_formspec_callback; v případě úspěchu vrací:
        {
            id = string, -- ID vybraného kontejneru
            owner_data = table, -- tabulku dat pro vlastníka/ici daného kontejneru
            cont_data = table, -- záznam vybraného kontejneru v owner_data
            owner = string, -- jméno vlastníka/ice kontejneru
            index = int, -- index kontejneru v owner_data
            list_index = int, -- index kontejneru v custom_state.list
        }
        v případě neúspěchu vrací nil
    ]]
    assert(custom_state.player_name)
    if custom_state.list == nil then
        custom_state.list = generate_container_list(
            custom_state.player_name,
            ch_core.get_player_role(custom_state.player_name),
            custom_state.only_mine == "true")
    end

    local selected_id = assert(custom_state.selected_id)
    for list_index, list_record in ipairs(custom_state.list) do
        if list_record.id == selected_id then
            local owner = list_record.owner
            local data = internal.get_containers(owner)
            if data ~= nil then
                for i, cont_data in ipairs(data) do
                    if cont_data.id == selected_id then
                        return {
                            id = cont_data.id,
                            owner_data = data,
                            cont_data = cont_data,
                            owner = owner,
                            index = i,
                            list_index = list_index,
                        }
                    end
                end
            end
        end
    end
end

list_formspec_callback = function(custom_state, player, formname, fields)
    local player_name = custom_state.player_name
    local player_role = ch_core.get_player_role(player)
    local is_admin = player_role == "admin"
    local sel_info = find_selected_container(custom_state)
    local is_owner = sel_info ~= nil and sel_info.owner == player_name
    local update_formspec = false
    local success, error_message, table_event
    if fields.containers then
        table_event = core.explode_table_event(fields.containers)
        if table_event.type == "CHG" or table_event.type == "DCL" then
            local new_selected_container = custom_state.list[table_event.row - 1]
            local new_selected_id = ""
            if new_selected_container ~= nil then
                new_selected_id = assert(new_selected_container.id)
            end
            local old_selected_id = custom_state.selected_id
            custom_state.selected_id = new_selected_id
            if table_event.type == "CHG" and old_selected_id ~= new_selected_id then
                return get_list_formspec(custom_state)
            end
        end
    end
    if fields.only_mine and fields.only_mine ~= custom_state.only_mine then
        update_formspec = true
        custom_state.only_mine = fields.only_mine
        custom_state.list = generate_container_list(player_name, player_role, custom_state.only_mine == "true")
    end
    if fields["return"] then
        success, error_message = internal.leave_container(player, {delay = 3.0})
        if not success then
            ch_core.systemovy_kanal(player_name, "CHYBA: "..(error_message or "Neznámá chyba"))
        end
        return
    end
    if fields.create and player_role ~= "new" then
        local offline_charinfo = assert(ch_data.offline_charinfo[player_name])
        local current_containers_count = internal.get_container_count(player_name)
        if current_containers_count < offline_charinfo.ap_level then
            -- ch_core.show_formspec(player_or_player_name, formname, formspec, formspec_callback, custom_state, options)
            -- local function formspec_callback(custom_state, player, formname, fields)
            custom_state = {
                player_name = player_name,
            }
            ch_core.show_formspec(player, "ch_containers:create", get_create_formspec(custom_state), create_formspec_callback, custom_state, {})
            return
        else
            custom_state.message = "Máte úroveň "..offline_charinfo.ap_level..", takže můžete mít nanejvýš "..offline_charinfo.ap_level..
                " vlastních kontejnerů."
                update_formspec = true
        end
    elseif fields.savename and player_role ~= "new" and custom_state.selected_id ~= "" then
        -- najít stávající kontejner v seznamu
        if sel_info == nil then
            return -- žádný kontejner není vybraný
        end
        success, error_message = internal.set_properties(sel_info.id, {name = fields.name, owner = fields.owner}, player_name)
        custom_state.list = nil
        if success then
            custom_state.message = "Úspěšně nastaveno."
        else
            custom_state.message = "CHYBA: "..(error_message or "Neznámá chyba")
        end
        update_formspec = true

    elseif fields.up or fields.down or fields.upup or fields.downdown then
        -- najít stávající kontejner v seznamu
        if sel_info == nil then
            return -- žádný kontejner není vybraný
        end
        if not is_owner and not is_admin then
            return -- nemá právo nastavit
        end
        custom_state.list = nil
        local owner_data = sel_info.owner_data
        if fields.up and sel_info.index ~= 1 then
            local x = owner_data[sel_info.index - 1]
            owner_data[sel_info.index - 1] = owner_data[sel_info.index]
            owner_data[sel_info.index] = x
        elseif fields.down and sel_info.index ~= #owner_data then
            local x = assert(owner_data[sel_info.index + 1])
            owner_data[sel_info.index + 1] = owner_data[sel_info.index]
            owner_data[sel_info.index] = x
        elseif fields.upup and sel_info.index ~= 1 then
            table.insert(owner_data, 1, owner_data[sel_info.index])
            table.remove(owner_data, sel_info.index + 1)
        elseif fields.downdown and sel_info.index ~= #owner_data then
            table.insert(owner_data, owner_data[sel_info.index])
            table.remove(owner_data, sel_info.index)
        else
            return
        end
        custom_state.list = nil
        update_formspec = true

    elseif fields.enter_container or (table_event ~= nil and table_event.type == "DCL") then
        if sel_info ~= nil then
            if
                not is_admin and
                player_name ~= sel_info.owner and
                not internal.is_public_container(sel_info.id)
            then
                custom_state.message = "CHYBA: Do tohoto kontejneru nemáte přístup!"
            else
                success, error_message = internal.enter_container(sel_info.id, player, {delay = 3.0})
                if success then
                    fields.quit = "true"
                    core.close_formspec(player_name, formname)
                    return
                else
                    custom_state.message = "CHYBA: "..(error_message or "Neznámá chyba")
                end
            end
        end
        update_formspec = true

    elseif (is_owner or is_admin) and fields.public and sel_info ~= nil then
        success, error_message = internal.set_properties(sel_info.id, {public_until = core.get_us_time() + 60000000}, player_name)
        if success then
            custom_state.message = "Nastaveno. Kontejner je nyní minutu veřejně přístupný."
        else
            custom_state.message = "CHYBA: "..(error_message or "Neznámá chyba")
        end
        update_formspec = true

    elseif is_admin and fields.set_free then
        if sel_info ~= nil then
            success, error_message = internal.release_container(sel_info.id)
            if success then
                custom_state.message = "Kontejner uvolněn."
            else
                custom_state.message = "CHYBA: "..(error_message or "Neznámá chyba")
            end
            custom_state.list = nil
        end
        update_formspec = true
    end

    if update_formspec then
        return get_list_formspec(custom_state)
    end
end



control_formspec_callback = function(custom_state, player, formname, fields)
    local container_info = internal.get_basic_info(custom_state.container_id)
    if container_info == nil then
        return
    end
    local player_name = player:get_player_name()
    local is_admin = ch_core.get_player_role(player)
    local is_owner = player_name == container_info.owner
    if fields.tolist then
        custom_state = {
            only_mine = "true",
            message = "",
            player_name = custom_state.player_name,
            selected_id = custom_state.container_id,
        }
        ch_core.show_formspec(player, "ch_containers:list", get_list_formspec(custom_state), list_formspec_callback, custom_state, {})
        return
    elseif fields.savename and (is_owner or is_admin) then
        local success, error_message = internal.set_properties(
            custom_state.container_id, {name = fields.name, owner = fields.owner}, player_name)
        if success then
            custom_state.message = "Úspěšně nastaveno."
        else
            custom_state.message = "CHYBA: "..(error_message or "Neznámá chyba")
        end
        return get_control_formspec(custom_state)
    elseif fields["return"] then
        local success, error_message = internal.leave_container(player, {delay = 3.0})
        if not success then
            custom_state.message = "CHYBA: "..(error_message or "Neznámá chyba")
            return get_control_formspec(custom_state)
        else
            return
        end
    --[[
    elseif fields.dig then
        fields.quit = "true"
        core.close_formspec(custom_state.player_name, formname)
        -- TODO...
        -- ch_core.systemovy_kanal(custom_state.player_name, "*** Zatím není implementováno.")
        local subtasks = internal.assembly_subtasks(container_info.pos, vector.offset(container_info.pos, c_width - 1, c_height - 1, c_width - 1))
        if subtasks ~= nil then
            internal.add_digtask(player_name, subtasks)
        end
        return
        ]]
    end
end



create_formspec_callback = function(custom_state, player, formname, fields)
    local player_role = ch_core.get_player_role(player)
    if player_role == "new" then
        return
    end
    if fields.create then
        local player_name = custom_state.player_name
        local price, error_message = get_container_price(player_name)
        local is_admin = ch_core.get_player_role(player_name) == "admin"
        local new_owner
        if not is_admin and not price then
            custom_state = {
                only_mine = "false",
                player_name = player_name,
                selected_id = "",
                message = "CHYBA: "..(error_message or "Neznámá chyba"),
            }
            ch_core.show_formspec(player, "ch_containers:list", get_list_formspec(custom_state), list_formspec_callback, custom_state, {})
            return
        end
        if is_admin then
            if fields.owner then
                new_owner = ch_core.jmeno_na_prihlasovaci(fields.owner)
                if ch_data.offline_charinfo[new_owner] == nil then
                    ch_core.systemovy_kanal(player_name, "Postava "..fields.owner.." neexistuje!")
                    return
                end
            end
        else
            new_owner = player_name
            if price ~= 0 and not ch_core.pay_from(player_name, price, {simulation = true, silent = true}) then -- label =
                local s = ch_core.formatovat_castku(price)
                ch_core.systemovy_kanal(player_name, "Platba "..s.." za zřízení kontejneru selhala! Možná nemáte dost peněz.")
                return
            end
        end

        local new_container_id
        new_container_id, error_message = internal.create_new_container(new_owner, fields.name or "")
        custom_state = {
            only_mine = "false",
            player_name = player_name,
            selected_id = new_container_id or "",
        }
        if new_container_id == nil then
            custom_state.message = "CHYBA: "..(error_message or "Vytváření kontejneru selhalo")
        else
            if not is_admin and price ~= nil and price > 0 then
                ch_core.pay_from(player_name, price, {label = "zřízení osobního herního kontejneru"})
            end
            custom_state.message = "Kontejner byl úspěšně vytvořen."
        end
        ch_core.show_formspec(player, "ch_containers:list", get_list_formspec(custom_state), list_formspec_callback, custom_state, {})
        return
    elseif fields.cancel then
        custom_state = {
            message = "",
            only_mine = "false",
            player_name = custom_state.player_name,
            selected_id = "",
        }
        ch_core.show_formspec(player, "ch_containers:list", get_list_formspec(custom_state), list_formspec_callback, custom_state, {})
    end
end



function internal.cp_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
    if clicker ~= nil and core.is_player(clicker) and pointed_thing.type == "node" then
        local custom_state = {
            container_id = internal.get_container_id(assert(pointed_thing.above)),
            message = "",
            player_name = assert(clicker:get_player_name()),
        }
        if custom_state.container_id == nil then
            core.log("error", "cp_on_rightclick() at "..core.pos_to_string(pos)..": container id not found for "..
                core.pos_to_string(pointed_thing.above).."! "..dump2({pointed_thing = pointed_thing}))
            core.chat_send_player(custom_state.player_name,
                "*** Vnitřní chyba, data kontejneru nenalezena. Nahlaste prosím tuto chybu Administraci.")
            return
        end
        ch_core.show_formspec(clicker, "ch_containers:control_panel", get_control_formspec(custom_state), control_formspec_callback, custom_state, {})
    end
end



function internal.ap_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
    if clicker ~= nil and core.is_player(clicker) then
        local custom_state = {
            message = "",
            only_mine = "false",
            player_name = assert(clicker:get_player_name()),
            selected_id = "",
        }
        ch_core.show_formspec(clicker, "ch_containers:access_point", get_list_formspec(custom_state), list_formspec_callback, custom_state, {})
    end
end
