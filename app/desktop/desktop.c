/**
 * Copyright (c) 2011 ~ 2012 Deepin, Inc.
 *               2011 ~ 2012 snyh
 *
 * Author:      snyh <snyh@snyh.org>
 * Maintainer:  snyh <snyh@snyh.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <http://www.gnu.org/licenses/>.
 **/

#include "xdg_misc.h"
#include "X_misc.h"
#include "pixbuf.h"
#include "i18n.h"
#include "dentry/entry.h"

#include <dwebview.h>
#include <utils.h>
#include <gtk/gtk.h>
#include <cairo/cairo-xlib.h>

void install_monitor();
static
GFile* _get_useable_file(const char* basename);

JS_EXPORT_API
JSObjectRef desktop_get_desktop_entries()
{
    JSObjectRef array = json_array_create();
    char* desktop_path = get_desktop_dir(FALSE);
    GDir* dir = g_dir_open(desktop_path, 0, NULL);

    const char* file_name = NULL;
    for (int i=0; NULL != (file_name = g_dir_read_name(dir));) {
        if (file_name[0] == '.' && !g_str_has_prefix(file_name, DEEPIN_RICH_DIR)) continue;

        char* path = g_build_filename(desktop_path, file_name, NULL);
        Entry* e = dentry_create_by_path(path);
        g_free(path);
        json_array_append_nobject(array, i++, e, g_object_ref, g_object_unref);
        g_object_unref(e);
    }
    g_dir_close(dir);
    g_free(desktop_path);
    return array;
}

JS_EXPORT_API
char* desktop_get_rich_dir_name(GFile* dir)
{
    char* name = g_file_get_basename(dir);
    char* ret = g_strdup(name+DEEPIN_RICH_DIR_LEN);
    g_free(name);
    return ret;
}

JS_EXPORT_API
void desktop_set_rich_dir_name(GFile* dir, const char* name)
{
    char* new_name = g_strconcat(DEEPIN_RICH_DIR, name, NULL);
    dentry_set_name(dir, new_name);
    g_free(new_name);
}

JS_EXPORT_API
char* desktop_get_rich_dir_icon(GFile* _dir)
{
    char* icons[4] = {NULL, NULL, NULL, NULL};
    char* bad_icons[4] = {NULL, NULL, NULL, NULL};

    char* dir_path = g_file_get_path(_dir);
    GDir* dir = g_dir_open(dir_path, 0, NULL);
    const char* child_name = NULL;
    int i=0, j=0;
    for (; NULL != (child_name = g_dir_read_name(dir));) {
        if (g_str_has_suffix(child_name, ".desktop")) {
            char* path = g_build_filename(dir_path, child_name, NULL);
            Entry* entry = dentry_create_by_path(path);
            icons[i++] = dentry_get_icon(entry);
            g_object_unref(entry);
            g_free(path);
        } else if (j<4) {
            char* path = g_build_filename(dir_path, child_name, NULL);
            Entry* entry = dentry_create_by_path(path);
            bad_icons[j++] = dentry_get_icon(entry);
            g_object_unref(entry);
            g_free(path);
        }

        if (i >= 4) break;
    }
    g_dir_close(dir);
    g_free(dir_path);
    int z = 0;
    char* ret = generate_directory_icon(
            icons[0] ? icons[0] : bad_icons[z++], 
            icons[1] ? icons[1] : bad_icons[z++], 
            icons[2] ? icons[2] : bad_icons[z++], 
            icons[3] ? icons[3] : bad_icons[z++]);
    for (int i=0; i<4; i++) {
        g_free(icons[i]);
        g_free(bad_icons[i]);
    }
    return ret;
}

JS_EXPORT_API
gboolean desktop_create_rich_dir(ArrayContainer fs)
{
    GFile* dir = _get_useable_file(_(DEEPIN_RICH_DIR"RichDir"));
    g_file_make_directory(dir, NULL, NULL);
    dentry_move(fs, dir);
    return TRUE;
}

JS_EXPORT_API
char* desktop_get_desktop_path()
{
    return get_desktop_dir(FALSE);
}

static 
GFile* _get_useable_file(const char* basename)
{
    char* destkop_path = get_desktop_dir(FALSE);
    GFile* dir = g_file_new_for_path(destkop_path);

    char* name = g_strdup(basename);
    GFile* child = g_file_get_child(dir, name);
    for (int i=0; g_file_query_exists(child, NULL); i++) {
        g_object_unref(child);
        g_free(name);
        name = g_strdup_printf("%s(%d)", basename, i);
        child = g_file_get_child(dir, name);
    }

    g_object_unref(dir);
    g_free(destkop_path);
    return child;
}

JS_EXPORT_API
GFile* desktop_new_file()
{
    GFile* file = _get_useable_file(_("NewFile"));
    GFileOutputStream* stream = 
        g_file_create(file, G_FILE_CREATE_NONE, NULL, NULL);
    if (stream)
        g_object_unref(stream);
    return file;
}

JS_EXPORT_API
GFile* desktop_new_directory()
{
    GFile* dir = _get_useable_file(_("NewDirectory"));
    g_file_make_directory(dir, NULL, NULL);
    //TODO: detect create status..
    return dir;
}

JS_EXPORT_API
void desktop_notify_workarea_size()
{
    int x, y, width, height;
    get_workarea_size(0, 0, &x, &y, &width, &height);
    char* tmp = g_strdup_printf("{\"x\":%d, \"y\":%d, \"width\":%d, \"height\":%d}", x, y, width, height);
    js_post_message_simply("workarea_changed", tmp);
}


//TODO: connect gtk_icon_theme changed.

static
void screen_change_size(GdkScreen *screen, GtkWidget *w)
{
    gtk_widget_set_size_request(w, gdk_screen_get_width(screen),
            gdk_screen_get_height(screen));
}

gboolean prevent_exit(GtkWidget* w, GdkEvent* e)
{
    return true;
}

GtkWidget* container = NULL;
void send_lost_focus()
{
    js_post_message_simply("lost_focus", NULL);
}
void send_get_focus()
{
    js_post_message_simply("get_focus", NULL);
}

int main(int argc, char* argv[])
{
    //remove  option -f 
    parse_cmd_line (&argc, &argv);
    init_i18n();
    gtk_init(&argc, &argv);
    g_log_set_default_handler((GLogFunc)log_to_file, "desktop");
    set_default_theme("Deepin");
    set_desktop_env_name("GNOME");

    container = create_web_container(FALSE, FALSE);
    g_signal_connect(container, "delete-event", G_CALLBACK(prevent_exit), NULL);

    GtkWidget *webview = d_webview_new_with_uri(GET_HTML_PATH("desktop"));
    gdk_error_trap_push();

    gtk_window_set_skip_pager_hint(GTK_WINDOW(container), TRUE);
    gtk_container_add(GTK_CONTAINER(container), GTK_WIDGET(webview));

    gtk_widget_realize(container);
    gtk_widget_realize(webview);
    g_signal_connect (webview, "draw", G_CALLBACK(erase_background), NULL);
    g_signal_connect(webview, "focus-out-event", G_CALLBACK(send_lost_focus), NULL);
    g_signal_connect(webview, "focus-in-event", G_CALLBACK(send_get_focus), NULL);

    GdkWindow* get_background_window();
    GdkWindow* background = get_background_window();
    /*gdk_window_restack(background, gtk_widget_get_window(container), FALSE);*/

    GdkScreen* screen = gtk_window_get_screen(GTK_WINDOW(container));
    gtk_widget_set_size_request(container, gdk_screen_get_width(screen),
            gdk_screen_get_height(screen));

    g_signal_connect(screen, "size-changed", G_CALLBACK(screen_change_size), container);
    g_signal_connect(screen, "size-changed", G_CALLBACK(screen_change_size), background);

    set_wmspec_desktop_hint(gtk_widget_get_window(container));

    GdkWindow* fw = webkit_web_view_get_forward_window(webview);
    gdk_window_stick(fw);

    install_monitor();

    gtk_widget_show_all(container);
    g_signal_connect (container , "destroy", G_CALLBACK (gtk_main_quit), NULL);

    watch_workarea_changes(container);
    gtk_main();
    unwatch_workarea_changes(container);
    return 0;
}
