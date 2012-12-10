#include "dwebview.h"
#include "dock_config.h"

#include <math.h>

//c99 didn't define M_PI and so on.
#ifndef M_PI_2
#define M_PI_2 1.57079632679489661923 
#endif

#define TO_DOUBLE(c) ( (c) / 255.0)
#define GET_R(c) TO_DOUBLE(c >> 24)
#define GET_G(c) TO_DOUBLE(c >> 16 & 0xff)
#define GET_B(c) TO_DOUBLE(c >> 8 & 0xff)
#define GET_A(c) ((c & 0xff) / 100.0)

void draw_board(JSValueRef canvas, JSData* data)
{
    cairo_t* cr =  fetch_cairo_from_html_canvas(data->ctx, canvas);

    int w = gdk_screen_get_width(gdk_screen_get_default());
    int h = 30;

    cairo_save(cr);
    cairo_set_source_rgba(cr, 
            GET_R(GD.config.color),
            GET_G(GD.config.color),
            GET_B(GD.config.color),
            GET_A(GD.config.color)
            );
    cairo_paint(cr);

    cairo_set_line_width(cr, 1);

    cairo_set_source_rgba(cr, 0, 0, 0, 0.6);
    cairo_rectangle(cr, 0, 0, w, 1);
    cairo_stroke(cr);

    cairo_set_source_rgba(cr, 1, 1, 1, 0.7);
    cairo_rectangle(cr, 0, 1, w, 1);
    cairo_stroke(cr);

    cairo_set_source_rgba(cr, 0, 0, 0, 0.05);

    int l = h-4-3;
    int b = w/2;
    double r = (b*b+l*l) / (2.0 * l);
    double e = asin(b / r);

    cairo_move_to(cr, w, 3);
    cairo_arc(cr, b, l-r , r, M_PI_2-e, M_PI_2+e);

    cairo_line_to(cr, 0, h);
    cairo_line_to(cr, w, h);
    cairo_line_to(cr, w, 3);
    cairo_close_path(cr);
    cairo_clip(cr);
    cairo_paint(cr);
    cairo_restore(cr);

    canvas_custom_draw_did(cr, NULL);
}

void gen_client_icon()
{
}