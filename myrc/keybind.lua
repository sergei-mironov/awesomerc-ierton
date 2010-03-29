-- Author: Sergey Mironov ierton@gmail.com
-- License: BSD3
-- 2009-2010
--
-- Library allows user to bind GNU Screen style 'chords'

local awful = require("awful")
local naughty = require("naughty")

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

local function chord_new(kt, title, c, preset)
    local description = ""
    local newkeys = nil
    for _, k in ipairs(kt) do
        newkeys = awful.util.table.join(newkeys, k.keys)
        -- TODO: Take modifiers into account when 
        -- generating descriptions
        description = description .. 
        "\n" .. tostring(k.keysym) ..  
        ": " ..  ( k.desc or "<no_description>" )
    end

    local allkeys = get_keys(c)
    for _,k in ipairs(newkeys) do
        table.insert(allkeys, k)
    end
    set_keys(c, allkeys)

    local nb = naughty.notify({
        title = title,
        text = description,
        preset = preset or naughty.config.presets.keybind or {}
    })

    return {
        client = c,
        naughtybox = nb,
        keytable = newkeys,
        title = title,
        desc = description
    }
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
    for _,n in ipairs(ch.keytable) do
        remove_a_key(n,allkeys)
    end
    set_keys(ch.client, allkeys)

    if ch.naughtybox then
        naughty.destroy(ch.naughtybox)
    end
end

-- Function inserts keys from table 'keytable'
-- into client's keys(). Then it pops naughtybox 
-- showing chord description.
--
-- title - naughty's title
-- keytable - keys to be mapped
-- c - client. if nil, global keys will be used.
-- preset - naughty's preset defulting to
-- try naughty.config.presets.keybind
--
-- Note: 
-- 1) User has to call pop() manually to cancel 
-- current chord, or push() to start another chord.
-- 2) User has to use keybind.key() instead of awful.key()
-- to build 'keytable' table
function push(title, keytable, c, preset)
    if the_chord ~= nil then
        chord_release(the_chord)
        the_chord = nil
    end
    the_chord = chord_new(keytable, title, c, preset)
end

-- Cancels current chord, if any
function pop()
    if the_chord ~= nil then
        chord_release(the_chord)
        the_chord = nil
    end
end

-- User should use this function inside push()
-- to build chord table
function key(mod, key, desc, press)
    local k = {
        keys = awful.key(mod, key, press),
        desc = tostring(desc),
        keysym = tostring(key),
    }
    return k
end

