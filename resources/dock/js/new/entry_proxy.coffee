ITEM_PROPERTY=
    id: "Id"
    type:"Type"

class EntryProxy
    constructor: (@dbus)->
        @updateCache = true
        @stat = null

    connect: (signal, cb)->
        @dbus?.connect(signal, (name, value)=>
            if name == ITEM_DATA_FIELD.status
                @updateCache = true
                @status()
            cb(name, value)
        )

    getProperty:(name, data)->
        if @dbus
            if data
                return @dbus.Data[name] || null
            else
                return @dbus[name] || null

        null

    icon:->
        @getProperty(ITEM_DATA_FIELD.icon, true)

    title:->
        @getProperty(ITEM_DATA_FIELD.title, true)

    xids:->
        @getProperty(ITEM_DATA_FIELD.xids, true)

    status:->
        # using on destroying, the status must be stored.
        if @updateCache
            @stat = @getProperty(ITEM_DATA_FIELD.status, true)
            @updateCache = false

        @stat

    menuContent:->
        @getProperty(ITEM_DATA_FIELD.menu, true)

    type:->
        @getProperty(ITEM_PROPERTY.type, false)

    id:->
        @getProperty(ITEM_PROPERTY.id, false)

    isNormal:->
        @status() == ITEM_STATUS.normal

    isActive:->
        @status() == ITEM_STATUS.active

    isValid:->
        @status() && @status() != ITEM_STATUS.invalid

    isApplet:->
        @type() == ITEM_TYPE.applet

    isApp:->
        @type() == ITEM_TYPE.app

    activate:(x,y)->
        @dbus?.Activate(x, y)

    handleMenuItem:(itemId)->
        @dbus?.HandleMenuItem(itemId)
