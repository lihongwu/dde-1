DCore.signal_connect("active_window_changed", (info)->)
DCore.signal_connect("launcher_added", (info) ->)
DCore.signal_connect("dock_request", (info) ->)
DCore.signal_connect("launcher_removed", (info) ->)
DCore.signal_connect("task_updated", (info) ->)
DCore.signal_connect("dock_hidden", ->)
DCore.signal_connect("task_removed", (info) ->)
DCore.signal_connect("in_mini_mode", ->)
DCore.signal_connect("in_normal_mode", ->)
DCore.signal_connect("close_window", (info)->)
DCore.signal_connect("active_window", (info)->)
DCore.signal_connect("message_notify", (info)->)

show_desktop = new ShowDesktop()

panel = new Panel("panel")
panel.draw()

app_list = new AppList("app_list")

EntryManager = "dde.dock.EntryManager"
entryManager = get_dbus('session', EntryManager)

entryManager.connect("Added", (path)->
    console.log("added #{path}")
    if Widget.look_up(path)
        return

    d = get_dbus("session", itemDBus(path))
    console.log("Status: #{d.Status}")
    if d.Status == 2
        console.log("Activator #{d.Id}")
        new Activator(entry, d, app_list)
    else if d.Status == 1
        console.log("ClientGroup #{d.Id}")
        new ClientGroup(entry, d, app_list)
    calc_app_item_size()
)

entryManager.connect("Removed", (id)->
    # TODO: change id to the real id
    id = id.split('.')
    last = id.pop()
    id.push("v1")
    id.push(last)
    id = id.join("/")
    id = "/" + id
    console.log("removed #{id}")
    i = Widget.look_up(id)
    # console.log i.constructor.name
    i?.destroy()
    calc_app_item_size()
)

entries = entryManager.Entries
for entry in entries
    # console.log(itemDBus(entry))
    d = get_dbus("session", itemDBus(entry))
    console.log("Status: #{d.Status}")
    if d.Status == 2
        console.log("Activator #{d.Id}:#{entry}")
        new Activator(entry, d, app_list)
    else if  d.Status == 1
        console.log("ClientGroup #{d.Id}:#{entry}")
        new ClientGroup(entry, d, app_list)
    # console.log('created end')
    # console.log(d.Status)

setTimeout(->
    IN_INIT = false
    calc_app_item_size()
    # apps are moved up, so add 8
    DCore.Dock.change_workarea_height(ITEM_HEIGHT * ICON_SCALE + 8)
, 100)

try
    icon_launcher = DCore.get_theme_icon("start-here", 48)

show_launcher = new LauncherItem("show_launcher", icon_launcher, _("Launcher"))
# clock = create_clock(DCore.Dock.clock_type())
trash = new Trash("trash", Trash.get_icon(DCore.DEntry.get_trash_count()), _("Trash"))
show_desktop = new ShowDesktop()

DCore.Dock.emit_webview_ok()
DCore.Dock.test()
