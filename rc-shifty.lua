-- Include awesome libraries, with lots of useful function!
require("awful")
require("beautiful")
require("naughty")
require("shifty")
require("freedesktop.utils")
require("freedesktop.menu")

-- Helper functions {{{
--{{{ Debug 
function dbg(vars)
	local text = ""
	for i=1, #vars do text = text .. tostring(vars[i]) .. " | " end
	naughty.notify({ text = text, timeout = 0 })
end
--}}}

--{{{ Menu generators
-- Create a symlink from the given theme to /home/user/.config/awesome/current_theme
function theme_load(theme)
	local cfg_path = awful.util.getdir("config")
	awful.util.spawn("ln -sf " .. cfg_path .. "/themes/" .. theme .. " " .. cfg_path .. "/current_theme")
	awesome.restart()
end

-- List your theme files and feed the menu table
function build_theme_menu()
	local mythememenu = {}
	local cmd = "ls -1 " .. awful.util.getdir("config") .. "/themes/"
	local f = io.popen(cmd)
	for l in f:lines() do
		local item = { l, function () theme_load(l) end }
		table.insert(mythememenu, item)
	end

	f:close()
	return mythememenu
end

-- Builds menu for client c
function build_client_menu(c)
	if mycontextmenu then awful.menu.hide(mycontextmenu) end
	mycontextmenu = awful.menu.new( { 
		items = { 
			{ "Close", function() c:kill() end ,
				freedesktop.utils.lookup_icon({ icon = 'gtk-stop' })} ,
			{ "Floating", function() awful.client.floating.set(c, not awful.client.floating.get(c)) end ,
				beautiful.tasklist_floating_icon  }
		}, 
		height = beautiful.menu_context_height 
	} )
	mycontextmenu:show()
end--}}}
--}}}

-- {{{ Variable definitions
-- Default modkey.
modkey = "Mod4"

-- Helper variables
browser = "firefox"
terminal = "xterm -e screen"
terminal_root = "xterm -e su -c screen"
terminal_pure = "xterm"
im = "pidgin"
editor = os.getenv("EDITOR") or "gvim"
editor_cmd = "xterm -e " .. editor

home_dir = os.getenv("HOME")
beautiful.init(awful.util.getdir("config") .. "/current_theme")

-- Freedesktop variables
freedesktop.utils.terminal = terminal
freedesktop.utils.icon_theme = 'Tango' -- look inside /usr/share/icons/, default: nil (don't use icon theme)
freedesktop.utils.icon_sizes = {'32x32'}

-- Noughty
--naughty.config.border_color = '#7985A3'
naughty.config.position = 'top_right'

-- Misc
use_titlebar = true

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = 
{
    awful.layout.suit.max,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

shifty.config.tags = {
	["1:work"] = 
		{ 
			layout = awful.layout.suit.max,
			init = true, position = 1 
		},
	["2:www"]  = 
		{ 
			layout = awful.layout.suit.max,
			exclusive = true, position = 2, spawn = "firefox", float = false,
		},
	["3:icq"]  = 
		{ 
			layout = awful.layout.suit.bottom,
			exclusive = true, position = 3
		},
	["4:mus"]  = 
		{ 
			layout = awful.layout.suit.max,
			position = music_tag_position , 
			spawn = "urxvt -e bash -c 'sleep 0.2; ncmpcpp'" 
		},
	["gimp"]   = 
		{ 
			layout = awful.layout.suit.tile.left, float = false,
		},
	--	{ 
	--		layout = awful.layout.suit.tile,
	--		mwfact = 0.2 
	--	},
	["vbox"]   = 
		{ 
			layout = awful.layout.suit.max,
			exclusive = true 
		},
}

shifty.config.apps = {
	{ match = {"xterm"}, 
		tag = "1:work"
	},
	{ match = {"Browser", "Mozilla" }, 
		tag = "2:www", float = true, nopopup = true
	},
	{ match = {"Firefox.*", "Opera"}, 
		tag = "2:www"
	},
	{ match = {"Skype","pidgin"}, 
		tag = "3:icq"
	},
	--{ match = {"Gimp", "Gimp-2.6"},
		--tag = "gimp", float = false,
	--},
	{ match = {"Vncviewer"}, 
		tag = "dcpp"
	},
	{ match = {"gqview"}, 
		tag = "gqview"
	},
	{ match = {"gcolor2","xmag"}, 
		intrusive = true, float = true, geometry = { 100,100,nil,nil },
	},
	{ match = {"Wine"}, 
		float = true, geometry = { x= 100, y = 100 }, nopopup = true
	},
	{ match = {"VirtualBox"}, 
		tag = "vbox"
	}
}

shifty.config.defaults = {
  floatBars=true,
  layout = awful.layout.suit.tile.max, 
  run = function(tag) naughty.notify({ text = tag.name }) end,
}

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

-- Creating main menu
myawesomemenu = { 
	{ "Manual", "xterm -e man awesome", 
		freedesktop.utils.lookup_icon({ icon = 'help' }) 
	},
	{ "Edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua", 
		freedesktop.utils.lookup_icon({ icon = 'package_settings' }) 
	},
	{ "Edit theme", editor_cmd .. " " .. awful.util.getdir("config") .. "/current_theme" ,
		freedesktop.utils.lookup_icon({ icon = 'package_settings' }) 
	},
	{ "Themes", build_theme_menu() },
}

mymainmenu_items_head = {
	{ "Awesome", myawesomemenu, beautiful.awesome_icon },
	{ "Terminal", terminal, 
		freedesktop.utils.lookup_icon({icon = 'terminal'}) },
	{"", nil, nil} --separator
}

mymainmenu_items_tail = {
	{"", nil, nil}, --separator
	{ "Restart", awesome.restart, 
		freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) 
	},
	{ "Quit", awesome.quit, 
		freedesktop.utils.lookup_icon({ icon = 'gnome-logout' }) 
	} 
}

mymainmenu_items = {}
for _, item in ipairs(mymainmenu_items_head) do table.insert(mymainmenu_items, item) end
for _, item in ipairs(freedesktop.menu.new()) do table.insert(mymainmenu_items, item) end
for _, item in ipairs(mymainmenu_items_tail) do table.insert(mymainmenu_items, item) end

mymainmenu = awful.menu.new({ items = mymainmenu_items })

-- Empty launcher
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Create a systray
mysystray = widget({ type = "systray", align = "right" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}

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
mytasklist.buttons = { button({ }, 1, function (c)
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
                                      end) }

for s = 1, screen.count() do

    -- Create a promptbox for each screen
    mypromptbox[s] = widget({ type = "textbox", align = "left" })

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = widget({ type = "imagebox", align = "left" })
    mylayoutbox[s]:buttons({ 
		button({ }, 1, function () awful.layout.inc(layouts, 1) end),
		button({ }, 3, function () awful.layout.inc(layouts, -1) end),
		button({ }, 4, function () awful.layout.inc(layouts, 1) end),
		button({ }, 5, function () awful.layout.inc(layouts, -1) end) 
	})

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

shifty.taglist = mytaglist
shifty.init()
-- }}}

-- {{{ Mouse bindings
root.buttons({
    button({ }, 3, function () mymainmenu:show() end),
    button({ }, 4, awful.tag.viewnext),
    button({ }, 5, awful.tag.viewprev)
})
-- }}}

-- {{{ Key bindings
-- Standard program
function awesome_restart()
	mypromptbox[mouse.screen].text = awful.util.escape(awful.util.restart())
end

function open_terminal_as(is_root)
	if is_root == "root" then
		awful.util.spawn(terminal_root) 
	else
		awful.util.spawn(terminal)
	end
end

function switch_to_client(direction)
	if direction == 0 then
		awful.client.focus.history.previous()
	else
		awful.client.focus.byidx(direction);  
	end
	if client.focus then client.focus:raise() end
end

-- Bind keyboard digits
globalkeys = {
	key({ modkey }, "Escape", function() mymainmenu:show() end),

	key({ modkey, "Control" }, "r", function() awesome_restart() end),
	key({ modkey, "Control" }, "q", awesome.quit),

    key({ "Mod1", }, "F1", awful.tag.viewprev ),
    key({ "Mod1", }, "F2", awful.tag.viewnext ),
	key({ modkey, }, "F1", shifty.send_prev),-- move client to prev tag
	key({ modkey, }, "F2", shifty.send_next),-- move client to next tag

	-- Client manipulation
	key({ modkey }, "f", function () awful.util.spawn(browser) end),
	key({ modkey }, "i", function () awful.util.spawn(im) end),
	key({ modkey }, "e", function () open_terminal_as("user") end),
	key({ modkey }, "r", function () open_terminal_as("root") end),

	key({ "Mod1" }, "j", function () switch_to_client(-1) end),
	key({ "Mod1" }, "k", function () switch_to_client(1) end),
	key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(1) end),
	key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx(-1) end),
	key({ modkey, "Control" }, "j", function () awful.screen.focus(1) end),
	key({ modkey, "Control" }, "k", function () awful.screen.focus(-1) end),
	key({ modkey }, "Tab", function() switch_to_client(0) end),
	key({ "Mod1" }, "Tab", function() switch_to_client(0) end),
	key({ modkey }, "u", awful.client.urgent.jumpto),

	-- Layout manipulation
	key({ modkey }, "h", function () awful.tag.incmwfact(-0.05) end),
	key({ modkey }, "l", function () awful.tag.incmwfact(0.05) end),
	key({ modkey, "Shift" }, "h", function () awful.tag.incnmaster(1) end),
	key({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1) end),
	key({ modkey, "Control" }, "h", function () awful.tag.incncol(1) end),
	key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1) end),
	key({ modkey }, "space", function () awful.layout.inc(layouts, 1) end),
	key({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end),

	-- Prompt
	key({ modkey }, "F5", 
		function ()
			awful.prompt.run(
			{ prompt = "Run: " }, 
			mypromptbox[mouse.screen], 
			awful.util.spawn, 
			awful.completion.bash,
			awful.util.getdir("cache") .. "/history")
		end),

	key({ modkey }, "F6", 
		function ()
			awful.prompt.run(
			{ prompt = "Run Lua code: " }, 
			mypromptbox[mouse.screen], 
			awful.util.eval, 
			awful.prompt.bash,
			awful.util.getdir("cache") .. "/history_eval")
		end),

	key({ modkey, "Ctrl" }, "i", 
		function ()
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
			end
		end)
}

root.keys(globalkeys)

-- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
clientkeys =
{
	key({ "Mod1" }, "F4", function (c) c:kill() end),
    key({ modkey }, "s", function (c) c.fullscreen = not c.fullscreen  end),
    key({ modkey }, "m", function(c) awful.client.floating.set(c, not awful.client.floating.get(c)) end),
    key({ modkey }, "t", awful.client.togglemarked ),
    key({ modkey }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
}
shifty.config.clientkeys = clientkeys
-- }}}

-- {{{ Hooks
-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end
	if mymainmenu then mymainmenu:hide() end
	if mycontextmenu then mycontextmenu:hide() end
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end
end)

-- Hook function to execute when marking a client
awful.hooks.marked.register(function (c)
    c.border_color = beautiful.border_marked
	dbg({'marked'})
end)

-- Hook function to execute when unmarking a client.
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
	dbg({'unmarked'})
end)

-- Hook function to execute when a new client appears.
--awful.hooks.manage.register(function (c)
    -- New client may not receive focus
    -- if they're not focusable, so set border anyway.

 --   if awful.client.floating.get(c) then
--		awful.placement.centered(c, c.transient_for)
--		awful.placement.no_offscreen(c)
--    end

    -- Do this after tag mapping, so you don't see it on the wrong tag for a split second.

    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)

    -- Honor size hints: if you want to drop the gaps between windows, set this to false.

	-- Add keys
    --c:keys(clientkeys)

    -- Add mouse bindings
    --c:buttons({
        --button({ }, 1, function (c) client.focus = c; c:raise() end),
        --button({ modkey }, 1, awful.mouse.client.move),
        --button({ modkey }, 3, awful.mouse.client.resize)
    --})
--end)

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

-- vim: filetype=lua
