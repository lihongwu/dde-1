// Generated by CoffeeScript 1.3.3
(function() {
  var DesktopEntry, Folder, IconGroup, Item, Module, Recordable, Widget, db_conn, echo, render_item,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  echo = function(log) {
    return console.log(log);
  };

  Module = (function() {
    var moduleKeywords;

    function Module() {}

    moduleKeywords = ['extended', 'included'];

    Module.extended = function(obj) {
      var key, value, _ref;
      for (key in obj) {
        value = obj[key];
        if (__indexOf.call(moduleKeywords, key) < 0) {
          this[key] = value;
        }
      }
      if ((_ref = obj.extended) != null) {
        _ref.apply(this);
      }
      return this;
    };

    Module.included = function(obj, parms) {
      var key, value, _ref, _ref1;
      for (key in obj) {
        value = obj[key];
        if (__indexOf.call(moduleKeywords, key) < 0) {
          this.prototype[key] = value;
        }
      }
      if ((_ref = obj.included) != null) {
        _ref.apply(this);
      }
      return (_ref1 = obj.__init__) != null ? _ref1.call(this, parms) : void 0;
    };

    return Module;

  })();

  Recordable = {
    db_tabls: [],
    __init__: function(parms) {
      this.prototype.get_fields = parms;
      return this.prototype.create_table();
    },
    table: function() {
      return "__d_" + this.constructor.name + "__";
    },
    fields: function() {
      return this.get_fields.join();
    },
    fields_n: function() {
      var i, _i, _ref, _results;
      _results = [];
      for (i = _i = 1, _ref = this.get_fields.length; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        _results.push('?');
      }
      return _results;
    },
    save: function() {
      var fn, i, values,
        _this = this;
      values = (function() {
        var _i, _len, _ref, _results;
        _ref = this.get_fields;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          _results.push(this["get_" + i]());
        }
        return _results;
      }).call(this);
      fn = this.fields_n();
      return db_conn.transaction(function(tx) {
        return tx.executeSql("replace into " + (_this.table()) + " (" + (_this.fields()) + ") values (" + fn + ");", values, function(result) {}, function(tx, error) {
          return console.log(error);
        });
      });
    },
    create_table: function() {
      var fs;
      fs = this.fields().split(',').slice(1).join(' Int, ') + " Int";
      return Recordable.db_tabls.push("CREATE TABLE " + (this.table()) + " (id REAL UNIQUE, " + fs + ");");
    },
    load: function() {
      var _this = this;
      return db_conn.transaction(function(tx) {
        return tx.executeSql("select " + (_this.fields()) + " from " + (_this.table()) + " where id = ?", [_this.id], function(tx, r) {
          var field, p, _i, _len, _ref, _results;
          p = r.rows.item(0);
          _ref = _this.get_fields;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            field = _ref[_i];
            _results.push(_this["set_" + field](p[field]));
          }
          return _results;
        }, function(tx, error) {});
      });
    }
  };

  Widget = (function(_super) {

    __extends(Widget, _super);

    function Widget() {
      return Widget.__super__.constructor.apply(this, arguments);
    }

    Widget.prototype._$ = function() {
      return $("#" + this.id);
    };

    Widget.prototype.get_id = function() {
      return this.id;
    };

    Widget.prototype.set_id = function(id) {
      return this.id = id;
    };

    Widget.prototype.get_x = function() {
      return this._$().position().left;
    };

    Widget.prototype.set_x = function(x) {
      return this.set_position(x, -1);
    };

    Widget.prototype.get_y = function() {
      return this._$().position().top;
    };

    Widget.prototype.set_y = function(y) {
      return this.set_position(-1, y);
    };

    Widget.prototype.get_width = function() {
      return this._$().outerWidth();
    };

    Widget.prototype.get_height = function() {
      return this._$().outerHeight();
    };

    Widget.prototype.get_position = function() {
      var pos;
      pos = this._$().position();
      return [pos.top, pos.left];
    };

    Widget.prototype.set_position = function(x, y) {
      if (x === -1) {
        x = this.get_x();
      }
      if (y === -1) {
        y = this.get_y();
      }
      return this._$().position({
        of: this._$().parent(),
        my: "left top",
        at: "left top",
        offset: "" + x + " " + y
      });
    };

    return Widget;

  })(Module);

  Item = (function(_super) {

    __extends(Item, _super);

    Item.included(Recordable, ["id", "x", "y"]);

    function Item(name, icon, exec) {
      this.name = name;
      this.icon = icon;
      this.exec = exec;
      this.id = Desktop.Core.gen_id(this.name + this.icon + this.exec);
      this.itemTemp = "icontemp";
      this.itemContainer = "itemContainer";
      this.load();
    }

    Item.prototype.render = function() {
      var _this = this;
      $("#" + this.itemContainer).append($("#" + this.itemTemp).render({
        "class": "item",
        "id": this.id,
        "name": this.name,
        "icon": this.icon,
        "exec": this.exec
      }));
      return this._$().draggable({
        stop: function(event, ui) {
          return _this.save();
        }
      }).dblclick(function() {
        return Desktop.Core.run_command($(this)[0].getAttribute('exec'));
      });
    };

    return Item;

  })(Widget);

  DesktopEntry = (function(_super) {

    __extends(DesktopEntry, _super);

    function DesktopEntry() {
      return DesktopEntry.__super__.constructor.apply(this, arguments);
    }

    return DesktopEntry;

  })(Item);

  Folder = (function(_super) {

    __extends(Folder, _super);

    function Folder() {
      return Folder.__super__.constructor.apply(this, arguments);
    }

    return Folder;

  })(Item);

  IconGroup = (function(_super) {

    __extends(IconGroup, _super);

    function IconGroup() {
      return IconGroup.__super__.constructor.apply(this, arguments);
    }

    return IconGroup;

  })(Item);

  db_conn = openDatabase("test1", "", "test widget info database", 10 * 1024);

  db_conn.changeVersion("", "1", function(tx) {
    var i, _i, _len, _ref;
    _ref = Recordable.db_tabls;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      tx.executeSql(i);
    }
    return console.log("OK");
  });

  render_item = function(item) {
    var i;
    i = new Item(item.name, item.icon, item.exec);
    return i.render();
  };

  $(function() {
    var item, _i, _len, _ref;
    _ref = Desktop.Core.get_desktop_items();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      render_item(item);
    }
    $("#dialog").dialog({
      autoOpen: false,
      show: "blind",
      hide: "explode"
    });
    return $("#opener").click(function() {
      Desktop.Core.make_popup("dialog");
      $("#dialog").dialog("open");
      return false;
    });
  });

  $(function() {
    var s;
    s = Desktop.DBus.session_bus();
    window.shell = Desktop.DBus.get_object(s, "org.gnome.Shell", "/org/gnome/Shell", "org.gnome.Shell");
    window.notify = Desktop.DBus.get_object(s, "org.gnome.Magnifier", "/org/freedesktop/Notifications", "org.freedesktop.Notifications");
    echo(notify.CloseNotification(0));
    return echo(shell.Screenshot(true, true, 1, "/dev/shm/a.png"));
  });

}).call(this);
