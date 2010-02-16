---------------------------
-- Awesome theme  3
---------------------------

theme = {}
theme.name = "blue-black-red"
theme.config = awful.util.getdir("config")
theme.path = theme.config .. "/themes/" .. theme.name

-- theme.font          = "terminus 9"
theme.font          = "Sans 8"

theme.bg_normal     = "#1c1c1c"
theme.bg_focus      = "#7985A3"
theme.bg_urgent     = "#A36666"

theme.fg_normal     = "#C5C5C5"
theme.fg_focus      = "#E4E4E4"
theme.fg_urgent     = "#A36666"

theme.border_width  = "1"
theme.border_normal = "#272C30"
theme.border_focus  = "#7985A3"
theme.border_marked = "#A3BA8C"

-- There are another variables sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- Example:
theme.taglist_bg_focus = "#990000"

-- Display the taglist squares
theme.taglist_squares_sel = "/usr/share/awesome/themes/default/taglist/squarefw.png"
theme.taglist_squares_unsel = "/usr/share/awesome/themes/default/taglist/squarew.png"
theme.tasklist_floating_icon = "/usr/share/awesome/themes/default/tasklist/floatingw.png"

-- Variables set for theming menu
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_bg_focus = "#7985A3"
theme.menu_bg_normal = "#454545"
theme.menu_border_color = "#7985A3"
theme.menu_border_width = "0"
theme.menu_submenu_icon = "/usr/share/awesome/themes/default/submenu.png"
theme.menu_height   = "24"
theme.menu_context_height = "19"
theme.menu_width    = "200"

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--bg_widget    = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = theme.path .. "/titlebar/close_normal.png"
theme.titlebar_close_button_focus = theme.path .. "/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = theme.path .. "/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = theme.path .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = theme.path .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = theme.path .. "/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = theme.path .. "/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = theme.path .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = theme.path .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = theme.path .. "/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = theme.path .. "/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = theme.path .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = theme.path .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = theme.path .. "/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = theme.path .. "/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = theme.path .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = theme.path .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = theme.path .. "/titlebar/maximized_focus_active.png"

-- You can use your own command to set your wallpaper
theme.wallpaper_cmd = { "awsetbg " .. theme.config .. "/wallpapers/vladstudio-1.jpg" }

-- You can use your own layout icons like this:
theme.layout_dwindle = "/usr/share/awesome/themes/default/layouts/dwindlew.png"
theme.layout_fairh = "/usr/share/awesome/themes/default/layouts/fairhw.png"
theme.layout_fairv = "/usr/share/awesome/themes/default/layouts/fairvw.png"
theme.layout_floating = "/usr/share/awesome/themes/default/layouts/floatingw.png"
theme.layout_magnifier = "/usr/share/awesome/themes/default/layouts/magnifierw.png"
theme.layout_max = "/usr/share/awesome/themes/default/layouts/maxw.png"
theme.layout_spiral = "/usr/share/awesome/themes/default/layouts/spiralw.png"
theme.layout_tilebottom = "/usr/share/awesome/themes/default/layouts/tilebottomw.png"
theme.layout_tileleft = "/usr/share/awesome/themes/default/layouts/tileleftw.png"
theme.layout_tile = "/usr/share/awesome/themes/default/layouts/tilew.png"
theme.layout_tiletop = "/usr/share/awesome/themes/default/layouts/tiletopw.png"

--awesome_icon = "/usr/share/awesome/icons/awesome16.png"
--awesome_icon = "/home/ierton/.config/awesome/icons/gnome-logout.png"
theme.awesome_icon = theme.config .. "/icons/im-aim.png"

-- look inside /usr/share/icons/, default: nil (don't use icon theme)
theme.icon_theme = "Tango"
theme.icon_theme_size = "32x32"
theme.default_client_icon = theme.config .. "/icons/emptytrash.png"

return theme


