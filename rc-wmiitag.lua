-- Standard awesome library
require("awful")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- wikipedia
require("wikipedia")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- The default is a dark theme
-- theme_path = "/usr/share/awesome/themes/default/theme.lua"
-- Uncommment this for a lighter theme
-- theme_path = "/usr/share/awesome/themes/sky/theme.lua"
theme_path = "/home/goj/.config/awesome/theme.lua"

-- Use right wallpaper based on screen count
if screen.count() == 1 then
    os.execute("ln -sf ~/dokumenty/cow-push-1280x800.png ~/.config/awesome/wallpaper.png")
else
    os.execute("ln -sf ~/dokumenty/cow-push2-2650x1024e.png ~/.config/awesome/wallpaper.png")
end

-- Actually load theme
beautiful.init(theme_path)

-- This is used later as the default terminal and editor to run.
terminal = "sakura"
browser = "epiphany"
alt_browser = "firefox"
editor = os.getenv("EDITOR")
editor_cmd = "gvim"
dmenu = "dmenu_path | dmenu | xargs sh -c" 

-- {{{ Utilities
function dictlen(tbl)
    local result = 0
    for _, __ in pairs(tbl) do
        result = result + 1
    end
    return result
end

function get_keys(tbl)
    local result = {}
    for key, _ in pairs(tbl) do
        if key then table.insert(result, key) end
    end
    return result
end

function confirm_menu(name, command)
    return function()
        local menu = awful.menu.new({items = {{name,     command},
                                              {"cancel", function() end}}})
        menu:show(true)
    end
end

function get_known_hosts()
    local hosts = {}
    for host in io.popen('cat .ssh/known_hosts | cut -d " " -f 1 | sed -e "{s/,/\\n/g}"'):lines() do
        table.insert(hosts, host)
    end
    return hosts
end

function make_spawner(command)
    return function() awful.util.spawn(command) end
end

function make_completer(choices)
    return function(cmd, cur_pos, ncomp)
        local matches = {}
        -- abort completion under certain circumstances
        if #cmd == 0 or (cur_pos ~= #cmd + 1 and cmd:sub(cur_pos, cur_pos) ~= " ") then
            return cmd, cur_pos
        end     
        -- match
        for _, match in pairs(choices) do
            if match:find("^" .. cmd:sub(1,cur_pos)) then
                table.insert(matches, match)
            end     
        end       
        -- if there are no matches
        if #matches == 0 then
            return cmd, cur_pos
        end 
        -- cycle
        while ncomp > #matches do
            ncomp = ncomp - #matches
        end     
        -- return match and position
        return matches[ncomp], cur_pos
    end
end

function tag_prompt(txt, callback)
    return function()
        local screen = mouse.screen
        awful.prompt.run({ prompt = txt }, 
        mypromptbox[screen].widget,
        function(t) callback(screen, t) end,
        make_completer(get_keys(tags[screen])),
        awful.util.getdir("cache") .. "/history_tags")
    end
end
-- }}}

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
--
-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

-- Table of clients that should be set floating. The index may be either
-- the application class or instance. The instance is useful when running
-- a console app in a terminal like (Music on Console)
--    xterm -name mocp -e mocp
floatapps =
{
    -- by class
    ["MPlayer"] = true,
    ["pinentry"] = true,
    ["gimp"] = true,
    ["Volwheel"] = true,
    -- by instance
    ["mocp"] = true
}

-- Applications to be moved to a pre-defined tag by class or instance.
-- Use the screen and tags indices.
apptags =
{
     ["Thunderbird-bin"] = { screen = 1, tag = "mail" },
     ["Xchat"] = { screen = 1, tag = "irc" },
     --["pidgin"] = { screen = 1, tag = "im" },
}

-- Define if we want to use titlebar on all applications.
use_titlebar = false
-- }}}

-- {{{ Tags
-- Define tags table.
tags = {}

-- put all clients with no tags to "0" tag on screen 1
function handle_orphans()
    for _, c in pairs(client.get()) do
        if #c:tags() == 0 then
            c:tags({get_tag(1, "0")})
        end
    end
end

function sort_tags(screen_no)
    local all_tags = screen[screen_no]:tags()
    table.sort(all_tags, function (a, b) return a.name < b.name end)
    screen[screen_no]:tags(all_tags)
end

function delete_tag(screen_no, name)
    local strname = '' .. name
    if protected_tag == screen_no .. strname then return end
    local result = tags[screen_no][strname]
    if result ~= nil then
        result.screen = nil
        tags[screen_no][strname] = nil
    end
end

-- gets or creates tag
function get_tag(screen_no, name)
    local strname = '' .. name
    local result = tags[screen_no][strname]
    if not tags[screen_no][strname] then
        protected_tag = screen_no .. strname
        result = tag(strname)
        result.screen = screen_no
        tags[screen_no][strname] = result
        awful.layout.set(layouts[1], result)
    end
    protected_tag = nil
    return result
end


for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = {}
    get_tag(s, 1).selected = true
end
-- }}}

-- {{{ Wibox
-- Create a textbox widget
mytextbox = widget({ type = "textbox", align = "right" })
-- Set the default text in textbox
mytextbox.text = "<b><small> " .. awesome.release .. " </small></b>"

-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu.new({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                        { "exit", {
                                            {"hibernate", "sudo hibernate"},
                                            {"reboot",    "sudo reboot"},
                                            {"shutdown",  "sudo shutdown -h now"}
                                        }},
                                        { "open terminal", terminal }
                                      }
                            })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })

-- Create a systray
mysystray = widget({ type = "systray", align = "right" })



-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, function (tag) tag.selected = not tag.selected end),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ align = "left" })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = widget({ type = "imagebox", align = "right" })
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                                  return awful.widget.tasklist.label.currenttags(c, s)
                                              end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = wibox({ position = "bottom", fg = beautiful.fg_normal, bg = beautiful.bg_normal })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = { mylauncher,
                           mypromptbox[s],
                           mytaglist[s],
                           mytasklist[s],
                           mytextbox,
                           mylayoutbox[s],
                           s == 1 and mysystray or nil }
    mywibox[s].screen = s
end
-- }}}

-- {{{ Naughty configuration
naughty.config.presets.normal.position = 'bottom_right'
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "a", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus( 1)       end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus(-1)       end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- quit & restart
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- Standard programs
    awful.key({ modkey,           }, "p",       function() os.execute(dmenu .. " &")    end),
    awful.key({ modkey,           }, "Return",  make_spawner(terminal)),
    awful.key({ modkey,           }, "w",       make_spawner(browser)),
    awful.key({ modkey,           }, "v",       make_spawner(editor_cmd)),
    awful.key({ modkey, "Shift"   }, "x",       make_spawner("xkill")),

    -- multimedia keys
    awful.key({ }, "XF86HomePage", function () awful.util.spawn(alt_browser)            end),
    awful.key({ }, "XF86Sleep",    confirm_menu("hibernate", "sudo hibernate"))             ,

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    awful.key({ modkey }, "e",
              function () awful.prompt.run({ prompt = "Wikipedia: " }, 
                  mypromptbox[mouse.screen].widget,
                  function (article)
                      awful.util.spawn(browser .. " 'http://en.wikipedia.org/wiki/" .. article .. "'")
                  end,
                  wikipedia_complete,
                  awful.util.getdir("cache") .. "/history_wikipedia")
              end),

    awful.key({ modkey }, "s",
              function () awful.prompt.run({ prompt = "SSH: " }, 
                  mypromptbox[mouse.screen].widget,
                  function (host)
                      awful.util.spawn(terminal .. " -t 'SSH: " .. host .. "' -e 'ssh " .. host .. "'")
                  end,
                  make_completer(get_known_hosts()),
                  awful.util.getdir("cache") .. "/history_ssh")
              end),

    awful.key({ modkey,           },       "t", tag_prompt("go to tag: ",   function (screen, tag) awful.tag.viewonly(get_tag(screen, tag)) end)),
    awful.key({ modkey, "Shift"   },       "t", tag_prompt("move to tag: ", function (screen, tag) awful.client.movetotag(get_tag(screen, tag)) end)),
    awful.key({ modkey, "Ctrl", "Shift" }, "t", tag_prompt("toggle tag: ",  function (screen, tag) awful.tag.toggletag(get_tag(screen, tag)) end))
)

-- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey, "Ctrl"    }, "t", awful.client.togglemarked),
    awful.key({ modkey,}, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

for i = 0, 9 do
    table.foreach(awful.key({ modkey }, i,
                  function ()
                        local screen = mouse.screen
                        awful.tag.viewonly(get_tag(screen, i))
                  end), function(_, k) table.insert(globalkeys, k) end)
    table.foreach(awful.key({ modkey, "Control" }, i,
                  function ()
                      local screen = mouse.screen
                      local tag = get_tag(screen, i)
                      if tag then
                          tag.selected = not tag.selected
                      end
                  end), function(_, k) table.insert(globalkeys, k) end)
    table.foreach(awful.key({ modkey, "Shift" }, i,
                  function ()
                      if client.focus then
                          awful.client.movetotag(get_tag(client.focus.screen, i))
                      end
                  end), function(_, k) table.insert(globalkeys, k) end)
    table.foreach(awful.key({ modkey, "Control", "Shift" }, i,
                  function ()
                      if client.focus then
                          awful.client.toggletag(get_tag(client.focus.screen, i))
                      end
                  end), function(_, k) table.insert(globalkeys, k) end)
    if i > 0 then
        table.foreach(awful.key({ modkey, "Shift" }, "F" .. i,
                      function ()
                          local screen = mouse.screen
                          if tags[screen][i] then
                              for k, c in pairs(awful.client.getmarked()) do
                                  awful.client.movetotag(get_tag(screen, i), c)
                              end
                          end
                       end), function(_, k) table.insert(globalkeys, k) end)
    end
end

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Hooks
-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end
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
end)

-- Hook function to execute when unmarking a client.
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
end)

-- Hook function to execute when the mouse enters a client.
awful.hooks.mouse_enter.register(function (c)
    -- Sloppy focus, but disabled for magnifier layout
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- Hook function to execute when a new client appears.
awful.hooks.manage.register(function (c, startup)
    -- If we are not managing this application at startup,
    -- move it to the screen where the mouse is.
    -- We only do it for filtered windows (i.e. no dock, etc).
    if not startup and awful.client.focus.filter(c) then
        c.screen = mouse.screen
    end

    if use_titlebar then
        -- Add a titlebar
        awful.titlebar.add(c, { modkey = modkey })
    end
    -- Add mouse bindings
    c:buttons(awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
        awful.button({ modkey }, 1, awful.mouse.client.move),
        awful.button({ modkey }, 3, awful.mouse.client.resize)
    ))
    -- New client may not receive focus
    -- if they're not focusable, so set border anyway.
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal

    -- Check if the application should be floating.
    local cls = c.class
    local inst = c.instance
    if floatapps[cls] then
        awful.client.floating.set(c, floatapps[cls])
    elseif floatapps[inst] then
        awful.client.floating.set(c, floatapps[inst])
    end

    -- Check application->screen/tag mappings.
    local target
    if apptags[cls] then
        target = apptags[cls]
    elseif apptags[inst] then
        target = apptags[inst]
    end
    if target then
        c.screen = target.screen
        awful.client.movetotag(get_tag(target.screen, target.tag), c)
    end

    -- Do this after tag mapping, so you don't see it on the wrong tag for a split second.
    client.focus = c

    -- Set key bindings
    c:keys(clientkeys)

    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)

    -- Honor size hints: if you want to drop the gaps between windows, set this to false.
    -- c.size_hints_honor = false
end)

-- Hook function to execute when arranging the screen.
-- (tag switch, new client, etc)
awful.hooks.arrange.register(function (screen_no)
    local layout = awful.layout.getname(awful.layout.get(screen_no))
    if layout and beautiful["layout_" ..layout] then
        mylayoutbox[screen_no].image = image(beautiful["layout_" .. layout])
    else
        mylayoutbox[screen_no].image = nil
    end

    -- Give focus to the latest client in history if no window has focus
    -- or if the current window is a desktop or a dock one.
    if not client.focus then
        local c = awful.client.focus.history.get(screen_no, 0)
        if c then client.focus = c end
    end

    if screen_no == mouse.screen then
        for n, t in pairs(tags[screen_no]) do
            if #t:clients() == 0 and t ~= awful.tag.selected() and dictlen(tags[screen_no]) > 1 then
                delete_tag(screen_no, n)
            end
        end
    end

    sort_tags(screen_no)
    handle_orphans()
end)

-- Hook called every 5 seconts
awful.hooks.timer.register(5, function ()
    mytextbox.text = os.date(" %a %b %d, %H:%M ")
end)
-- }}}


-- Autostart
for prg in io.lines(os.getenv("HOME") .. "/.config/awesome/autostart") do
    os.execute("pgrep -u $USER -x " .. prg:gmatch("%w+")() .. " || (" .. prg .. " &)")
end
