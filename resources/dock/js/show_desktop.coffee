#Copyright (c) 2011 ~ Deepin, Inc.
#              2013 ~ Liqiang Lee
#
#Author:      Liqiang Lee <liliqiang@linuxdeepin.com>
#Maintainer:  Liqiang Lee <liliqiang@linuxdeepin.com>
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


class ShowDesktop
    @set_time_id: null
    __show: false
    constructor:->
        DCore.signal_connect("desktop_status_changed", =>
            @set_status(DCore.Dock.get_desktop_status())
        )

    show: (v)->
        @__show = v
        if @__show
            @open_indicator.style.display = "block"
        else
            @open_indicator.style.display = "none"

    set_status: (status)=>
        @show(status)

    toggle: =>
        DCore.Dock.show_desktop(!@__show)

    # do_click: (e)=>
    #     DCore.Dock.show_desktop(!@__show)

    # do_dragenter: (e) =>
    #     e.stopPropagation()
    #     ShowDesktop.set_time_id = setTimeout(=>
    #         DCore.Dock.show_desktop(true)
    #     , 1000)
    # do_dragleave: (e) =>
    #     e.stopPropagation()
    #     clearTimeout(ShowDesktop.set_time_id)
    #     ShowDesktop.set_time_id = null


