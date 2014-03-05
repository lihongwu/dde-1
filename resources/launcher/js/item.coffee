#Copyright (c) 2011 ~ 2013 Deepin, Inc.
#              2013 ~ 2013 Li Liqiang
#
#Author:      Li Liqiang <liliqiang@linuxdeepin.com>
#Maintainer:  Li Liqiang <liliqiang@linuxdeepin.com>
#
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, see <http://www.gnu.org/licenses/>.


try
    s_dock = DCore.DBus.session("com.deepin.dde.dock")
catch error
    s_dock = null


# to resize the drag image.
canvas = null

class Item extends Widget
    @autostart_flag: null
    @hoverItem: null
    @clean_hover_temp: false
    @display_temp: false
    constructor: (@id, @name, @path, @icon)->
        super
        @element.removeAttribute("id")
        @element.setAttribute("appid", @id)
        @hoverBoxOutter = create_element("div", "hoverBoxOutter", @element)
        @hoverBoxOutter.setAttribute("appid", @id)
        @hoverBox = create_element("div", "hoverBox", @hoverBoxOutter)
        @basename = get_path_name(@path) + ".desktop"
        @isAutostart = false
        @isFavor = false
        @status = SOFTWARE_STATE.IDLE
        @displayMode = 'display'

        @load_image()
        @itemName = create_element("div", "item_name", @hoverBox)
        @itemName.innerText = @name
        @hoverBoxOutter.draggable = true
        # @try_set_title(@element, @name, 80)
        # @element.setAttribute("title", @name)
        @elements = {'element': @element}#favor: null, search: null

    @updateHorizontalMargin:->
        containerWidth = $("#container").clientWidth
        # echo "containerWidth:#{containerWidth}"
        Item.itemNumPerLine = Math.floor(containerWidth / ITEM_WIDTH)
        # echo "itemNumPerLine: #{Item.itemNumPerLine}"
        Item.horizontalMargin =  (containerWidth - Item.itemNumPerLine * ITEM_WIDTH) / 2 / Item.itemNumPerLine
        # echo "horizontalMargin: #{Item.horizontalMargin}"
        for own id, info of applications
            info.element.style.marginLeft = "#{Item.horizontalMargin}px"
            info.element.style.marginRight = "#{Item.horizontalMargin}px"
            if info.favorElement
                info.favorElement.style.marginLeft = "#{Item.horizontalMargin}px"
                info.favorElement.style.marginRight = "#{Item.horizontalMargin}px"

    try_set_title: (el, text, width)->
        setTimeout(->
            height = calc_text_size(text, width)
            if height > 38
                el.setAttribute('title', text)
        , 200)

    destroy: ->
        categoryList.removeItem(@id)
        delete Widget.object_table[@id]

    # TODO: remove parent, connect to categoryList.
    add:(pid, parent)->
        if @elements[pid]
            return null
        if pid == CATEGORY_ID.FAVOR
            pid = 'favor'

        el = @element.cloneNode(true)
        inner = el.firstElementChild.firstElementChild
        im = inner.firstElementChild
        # img may not be loaded.
        if im.classList.length == 1
            im.onload = (e)=>
                @setImageSize(im)

        @elements[pid] = el
        if pid == 'favor'
            @isFavor = true
        else
            if !parent?
                categoryList.addItem(@id, pid)
        parent?.appendChild(el)
        el

    remove:(pid)->
        el = @elements[pid]
        delete @elements[pid]
        pNode = el.parentNode
        pNode.removeChild(el)
        if pid == 'favor' || pid == CATEGORY_ID.FAVOR
            @isFavor = false

    getElement:(pid)->
        if pid == CATEGORY_ID.FAVOR
            pid = 'favor'
        @elements[pid]

    get_img: ->
        im = DCore.get_theme_icon(@icon, 48)
        if im == null
            @icon = get_path_name(@path)

        im = DCore.get_theme_icon(@icon, 48)
        if im == null
            im = DCore.get_theme_icon(INVALID_IMG, ITEM_IMG_SIZE)

        im

    update: (info)->
        # TODO: update category infos
        # update it.
        if @name != info?.name
            @name = info.name
            @itemName.innerText = @name

        if @path != info?.path
            @path = info.path

        if @basename != info?.basename
            @basename = info.basename

        if @icon != info?.icon
            @icon = info.icon
            im = @get_img()
            @img.src = im

        if @isAutostart != info?.isAutostart
            @toggle_autostart()

        if @status != info?.status
            @status = info.status

        if @displayMode != info?.displayMode
            @toggle_icon()
            # @displayMode = info.displayMode

    setImageSize: (img)=>
        if img.width == img.height
            # echo 'set class name to square img'
            img.classList.add('square_img')
        else if img.width > img.height
            img.classList.add('hbar_img')
            new_height = ITEM_IMG_SIZE * img.height / img.width
            grap = (ITEM_IMG_SIZE - Math.floor(new_height)) / 2
            img.style.padding = "#{grap}px 0px"
        else
            img.classList.add('vbar_img')

    load_image: ->
        im = @get_img()
        @img = create_img("item_img", im, @hoverBox)
        # @img.draggable = true
        @img.onload = (e) =>
            @setImageSize(@img)

    on_click: (e)->
        target = e?.target
        target?.style.cursor = "wait"
        e = e && e.originalEvent || e
        e?.stopPropagation()
        startManager.Launch(@basename)
        Item.hoverItem = target
        target?.style.cursor = "auto"
        exit_launcher()

    on_dragstart: (e)=>
        # target is hoverBoxOutter
        target = e.target
        o = e
        e = e.originalEvent || e
        if canvas == null
            canvas = create_element(tag: 'canvas', width: ITEM_IMG_SIZE, height: ITEM_IMG_SIZE)
        ctx = canvas.getContext("2d")
        ctx.clearRect(0, 0, canvas.width, canvas.height)
        ctx.drawImage(@img, 0, 0, ITEM_IMG_SIZE, ITEM_IMG_SIZE)
        dt = e.dataTransfer
        dt.setDragCanvas(canvas, ITEM_IMG_SIZE/2 + 3, ITEM_IMG_SIZE/2)

        if switcher.isFavor()
            return
        # echo 'drag start'
        # grid = target.parentNode.parentNode
        # echo grid.parentNode.getAttribute("catId")
        # if grid.parentNode.getAttribute("catId") == "#{CATEGORY_ID.FAVOR}"
        #     echo 'drag favor'
        #     target = target.parentNode
        #     dt.effectAllowed = "move"
        #     dragSrcEl = target
        #     categoryList.favor.indicatorItem = @
        #     # dt.setData("text/html", target.innerHtml)
        #     # TODO: change to animation.
        #     setTimeout(->
        #         target.style.display = 'none'
        #     , 100)
        #     return
        dt.setData("text/plain", @id)
        dt.setData("text/uri-list", "file://#{@path}")
        dt.effectAllowed = "copy"
        categoryBar.dark()
        switcher.bright()

    on_dragend: (e)=>
        e = e.originalEvent || e
        e.preventDefault()
        if true
            @elements.favor?.style.display = 'block'
        categoryBar.bright()
        switcher.normal()

    createMenu:->
        @menu = null
        @menu = new Menu(
            DEEPIN_MENU_TYPE.NORMAL,
            new MenuItem(1, _("_Open")),
            new MenuSeparator(),
            new MenuItem(2, ITEM_HIDDEN_ICON_MESSAGE[@displayMode]),
            new MenuItem(7, FAVOR_MESSAGE[@isFavor]),
            new MenuSeparator(),
            new MenuItem(3, _("Send to d_esktop")).setActive(
                not daemon.IsOnDesktop_sync(@path)
            ),
            new MenuItem(4, _("Send to do_ck")).setActive(s_dock != null),
            new MenuSeparator(),
            new MenuItem(5, AUTOSTART_MESSAGE[@isAutostart]),
            new MenuSeparator(),
            new MenuItem(6, _("_Uninstall"))
        )

        # if DCore.DEntry.internal()
        #     @menu.addSeparator().append(
        #         new MenuItem(100, "report this bad icon")
        #     )

    on_rightclick: (e)->
        DCore.Launcher.force_show(true)
        e = e && e.originalEvent || e
        e.preventDefault()
        e.stopPropagation()

        @createMenu()

        # echo @menu
        # return
        @menu.dbus.connect("MenuUnregistered", ->
            setTimeout(->
                DCore.Launcher.force_show(false)
            , 100)
        )
        @menu.addListener(@on_itemselected).showMenu(e.screenX, e.screenY)

    on_itemselected: (id)=>
        id = parseInt(id)
        switch id
            when 1
                startManager.Launch(@basename)
                # exit_launcher()
            when 2 then @toggle_icon()
            when 3 then daemon.SendToDesktop(@path)
            when 4 then s_dock?.RequestDock_sync(escape(@path))
            when 5 then @toggle_autostart()
            when 6
                if confirm("This operation may lead to uninstalling other corresponding softwares. Are you sure to uninstall this Item?", "Launcher")
                    @status = SOFTWARE_STATE.UNINSTALLING
                    @hide()
                    uninstalling_apps[@id] = @
                    echo 'start uninstall'
                    uninstall(item:@, purge:true)
            when 7
                if @isFavor
                    echo 'remove from favor'
                    favor.remove(@id)
                else
                    echo 'add to favor'
                    favor.add(@id)
            # when 100 then DCore.DEntry.report_bad_icon(@path)  # internal
        DCore.Launcher.force_show(false)

    hide_icon: (e)=>
        @displayMode = "hidden"
        # applications[@id].setDisplayMode("hidden").notify()
        if !@element.classList.contains(HIDE_ICON_CLASS)
            @updateProperty((k, v)->
                v.classList.add(HIDE_ICON_CLASS)
            )
        if not Item.display_temp and not is_show_hidden_icons
            @hide()
            Item.display_temp = false
         if !hiddenIcons.contains(@id)
             # echo 'save'
            hiddenIcons.add(@id, @).save()
        categoryList.hideEmptyCategories()
        hidden_icons_num = hiddenIcons.number()
        if hidden_icons_num == 0
            Item.display_temp = false

    display_icon: (e)=>
        @displayMode = "display"
        # applications[@id].setDisplayMode("display").notify()
        @show()
        if @element.classList.contains(HIDE_ICON_CLASS)
            @updateProperty((k, v)->
                v.classList.remove(HIDE_ICON_CLASS)
            )
        hidden_icons_num = hiddenIcons.remove(@id).save().number()
        categoryList.showNonemptyCategories()
        if hidden_icons_num == 0
            is_show_hidden_icons = false
            _show_hidden_icons(is_show_hidden_icons)

    display_icon_temp: ->
        @show()
        Item.display_temp = true
        categoryList.showNonemptyCategories()

    toggle_icon: ->
        if @displayMode == 'display'
            @hide_icon()
        else
            @display_icon()

    updateProperty: (fn)->
        for own k, v of @elements
            if v
                fn(k, v)

    showAutostartFlag:->
        Item.autostart_flag ?= "file://#{DCore.get_theme_icon(AUTOSTART_ICON.NAME,
            AUTOSTART_ICON.SIZE)}"

        @updateProperty((k, v)->
            last = v.firstElementChild.firstElementChild.lastElementChild
            if last.tagName != 'IMG'
                create_img("autostart_flag", Item.autostart_flag, v.firstElementChild.firstElementChild)
            last.style.visibility = 'visible'
        )

    hideAutostartFlag:->
        @updateProperty((k, v)->
            last = v.firstElementChild.firstElementChild.lastElementChild
            if last.tagName == 'IMG'
                last.style.visibility = 'hidden'
        )

    add_to_autostart: ->
        # echo @basename
        if startManager.AddAutostart_sync(@path)
            # echo 'add success'
            @isAutostart = true
            @showAutostartFlag()

    remove_from_autostart: ->
        if startManager.RemoveAutostart_sync(@path)
            @isAutostart = false
            @hideAutostartFlag()

    toggle_autostart: ->
        if @isAutostart
            @remove_from_autostart()
        else
            @add_to_autostart()

    hide: ->
        @updateProperty((k, v)->
            v.style.display = "none"
        )

    # use '->', Item.display_temp and @displayMode will be undifined when
    # this function is pass to some other functions like setTimeout
    show: =>
        if (Item.display_temp or @displayMode == 'display') and @status == SOFTWARE_STATE.IDLE
            @updateProperty((k, v)->
                v.style.display = "-webkit-box"
            )

    # just working for categories, not searching and favor.

    on_mouseover: (e)=>
        # this event is a wrap, use e.originalEvent to get the original event
        target = e.target
        Item.hoverItem = target
        if not Item.clean_hover_temp
            inner = target.firstElementChild
            # not use @select() for storing status.
            inner.style.background = "rgba(0, 0, 0, 0.1)"
            inner.style.border = "2px rgba(255, 255, 255, 0.2) solid"
            target.style.border = "1px rgba(0, 0, 0, 0.25) solid"

    on_mouseout: (e)=>
        target = e.target
        target.style.border = ""

        inner = target.firstElementChild
        inner.style.border = ""
        inner.style.background = ""

        Item.hoverItem = null
