###############################################################################
##
## Goodyear K-type airship for FlightGear.
##
##  Copyright (C) 2010 - 2023  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license v2 or later.
##
###############################################################################

###############################################################################
# External API
#
# auto_weight_off()
# step_air_scoop_cmd(n, d)
# step_air_damper_cmd(n, d)
# step_air_valve_cmd(n, d)
# step_gas_valve_cmd(n, d)
# print_wow()
# about()
#

###############################################################################
var air_scoop_cmd_p =
    ["controls/air/scoop[0]",
     "controls/air/scoop[1]"];
var air_damper_cmd_p =
    ["controls/air/damper[0]",
     "controls/air/damper[1]"];
var air_valve_cmd_p =
    ["controls/air/valve[0]",
     "controls/air/valve[1]"];
var air_blower_cmd_p =
    "controls/air/blower";
var gas_valve_cmd_p =
    ["controls/gas/valve[0]",
     "controls/gas/valve[1]"];
var gas_rip_cord_p =
    ["controls/gas/rip-cord[0]",
     "controls/gas/rip-cord[1]"];

var weight_on_gear_p = "/fdm/jsbsim/forces/fbz-gear-lbs";
var ballast_p = "/fdm/jsbsim/inertia/pointmass-weight-lbs";

var print_wow = func {
    gui.popupTip("Current weight on gear " ~
                 -getprop(weight_on_gear_p) ~ " lbs.");
}

var auto_weighoff = func {
    var lift = getprop("/fdm/jsbsim/static-condition/net-lift-lbs");
    var v = getprop(ballast_p) + 1000 + lift;
        
    print("ZNP-K: Auto weigh off from " ~ (-lift) ~
          " lb heavy to 1000 lb heavy.");

    interpolate(ballast_p,
                (v > 0 ? v : 0),
                0.5);
}

var initial_weighoff = func {
    # Set initial static condition.
    # Finding the right static condition at initialization time is tricky.
    auto_weighoff();
    settimer(auto_weighoff, 0.25);
    settimer(auto_weighoff, 1.0);
    # Fill up the envelope if not at pressure already. A bit of a hack.
    settimer(func {
        setprop("/fdm/jsbsim/buoyant_forces/gas-cell/contents-mol",
                2.0 *
                getprop("/fdm/jsbsim/buoyant_forces/gas-cell/contents-mol"));
    }, 0.8);
}

var mp_mast_carriers =
    ["Aircraft/ZLT-NT/Models/GroundCrew/scania-mast-truck.xml"];

var init_all = func(reinit=0) {
    setprop(air_scoop_cmd_p[0], 1.0);
    setprop(air_scoop_cmd_p[1], 1.0);
    setprop(air_damper_cmd_p[0], 0.0);
    setprop(air_damper_cmd_p[1], 0.0);
    setprop(air_blower_cmd_p, 1.0);
    setprop(air_valve_cmd_p[0], 0.0);
    setprop(air_valve_cmd_p[1], 0.0);
    setprop(gas_valve_cmd_p[0], 0.0);
    setprop(gas_valve_cmd_p[1], 0.0);
    setprop(gas_rip_cord_p[0], 0.0);
    setprop(gas_rip_cord_p[1], 0.0);
    initial_weighoff();

    fake_electrical();
    # Disable the autopilot menu.
    gui.menuEnable("autopilot", 0);

    if (!reinit) {
        # Hobbs counters.
        aircraft.timer.new("/sim/time/hobbs/envelope", 73).start();
        # Livery support.
        #aircraft.livery.init("Aircraft/ZLT-NT/Models/Liveries")

        # Timed initialization.
        settimer(func {
        # Add some AI moorings.
            foreach (var c;
                     props.globals.getNode("/ai/models").
                         getChildren("carrier")) {
                mooring.add_ai_mooring(c, 160.0);
            }
        }, 1.0);
    }
    print("ZNP-K Systems ... Check");
}

var _ZNPK_initialized = 0;
setlistener("/sim/signals/fdm-initialized", func {
    init_all(_ZNPK_initialized);
    _ZNPK_initialized = 1;
});

###############################################################################
# controls.nas overrides.

# Ballonet control
var step_air_scoop_cmd = func(n, d) {
    var p = air_scoop_cmd_p[n];
    var t = getprop(p) + d;
    if (t > 1.0) { t =  1.0; }
    if (t < 0.0) { t = 0.0; }
    setprop(p, t);
    gui.popupTip((n ? "Port" : "Starboard") ~ " air " ~
                 "scoop " ~ int(100*t + 0.005) ~ "% open.");
}
var step_air_damper_cmd = func(n, d) {
    var p = air_damper_cmd_p[n];
    var t = getprop(p) + d;
    if (t > 1.0) { t =  1.0; }
    if (t < 0.0) { t = 0.0; }
    setprop(p, t);
    gui.popupTip((n ? "Aft" : "Forward") ~ " ballonet " ~
                 "damper " ~ int(100*t + 0.005) ~ "% open.");
}
var step_air_valve_cmd = func(n, d) {
    var p = air_valve_cmd_p[n];
    var t = getprop(p) + d;
    if (t > 1.0) { t =  1.0; }
    if (t < 0.0) { t = 0.0; }
    setprop(p, t);
    gui.popupTip((n ? "Aft" : "Forward") ~ " ballonet " ~
                 "valve " ~ int(100*t + 0.005) ~ "% open.");
}

# Gas valve control
var step_gas_valve_cmd = func(n, d) {
    var p = gas_valve_cmd_p[n];
    var t = getprop(p) + d;
    if (t >  1.0) { t =  1.0; }
    if (t <  0.0) { t =  0.0; }
    setprop(p, t);
    setprop("controls/gas/open-valve[" ~ n ~ "]", (t > 0 ? 1.0 : 0.0));
    gui.popupTip("Gas valve " ~
                 (t ? (int(100*t + 0.005) ~ "% open.") : " closed."));
}

###############################################################################
# Debug display - stand in instrumentation.
var debug_display_view_handler = {
    init : func {
        if (contains(me, "left")) return;

        me.left  = screen.display.new(20, 10);
        me.right = screen.display.new(-250, 20);
        # Static condition
        me.left.add
            ("/fdm/jsbsim/instrumentation/gas-pressure-psf");
        me.left.add
            ("/fdm/jsbsim/buoyant_forces/gas-cell/ballonet[0]/volume-ft3",
             "/fdm/jsbsim/buoyant_forces/gas-cell/ballonet[1]/volume-ft3");
        me.left.add("/fdm/jsbsim/static-condition/net-lift-lbs");
        me.left.add("/fdm/jsbsim/static-condition/flight-heaviness-lbs");
        me.left.add("/fdm/jsbsim/static-condition/design-heaviness-lbs");
        me.left.add("/fdm/jsbsim/atmosphere/T-R");
        me.left.add("/fdm/jsbsim/buoyant_forces/gas-cell/temp-R");
        me.left.add("/fdm/jsbsim/ballonets/valve-pos-norm[0]",
                    "/fdm/jsbsim/ballonets/valve-pos-norm[1]");
        # C.G.
        me.left.add("/fdm/jsbsim/inertia/cg-x-in");
        me.left.add("/fdm/jsbsim/mooring/total-distance-ft");
        # Flight information
        me.right.add("orientation/pitch-deg");
        me.right.add("surface-positions/elevator-pos-norm");
        me.right.add("surface-positions/rudder-pos-norm");
        me.right.add("instrumentation/magnetic-compass/indicated-heading-deg");
        me.right.add("instrumentation/altimeter/indicated-altitude-ft");
        me.right.add("instrumentation/airspeed-indicator/indicated-speed-kt");
        # Engines
        me.right.add("/engines/engine[0]/rpm",
                     "/engines/engine[0]/mp-inhg",
                     "/fdm/jsbsim/propulsion/engine[0]/power-hp");
        me.right.add("/engines/engine[1]/rpm",
                     "/engines/engine[1]/mp-inhg",
                     "/fdm/jsbsim/propulsion/engine[1]/power-hp");
        me.shown = 1;
        me.stop();
    },
    start  : func {
        if (!me.shown) {
            me.left.toggle();
            me.right.toggle();
        }
        me.shown = 1;
    },
    stop   : func {
        if (me.shown) {
            me.left.toggle();
            me.right.toggle();
        }
        me.shown = 0;
    }
};

# Install the debug display for some views.
setlistener("/sim/signals/fdm-initialized", func {
    view.manager.register("Pilot View", debug_display_view_handler);
    view.manager.register("Copilot View", debug_display_view_handler);
    print("Debug instrumentation ... check");
});

###############################################################################
# fake part of the electrical system.
var fake_electrical = func {
    setprop("systems/electrical/ac-volts", 24);
    setprop("systems/electrical/volts", 24);

    setprop("/systems/electrical/outputs/comm[0]", 24.0);
    setprop("/systems/electrical/outputs/comm[1]", 24.0);
    setprop("/systems/electrical/outputs/nav[0]", 24.0);
    setprop("/systems/electrical/outputs/nav[1]", 24.0);
    setprop("/systems/electrical/outputs/dme", 24.0);
    setprop("/systems/electrical/outputs/adf", 24.0);
    setprop("/systems/electrical/outputs/transponder", 24.0);
    setprop("/systems/electrical/outputs/instrument-lights", 24.0);

    setprop("/instrumentation/clock/flight-meter-hour",0);
}
###############################################################################

###########################################################################
## MP integration of user's fixed local mooring locations.
## NOTE: Should this be here or elsewhere?
settimer(func { ZLTNT.mp_network_init(1); }, 0.1);

###############################################################################
# About dialog.

var ABOUT_DLG = 0;

var dialog = {
#################################################################
    init : func (x = nil, y = nil) {
        me.x = x;
        me.y = y;
        me.bg = [0, 0, 0, 0.3];    # background color
        me.fg = [[1.0, 1.0, 1.0, 1.0]]; 
        #
        # "private"
        me.title = "About";
        me.dialog = nil;
        me.namenode = props.Node.new({"dialog-name" : me.title });
    },
#################################################################
    create : func {
        if (me.dialog != nil)
            me.close();

        me.dialog = gui.Widget.new();
        me.dialog.set("name", me.title);
        if (me.x != nil)
            me.dialog.set("x", me.x);
        if (me.y != nil)
            me.dialog.set("y", me.y);

        me.dialog.set("layout", "vbox");
        me.dialog.set("default-padding", 0);

        var titlebar = me.dialog.addChild("group");
        titlebar.set("layout", "hbox");
        titlebar.addChild("empty").set("stretch", 1);
        titlebar.addChild("text").set
            ("label",
             "About");
        var w = titlebar.addChild("button");
        w.set("pref-width", 16);
        w.set("pref-height", 16);
        w.set("legend", "");
        w.set("default", 0);
        w.set("key", "esc");
        w.setBinding("nasal", "ZNPK.dialog.destroy(); ");
        w.setBinding("dialog-close");
        me.dialog.addChild("hrule");

        var content = me.dialog.addChild("group");
        content.set("layout", "vbox");
        content.set("halign", "center");
        content.set("default-padding", 5);
        props.globals.initNode("sim/about/text",
             "Goodyear K-type airship for FlightGear\n" ~
             "Copyright (C) 2010 - 2023  Anders Gidenstam\n\n" ~
             "FlightGear flight simulator\n" ~
             "Copyright (C) 1996 - 2023  http://www.flightgear.org\n\n" ~
             "This is free software, and you are welcome to\n" ~
             "redistribute it under certain conditions.\n" ~
             "See the GNU GENERAL PUBLIC LICENSE Version 2 for the details.",
             "STRING");
        var text = content.addChild("textbox");
        text.set("halign", "fill");
        #text.set("slider", 20);
        text.set("pref-width", 400);
        text.set("pref-height", 300);
        text.set("editable", 0);
        text.set("property", "sim/about/text");

        #me.dialog.addChild("hrule");

        fgcommand("dialog-new", me.dialog.prop());
        fgcommand("dialog-show", me.namenode);
    },
#################################################################
    close : func {
        fgcommand("dialog-close", me.namenode);
    },
#################################################################
    destroy : func {
        ABOUT_DLG = 0;
        me.close();
        delete(gui.dialog, "\"" ~ me.title ~ "\"");
    },
#################################################################
    show : func {
        if (!ABOUT_DLG) {
            ABOUT_DLG = 1;
            me.init(400, getprop("/sim/startup/ysize") - 500);
            me.create();
        }
    }
};
###############################################################################

# Popup the about dialog.
var about = func {
    dialog.show();
}
