import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Activity;
import Toybox.Time;
import Toybox.Time.Gregorian;

class GarminWatchFaceView extends WatchUi.WatchFace {

    // Accent colour: lime/yellow-green #C8E600
    var ACCENT_COLOR = 0xC8E600;
    var hrIcon; 
    var stepsIcon; 

    function initialize() {
        WatchFace.initialize();
        hrIcon = WatchUi.loadResource(Rez.Drawables.HrIcon);
        stepsIcon = WatchUi.loadResource(Rez.Drawables.StepsIcon);
    }

    function onLayout(dc as Dc) as Void {
        // We draw everything programmatically in onUpdate
    }

    function onShow() as Void {}
    function onHide() as Void {}

    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}

    // ── Main draw loop ────────────────────────────────────────────────────────
    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;

        // ── Background: fill circle black ──────────────────────────────────────
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.fillCircle(cx, cy, cx);

        // ── System data ────────────────────────────────────────────────────────
        var stats    = System.getSystemStats();
        var clock    = System.getClockTime();
        var actInfo  = ActivityMonitor.getInfo();

        // Battery
        var battery  = stats.battery.toNumber();

        // Heart rate: prefer live sensor reading, fallback to activity history
        var hr = 0;
        var activity = Activity.getActivityInfo();
        if (activity != null && activity.currentHeartRate != null) {
            hr = activity.currentHeartRate;
        }

        // Steps
        var steps = 0;
        if (actInfo != null && actInfo.steps != null) {
            steps = actInfo.steps;
        }

        // ── Date ───────────────────────────────────────────────────────────────
        var now      = Time.now();
        var dateInfo = Gregorian.info(now, Time.FORMAT_SHORT);
        var dayNames   = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        var dayStr   = dayNames[dateInfo.day_of_week - 1];
        var monStr   = monthNames[dateInfo.month - 1];
        var dateStr  = dayStr + ", " + monStr + " " + dateInfo.day.toString();

        // ── Time string ────────────────────────────────────────────────────────
        var hours   = clock.hour.format("%02d");
        var minutes = clock.min.format("%02d");
        var timeStr = hours + ":" + minutes;

        // ── Battery label (top, accent colour) ────────────────────────────────
        dc.setColor(ACCENT_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 95, Graphics.FONT_TINY,
                    battery.toString() + "%",
                    Graphics.TEXT_JUSTIFY_CENTER);

        // ── Time (large, white) ────────────────────────────────────────────────
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 70, Graphics.FONT_NUMBER_MEDIUM,
                    timeStr,
                    Graphics.TEXT_JUSTIFY_CENTER);

        // ── Date (accent colour, right-aligned below time) ────────────────────
        dc.setColor(ACCENT_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + 75, cy, Graphics.FONT_SYSTEM_TINY,
                    dateStr,
                    Graphics.TEXT_JUSTIFY_RIGHT);

        // ── Steps (bottom right section) ──────────────────────────────────────
        dc.drawBitmap(cx - 80, cy + 43, stepsIcon);
        var stepsStr;
        if (steps >= 1000) {
            var k = steps / 1000.0;
            stepsStr = k.format("%.1f") + "k";
        } else {
            stepsStr = steps.toString();
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 57, cy + 42, Graphics.FONT_TINY,
                    stepsStr,
                    Graphics.TEXT_JUSTIFY_LEFT);

        // ── Heart rate (bottom left section) ──────────────────────────────────
        dc.drawBitmap(cx + 10, cy + 43, hrIcon);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + 42, cy + 42, Graphics.FONT_TINY,
                    hr.toString(),
                    Graphics.TEXT_JUSTIFY_LEFT);
    }
}
