#Copyright (c) 2011 ~ 2012 Deepin, Inc.
#              2011 ~ 2012 yilang
#
#Author:      LongWei <yilang2007lw@gmail.com>
#                     <snyh@snyh.org>
#Maintainer:  LongWei <yilang2007lw@gmail.com>
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

class DesktopMenu extends Widget
    constructor: (parent_el) ->
        super
        @parent = parent_el
        @img_before = "images/desktopmenu/"
        @user_session = []
        @current_img_src = null
        if not @parent? then @parent = document.body
        @parent.appendChild(@element)
   
        @is_one_session = false
        @sessions = DCore.Greeter.get_sessions()
        if @sessions.length < 2 then @is_one_session = true
       

    hide:->
        @element.style.display = "none"
        @de_menu?.hide()

    show:->
        @element.style.display = "block"
        @de_menu?.show()

    update_current_icon:(@current)->
        return if @is_one_session
        @show()
        try
            echo "set_current(@current) :----#{@current}----"
            icon = DCore.Greeter.get_session_icon(@current)
            @current_img_src = "images/desktopmenu/current/#{icon}.png"
        catch error
            echo "set_current(#{@current}) error:#{error}"
            @current_img_src = "images/desktopmenu/current/unkown.png"
        finally
            echo @current_img_src
            localStorage.setItem("menu_current_id",@current)
            @de_menu.current_img.src = @current_img_src

    menuChoose_click_cb : (current, title)=>
        return if @is_one_session
        @current = @de_menu.set_current(current)
        @update_current_icon(@current)

    new_desktop_menu: ->
        echo "new_desktop_menu"
        return if @is_one_session
        
        @de_menu = new ComboBox("desktop", @menuChoose_click_cb)
        for session in @sessions
            id = session.toLowerCase()
            name = id
            #name = DCore.Greeter.get_session_name(id)
            icon = DCore.Greeter.get_session_icon(session)
            icon_path_normal = @img_before + "#{icon}_normal.png"
            icon_path_hover = @img_before + "#{icon}_hover.png"
            icon_path_press = @img_before + "#{icon}_press.png"
            @de_menu.insert(id, name, icon_path_normal,icon_path_hover,icon_path_press)
        @de_menu.frame_build()
        @de_menu.currentTextShow()
        @element.appendChild(@de_menu.element)
        

    keydown_listener:(e)->
        return if @is_one_session
        echo "@de_menu keydown_listener"
        @de_menu.menu.keydown(e)
