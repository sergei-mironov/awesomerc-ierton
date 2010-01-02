local awful = require("awful")
local beautiful = require("beautiful")

local capi = {
	io = io,
	screen = screen,
	tag = tag,
	mouse = mouse,
	client = client
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

-- returns tag by name
function find(name)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	return tags[s][name]
end

-- returns list of tag names
function names()
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local stags = capi.screen[s]:tags()
	local result = {}
	for _,tag in ipairs(stags) do table.insert(result, tag.name) end
	return result
end

-- returns tag by index
function get(index, s)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local stags = capi.screen[s]:tags()
    return stags[awful.util.cycle(#stags, index)]
end

-- offset : offset from base tag (+n , -n , 0)
-- basetag : see code :)
-- s - screen
--
-- returns tag object, which can be passed to functions like 
-- awful.client.movetotag()
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

-- moves tag to position #where (if where is number) -OR- next 
-- to tag where (if where is object)
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
	tag:emit_signal("tagman::update", tag)
end

function add(tn, props, s)
	local props = props or {}
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local tn = tostring(tn)
	local t = capi.tag {name = tn}
	t.screen = s
	awful.layout.set(props.layout or awful.layout.suit.max, t)
	tags[s][tn] = t
	if props.setsel == true then t.selected = true end
	t:emit_signal("tagman::update", t)
	return t
end

function del(tag, s)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	local stags = capi.screen[s]:tags()
	if #stags <= 1 then return end
	if tag == stags[1] then awful.tag.viewnext() else awful.tag.viewprev() end
	tag:emit_signal("tagman::update", tag)
	tags[s][tag.name] = nil
	tag.screen = nil
	--FIXME: When there were 2 tags before del(), clients are dissapearing 
	--insted of jumping to the last tag.
	handle_orphans(s, awful.tag.selected(s))
end

function rename(tag, newname, s)
	local s = s or client.focus and client.focus.screen or capi.mouse.screen
	tags[s][tag.name] = nil
	tag.name = newname
	tags[s][tag.name] = tag
	tag:emit_signal("tagman::update", tag)
end

function init(namelist)
	if namelist == nil then
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

