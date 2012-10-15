# workarea size
s_width = 1280
s_height = 546

# workarea offset
s_x = 0
s_y = 100

# item size
i_width = 80
i_height = 84

cols = Math.floor(s_width/i_width)
rows = Math.floor(s_height/i_height)

o_table = new Array()
for i in [0..cols]
    o_table[i] = new Array(rows)

# update the coordinate of the gird_div to fit the size of the workarea
update_gird_position = (wa_x, wa_y, wa_width, wa_height) ->
    s_x = wa_x
    s_y = wa_y
    s_width = wa_width
    s_height = wa_height

    div_grid.style.left = s_x
    div_grid.style.top = s_y
    div_grid.style.width = s_width
    div_grid.style.height = s_height

load_position = (widget) ->
    localStorage.getObject(widget.path)


clear_occupy = (info) ->
    for i in [0..info.width-1]
        for j in [0..info.height-1]
            o_table[info.x+i][info.y+j] = null


set_occupy = (info) ->
    assert(info!=null, "set_occupy")
    for i in [0..info.width-1]
        for j in [0..info.height-1]
            o_table[info.x+i][info.y+j] = true
    #draw_grid()


detect_occupy = (info) ->
    assert(info!=null, "detect_occupy")
    for i in [0..info.width-1]
        for j in [0..info.height-1]
            if o_table[info.x+i][info.y+j]
                return true
    return false


pixel_to_position = (x, y) ->
    p_x = x - s_x
    p_y = y - s_y
    index_x = Math.floor(p_x / i_width)
    index_y = Math.floor(p_y / i_height)
    echo "#{index_x},#{index_y}"
    return [index_x, index_y]


find_free_position = (w, h) ->
    info = {x:0, y:0, width:w, height:h}
    for i in [0..cols - 1]
        for j in [0..rows - 1]
            if not o_table[i][j]?
                info.x = i
                info.y = j
                return info
    return null


move_to_anywhere = (widget) ->
    info = localStorage.getObject(widget.path)
    if info?
        move_to_position(widget, info)
    else
        info = find_free_position(1, 1)
        move_to_position(widget, info)


move_to_position = (widget, info) ->
    old_info = localStorage.getObject(widget.path)

    if not info?
        info = localStorage.getObject(widget.path)

    if not detect_occupy(info)
            localStorage.setObject(widget.path, info)

            widget.move(info.x*i_width, info.y*i_height)

            if old_info?
                clear_occupy(old_info)
            set_occupy(info)


draw_grid = (ctx) ->
    grid = document.querySelector("#grid")
    ctx = grid.getContext('2d')
    ctx.fillStyle = 'rgba(0, 100, 0, 0.8)'
    for i in [0..cols]
        for j in [0..rows]
            if o_table[i][j]?
                ctx.fillRect(i*i_width, j*i_height, i_width-5, i_height-5)
            else
                ctx.clearRect(i*i_width, j*i_height, i_width-5, i_height-5)


sort_item = ->
    for item, i in $(".item")
        x = Math.floor (i / rows)
        y = Math.ceil (i % rows)
        echo "sort :(#{i}, #{x}, #{y})"


div_grid = document.createElement("div")
div_grid.setAttribute("id", "item_grid")
document.body.appendChild(div_grid)
update_gird_position(s_x, s_y, s_width, s_height)


$("#item_grid").drop
    "drop": (evt) ->
        echo evt
        for file in evt.originalEvent.dataTransfer.files
            pos = pixel_to_position(evt.originalEvent.x, evt.originalEvent.y)
            p_info = {"x": pos[0], "y": pos[1], "width": 1, "height": 1}
            path = Desktop.Core.move_to_desktop(file.path)
            localStorage.setObject(path, p_info)
        evt.dataTransfer.dropEffect = "move"

    "over": (evt) ->
        #echo "over"
        evt.dataTransfer.dropEffect = "move"
        evt.preventDefault()

    "enter": (evt) ->
        #evt.dataTransfer.dropEffect = "move"

    "leave": (evt) ->
        #evt.dataTransfer.dropEffect = "move"
