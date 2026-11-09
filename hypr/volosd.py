import subprocess, signal, gi
gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gtk, GLib, GtkLayerShell

state = {"filled": 0, "mode": "vol", "timer": None}

win = Gtk.Window()
GtkLayerShell.init_for_window(win)
GtkLayerShell.set_layer(win, GtkLayerShell.Layer.OVERLAY)
GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.BOTTOM, True)
GtkLayerShell.set_margin(win, GtkLayerShell.Edge.BOTTOM, 60)
win.set_visual(win.get_screen().get_rgba_visual())
win.set_app_paintable(True)

def draw(w, cr):
    cr.set_operator(1)
    cr.set_source_rgba(0, 0, 0, 0)
    cr.paint()
    cr.set_operator(2)
    cr.set_line_cap(1)
    cr.set_line_width(90)
    cr.set_source_rgba(0.07, 0.07, 0.11, 0.75)
    cr.move_to(45, 45)
    cr.line_to(275, 45)
    cr.stroke()
    if state["mode"] == "vol":
        cr.set_line_width(8)
        for i in range(20):
            h = 12 + i * 2
            x = 27 + i * 14
            if i < state["filled"]:
                t = i / 19
                cr.set_source_rgba(1 - 0.816 * t, 0.478 + 0.4 * t, 0.776 + 0.04 * t, 1)
            else:
                cr.set_source_rgba(1, 1, 1, 0.15)
            cr.move_to(x, 61)
            cr.line_to(x, 65 - h + 4)
            cr.stroke()
    else:
        x = 21
        for i in range(10):
            r = 4 + 1.6 * i
            t = i / 9
            if i < state["filled"]:
                cr.set_source_rgba(1, 0.624 + 0.329 * t, 0.263 + 0.506 * t, 1)
            else:
                cr.set_source_rgba(1, 1, 1, 0.15)
            cr.arc(x + r, 45, r, 0, 6.2832)
            cr.fill()
            x += 2 * r + 6

area = Gtk.DrawingArea()
area.set_size_request(320, 90)
area.connect("draw", draw)
win.add(area)

def hide():
    win.hide()
    state["timer"] = None
    return False

def show(frac, off, mode):
    n = 20 if mode == "vol" else 10
    filled = 0 if off else round(min(frac, 1.0) * n)
    if mode == "bri":
        filled = max(1, filled)
    state["mode"] = mode
    state["filled"] = filled
    area.queue_draw()
    win.show_all()
    if state["timer"]:
        GLib.source_remove(state["timer"])
    state["timer"] = GLib.timeout_add(1500, hide)

def volume():
    out = subprocess.run(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"], capture_output=True, text=True).stdout
    show(float(out.split()[1]), "MUTED" in out, "vol")
    return True

def brightness():
    out = subprocess.run(["brightnessctl", "-m"], capture_output=True, text=True).stdout
    show(int(out.splitlines()[0].split(",")[3].strip("%")) / 100, False, "bri")
    return True

GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGUSR1, volume)
GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGUSR2, brightness)
Gtk.main()
