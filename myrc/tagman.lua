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

-- Returns index of current tag (on this screen)
function indexof(tag)
	local all_tags = capi.screen[tag.screen]:tags()
	return awful.util.table.hasitem(all_tags,tag)
end

function next_to(t,n) return get(indexof(t)+(n or 1),s) end

function prev_to(t,n) return get(indexof(t)-(n or 1),s) end

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

-- Moves all tagless clients of screen @s to tag @deftag
local function handle_orphans(s, deftag)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local stags = capi.screen[s]:tags()
	if #stags < 1 then return end
    local deftag = deftag or stags[1]
    for _, c in pairs(client.get(s)) do
        if #c:tags() == 0 then
            c:tags({deftag})
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
-- to tag @where (if @where is object)
-- In latter case @where should be on the @tag's screen
function move(tag, where)
	local stags = capi.screen[tag.screen]:tags()
    -- Current possition of the tag
	local oldkey = indexof(tag)
    if oldkey == nil then return end
    -- New position of the tag
    local newkey = nil
	if type(where) == "number" then
		newkey = awful.util.cycle(#stags, where)
	else
        -- dest tag should be on the same screen with src
        if where.screen ~= tag.screen then return end
        -- expect a table (a tag)
		newkey = indexof(where)
	end

	local c = capi.client.focus

    table.remove(stags,oldkey)
    table.insert(stags,newkey,tag)
    capi.screen[tag.screen]:tags(stags)

	awesome.emit_signal("tagman::update", tag, tag.screen)
    if c~= nil then 
        capi.client.focus = c 
    end
end

-- Adds a tag named @tn with props @props
-- NOTE: those properties are not the same with awful.tag's
function add(tn, props, s)
	local props = props or {}
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local tname = tostring(tn)
    if tname == nil then return end
	local t = awful.tag.add(tname)
	t.screen = s
	awful.layout.set(props.layout or awful.layout.suit.max, t)
	if props.setsel == true then t.selected = true end
	awesome.emit_signal("tagman::update", t, s)
	return t
end

-- Removes tag @t. Move it's clients to tag @deft
function del(tag, deft)
    local s = tag.screen
    local stags = capi.screen[s]:tags()
    if #stags <= 1 then return end
    local deft = deft or prev_to(tag)
    if deft == nil then return end
    tag.screen = nil
    awesome.emit_signal("tagman::update", tag, s)
    handle_orphans(s, deft)
end

-- Renames tag @tag with name @newname
function rename(tag, newname)
	tag.name = newname
	awesome.emit_signal("tagman::update", tag, tag.screen)
end

-- Initializes the library. 
-- Creates a se of tags for each screen
-- @name_getter is a function taking screen index and returning 
-- a list of tag names.
function init(name_getter)
	for s = 1, capi.screen.count() do
        local namelist = name_getter(s)
        if namelist == nil or #namelist == 0 then
            namelist = {}
            for i=1,9 do namelist[i] = tostring(i) end
        end
		-- Each screen has its own tag table.
		for i, name in ipairs(namelist) do 
			add(name, { setsel=(i==1) }, s) 
		end
	end
end

