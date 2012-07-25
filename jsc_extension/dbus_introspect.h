#ifndef __DBUS_INTROSPECTOR__
#define __DBUS_INTROSPECTOR__
#include <dbus/dbus-glib.h>
#include <JavaScriptCore/JSBase.h>

JSObjectRef get_dynamic_object(JSContextRef ctx, DBusGConnection* con,
        const char* server, const char* path, const char* iface);
#endif

