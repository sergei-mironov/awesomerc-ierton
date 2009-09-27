local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")

local capi = {
	io = io,
	screen = screen,
	tag = tag,
	client = client,
	mouse = mouse,
	root = root,
	key = key,
}

local table = table
local awesome = awesome
local ipairs = ipairs
local pairs = pairs
local tostring = tostring

module("myrc.keybind")

local notify_keychain = nil

-- Will inser keys from mytable to the end of globalkeys
-- one has to call pop() with same mytable
function push(mytable,ftitle)
	local description = ""
	local newkeys = {}
    for _, k in ipairs(mytable) do
		newkeys = awful.util.table.join(newkeys, k.keys)
		description = description .. "\n"
		description = description ..  tostring(k.keysym) .. ": " ..  ( k.desc or "<no_description>" )
    end

	local globalkeys = awful.util.table.join(
		capi.root.keys(), newkeys)

	capi.root.keys(globalkeys)

    if not notify_keychain then
        notify_keychain = naughty.notify({
            title = ftitle,
            text = description,
            timeout = 0,
            position = "top_left",
        })
    end
end

-- removes #mytable items from the end of globalkeys
-- FIXME: add some fool-protection, man..
function pop(mytable)
	local newkeys = {}
    for _, k in ipairs(mytable) do
		newkeys = awful.util.table.join(newkeys, k.keys)
    end

	local globalkeys = capi.root.keys()
    for k, v in ipairs(newkeys) do
        table.remove(globalkeys)
    end

	capi.root.keys(globalkeys)

    if notify_keychain then
        naughty.destroy(notify_keychain)
        notify_keychain = nil
    end
end

function key(mod, key, desc, press)
	local k = {
		keys = awful.key(mod, key, press),
		desc = tostring(desc),
		keysym = tostring(key),
	}
	return k
end

