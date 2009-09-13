-- Include awesome libraries, with lots of useful function!
require("awful")
require("beautiful")
require("naughty")
require("freedesktop.utils")
require("freedesktop.menu")

require("tsave")

require("myrc.mainmenu")
require("myrc.tagman")
require("myrc.themes")
require("myrc.keybind")
require("myrc.memory")

--{{{ Debug 
function dbg(vars)
	local text = ""
	for i=1, #vars do text = text .. tostring(vars[i]) .. " | " end
	naughty.notify({ text = text, timeout = 0 })
end
--}}}

--{{{ Menu generators
function client_name(c)
    local cls = c.class or ""
    local inst = c.instance or ""
	local role = c.role or ""
	return cls..":"..inst..":"..role
end

function get_floating(c)
	return myrc.memory.get("floating", client_name(c), 
		awful.client.floating.get(c))
end

function save_floating(c, f)
	myrc.memory.set("floating", client_name(c), f)
	awful.client.floating.set(c, f)
	return f
end

function save_centered(c, val)
	myrc.memory.set("centered", client_name(c), val)
	awful.placement.centered(c)
	return val
end

function get_centered(c)
	return myrc.memory.get("centered", client_name(c), nil)
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

function get_titlebar(c)
	return myrc.memory.get("titlebar", client_name(c), false)
end

-- Builds menu for client c
function build_client_menu(c)
	if mycontextmenu then awful.menu.hide(mycontextmenu) end
	local centered = get_centered(c)
	local floating = get_floating(c)
	local titlebar = get_titlebar(c)
	function checkbox(name, val) 
		if val==true then return "[on] "..name 
		elseif val==false then return "[off] " .. name 
		else return "[auto] " .. name 
		end 
	end
	mycontextmenu = awful.menu.new( { 
		items = { 
			{ "Close", function() c:kill() 
				end, freedesktop.utils.lookup_icon({ icon = 'gtk-stop' })} ,
			{ checkbox("Floating",floating), function() 
				save_floating(c, not floating) 
				end, beautiful.tasklist_floating_icon  },
			{ checkbox("Centered", centered), function() 
				save_centered(c, not centered) 
				end,   },
			{ checkbox("Titlebar", titlebar), function() 
				save_titlebar(c, not titlebar) 
				end,   },
			{ "Maximize", function () 
				c.maximized_horizontal = not c.maximized_horizontal
				c.maximized_vertical   = not c.maximized_vertical
				end, beautiful.layout_max  }
		}, 
		height = beautiful.menu_context_height 
	} )
	mycontextmenu:show()
end
--}}}

-- {{{ Variable definitions
-- Default modkey.
modkey = "Mod4"

-- Helper variables
env = {
	browser = "firefox ",
	man = "xterm -e man ",
	terminal = "xterm ", 
	screen = "xterm -e screen ",
	terminal_root = "xterm -e su -c screen ",
	im = "pidgin ",
	editor = os.getenv("EDITOR") or "xterm -e vim ",
	home_dir = os.getenv("HOME"),
	music_show = "gmpc --replace",
	music_hide = "gmpc --quit",
}

-- Noughty
naughty.config.position = 'top_right'

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
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

myrc.memory.init()

beautiful.init(myrc.themes.current())

myrc.mainmenu.init(env)

myrc.tagman.init()

--awful.titlebar.button_groups.close_buttons.align = "right"

-- }}}

-- {{{ Wibox
-- Create a textbox widget
mytextbox = widget({ type = "textbox", align = "right" })
mytextbox:buttons({ 
	button({ }, 1, function () awful.util.spawn("cal | awnaughty -t 0 -w 140 ' ' - ") end),
	button({ }, 3, function () awful.layout.inc(layouts, -1) end),
	button({ }, 4, function () awful.layout.inc(layouts, 1) end),
	button({ }, 5, function () awful.layout.inc(layouts, -1) end) 
})

-- Empty launcher
mymainmenu = myrc.mainmenu.build()
mylauncher = awful.widget.launcher({ 
	image = beautiful.awesome_icon, menu = mymainmenu })

-- Create a systray
mysystray = widget({ type = "systray", align = "right" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}

mylayoutbox = {}
mylayoutbox.buttons = { 
	button({ }, 1, function () 
		awful.layout.inc(layouts, 1) 
		naughty.notify({text = awful.layout.getname(awful.layout.get(1))}) 
	end),
	button({ }, 3, function () 
		awful.layout.inc(layouts, -1) 
		naughty.notify({text = awful.layout.getname(awful.layout.get(1))}) 
	end),		
	button({ }, 4, function () awful.layout.inc(layouts, 1) end),
	button({ }, 5, function () awful.layout.inc(layouts, -1) end) 
}

-- Taglist
mytaglist = {}
mytaglist.buttons = { 
	button({ }, 1, awful.tag.viewonly),
	button({ modkey }, 1, awful.client.movetotag),
	button({ }, 3, function (tag) tag.selected = not tag.selected end),
	button({ modkey }, 3, awful.client.toggletag),
	button({ }, 4, awful.tag.viewnext),
	button({ }, 5, awful.tag.viewprev) 
}




-- Tasklist
mytasklist = {}
mytasklist.buttons = { 
	button({ }, 1, function (c)
		if not c:isvisible() then
			awful.tag.viewonly(c:tags()[1])
		end
		client.focus = c
		c:raise()
	end),
	button({ }, 3, function (c) build_client_menu(c) end),
	button({ }, 4, function ()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end),
	button({ }, 5, function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end) 
}

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = widget({ type = "textbox", align = "left" })

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = widget({ type = "imagebox", align = "left" })
    mylayoutbox[s]:buttons(mylayoutbox.buttons)

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist.new(
		function(c)
			return awful.widget.tasklist.label.currenttags(c, s)
		end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = wibox({ 
		position = "top", 
		fg = beautiful.fg_normal, 
		bg = beautiful.bg_normal 
	})

    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = { 
		mylauncher,
		mylayoutbox[s],
		mytaglist[s],
		mytasklist[s],
		mypromptbox[s],
		mytextbox,
		s == 1 and mysystray or nil 
	}

    mywibox[s].screen = s
end
-- }}}

-- {{{ Mouse bindings
root.buttons({
    button({ }, 3, function () awful.menu.show(mymainmenu) end),
    button({ }, 4, awful.tag.viewnext),
    button({ }, 5, awful.tag.viewprev)
})
-- }}}

-- {{{ Key bindings
-- Standard program

function switch_to_client(direction)
	if direction == 0 then
		awful.client.focus.history.previous()
	else
		awful.client.focus.byidx(direction);  
	end
	if client.focus then client.focus:raise() end
end

muskeys = {
    myrc.keybind.key({}, "Escape", "Cancel", function () 
		myrc.keybind.pop(muskeys) 
	end),
	myrc.keybind.key({}, "u", "Volume up", function()
		dbg({"vup"})
		myrc.keybind.pop(muskeys)
	end)
}

tagkeys = {
    myrc.keybind.key({}, "Escape", "Cancel", function () 
		myrc.keybind.pop(tagkeys) 
	end),
    myrc.keybind.key({}, "s", "Rename current tag", function () 
        awful.prompt.run(
            { prompt = "Rename this tag: " }, 
            mypromptbox[mouse.screen], 
            function(newname) 
				myrc.tagman.rename(awful.tag.selected(),newname) 
			end, 
            awful.completion.bash,
            awful.util.getdir("cache") .. "/tag_rename")
		myrc.keybind.pop(tagkeys);
    end),

	myrc.keybind.key({}, "c", "Create new tag", function () 
		awful.prompt.run(
			{ prompt = "Create new tag: " }, 
			mypromptbox[mouse.screen], 
			function(newname) 
				local t = myrc.tagman.add(newname) 
				myrc.tagman.move(t, awful.tag.selected()) 
			end, 
			awful.completion.bash,
			awful.util.getdir("cache") .. "/tag_new")
		myrc.keybind.pop(tagkeys);
	end),

	myrc.keybind.key({}, "d", "Delete current tag", function () 
		myrc.tagman.del(awful.tag.selected()) 
		myrc.keybind.pop(tagkeys);
	end),
}

for i=1,9 do
	table.insert(tagkeys, 
	myrc.keybind.key({}, tostring(i), "Move tag to position " .. tostring(i), function()
		myrc.tagman.move(awful.tag.selected(), i)
		myrc.keybind.pop(tagkeys)
	end))
end

-- Bind keyboard digits
globalkeys = {

	-- Application hotkeys
	key({ modkey            }, "f", function () awful.util.spawn(env.browser) end),
	key({ modkey            }, "i", function () awful.util.spawn(env.im) end),
	key({ modkey            }, "e", function () awful.util.spawn(env.screen)  end),
	key({ modkey            }, "r", function () awful.util.spawn(env.terminal_root) end),
	key({ "Mod1"            }, "Escape", function() myrc.mainmenu.show_at(mymainmenu,true) end),
	key({ modkey, "Control" }, "r", function() 
		mypromptbox[mouse.screen].text = awful.util.escape(awful.util.restart())
	end),
	key({ modkey, "Control" }, "q", awesome.quit),

	-- Client manipulation
	key({ "Mod1"            }, "j", function () switch_to_client(-1) end),
	key({ "Mod1"            }, "k", function () switch_to_client(1) end),
	key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(1) end),
	key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx(-1) end),
	key({ modkey, "Control" }, "j", function () awful.screen.focus(1) end),
	key({ modkey, "Control" }, "k", function () awful.screen.focus(-1) end),
	key({ modkey            }, "Tab", function() switch_to_client(0) end),
	key({ "Mod1"            }, "Tab", function() switch_to_client(0) end),

	-- Layout manipulation
    key({ "Mod1",           }, "F1", awful.tag.viewprev ),
    key({ "Mod1",           }, "F2", awful.tag.viewnext ),
	key({ modkey,           }, "h", function () awful.tag.incmwfact(-0.05) end),
	key({ modkey,           }, "l", function () awful.tag.incmwfact(0.05) end),
	key({ modkey, "Shift"   }, "h", function () awful.tag.incnmaster(1) end),
	key({ modkey, "Shift"   }, "l", function () awful.tag.incnmaster(-1) end),
	key({ modkey, "Control" }, "h", function () awful.tag.incncol(1) end),
	key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1) end),
	key({ modkey,           }, "space", function () awful.layout.inc(layouts, 1) end),
	key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

	key({ modkey, "Control"   }, "s", function () 
		myrc.keybind.push(tagkeys, "Do smth on tags") 
	end),

	key({ modkey }, "w", function () 
		myrc.keybind.push(muskeys, "Enter music command") 
	end),

	-- Prompt
	key({ modkey }, "F5", function ()
		awful.prompt.run(
			{ prompt = "Run: " }, 
			mypromptbox[mouse.screen], 
			awful.util.spawn, 
			awful.completion.bash,
			awful.util.getdir("cache") .. "/history")
	end),

	key({ modkey }, "F6", function ()
		awful.prompt.run(
			{ prompt = "Run Lua code: " }, 
			mypromptbox[mouse.screen], 
			awful.util.eval, 
			awful.prompt.bash,
			awful.util.getdir("cache") .. "/history_eval")
	end),

	key({ modkey, "Ctrl" }, "m", function ()
		for k, i in ipairs(tagkeys) do
			dbg({ i.keysym  })
		end
	end),

	key({ modkey, "Ctrl" }, "i", function ()
		local s = mouse.screen
		if mypromptbox[s].text then
			mypromptbox[s].text = nil
		elseif client.focus then
			mypromptbox[s].text = nil
			if client.focus.class then
				mypromptbox[s].text = 
				"Class: " .. client.focus.class .. " "
			end
			if client.focus.instance then
				mypromptbox[s].text = 
				mypromptbox[s].text .. "Instance: ".. client.focus.instance .. " "
			end
			if client.focus.role then
				mypromptbox[s].text = 
				mypromptbox[s].text .. "Role: ".. client.focus.role
			end
			if client.focus.type then
				mypromptbox[s].text = 
				mypromptbox[s].text .. "Type: ".. client.focus.type
			end
		end
	end)
}

root.keys(globalkeys)

-- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
clientkeys = {
    key({ modkey }, "F1", 
		function (c) 
			local tag = myrc.tagman.getn(-1)
			awful.client.movetotag(tag, c)
			awful.tag.viewonly(tag)
		end),
    key({ modkey }, "F2", 
		function (c) 
			local tag = myrc.tagman.getn(1)
			awful.client.movetotag(tag, c)
			awful.tag.viewonly(tag)
		end),
	key({ "Mod1" }, "F4", function (c) c:kill() end),
    key({ "Mod1" }, "F5",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
    key({ modkey }, "s", function (c) c.fullscreen = not c.fullscreen  end),
    key({ modkey }, "m", function(c) save_floating(c, not awful.client.floating.get(c)) end),
    key({ modkey }, "t", awful.client.togglemarked ),
}
-- }}}

-- {{{ Hooks
-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end
	if mymainmenu then awful.menu.hide(mymainmenu) end
	if mycontextmenu then awful.menu.hide(mycontextmenu) end
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end
	if mymainmenu then awful.menu.hide(mymainmenu) end
	if mycontextmenu then awful.menu.hide(mycontextmenu) end
end)

-- Hook function to execute when marking a client
awful.hooks.marked.register(function (c)
    c.border_color = beautiful.border_marked
end)

-- Hook function to execute when unmarking a client.
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
end)

-- Hook function to execute when a new client appears.
awful.hooks.manage.register(function (c)
    if use_titlebar then
        awful.titlebar.add(c, { modkey = modkey })
    end

	local name = client_name(c)
	local floating = myrc.memory.get("floating", name, awful.client.floating.get(c))
	save_floating(c, floating)
	if floating == true then
		local centered = get_centered(c)
		if centered ~= false then 
			awful.placement.centered(c)
		end
		local c_geometry = c:geometry()
		if c_geometry.x < 0 or c_geometry.y < 0 then
			awful.placement.centered(c)
		end
		local titlebar = get_titlebar(c)
		if titlebar == true then
			save_titlebar(c, titlebar)
		end
	end

    -- Add mouse bindings
    c:buttons({
        button({ }, 1, function (c) client.focus = c; c:raise() end),
        button({ modkey }, 1, awful.mouse.client.move),
        button({ modkey }, 3, awful.mouse.client.resize)
    })

    -- New client may not receive focus
    -- if they're not focusable, so set border anyway.
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal

    -- Do this after tag mapping, so you don't see it on the wrong tag for a split second.
    client.focus = c

    c.size_hints_honor = false

    -- Set key bindings
    c:keys(clientkeys)

	if not c.icon and theme.default_client_icon then
		c.icon = image(theme.default_client_icon)
	end
end)

-- Hook function to execute when arranging the screen.
-- (tag switch, new client, etc)
awful.hooks.arrange.register(function (screen)
    local layout = awful.layout.getname(awful.layout.get(screen))
    if layout and beautiful["layout_" ..layout] then
        mylayoutbox[screen].image = image(beautiful["layout_" .. layout])
    else
        mylayoutbox[screen].image = nil
    end

    -- Give focus to the latest client in history if no window has focus
    -- or if the current window is a desktop or a dock one.
    if not client.focus then
        local c = awful.client.focus.history.get(screen, 0)
        if c then client.focus = c end
    end
end)

-- Hook called every second
awful.hooks.timer.register(1, function ()
	 mytextbox.text = " " .. os.date("%d %B %Y  %k:%M:%S") .. " "
end)
-- }}}

