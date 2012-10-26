MAX_ITEM_TITLE = 20

m = new DeepinMenu()
i1 = new DeepinMenuItem(1, "Open")
i2 = new DeepinMenuItem(2, "Open with")
i3 = new DeepinMenuItem(3, "Delete")
i4 = new DeepinMenuItem(4, "Rename")
i5 = new DeepinMenuItem(5, "Properties")
m.appendItem(i1)
m.appendItem(i2)
m.appendItem(i3)
m.appendItem(i4)
m.appendItem(i5)

shorten_text = (str, n) ->
    r = /[^\x00-\xff]/g
    if str.replace(r, "mm").length <= n
        return str

    mid = Math.floor(n / 2)
    n = n - 3
    for i in [mid..(str.length - 1)]
        if str.substr(0, i).replace(r, "mm").length >= n
            return str.substr(0, i) + "..."

    return str

class Item extends Widget
    constructor: (@name, @icon, @exec, @path) ->
        @selected = false
        @id = @path
        super

        el = @element
        info = {x:0, y:0, width:1, height:1}

        #el.setAttribute("tabindex", 0)
        el.draggable = true
        el.innerHTML = "
        <img draggable=false src=#{@icon} />
        <div class=item_name>#{shorten_text(@name, MAX_ITEM_TITLE)}</div>
        "

        # search the div for store the name
        @item_name = sub_item for sub_item in el.childNodes when sub_item.className == "item_name"

        @element.addEventListener('click', (e) =>
            e.stopPropagation()
            update_selected_stats(this, e)
        )
        @element.addEventListener('dblclick', -> DCore.run_command exec)
        @element.addEventListener('itemselected', (env) ->
            echo "menu clicked:id=#{env.id} title=#{env.title}"
        )
        @init_drag?()
        @init_drop?()
        #@init_keypress?()
        @element.contextMenu = m

    item_focus: ->
        @selected = true
        @element.className += " item_selected"
        @item_name.innerText = @name

    item_blur: ->
        @selected = false
        @element.className = @element.className.replace(" item_selected", "")
        @item_name.innerText = shorten_text(@name, MAX_ITEM_TITLE)

    rename: (new_name) ->
        @item_name.innerText = new_name

    destroy: ->
        info = load_position(this)
        clear_occupy(info)
        super

    init_keypress: ->
        document.designMode = 'On'
        @element.addEventListener('keydown', (evt)->
            switch (evt.which)
                when 113
                    echo "Rename"
        )


class DesktopEntry extends Item
    init_drag: ->
        el = @element
        el.addEventListener('dragstart', (evt) =>
                evt.dataTransfer.setData("text/uri-list", "file://#{@path}")
                evt.dataTransfer.setData("text/plain", "#{@name}")
                evt.dataTransfer.effectAllowed = "all"
        )
        el.addEventListener('dragend', (evt) =>
                if evt.dataTransfer.dropEffect == "move"
                    evt.preventDefault()
                    node = evt.target
                    pos = pixel_to_position(evt.x, evt.y)

                    info = localStorage.getObject(@path)
                    info.x = pos[0]
                    info.y = pos[1]
                    move_to_position(this, info)

                else if evt.dataTransfer.dropEffect == "link"
                    node = evt.target
                    node.parentNode.removeChild(node)
        )

class Folder extends DesktopEntry
    constructor : ->
        super

        @div_pop = null
        @element.addEventListener('click', =>
            @show_pop_block()
        )

    item_blur: ->
        super
        if @div_pop != null then @hide_pop_block()

    show_pop_block : =>
        if @selected == false then return
        if @div_pop != null then return
        @div_pop = document.createElement("div")
        @div_pop.setAttribute("id", "pop_grid")
        document.body.appendChild(@div_pop)

        @fill_pop_block()

        DCore.signal_connect("dir_changed", @reflesh_pop_block)
        DCore.Desktop.monitor_dir(@element.id)

    reflesh_pop_block : (id) =>
        if id.id == @id then @fill_pop_block()

    fill_pop_block : =>
        items = DCore.Desktop.get_items_by_dir(@element.id)
        str = ""
        str += "<li id=\"#{s.EntryPath}\" dragable=\"true\"><img src=\"#{s.Icon}\"><div>#{shorten_text(s.Name, MAX_ITEM_TITLE)}</div></li>" for s in items
        @div_pop.innerHTML = "<ul>#{str}</ul>"

        if items.length <= 3
            col = items.length
        else if items.length <= 6
            col = 3
        else if items.length <= 12
            col = 4
        else if items.length <= 20
            col = 5
        else
            col = 6
        @div_pop.style.width = "#{col * i_width + 20}px"

        n = Math.ceil(items.length / col)
        if n > 4 then n = 4
        n = n * i_height + 20
        if @element.offsetTop > n
            @div_pop.style.top = "#{@element.offsetTop - n}px"
        else
            @div_pop.style.top = "#{@element.offsetTop + @element.offsetHeight + 20}px"

        n = (col * i_width) / 2 + 10
        p = @element.offsetLeft + @element.offsetWidth / 2
        if p < n
            @div_pop.style.left = "0"
        else if p + n > s_width
            @div_pop.style.left = "#{s_width - 2 * n}px"
        else
            @div_pop.style.left = "#{p - n}px"

        items = @div_pop.getElementsByTagName("li")
        for i in items
            i.addEventListener('dragstart', (evt) ->
                    evt.dataTransfer.setData("text/uri-list", "file://#{this.id}")
                    evt.dataTransfer.setData("text/plain", "#{this.id}")
                    evt.dataTransfer.effectAllowed = "all"
            )
            i.addEventListener('dragend', (evt) =>
                if evt.dataTransfer.dropEffect == "move"
                    evt.preventDefault()
                    node = evt.target
                    #pos = pixel_to_position(evt.x, evt.y)

                    #info = localStorage.getObject(@path)
                    #info.x = pos[0]
                    #info.y = pos[1]
                    #move_to_position(this, info)

                else if evt.dataTransfer.dropEffect == "link"
                    node = evt.target
                    node.parentNode.removeChild(node)
            )

        #div_grid.addEventListener("click", @hide_pop_block)
        #div_grid.addEventListener("contextmenu", @hide_pop_block)

    hide_pop_block : =>
        #div_grid.removeEventListener("click", @hide_pop_block)
        #div_grid.removeEventListener("contextmenu", @hide_pop_block)
        DCore.Desktop.cancel_monitor_dir(@id)
        @div_pop.parentElement.removeChild(@div_pop)
        delete @div_pop
        @div_pop = null

    init_drop: =>
        $(@element).drop
            drop: (evt) =>
                evt.preventDefault()
                file = decodeURI(evt.dataTransfer.getData("text/uri-list"))
                #@icon_close()
                @move_in(file)

            over: (evt) =>
                echo evt
                evt.preventDefault()
                path = decodeURI(evt.dataTransfer.getData("text/uri-list"))
                if path == "file://#{@path}"
                    evt.dataTransfer.dropEffect = "none"
                else
                    evt.dataTransfer.dropEffect = "link"
                    #@icon_open()

            enter: (evt) =>

            leave: (evt) =>
                #@icon_close()

    move_in: (c_path) ->
        echo "move to #{c_path} from #{@path}"
        p = c_path.replace("file://", "")
        DCore.run_command("mv '#{p}' '#{@path}'")


class NormalFile extends DesktopEntry

class DesktopApplet extends Item