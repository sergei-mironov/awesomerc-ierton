-- Include awesome libraries, with lots of useful function!
require("awful")
require("awful.titlebar")
require("awful.autofocus")
require("awesome")
require("client")
require("screen")
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

--{{{ Run or raise
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
    awful.util.spawn(cmd, false)
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

-- where can be 'left' 'right' 'center' nil
function client_snap(c, where, geom)
    local sg = screen[c.screen].geometry
    local cg = geom or c:geometry()
    local cs = c:struts()
    cs['left'] = 0
    cs['top'] = 0
    cs['bottom'] = 0
    cs['right'] = 0
    if where == 'right' then
        cg.x = sg.width - cg.width
        cs[where] = cg.width
        c:struts(cs)
        c:geometry(cg)
    elseif where == 'left' then
        cg.x = 0
        cs[where] = cg.width
        c:struts(cs)
        c:geometry(cg)
    elseif where == 'bottom' then
        awful.placement.centered(c)
        cg = c:geometry()
        cg.y = sg.height - cg.height - beautiful.wibox_bottom_height
        cs[where] = cg.height + beautiful.wibox_bottom_height
        c:struts(cs)
        c:geometry(cg)
    elseif where == nil then
        c:struts(cs)
        c:geometry(cg)
    elseif where == 'center' then
        c:struts(cs)
        awful.placement.centered(c)
    else
        return
    end
end

function save_geometry(c, g)
	myrc.memory.set("geometry", client_name(c), g)
    if g ~= nil then
        c:geometry(g)
    end
end

function save_floating(c, f)
	myrc.memory.set("floating", client_name(c), f)
    awful.client.floating.set(c, f)
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

function save_dockable(c, val)
	myrc.memory.set("dockable", client_name(c), val)
    awful.client.dockable.set(c, val)
end

function get_dockable(c, def)
	return myrc.memory.get("dockable", client_name(c), def)
end

function save_hor(c, val)
	myrc.memory.set("maxhor", client_name(c), val)
    c.maximized_horizontal = val
end

function get_hor(c, def)
	return myrc.memory.get("maxhor", client_name(c), def)
end

function save_vert(c, val)
	myrc.memory.set("maxvert", client_name(c), val)
    c.maximized_vertical = val
end

function get_vert(c, def)
	return myrc.memory.get("maxvert", client_name(c), def)
end

function save_snap(c, val)
	myrc.memory.set("snap", client_name(c), val)
    client_snap(c, val)
end

function get_snap(c, def)
	return myrc.memory.get("snap", client_name(c), def)
end

function save_hidden(c, val)
	myrc.memory.set("hidden", client_name(c), val)
    c.skip_taskbar = val
end

function get_hidden(c, def)
	return myrc.memory.get("hidden", client_name(c), def)
end

function get_border(c, def)
	return myrc.memory.get("border", client_name(c), def)
end

function get_layout_border(c)
    if awful.client.floating.get(c) == false and 
        awful.layout.get() == awful.layout.suit.max
    then
        return 0
    else
        return get_border(c, beautiful.border_width)
    end
end

function save_border(c, val)
    myrc.memory.set("border", client_name(c), val)
    c.border_width = get_layout_border(c)
end
--}}}

-- Menu helpers--{{{
mymenu = nil
function menu_hide()
    if mymenu ~= nil then
        mymenu:hide()
        mymenu = nil
    end
end

function menu_current(menu, args)
    if mymenu ~= nil and mymenu ~= menu then
        mymenu:hide()
    end
    mymenu = menu
    mymenu:show(args)
    return mymenu
end

function client_contex_menu(c)
    local mp = mouse.coords()
    local menupos = {x = mp.x-1*beautiful.menu_width/3, y = mp.y}

    local menuitmes = {
        {"               ::: "..c.class.." :::" ,nil,nil}
        ,

        {"&Q Kill", function () 
            c:kill()
        end},

        {"",nil,nil}
        ,

        {"&F Floating", {
            { "&Enable", function () 
                save_floating(c, true)
            end},
            { "&Disable", function () 
                save_floating(c, false)
            end}
        }},

        {"&T Titlebar", {
            { "&Enable" , function () 
                save_titlebar(c, true)
            end},

            {"&Disable", function () 
                save_titlebar(c, false)
            end},
        }},

        {"&G Geometry", {
            { "&Save" , function () 
                save_geometry(c, c:geometry())
            end},

            {"&Clear", function () 
                save_geometry(c, nil)
            end},
        }},

        {"&V Fullscreen vert", {
            {"&Enable", function () 
                save_vert(c, true) 
            end},
            {"&Disable" , function () 
                save_vert(c, false) 
            end},
        }},

        {"&H Fullscreen hor", {
            {"&Enable", function () 
                save_hor(c, true) 
            end},
            {"&Disable" , function () 
                save_hor(c, false) 
            end},
        }},

        {"&S Snap", {
            { "&Center", function () 
                save_snap(c, 'center')
            end},

            {"&Right", function () 
                save_snap(c, 'right')
            end},

            {"&Left", function () 
                save_snap(c, 'left')
            end},

            {"&Bottom", function () 
                save_snap(c, 'bottom')
            end},

            {"&Off", function () 
                save_snap(c, nil)
            end},
        }},

        {"&B Border", {
            { "&None", function () 
                save_border(c, 0)
            end},

            {"&One", function () 
                save_border(c, 1)
            end},

            {"&Default", function () 
                save_border(c, nil)
            end},
        }},

        {"&S Stick", {
            { "To &this tag", 
            function () 
                local t = awful.tag.selected()
                save_tag(c, t) 
                naughty.notify({text = "Client " .. c.name .. " has been sticked to tag " .. t.name}) 
            end}, 

            {"To &none", function () 
                save_tag(c, nil) 
                naughty.notify({text = "Client " .. c.name .. " has been unsticked from tag"}) 
            end},
        }},

        { "&I Hidden", {
            {"&Enable", function () 
                save_hidden(c, true) 
            end},
            {"&Disable" , function () 
                save_hidden(c, false) 
            end},
        }},

        {"&R Rename", function () 
            awful.prompt.run(
            { prompt = "Rename client: " }, 
            mypromptbox[mouse.screen].widget, 
            function(n) 
                awful.client.property.set(c,"label", n) 
            end,
            awful.completion.bash,
            awful.util.getdir("cache") .. "/rename")
        end},
    } 

    return awful.menu( { items = menuitmes, height = theme.menu_context_height } ), menupos
end--}}}

-- {{{ Variable definitions
-- Default modkey.
modkey = "Mod4"
altkey = "Mod1"

-- Helper variables
env = {
    browser = "firefox ",
    man = "urxvt -e man ",
    terminal = "urxvt ", 
    screen = "urxvt -e screen",
    fileman = "urxvt -e mc",
    terminal_root = "urxvt -e su -c screen",
    im = "pidgin ",
    editor = os.getenv("EDITOR") or "urxvt -e vim ",
    home_dir = os.getenv("HOME"),
    music_show = "gmpc --replace",
    music_hide = "gmpc --quit",
    run = "gmrun",
    locker = "xscreensaver-command -lock",
    xkill = "xkill",
    poweroff = "sudo /sbin/poweroff",
    reboot = "sudo /sbin/reboot",
    hibernate = "sudo /usr/sbin/pm-hibernate",
    rotate = "rotator"
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
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
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

contextmenu_args = {
    coords={ x=0, y=0 },
    keygrabber = true
}

mainmenu_args = {
    coords={ x=0, y=0 },
    keygrabber = true
}

chord_menu_args = {
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
    awful.button({}, 1, nil, function () menu_current(mymainmenu, mainmenu_args) end)))

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mytop = {}
mybottom = {}
mypromptbox = {}

myclientmenu = {}
myclientmenu.timer = timer{ timeout=0.7 }
myclientmenu.timer:add_signal("timeout", function() 
    myclientmenu.suppress = nil 
    myclientmenu.timer:stop()
end)
myclientmenu.buttons = awful.util.table.join(
awful.button({ }, 1, function ()
    if myclientmenu.suppress ~= nil then return end
    if client.focus == nil then return end
    local menu, coords = client_contex_menu(client.focus)
    menu_current(menu, {coords = coords})
    myclientmenu.suppress = true
    myclientmenu.timer:start()
end))

-- On screen keyboard
mykbd = {}
mykbd.timer = timer{ timeout=0.7 }
mykbd.timer:add_signal("timeout", function() 
    mykbd.suppress = nil 
    mykbd.timer:stop()
end)
mykbd.buttons = awful.util.table.join(
awful.button({ }, 1, function ()
    if mykbd.suppress ~= nil then return end
    local clients = client.get()
    local xvkbd = nil
    for i, c in pairs(clients) do
        if c.class == "XVkbd" then 
            xvkbd = c 
            break 
        end
    end
    if xvkbd ~= nil then
        awful.util.spawn("killall xvkbd", false)
    else
        awful.util.spawn("xvkbd", false)
    end
    mykbd.suppress = true
    mykbd.timer:start()
end))

-- Clock
mytextclock = {}
mytextclock = widget({ type = "textbox", align="right" })
pipelets.register_fmt(mytextclock, "date", " $1 ")

-- Mountbox
mymountbox = widget({ type = "textbox", align="right" })
pipelets.register_fmt( mymountbox, "mmount", " $1")

-- BatteryBox
mybatbox = widget({ type = "textbox", align="right" })
pipelets.register( mybatbox, "batmon")

-- Kbdbox
mykbdbox = widget({ type = "textbox", align="right" })
pipelets.register_fmt( mykbdbox, "kbd", " $1 ")

-- Temp
mytemp = widget({ type = "textbox", align="right" })
pipelets.register_fmt( mytemp, "temp", " $1 ")

-- Wifi assoc ESSID
mywifibox = widget({ type = "textbox", align="right" })
pipelets.register_fmt( mywifibox, "wireless", "<span color='#4169E1'> $1</span>")

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
        if client.focus ~= c then 
            client.focus = c;
        end 
        client.focus:raise()
	end),
	awful.button({ }, 3, function (c) 
        local menu, coords = client_contex_menu(c)
        menu_current(menu, {coords = coords})
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
        awful.widget.taglist.label.all, 
        mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(
    function(c)
        local text,bg,st,icon = awful.widget.tasklist.label.currenttags(c, s)
        local usertext = awful.client.property.get(c, "name")
        if text ~= nil then
            if usertext ~= nil then text = usertext end
        end
        return text,bg,st,icon
    end, mytasklist.buttons)

    myclientmenu[s] = awful.widget.button({image = beautiful.clientmenu_icon})
    myclientmenu[s]:buttons(myclientmenu.buttons)

    mykbd[s] = awful.widget.button({image = beautiful.xvkbd_icon})
    mykbd[s]:buttons(mykbd.buttons)

    -- Create top wibox
    mytop[s] = awful.wibox({ 
		position = "top", screen = s, height = beautiful.wibox_height })
    mytop[s].widgets = {
        mylauncher,
        mylayoutbox[s],
        mytaglist[s],
        mypromptbox[s],
        {
            myclientmenu[s],
            s == 1 and mysystray or nil,
            mytextclock,
            layout = awful.widget.layout.horizontal.rightleft
        },
        mytasklist[s],
        layout = awful.widget.layout.horizontal.leftright,
        height = mytop[s].height
	}

    -- Create bottom wibox
    mybottom[s] = awful.wibox({ 
        position = "bottom", screen = s, height = beautiful.wibox_bottom_height })
    mybottom[s].widgets = {
        {
            mykbdbox,
            mykbd[s],
            layout = awful.widget.layout.horizontal.rightleft
        },
        mytemp,
        mybatbox,
        mymountbox,
        mywifibox,
        layout = awful.widget.layout.horizontal.leftright
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () menu_current(mymainmenu) end),
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
        if awful.layout.get() == awful.layout.suit.max then
            awful.client.focus.byidx(direction);  
        else
            awful.client.cycle(direction == 1)
            client.focus = awful.client.getmaster()
        end
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
            awful.util.spawn("mpc toggle", false)
        end},

        {{}, "n", "Next", function () 
            awful.util.spawn("mpc next", false)
        end},

        {{"Shift"}, "n", "Prev", function () 
            awful.util.spawn("mpc prev", false)
        end},

        {{}, "b", "Back", function () 
            awful.util.spawn("mpc seek 0%", false)
        end},

        {{}, "9", "Vol down", function () 
            awful.util.spawn("mpc volume -5", false)
            return false
        end},

        {{}, "0", "Vol up", function () 
            awful.util.spawn("mpc volume +5", false)
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
                myrc.tagman.move(t, myrc.tagman.next_to(awful.tag.selected())) 
            end, 
            awful.completion.bash,
            awful.util.getdir("cache") .. "/tag_new")
        end},

        {{}, "d", "Delete current tag", function () 
            local sel = awful.tag.selected()
            local def = myrc.tagman.prev_to(sel)
            myrc.tagman.del(sel,def) 
            awful.tag.viewonly(def)
        end}, 

        {{}, "k", "Move tag right", function () 
            local sel = awful.tag.selected()
            local tgt = myrc.tagman.next_to(sel)
            myrc.tagman.move(sel,tgt)
            return false
        end}, 

        {{}, "j", "Move tag left", function () 
            local sel = awful.tag.selected()
            local tgt = myrc.tagman.prev_to(sel)
            myrc.tagman.move(sel,tgt)
            return false
        end}
    }
end

-- Bind keyboard digits
globalkeys = awful.util.table.join(

    -- Main menu
    awful.key({ altkey            }, "Escape", function() 
        menu_current(mymainmenu,mainmenu_args) 
    end),

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
        local menu = client_contex_menu(c)
        menu_current(menu, contextmenu_args)
    end)
)

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
--}}}

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

-- TODO: Handle menu closing on mouse movements
--    c:add_signal("mouse::enter", function(c)
--        function kill_mousemode_menu(m) 
--            if m and (true ~= m.keygrabber) then m:hide() end 
--        end
--        kill_mousemode_menu(mymainmenu)
--        kill_mousemode_menu(mycontextmenu)
--    end)

    c:add_signal("mouse::enter", function(c)
        menu_hide()
    end)

	c:add_signal("property::floating", function(c) 
        c.border_width = get_layout_border(c)
	end)

    local name = client_name(c)
    if c.type == "dialog" then 
        save_snap(c, 'center')
    end

    local tag = get_tag(c, nil)
    if tag ~= nil then
        awful.client.movetotag(tag, c)
    end

    local floating = myrc.memory.get("floating", name)
    if floating ~= nil then 
        awful.client.floating.set(c, floating)
    else
        floating = awful.client.floating.get(c)
    end

    if floating == true then
        local dock = get_dockable(c, nil)
        if dock ~= nil then
            awful.client.dockable.set(c, dock)
        end
        local geom = myrc.memory.get("geometry", name)
        if geom ~= nil then
            c:geometry(geom)
        end
        local maxhor = get_hor(c, nil)
        if maxhor ~= nil then
            c.maximized_horizontal = maxhor
        end
        local maxvert = get_vert(c, nil)
        if maxvert ~= nil then
            c.maximized_vertical = maxvert
        end
        local snap = get_snap(c, nil)
        if snap ~= nil then
            client_snap(c, snap, geom)
        end
    end

    local hidme = get_hidden(c, nil)
    if hidme ~= nil then
        c.skip_taskbar = hidme
    end

    local titlebar = get_titlebar(c,nil)
    if titlebar == true then
        awful.titlebar.add(c, { modkey = modkey })
    else
        awful.titlebar.remove(c)
    end

    -- Set key bindings
    c:buttons(clientbuttons)
    c:keys(clientkeys)

    -- Set default app icon
    if not c.icon and theme.default_client_icon then
        c.icon = image(theme.default_client_icon)
    end

    -- New client may not receive focus
    -- if they're not focusable, so set border anyway.
    c.border_width = get_layout_border(c)
    c.border_color = beautiful.border_normal
    c.size_hints_honor = false

    if not c.skip_taskbar then
        client.focus = c
    end

    -- XVkbd hack
    if c.class == "XVkbd" then
        local sg = screen[1].geometry
        c.maximized_horizontal = sg.height > sg.width
    end
end)

-- Signal from tagman lib. 
-- Handler will store tag names to registry.
-- Those names will be used at next awesome start
-- to recreate current tags.
awesome.add_signal("tagman::update", function (t) 
    myrc.memory.set("tagnames","-", myrc.tagman.names())
end)

-- Will change border width for max layout
for s = 1, screen.count() do
    awful.tag.attached_add_signal(s,"property::layout", function()
        for _,c in pairs(awful.tag.selected():clients()) do
            c.border_width = get_layout_border(c)
        end
    end)
end

