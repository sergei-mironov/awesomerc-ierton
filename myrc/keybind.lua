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

function push(mytable,ftitle)
	local globalkeys = capi.root.keys()
	local description = ""
    for _, k in ipairs(mytable) do
        table.insert(globalkeys,k)
		description = description .. "\n"
		if k.release == nil then
			description = description .. "BUG! use myrc.keybind.key() for key " .. tostring(k.keysym)
		else
			description = description ..  tostring(k.keysym) .. ": " ..  ( k.release("describe!") or "<no_description>" )
		end
    end
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

function pop(mytable)
	local globalkeys = capi.root.keys()
    for k, v in ipairs(mytable) do
        table.remove(globalkeys)
        capi.root.keys(globalkeys)
    end
    if notify_keychain then
        naughty.destroy(notify_keychain)
        notify_keychain = nil
    end
end

function key(a1,a2,d,a3,a4)
	local k = capi.key(a1,a2,a3,function(var)
		if var == nil then 
			a4()
		else
			return tostring(d)
		end
	end)
	return k
end

function describe(t)

	for _, k in ipairs(t) do
		dbg({ k.keysym , k.press("describe!") })
	end

end

