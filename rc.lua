-- Include awesome libraries, with lots of useful function!
require("awful")
require("awful.titlebar")
require("awful.autofocus")
require("awesome")
require("client")
require("beautiful")
require("naughty")
require("freedesktop.utils")
require("freedesktop.menu")

require("tsave")
require("pipelets")

require("myrc.mainmenu")
require("myrc.tagman")
require("myrc.themes")
require("myrc.keybind")
require("myrc.memory")
require("myrc.logmon")

--{{{ Debug 
function dbg(vars)
	local text = ""
	for i=1, #vars-1 do text = text .. tostring(vars[i]) .. " | " end
	text = text .. tostring(vars[#vars])
	naughty.notify({ text = text, timeout = 10 })
end

function dbg_client(c)
	local text = ""
	if c.class then
		text = text .. "Class: " .. c.class .. " "
	end
	if c.instance then
		text = text .. "Instance: ".. c.instance .. " "
	end
	if c.role then
		text = text .. "Role: ".. c.role .. " "
	end
	if c.type then
		text = text .. "Type: ".. c.type .. " "
	end

	text = text .. "Full name: '" .. client_name(c) .. "'"

	dbg({text})
end
--}}}

--{{{ Data serialisation helpers
function client_name(c)
    local cls = c.class or ""
    local inst = c.instance or ""
	local role = c.role or ""
	local ctype = c.type or ""
	return cls..":"..inst..":"..role..":"..ctype
end

function save_floating(c, f)
	myrc.memory.set("floating", client_name(c), f)
	awful.client.floating.set(c, f)
    if f == true then
        c.border_width = beautiful.border_width
    else
        c.border_width = 0
    end
	return f
end

function get_floating(c, def)
	if def == nil then def = awful.client.floating.get(c) end
	return myrc.memory.get("floating", client_name(c), def)
end

function save_centered(c, val)
	myrc.memory.set("centered", client_name(c), val)
	if val == true then
        save_floating(c, true)
		awful.placement.centered(c)
	end
	return val
end

function get_centered(c, def)
	return myrc.memory.get("centered", client_name(c), def)
end

function save_titlebar(c, val)
	myrc.memory.set("titlebar", client_name(c), val)
	if val == true then
		awful.titlebar.add(c, { modkey = modkey })
	elseif val == false then
		awful.titlebar.remove(c)
	end
	return val
end

function get_titlebar(c, def)
	return myrc.memory.get("titlebar", client_name(c), def)
end

function save_tag(c, tag)
	local tn = "none"
	if tag then tn = tag.name end
	myrc.memory.set("tags", client_name(c), tn)
	if tag ~= nil and tag ~= awful.tag.selected() then 
		awful.client.movetotag(tag, c) 
	end
end

function get_tag(c, def)
	local tn = myrc.memory.get("tags", client_name(c), def)
	return myrc.tagman.find(tn)
end

function save_geometry(c, val)
	myrc.memory.set("geometry", client_name(c), val)
	c:geometry(val)
end

function get_geometry(c, def)
	return myrc.memory.get("geometry", client_name(c), def)
end
--}}}

-- {{{ Variable definitions
-- Default modkey.
modkey = "Mod4"
altkey = "Mod1"

-- Helper variables
env = {
    browser = "firefox ",
    man = "urxvt -e man ",
    terminal = "urxvt ", 
    screen = "urxvt -e zsh -ic screen",
    fileman = "urxvt -e zsh -ic mc",
    terminal_root = "urxvt -e su -c screen",
    im = "pidgin ",
    editor = os.getenv("EDITOR") or "urxvt -e vim ",
    home_dir = os.getenv("HOME"),
    music_show = "gmpc --replace",
    music_hide = "gmpc --quit",
    run = "gmrun",
    locker = "xscreensaver-command -lock",
    xkill = "xkill",
    shutdown = "urxvt -e " .. awful.util.getdir("config").."/shutdown"
}

-- Pipelets
pipelets.config.script_path = awful.util.getdir("config").."/pipelets/"

-- Naughty
naughty.config.presets.keybind = {
    position = 'top_left',
    timeout = 0,
}
logmon_width = 700
naughty.config.position = 'top_right'
naughty.config.presets.low.width = logmon_width
naughty.config.presets.normal.width = logmon_width
naughty.config.presets.critical.width = logmon_width

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = 
{
    awful.layout.suit.max,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

awful.menu.menu_keys = {
	up={ "Up", 'k' }, 
	down = { "Down", 'j' }, 
	back = { "Left", 'x', 'h' }, 
	exec = { "Return", "Right", 'o', 'l' },
	close = { "Escape" }
}

chord_menu_args = {
    coords={ x=0, y=0 },
    keygrabber = false
}

mainmenu_args = {
    coords={ x=0, y=0 },
    keygrabber = true
}

myrc.memory.init()

beautiful.init(myrc.themes.current())

myrc.mainmenu.init(env)

myrc.tagman.init(myrc.memory.get("tagnames", "-", nil))

myrc.logmon.init()

pipelets.init()
-- }}}

-- {{{ Wibox
-- Empty launcher
mymainmenu = myrc.mainmenu.build()
mylauncher = awful.widget.button({image = beautiful.awesome_icon})
-- Main menu will be placed at left top corner of screen
mylauncher:buttons(awful.util.table.join(mylauncher:buttons(), 
    awful.button({}, 1, nil, function () mymainmenu:show(mainmenu_args) end)))

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mytop = {}
mybottom = {}
mypromptbox = {}

-- Clock
mytextclock = {}
mytextclock = widget({ type = "textbox", align="right" })
pipelets.register_fmt(mytextclock, "date", " $1 ")

-- Mountbox
mymountbox = widget({ type = "textbox", align="right" })
pipelets.register( mymountbox, "mmount")

-- BatteryBox
mybatbox = widget({ type = "textbox", align="right" })
pipelets.register( mybatbox, "batmon")

-- Layoutbox
mylayoutbox = {}
mylayoutbox.buttons = awful.util.table.join(
	awful.button({ }, 1, function () 
		awful.layout.inc(layouts, 1) 
	end),
	awful.button({ }, 3, function () 
		awful.layout.inc(layouts, -1) 
	end),		
	awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
	awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end) 
)

-- Taglist
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
	awful.button({ }, 1, awful.tag.viewonly),
	awful.button({ modkey }, 1, awful.client.movetotag),
	awful.button({ }, 3, function (tag) tag.selected = not tag.selected end),
	awful.button({ modkey }, 3, awful.client.toggletag),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev) 
)


-- Tasklist
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
	awful.button({ }, 1, function (c)
		if not c:isvisible() then
			awful.tag.viewonly(c:tags()[1])
		end
		client.focus = c
		c:raise()
	end),
	awful.button({ }, 3, function (c) 
        if mycontextmenu then mycontextmenu:hide() end
        local mp = mouse.coords()
        mycontextmenu = myrc.keybind.chord_menu(chord_client(c))
        mycontextmenu:show({coords = {x = mp.x-1*beautiful.menu_width/3, y = mp.y}})
    end),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end) 
)

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({layout = awful.widget.layout.horizontal.leftright})

    -- Create an imagebox widget which will contains an icon indicating
    -- which layout we're using. We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(mylayoutbox.buttons)

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, 
        awful.widget.taglist.filter.all, 
        mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, 
        awful.widget.tasklist.filter.currenttags, 
        mytasklist.buttons)

    -- Create top wibox
    mytop[s] = awful.wibox({ position = "top", screen = s, })
    mytop[s].widgets = {
        mylauncher,
        mylayoutbox[s],
        mytaglist[s],
        mypromptbox[s],
		{
            mytextclock,
            s == 1 and mysystray or nil,
            layout = awful.widget.layout.horizontal.rightleft
		},
        mytasklist[s],
        layout = awful.widget.layout.horizontal.leftright,
        height = mytop[s].height
	}

    -- Create bottom wibox
    mybottom[s] = awful.wibox({ 
        position = "bottom", screen = s, height = beautiful.wibox_bottom_height})
    mybottom[s].widgets = {
        mybatbox,
        mymountbox,
        layout = awful.widget.layout.horizontal.leftright
    }

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:show() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
-- Switches to prev/next client
function switch_to_client(direction)
	if direction == 0 then
		awful.client.focus.history.previous()
	else
		awful.client.focus.byidx(direction);  
	end
	if client.focus then client.focus:raise() end
end

-- Toggle tags between current and one, that has name @name
function toggle_tag(name)
    local this = awful.tag.selected()
    if this.name == name then
        awful.tag.history.restore()
    else
        local t = myrc.tagman.find(name)
        if t == nil then
            naughty.notify({text = "Can't find tag with name '" .. name .. "'"})
            return
        end
        awful.tag.viewonly(t)
    end
end

--- Spawns cmd if no client can be found matching properties
-- If such a client can be found, pop to first tag where it is visible, and give it focus
-- @param cmd the command to execute
-- @param properties a table of properties to match against clients.  Possible entries: any properties of the client object
function run_or_raise(cmd, properties)
    local clients = client.get()
    local focused = awful.client.next(0)
    local findex = 0
    local matched_clients = {}
    local n = 0

    -- Returns true if all pairs in table1 are present in table2
    function match (table1, table2)
        for k, v in pairs(table1) do
            if table2[k] ~= v and not table2[k]:find(v) then
                return false
            end
        end
        return true
    end

    for i, c in pairs(clients) do
        --make an array of matched clients
        if match(properties, c) then
            n = n + 1
            matched_clients[n] = c
            if c == focused then
                findex = n
            end
        end
    end
    if n > 0 then
        local c = matched_clients[1]
        -- if the focused window matched switch focus to next in list
        if 0 < findex and findex < n then
            c = matched_clients[findex+1]
        end
        local ctags = c:tags()
        if table.getn(ctags) == 0 then
            -- ctags is empty, show client on current tag
            local curtag = awful.tag.selected()
            awful.client.movetotag(curtag, c)
        else
            -- Otherwise, pop to first tag client is visible on
            awful.tag.viewonly(ctags[1])
        end
        -- And then focus the client
        if client.focus == c then
            c:tags({})
        else
            client.focus = c
            c:raise()
        end
        return
    end
    awful.util.spawn(cmd)
end

function chord_client(c)
    return {
        menu = {
            height = theme.menu_context_height
        },
        naughty = {
            title = "::Client::"
        },

        {{}, "Escape", "Cancel", function () 
        end},

        {{"Shift"}, "k", "Kill", function () 
            c:kill()
        end},

        {{}, "l", "Toggle floating", function () 
            save_floating(c, not awful.client.floating.get(c))
        end},

        {{}, "c", "Set centered on", function () 
            save_centered(c, true)
        end},

        {{"Shift"}, "c", "Set centered off", function () 
            save_centered(c, false)
        end},

        {{}, "t", "Toggle titlebar", function () 
            save_titlebar(c, not get_titlebar(c, false)) 
        end},

        {{}, "g", "Save geometry", function () 
            save_geometry(c, get_geometry(c))
        end},

        {{}, "f", "Toggle fullscreen", function () 
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end},

        {{}, "r", "Rename", function () 
            awful.prompt.run(
            { prompt = "Rename client: " }, 
            mypromptbox[mouse.screen].widget, 
            function(n) 
                awful.client.property.set(c,"label", n) 
            end,
            awful.completion.bash,
            awful.util.getdir("cache") .. "/rename")
        end},

        {{}, "s", "Stick to this tag", function () 
            local t = awful.tag.selected()
            save_tag(c, t) 
            naughty.notify({text = "Client " .. c.name .. " has been sticked to tag " .. t.name}) 
        end}, 

        {{"Shift"}, "s", "Unstick from any tag", function () 
            save_tag(c, nil) 
            naughty.notify({text = "Client " .. c.name .. " has been unsticked from tag"}) 
        end},
    } 
end

function chord_mpd()
    return {
        menu = {
            height = theme.menu_context_height
        },
        naughty = {
            title = "::MPD::"
        },

        {{}, "Escape", "Cancel", function () 
        end},

        {{}, "w", "Cancel", function () 
        end},

        {{}, "p", "Play/pause", function () 
            awful.util.spawn("mpc toggle")
        end},

        {{}, "n", "Next", function () 
            awful.util.spawn("mpc next")
        end},

        {{"Shift"}, "n", "Prev", function () 
            awful.util.spawn("mpc prev")
        end},

        {{}, "b", "Back", function () 
            awful.util.spawn("mpc seek 0%")
        end},

        {{}, "9", "Vol down", function () 
            awful.util.spawn("mpc volume -5")
            return false
        end},

        {{}, "0", "Vol up", function () 
            awful.util.spawn("mpc volume +5")
            return false
        end},
    }
end

function chord_tags()
    return {
        menu = {
            height = theme.menu_context_height
        },
        naughty = {
            title = "::TAGS::"
        },
        {{}, "Escape", "Cancel", function () 
        end},

        {{}, "Return", "Cancel", function () 
        end},

        {{}, "r", "Rename current tag", function () 
            awful.prompt.run(
            { prompt = "Rename this tag: " }, 
            mypromptbox[mouse.screen].widget, 
            function(newname) 
                myrc.tagman.rename(awful.tag.selected(),newname) 
            end, 
            awful.completion.bash,
            awful.util.getdir("cache") .. "/tag_rename")
        end},

        {{}, "c", "Create new tag", function () 
            awful.prompt.run(
            { prompt = "Create new tag: " }, 
            mypromptbox[mouse.screen].widget, 
            function(newname) 
                local t = myrc.tagman.add(newname) 
                myrc.tagman.move(t, awful.tag.selected()) 
            end, 
            awful.completion.bash,
            awful.util.getdir("cache") .. "/tag_new")
        end},

        {{}, "d", "Delete current tag", function () 
            myrc.tagman.del(awful.tag.selected()) 
        end}, 

        {{}, "k", "Move tag right", function () 
            myrc.tagman.move(awful.tag.selected(), myrc.tagman.getn(0))
            return false
        end}, 

        {{}, "j", "Move tag left", function () 
            myrc.tagman.move(awful.tag.selected(), myrc.tagman.getn(-2))
            return false
        end}
    }
end

-- Bind keyboard digits
globalkeys = awful.util.table.join(

    -- Main menu
    awful.key({ altkey            }, "Escape", function() mymainmenu:show(mainmenu_args) end),

    -- Awesome control
    awful.key({ modkey, "Control" }, "q", awesome.quit),
    awful.key({ modkey, "Control" }, "r", function() 
        mypromptbox[mouse.screen].widget.text = awful.util.escape(awful.util.restart())
    end),

    -- Application hotkeys
    awful.key({ modkey            }, "f", function () awful.util.spawn(env.browser) end),
    awful.key({ modkey            }, "e", function () awful.util.spawn(env.screen)  end),
    awful.key({                   }, "Scroll_Lock", function () awful.util.spawn(env.locker) end),
    awful.key({ modkey            }, "r", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey,           }, "m", function () run_or_raise("gmpc", { class = "Gmpc" }) end),
    awful.key({ modkey            }, "p", function () awful.util.spawn("pidgin") end),
    awful.key({ modkey            }, "c", function () run_or_raise("xterm -e calc", { class="XTerm", name = "calc" }) end),

    -- Tag hotkeys
    awful.key({ modkey, "Control" }, "m", function () toggle_tag("im") end),
    awful.key({ modkey, "Control" }, "w", function () toggle_tag("work") end),
    awful.key({ modkey, "Control" }, "n", function () toggle_tag("net") end),
    awful.key({ modkey, "Control" }, "f", function () toggle_tag("fun") end),
    awful.key({ modkey, "Control" }, "e", function () toggle_tag("sys") end),
    awful.key({ modkey            }, "Tab", function() awful.tag.history.restore() end),

    -- Client manipulation
    awful.key({ altkey            }, "j", function () switch_to_client(-1) end),
    awful.key({ altkey            }, "k", function () switch_to_client(1) end),
    awful.key({ altkey            }, "1", function () switch_to_client(-1) end),
    awful.key({ altkey            }, "2", function () switch_to_client(1) end),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(1) end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx(-1) end),
    awful.key({ altkey            }, "Tab", function() switch_to_client(0) end),

    -- Layout manipulation
    awful.key({ altkey,           }, "F1", awful.tag.viewprev ),
    awful.key({ altkey,           }, "F2", awful.tag.viewnext ),
    awful.key({ altkey,           }, "h", function () awful.tag.incmwfact(-0.05) end),
    awful.key({ altkey,           }, "l", function () awful.tag.incmwfact(0.05) end),
    awful.key({ altkey, "Shift"   }, "h", function () awful.tag.incnmaster(1) end),
    awful.key({ altkey, "Shift"   }, "l", function () awful.tag.incnmaster(-1) end),
    awful.key({ altkey, "Control" }, "h", function () awful.tag.incncol(1) end),
    awful.key({ altkey, "Control" }, "l", function () awful.tag.incncol(-1) end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts, 1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ altkey,           }, "e", function () 
        myrc.keybind.push_menu(chord_mpd(), chord_menu_args) 
    end),

    -- Tagset operations (Win+Ctrl+s,<letter> chords)
    awful.key({ altkey,           }, "F3", function () 
        myrc.keybind.push_menu(chord_tags(), chord_menu_args) 
    end)
)

root.keys(globalkeys)

clientkeys = awful.util.table.join(
    awful.key({ modkey }, "F1", function (c) 
        local tag = myrc.tagman.getn(-1)
        awful.client.movetotag(tag, c)
        awful.tag.viewonly(tag)
        c:raise()
    end),
    awful.key({ modkey }, "F2", function (c) 
        local tag = myrc.tagman.getn(1)
        awful.client.movetotag(tag, c)
        awful.tag.viewonly(tag)
        c:raise()
    end),
    awful.key({ altkey }, "F4", function (c) 
        c:kill() 
    end),
    awful.key({ altkey }, "F5", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end),

    awful.key({ altkey }, "F6", function (c) 
        dbg_client(c) 
    end),

    -- Client keys
    awful.key({ altkey ,        }, "3", function(c) 
        myrc.keybind.push_menu(chord_client(c), chord_menu_args, c)
    end)
)

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}

-- {{{ Hooks
-- Hook function to execute when focusing a client.
client.add_signal("focus", function (c)
	c.border_color = beautiful.border_focus
end)

-- Hook function to execute when unfocusing a client.
client.add_signal("unfocus", function (c)
	c.border_color = beautiful.border_normal
end)

-- Hook function to execute when a new client appears.
client.add_signal("manage", function (c, startup)

    local name = client_name(c)
    if c.type == "dialog" then 
        save_centered(c, true)
    end

    local floating = myrc.memory.get("floating", name, awful.client.floating.get(c))
    save_floating(c, floating)
    if floating == true then
        local centered = get_centered(c)
        if centered then 
            save_centered(c, centered)
        end
        local geom = get_geometry(c)
        if geom then
            save_geometry(c, geom)
        end
        local titlebar = get_titlebar(c)
        if titlebar then
            save_titlebar(c, titlebar)
        end
    end

    local tag = get_tag(c, nil)
    if tag ~= nil then
        awful.client.movetotag(tag,c)
    end

    -- Set key bindings
    c:buttons(clientbuttons)
    c:keys(clientkeys)

    -- Set default app icon
    if not c.icon and theme.default_client_icon then
        c.icon = image(theme.default_client_icon)
    end

    c:add_signal("mouse::enter", function(c)
        function kill_mousemode_menu(m) 
            if m and (true ~= m.keygrabber) then m:hide() end 
        end
        kill_mousemode_menu(mymainmenu)
        kill_mousemode_menu(mycontextmenu)
    end)

    -- New client may not receive focus
    -- if they're not focusable, so set border anyway.
    c.border_color = beautiful.border_normal
    c.size_hints_honor = false

    client.focus = c
end)

-- Signal from tagman lib. 
-- Handler will store tag names to registry.
-- Those names will be used at next awesome start
-- to recreate current tags.
awesome.add_signal("tagman::update", function (t) 
    myrc.memory.set("tagnames","-", myrc.tagman.names())
end)

