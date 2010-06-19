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


local active = nil

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
    if active ~= nil then
        chord_release(active)
        active = nil
    end
end

local function mod(k) return k[1] end
local function keysym(k) return k[2] end
local function desc(k) return k[3] or "<no description>" end
local function press(k) return k[4] end
local function icon(k) return k[5] end

local function chord_new(keytable, c)
    local newkeys = nil
    local chord = {}
    local old = {}
    for _, k in ipairs(keytable) do
        if #k < 3 then
            dbg("Invalid chord key detected after:" .. keysym(old))
        end
        k.keys = awful.key(mod(k), keysym(k), function()
            local finish = press(k)()
            if finish ~= false then pop() end
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
    chord.keytable = keytable
    return chord
end

-- Constructs menu describing chord table given
function chord_menu(keytable)
    local template = keytable.menu or {}
    template.items = {}

    for _, k in ipairs(keytable) do
        local item = {
            tostring(keysym(k)) .. ": " .. desc(k), 
            press(k),
            icon(k)
        }
        table.insert(template.items, item)
    end

    return awful.menu.new(template)
end

-- Constructs naughty box describing chord table given
function chord_naughty(keytable)
    local template = keytable.naughty or {}

    template.text = ""
    for _, k in ipairs(keytable) do
        -- TODO: Take modifiers into account when 
        -- generating descriptions
        template.text = template.text ..
        "\n" .. tostring(k.keysym) ..
        ": " ..  ( k.desc or "<no_description>" )
    end

    return naughty.notify(template)
end

-- Function inserts keys from table 'keytable'
-- into client's keys(). Then it pops naughtybox 
-- showing chord description.
--
-- @param keytable Keys to be mapped
-- @param c Client. if nil, global keys will be used.
function push(keytable, c)
    pop()
    active = chord_new(keytable, c)
    return active
end

function push_menu(keytable, args, c)
    local chord = push(keytable, c)
    local menu = chord_menu(keytable)
    menu.hide = function(m)
        awful.menu.hide(m)
        pop()
    end
    chord.menu = menu
    chord.menu:show(args)
    return chord
end

function push_naughty(keytable, c)
    local chord = push(keytable, c)
    local nb = chord_naughty(keytable)
    chord.naughtybox = nb
    return chord
end

