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
        dc.drawText(cx, cy - 70, Graphics.FONT_NUMBER_HOT,
                    timeStr,
                    Graphics.TEXT_JUSTIFY_CENTER);

        // ── Date (accent colour, right-aligned below time) ────────────────────
        dc.setColor(ACCENT_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + 80, cy + 10, Graphics.FONT_SYSTEM_TINY,
                    dateStr,
                    Graphics.TEXT_JUSTIFY_RIGHT);

        // ── Heart rate (bottom left section) ──────────────────────────────────
        //drawHeart(dc, cx - 50, cy + 70, 13);
        dc.drawBitmap(cx - 60, cy + 62, hrIcon);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 30, cy + 58, Graphics.FONT_MEDIUM,
                    hr.toString(),
                    Graphics.TEXT_JUSTIFY_LEFT);

        // ── Steps (bottom right section) ──────────────────────────────────────
        //drawRunIcon(dc, cx + 18, cy + 70, 13);
        dc.drawBitmap(cx + 10, cy + 62, stepsIcon);
        var stepsStr;
        if (steps >= 1000) {
            var k = steps / 1000.0;
            stepsStr = k.format("%.1f") + "k";
        } else {
            stepsStr = steps.toString();
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + 37, cy + 58, Graphics.FONT_MEDIUM,
                    stepsStr,
                    Graphics.TEXT_JUSTIFY_LEFT);
    }

    // ── Heart icon (two lobes + downward triangle) ────────────────────────────
    function drawHeart(dc as Dc, x as Number, y as Number, size as Number) as Void {
        dc.setColor(ACCENT_COLOR, Graphics.COLOR_TRANSPARENT);
        var r = size / 2;
        // Two upper lobes
        dc.fillCircle(x - r, y - r, r);
        dc.fillCircle(x + r, y - r, r);
        // Lower triangle connecting lobes to a downward point
        var pts = [[x - size, y - r],
                   [x + size, y - r],
                   [x,        y + size - 2]] as Array<[Number, Number]>;
        dc.fillPolygon(pts);
    }

    // ── Running shoe icon (side profile facing left) ────────────────────────
    function drawRunIcon(dc as Dc, x as Number, y as Number, size as Number) as Void {
        dc.setColor(ACCENT_COLOR, Graphics.COLOR_TRANSPARENT);
        var s = size;
        // Shoe profile: heel on right, toe on left, sole at bottom
        var pts = [
            [x + s,      y - s / 2],   // heel top
            [x + s,      y + s / 3],   // heel back
            [x + s / 2,  y + s / 2],   // heel sole corner
            [x - s,      y + s / 2],   // toe sole
            [x - s,      y + s / 6],   // toe front
            [x - s / 4,  y - s / 2],   // toe cap top
            [x + s / 4,  y - s],       // instep / lace area
            [x + s / 2,  y - s + 2]    // collar opening
        ] as Array<[Number, Number]>;
        dc.fillPolygon(pts);
    }
}
