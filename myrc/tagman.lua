-- Author: Sergey Mironov ierton@gmail.com
-- License: BSD3
-- 2009-2010
--
-- Tag manipulation library
-- Note: library uses signal "tagman::update"

local awful = require("awful")
local beautiful = require("beautiful")

local capi = {
	io = io,
	screen = screen,
	tag = tag,
	mouse = mouse,
	client = client,
    awesome = awesome
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

-- Returns tag by name
function find(name,s)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	for _,t in ipairs(capi.screen[s]:tags()) do 
        if name == t.name then return t end 
    end
	return nil
end

-- Returns list of tag names at screen @s
function names(s)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local result = {}
	for _,t in ipairs(capi.screen[s]:tags()) do 
        table.insert(result, t.name) 
    end
	return result
end

-- Returns tag by index @index, starting from 0.
function get(index, s)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local stags = capi.screen[s]:tags()
    return stags[awful.util.cycle(#stags, index)]
end

-- Gets tag object, by its offset @offset, starting from 
-- tag @basetag
function getn(offset, basetag, s)
	local offset = offset or 0
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local stags = capi.screen[s]:tags()
	local basetag = basetag or awful.tag.selected()
	local k = awful.util.table.hasitem(stags,basetag)
    return stags[awful.util.cycle(#stags, k + offset)]
end

local function handle_orphans(s, deftag)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local stags = capi.screen[s]:tags()
	if #stags < 1 then return end
    for _, c in pairs(client.get()) do
        if #c:tags() == 0 then
            c:tags({deftag or stags[1]})
        end
    end
end

-- Does what?
function sort(s, fn)
	local fn = fn or function (a, b) return a.name < b.name end
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
    local all_tags = capi.screen[s]:tags()
    table.sort(all_tags, fn)
    capi.screen[s]:tags(all_tags)
end

-- Moves tag to position @where (if where is number) -OR- next
-- to tag @where (if where is object)
function move(tag, where, s)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local stags = capi.screen[s]:tags()
	local oldkey = awful.util.table.hasitem(stags,tag)
	local c = capi.client.focus
	if oldkey == nil then return end
	if type(where) == "number" then
		local index = awful.util.cycle(#stags, where)
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
	capi.client.focus = c
	awesome.emit_signal("tagman::update", tag)
end

-- Adds a tag named @tn with props @props
function add(tn, props, s)
	local props = props or {}
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local tname = tostring(tn)
	local tag = capi.tag {name = tname}
	tag.screen = s
	awful.layout.set(props.layout or awful.layout.suit.max, tag)
	if props.setsel == true then tag.selected = true end
	awesome.emit_signal("tagman::update", tag)
	return t
end

-- Removes tag @tag. Move @tag's clients to another tag
function del(tag, s)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local stags = capi.screen[s]:tags()
	if #stags <= 1 then return end
	if tag == stags[1] then awful.tag.viewnext() else awful.tag.viewprev() end
	tag.screen = nil
	awesome.emit_signal("tagman::update", tag)
	--FIXME: When there were 2 tags, clients are dissapearing 
	--insted of jumping to the last tag.
	handle_orphans(s, awful.tag.selected(s))
end

-- Renames tag @tag with name @newname
function rename(tag, newname, s)
	tag.name = newname
	awesome.emit_signal("tagman::update", tag)
end

-- Initializes the library. 
-- Creates tags with names from @namelist table
-- If @namelist is empty, creates tags 1..9
function init(namelist)
	if namelist == nil or #namelist == 0 then
		namelist = {}
		for i=1,9 do namelist[i] = tostring(i) end
	end

	for s = 1, capi.screen.count() do
		-- Each screen has its own tag table.
		tags[s] = {}

		for i, name in ipairs(namelist) do 
			add(name, { setsel=(i==1) } ) 
		end
	end
end

