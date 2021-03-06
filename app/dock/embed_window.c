#include <gtk/gtk.h>
#include <gdk/gdk.h>
#include <X11/X.h>
#include <gdk/gdkx.h>
#include "jsextension.h"
#include "dwebview.h"


GdkWindow* GET_CONTAINER_WINDOW();

#define SKIP_UNINIT(key) do {\
    if (__EMBEDED_WINDOWS__ == NULL) { \
	return;\
    }\
    if (g_hash_table_lookup(__EMBEDED_WINDOWS__, (gpointer)(Window)key) == NULL) {\
	return;\
    }\
}while(0)


GHashTable* __EMBEDED_WINDOWS__ = NULL;
GHashTable* __EMBEDED_WINDOWS_TARGET__ = NULL;

void __init__embed__()
{
    if (__EMBEDED_WINDOWS__ == NULL) {
	void destroy_window(GdkWindow* child);
	__EMBEDED_WINDOWS__ = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL, (GDestroyNotify)destroy_window);
    }
    if (__EMBEDED_WINDOWS_TARGET__ == NULL) {
	__EMBEDED_WINDOWS_TARGET__ = g_hash_table_new(g_direct_hash, g_direct_equal);
    }
}


GdkWindow* get_wrapper(GdkWindow* win) { return g_object_get_data(G_OBJECT(win), "deepin_embed_window_wrapper"); }
void destroy_window(GdkWindow* win)
{

    GdkFilterReturn __monitor_embed_window(GdkXEvent *xevent, GdkEvent* ev, gpointer data);
    gdk_window_remove_filter(win, __monitor_embed_window, NULL);

    GdkWindow* wrapper = get_wrapper(win);
    if (wrapper) {
	gdk_window_destroy(wrapper);
    }

    g_object_unref(win);

}

GdkFilterReturn __monitor_embed_window(GdkXEvent *xevent, GdkEvent* ev, gpointer data)
{
    ev = ev;
    data  = data;
    XEvent* xev = xevent;
    if (xev->type == DestroyNotify) {
	Window xid = ((XDestroyWindowEvent*)xevent)->window;
	g_hash_table_remove(__EMBEDED_WINDOWS__, (gpointer)xid);

	JSObjectRef info = json_create();
	json_append_number(info, "XID", xid);
	js_post_message("embed_window_destroyed", info);
        return GDK_FILTER_CONTINUE;
    } else if (xev->type == ConfigureNotify) {
        XConfigureEvent* xev = (XConfigureEvent*)xevent;

	GdkWindow* win = (GdkWindow*)g_hash_table_lookup(__EMBEDED_WINDOWS__, (gpointer)xev->window);
	if (win != NULL) {
	    GdkWindow *wrapper = get_wrapper(win);
	    if (wrapper) {
		//TODO: seems no effect at this time
		gdk_window_resize(wrapper, xev->width, xev->height);
	    }
	    JSObjectRef info = json_create();
	    json_append_number(info, "XID", xev->window);
	    json_append_number(info, "x", xev->x);
	    json_append_number(info, "y", xev->y);
	    json_append_number(info, "width", xev->width);
	    json_append_number(info, "height",xev->height);
	    js_post_message("embed_window_configure_changed", info);
	}
        return GDK_FILTER_CONTINUE;
    } else if (xev->type == GenericEvent) {
	XGenericEvent* ge = xevent;
	if (ge->evtype == EnterNotify) {
	    JSObjectRef info = json_create();
	    json_append_number(info, "XID", ((XEnterWindowEvent*)xev)->window);
	    js_post_message("embed_window_enter", info);
	} else if (ge->evtype == LeaveNotify) {
	    JSObjectRef info = json_create();
	    json_append_number(info, "XID", ((XEnterWindowEvent*)xev)->window);
	    js_post_message("embed_window_leave", info);
	}
	return GDK_FILTER_REMOVE;
    }
    return GDK_FILTER_CONTINUE;
}

GdkWindow* wrapper(Window xid)
{
    GdkDisplay* dpy = gdk_window_get_display(GET_CONTAINER_WINDOW());
    GdkWindow* child = gdk_x11_window_foreign_new_for_display(dpy, xid);
    if (child == NULL) {
        return NULL;
    }
    int mask = GDK_ENTER_NOTIFY_MASK | GDK_LEAVE_NOTIFY_MASK | GDK_VISIBILITY_NOTIFY_MASK;
    gdk_window_set_events(child, mask);
    GdkWindow* parent = NULL;
    gint width = 16, height = 16;
    gdk_window_get_geometry(child, NULL, NULL, &width, &height);

    GdkVisual* visual = gdk_window_get_visual(child);
    if (gdk_visual_get_depth(visual) == 24) {
	GdkWindowAttr attr={0};
	attr.width = width;
	attr.width = width;
	attr.window_type = GDK_WINDOW_CHILD;
	attr.wclass = GDK_INPUT_OUTPUT;
	attr.event_mask = mask;
	attr.visual = visual;
	parent = gdk_window_new(GET_CONTAINER_WINDOW(), &attr, GDK_WA_VISUAL);
	g_object_set_data(G_OBJECT(child), "deepin_embed_window_wrapper", parent);

	XReparentWindow(gdk_x11_get_default_xdisplay(),
		xid,
		GDK_WINDOW_XID(parent),
		0, 0);
    } else {
	parent = child;
    }
    gdk_window_show(child);

    gdk_window_add_filter(child, __monitor_embed_window, NULL);
    gdk_window_show(child);

    g_hash_table_insert(__EMBEDED_WINDOWS__, (gpointer)xid, child);
    return parent;
}

//JS_EXPORT_API
void exwindow_create(double xid, gboolean enable_resize)
{
    //TODO: handle this flag with SubStructureNotify
    enable_resize = enable_resize;
    Window win = (Window)xid;
    __init__embed__();
    GdkWindow* p = wrapper(win);
    if (p != NULL) {
	gdk_window_reparent(p, GET_CONTAINER_WINDOW(), 0, 0);
	gdk_window_set_composited(p, TRUE);
	gdk_window_show(p);
    }
}

JSValueRef exwindow_window_size(double xid)
{
    Window win = (Window)xid;
    GdkDisplay* dpy = gdk_window_get_display(GET_CONTAINER_WINDOW());
    GdkWindow* w = gdk_x11_window_foreign_new_for_display(dpy, win);
    gint width = 0, height = 0;
    if (w != NULL) {
        gdk_window_get_geometry(w, NULL, NULL, &width, &height);
    }
    JSObjectRef o = json_create();
    json_append_number(o, "width", width);
    json_append_number(o, "height", height);
    return o;
}


//JS_EXPORT_API
void exwindow_move_resize(double xid, double x, double y, double width, double height)
{
    SKIP_UNINIT(xid);
    GdkWindow* win = (GdkWindow*)g_hash_table_lookup(__EMBEDED_WINDOWS__, (gpointer)(Window)xid);
    if (win != NULL) {

	GdkWindow* wrapper = get_wrapper(win);
	if (wrapper) {
	    gdk_window_move_resize(wrapper, (int)x, (int)y, (guint)width, (guint)height);
	    gdk_window_move_resize(win, 0, 0, (guint)width, (guint)height);
	} else {
	    gdk_window_move_resize(win, (int)x, (int)y, (guint)width, (guint)height);
	}
    }
}

//JS_EXPORT_API
void exwindow_move(double xid, double x, double y)
{
    SKIP_UNINIT(xid);
    GdkWindow* win = (GdkWindow*)g_hash_table_lookup(__EMBEDED_WINDOWS__, (gpointer)(Window)xid);
    if (win != NULL) {
	gdk_window_move(win, (int)x, (int)y);

	GdkWindow* wrapper = get_wrapper(win);
	if (wrapper) {
	    gdk_window_move(wrapper, (int)x, (int)y);
	} else {
	    gdk_window_move(win, (int)x, (int)y);
	}
    }
}

//JS_EXPORT_API
void exwindow_hide(double xid)
{
    SKIP_UNINIT(xid);
    GdkWindow* win = (GdkWindow*)g_hash_table_lookup(__EMBEDED_WINDOWS__, (gpointer)(Window)xid);
    if (win != NULL) {
	GdkWindow* wrapper = get_wrapper(win);
	if (wrapper) {
	    gdk_window_hide(wrapper);
	} else {
	    gdk_window_hide(win);
	}
    }
}

//JS_EXPORT_API
void exwindow_show(double xid)
{
    SKIP_UNINIT(xid);
    GdkWindow* win = (GdkWindow*)g_hash_table_lookup(__EMBEDED_WINDOWS__, (gpointer)(Window)xid);
    if (win != NULL) {
	GdkWindow* wrapper = get_wrapper(win);
	if (wrapper) {
	    gdk_window_show(wrapper);
	} else {
	    gdk_window_show(win);
	}
    } else {
        g_warning("window not found");
    }
}


void exwindow_draw_to_canvas(double _xid, JSValueRef canvas)
{
    Window xid = (Window)_xid;

    cairo_t* cr =  fetch_cairo_from_html_canvas(get_global_context(), canvas);

    g_hash_table_insert(__EMBEDED_WINDOWS_TARGET__, (gpointer)xid,
                            GINT_TO_POINTER((cr != NULL)));

    if (cr != NULL){
        GdkWindow* window = g_hash_table_lookup(__EMBEDED_WINDOWS__, (gpointer)xid);
        if (window != NULL) {
            cairo_save(cr);
            gdk_window_show(window);
            gdk_window_flush(window);
            gdk_flush();
            // gdk_display_sync(gdk_display_get_default());
            // sleep(1);
            gdk_cairo_set_source_window(cr, window, 0, 0);
            g_warning("draw to canvas");
            cairo_paint(cr);

            /*cairo_surface_t* s = cairo_get_target(cr);*/
            /*cairo_surface_write_to_png(s, "/tmp/draw_to_canvas.png");*/

            cairo_restore(cr);

            canvas_custom_draw_did(cr, NULL);
        }
    }
}


gboolean draw_embed_windows(GtkWidget* _w, cairo_t *cr)
{
    _w = _w;
    if (__EMBEDED_WINDOWS__ == NULL) {
	return FALSE;
    }
    cairo_save(cr);
    GHashTableIter iter;
    gpointer child = NULL;
    g_hash_table_iter_init (&iter, __EMBEDED_WINDOWS__);
    while (g_hash_table_iter_next (&iter, NULL, &child)) {
	GdkWindow* win = (GdkWindow*)child;
	GdkWindow* wrapper = get_wrapper(win);
	if (wrapper) {
	    win = wrapper;
	}

        Window xid = GDK_WINDOW_XID(child);
        gboolean has_target =
            GPOINTER_TO_INT(g_hash_table_lookup(__EMBEDED_WINDOWS_TARGET__,
                                                GINT_TO_POINTER(xid)));
        // g_warning("draw_target: %d", draw_target);
	if (win != NULL && !gdk_window_is_destroyed(win) &&
            gdk_window_is_visible(win) &&
            !has_target) {
	    int x = 0;
	    int y = 0;
	    gdk_window_get_geometry(win, &x, &y, NULL, NULL); //gdk_window_get_position will get error value when dock is hidden!
	    gdk_cairo_set_source_window(cr, win, x, y);
	    cairo_paint(cr);
	}
    }
    cairo_restore(cr);
    return FALSE;
}


#undef SKIP_UNINIT

// destroy
// allocation change

