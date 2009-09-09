local awful = require("awful")
local beautiful = require("beautiful")

local capi = {
	io = io,
	screen = screen,
	tag = tag,
	mouse = mouse
}

local client = client
local type = type
local table = table
local awesome = awesome
local ipairs = ipairs
local pairs = pairs
local tostring = tostring

module("myrc.tagman")

tags = {}

function getn(offset, basetag, s)
	local offset = offset or 0
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local stags = capi.screen[s]:tags()
	local basetag = basetag or awful.tag.selected()
	local k = awful.util.table.hasitem(stags,basetag)
    return stags[awful.util.cycle(#stags, k + offset)]
end


function handle_orphans(s, deftag)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local stags = capi.screen[s]:tags()
	if #stags < 1 then return end
    for _, c in pairs(client.get()) do
        if #c:tags() == 0 then
            c:tags({deftag or stags[1]})
        end
    end
end

function sort(s, fn)
	local fn = fn or function (a, b) return a.name < b.name end
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
    local all_tags = capi.screen[s]:tags()
    table.sort(all_tags, fn)
    capi.screen[s]:tags(all_tags)
end

function move(tag, where, s)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local stags = capi.screen[s]:tags()
	local oldkey = awful.util.table.hasitem(stags,tag)
	if oldkey == nil then return end
	if type(where) == "number" then
		local index = awful.util.cycle(#stags, where+1)
		table.remove(stags,oldkey)
		table.insert(stags,index,tag)
	else --tag object
		local newkey = awful.util.table.hasitem(stags, where)
		if newkey == nil then return end
		local index = awful.util.cycle(#stags, newkey+1)
		table.remove(stags,oldkey)
		table.insert(stags,index,tag)
	end
	capi.screen[s]:tags(stags)
end

function add(tn, props, s)
	local props = props or {}
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local tn = tostring(tn)
	local t = capi.tag(tn)
	t.screen = s
	awful.layout.set(props.layout or awful.layout.suit.max, t)
	tags[s][tn] = t
	if props.setsel == true then t.selected = true end
	return t
end

function del(tag, s)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local stags = capi.screen[s]:tags()
	if #stags <= 1 then return end
	if tag == stags[1] then awful.tag.viewnext() else awful.tag.viewprev() end
	tags[s][tag.name] = nil
	tag.screen = nil
	--FIXME: When there were 2 tags before del(), clients are dissapearing 
	--insted of jumping to the last tag.
	handle_orphans(s,awful.tag.selected())
end

function rename(tag, newname, s)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	tags[s][tag.name] = nil
	tag.name = newname
	tags[s][tag.name] = tag
end

function init()
	for s = 1, capi.screen.count() do
		-- Each screen has its own tag table.
		tags[s] = {}

		-- Create 9 tags per screen.
		for tagnumber = 1, 9 do 
			add(tostring(tagnumber), { setsel=(tagnumber==1) } ) 
		end
	end
end

