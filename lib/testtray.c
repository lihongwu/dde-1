#include <gtk/gtk.h>
#include <gdk/gdk.h>
#include <webkit/webkit.h>
#include "taskbar.h"

int main(int argc, char* argv[])
{
    gtk_init(&argc, &argv);
    GtkWidget *w = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    DTaskbar *tb = d_taskbar_new();
    gtk_container_add(GTK_CONTAINER(w), GTK_WIDGET(tb));
    webkit_web_view_open(WEBKIT_WEB_VIEW(tb), "http://baidu.com");
    gtk_widget_show_all(w);
    g_signal_connect (w , "destroy", G_CALLBACK (gtk_main_quit), NULL);
    gtk_main();
    return 0;
}
