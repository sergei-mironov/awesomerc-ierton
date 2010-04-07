-- Author: Sergey Mironov ierton@gmail.com
-- License: BSD3
-- 2009-2010
--
-- Library allows user to bind GNU Screen style 'chords'

local awful = require("awful")
local naughty = require("naughty")
local mouse = mouse

local capi = {
	root = root,
}

local table = table
local ipairs = ipairs
local tostring = tostring

module("myrc.keybind")


local the_chord = nil

local function get_keys(c)
    if c == nil then
        return capi.root.keys()
    else
        return c:keys()
    end
end

local function set_keys(c, k)
    if c == nil then
        capi.root.keys(k)
    else
        c:keys(k)
    end
end

local function dbg(m)
    naughty.notify({
        title = "[Warning]",
        text = m,
        timeout = 10,
        position = "bottom_left",
    })
end

local function remove_a_key(k, tbl)
    for pos,x in ipairs(tbl) do
        if x.key == k.key and #x.modifiers == #k.modifiers then
            local match = true
            for i=1, #x.modifiers do
                if x.modifiers[i] ~= k.modifiers[i] then
                    match = false
                    break
                end
            end
            if match then
                table.remove(tbl,pos)
                return
            end
        end
    end

    dbg("Can't find a key: " .. k.keysym)
end

local function chord_release(ch)
    local allkeys = get_keys(ch.client)
    for _,kt in ipairs(ch.keytable) do
        for _,k in ipairs(kt.keys) do
            remove_a_key(k,allkeys)
        end
    end

    set_keys(ch.client, allkeys)

    if ch.menu then
        awful.menu.hide(ch.menu)
        ch.menu = nil
    end

    if ch.naughtybox then
        naughty.destroy(ch.naughtybox)
        ch.naughtybox = nil
    end
end

-- Cancels current chord, if any
function pop()
    if the_chord ~= nil then
        chord_release(the_chord)
        the_chord = nil
    end
end

local function chord_new(kt, title, c)
    local newkeys = nil
    local chord = {}
    local old = nil
    for _, k in ipairs(kt) do
        if #k < 3 then
            dbg("Invalid chord key detected after:" .. old.keysym)
        end
        k.keys = awful.key(k.mod, k.keysym, function()
            k.press()
            if k.finish then pop() end
        end)
        newkeys = awful.util.table.join(newkeys, k.keys)
        old = k
    end

    local allkeys = get_keys(c)
    for _,k in ipairs(newkeys) do
        table.insert(allkeys, k)
    end
    set_keys(c, allkeys)

    chord.client = c
    chord.keytable = kt
    chord.title = title
    return chord
end

-- This function shows menu at position {x, y} aka menu_coord
-- kg is keygrabber (true/false)
local function show_at(menu, kg)
    local old_coords = mouse.coords()
    local menu_coords = old_coords
    if menu.x then menu_coords.x = menu.x end
    if menu.y then menu_coords.y = menu.y end
    mouse.coords(menu_coords)
    awful.menu.show(menu, kg)
    mouse.coords(old_coords)
end

function chord_show_menu(keytable, template)

    local template = template or {}
    local menu_items = {}

    for _, k in ipairs(keytable) do
        table.insert(menu_items, 
            {tostring(k.keysym) .. ": " .. k.desc, k.press})
    end

    template.items = menu_items

    local m = awful.menu.new(template)
    m.x = template.x
    m.y = template.y
    m.show = show_at
    m:show()
    return m
end

function chord_naughty(keytable, title, template)
    local description = ""
    local template = template or {}
    for _, k in ipairs(keytable) do
        -- TODO: Take modifiers into account when 
        -- generating descriptions
        description = description .. 
        "\n" .. tostring(k.keysym) ..  
        ": " ..  ( k.desc or "<no_description>" )
    end

    template.title = title
    template.text = description
    return naughty.notify(template)
end

-- Function inserts keys from table 'keytable'
-- into client's keys(). Then it pops naughtybox 
-- showing chord description.
--
-- title: naughty's title
-- keytable: keys to be mapped
-- c: client. if nil, global keys will be used.
--
-- Note: 
-- 1) User has to call pop() manually to cancel 
-- current chord, or push() to start another chord.
-- 2) User has to use keybind.key() instead of awful.key()
-- to build 'keytable' table
function push(title, keytable, c)
    pop()
    the_chord = chord_new(keytable, title, c)
    return the_chord
end

function push_menu(title, keytable, c, template)
    local chord = push(title, keytable, c)
    local menu = chord_show_menu(keytable, template)
    menu.hide = function(m)
        awful.menu.hide(m)
        pop()
    end
    chord.menu = menu
    return chord
end

function push_naughty(title, keytable, c, template)
    local chord = push(title, keytable, c)
    local nb = chord_naughty(chord, template)
    chord.naughtybox = nb
    return chord
end

-- User should use this function inside push()
-- to build chord table
function key(kt)
    kt.mod = kt.mod or kt[1]
    if kt.mod == nil then return {} end
    kt.keysym = kt.keysym or kt[2]
    if kt.keysym == nil then return {} end
    kt.desc = kt.desc or kt[3] or "<no description>"
    kt.press = kt.press or kt[4]
    if kt.press == nil then return {} end
    kt.finish = kt.finish or false
    return kt
end

