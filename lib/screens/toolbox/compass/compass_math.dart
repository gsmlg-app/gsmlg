double normalizeHeading(double heading) => ((heading % 360) + 360) % 360;

double shortestHeadingDelta(double from, double to) =>
    ((to - from + 540) % 360) - 180;

int compassDirectionIndex(double heading) =>
    ((normalizeHeading(heading) + 22.5) / 45).floor() % 8;

int roundedCompassHeading(double heading) =>
    normalizeHeading(heading).round() % 360;
