local internal = ...

local ifthenelse = ch_core.ifthenelse
local F = minetest.formspec_escape

local function get_list_formspec(custom_state)
    assert(custom_state.player_name)
    assert(custom_state.selection_index)
    local player_name = custom_state.player_name
    local player = core.get_player_by_name(player_name)
    local player_role = ch_core.get_player_role(player_name) == "admin"
    local formspec = {
        ch_core.formspec_header({formspec_version = 6, size = {20, 11.5}, auto_background = true}),
        "label[0.5,0.6;Osobní herní kontejnery]"..
        "tablecolumns[color,span=4;text;text,width=12;text;text]"..
        "table[0.5,1.25;19,5;linevar;#ffffff,POŘ.,NÁZEV,VLASTNÍ,POZNÁMKA",
    }
    local containers = internal.get_container_list(player_name)
    local viewname_cache = {}
    for i, cont in ipairs(containers) do
        local viewname = viewname_cache[cont.owner]
        if viewname == nil then
            viewname = ch_core.prihlasovaci_na_zobrazovaci(cont.owner)
            viewname_cache[cont.owner] = viewname
        end
        table.insert(formspec, ",#ffffff,"..i..","..F(cont.name)..","..F(viewname..","))
    end
    table.insert(formspec, ";"..custom_state.selection_index.."]"..
        "button_exit[18.75,0.3;0.75,0.75;close;X]")

    local selected_container = containers[custom_state.selection_index - 1]

    if selected_container ~= nil then
        if player_role == "admin" or custom_state.player_name == selected_container.owner then
            table.insert(formspec,
                "field[0.5,7;6.75,0.75;name;název:;"..F(selected_container.name).."]"..
                "button[7.5,7;3.25,0.75;savename;uložit název]"..
                "button[11,7;3.5,0.75;up;posunout výš (^)]"..
                "button[11,8;3.5,0.75;down;posunout níž (v)]")
        end
        if player_role == "admin" then
            table.insert(formspec,
                "button[10.5,0.3;3.5,0.75;set_free;uvolnit kontejner]"..
                "field[0.5,8.5;4,0.75;owner;spravuje:;"..ch_core.prihlasovaci_na_zobrazovaci(selected_container.owner).."]")
        else
            table.insert(formspec,
                "label[0.5,8.5;spravuje:\n"..ch_core.prihlasovaci_na_zobrazovaci(selected_container.owner).."]")
        end
        if player_role == "admin" or custom_state.player_name == selected_container.owner then -- nebo je kont. veřejný
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

local function get_control_formspec(custom_state)
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
    local is_owner = info.owner == custom_state.player_name

    if is_admin then
        table.insert(formspec, "field[11,1.75;4,0.75;owner;spravuje:;"..ch_core.prihlasovaci_na_zobrazovaci(info.owner).."]")
    else
        table.insert(formspec, "label[11,1.75;spravuje:\n"..ch_core.prihlasovaci_na_zobrazovaci(info.owner).."]")
    end

    if is_admin or is_owner then
        table.insert(formspec, "button[16,7.75;3.5,0.75;dig;vyklidit kontejner]")
    end

    table.insert(formspec, "button[0.5,10.25;19,1;return;vrátit se na hlavní nádraží]")

    if custom_state.message ~= "" then
        table.insert(formspec, "label[0.5,9;"..F(custom_state.message).."]")
    end
    return table.concat(formspec)
end

local function get_create_formspec(custom_state)
    assert(custom_state.player_name)
    local formspec = {
        ch_core.formspec_header({formspec_version = 6, size = {12.25, 5.25}, auto_background = true}),
        "label[0.5,0.6;Nový kontejner]"..
        "button_exit[11,0.3;0.75,0.75;close;X]"..
        "field[0.5,1.75;6.75,0.75;name;název:;]"..
        "button[0.5,4;4,0.75;create;vytvořit]"..
        "button[5,4;4,0.75;cancel;zrušit]",
    }
    if ch_core.get_player_role(custom_state.player_name) == "admin" then
        table.insert(formspec, "field[7.5,1.75;4.25,0.75;owner;spravuje:;"..
            ch_core.prihlasovaci_na_zobrazovaci(custom_state.player_name).."]")
    else
        table.insert(formspec, "label[7.5,1.75;spravuje:\n"..ch_core.prihlasovaci_na_zobrazovaci(custom_state.player_name).."]")
    end
    table.insert(formspec, "label[0.5,3;Cena: zdarma (první čtyři kontejnery jsou zdarma)]") -- TODO
    return table.concat(formspec)
end

local function list_formspec_callback(custom_state)
end

local function get_create_formspec()
end

function internal.cp_on_rightclick()
end

function internal.ap_on_rightclick()
end
