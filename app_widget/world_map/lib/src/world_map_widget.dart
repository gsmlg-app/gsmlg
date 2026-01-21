import 'dart:convert';

import 'package:data_visualization/data_visualization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that displays a world map with a location marker.
class WorldMapWidget extends StatefulWidget {
  /// The latitude of the location to mark on the map.
  final double latitude;

  /// The longitude of the location to mark on the map.
  final double longitude;

  /// Optional label to display next to the marker.
  final String? label;

  /// Path to the GeoJSON asset file containing world boundaries.
  /// Defaults to 'assets/world.geo.json'.
  final String geoJsonAssetPath;

  const WorldMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.label,
    this.geoJsonAssetPath = 'assets/world.geo.json',
  });

  @override
  State<WorldMapWidget> createState() => _WorldMapWidgetState();
}

class _WorldMapWidgetState extends State<WorldMapWidget> {
  GeoJsonFeatureCollection? _worldData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    try {
      final jsonString = await rootBundle.loadString(widget.geoJsonAssetPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _worldData = GeoJsonFeatureCollection.fromJson(jsonData);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator.adaptive(),
            SizedBox(height: 16),
            Text('Loading world map...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text('Error loading map: $_error'),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _WorldMapPainter(
                worldData: _worldData!,
                latitude: widget.latitude,
                longitude: widget.longitude,
                label: widget.label,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WorldMapPainter extends CustomPainter {
  final GeoJsonFeatureCollection worldData;
  final double latitude;
  final double longitude;
  final String? label;

  _WorldMapPainter({
    required this.worldData,
    required this.latitude,
    required this.longitude,
    this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Point(size.width / 2, size.height / 2);
    final scale = size.width / 6.5;

    // Use Mercator projection
    final proj = geoMercator(center: (0, 0), scale: scale, translate: center);

    // Draw ocean background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.lightBlue.shade100,
    );

    // Draw land masses
    final geoPathGenerator = GeoPath(proj);
    final landPaths = geoPathGenerator.generate(worldData);

    final landPaint = Paint()
      ..color = Colors.green.shade200
      ..style = PaintingStyle.fill;

    final landBorderPaint = Paint()
      ..color = Colors.green.shade600
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (final pathPoints in landPaths) {
      if (pathPoints.length < 3) continue;

      final path = Path();
      path.moveTo(pathPoints.first.x, pathPoints.first.y);
      for (int i = 1; i < pathPoints.length; i++) {
        path.lineTo(pathPoints[i].x, pathPoints[i].y);
      }
      path.close();

      canvas.drawPath(path, landPaint);
      canvas.drawPath(path, landBorderPaint);
    }

    // Draw graticule (grid lines)
    final graticulePaint = Paint()
      ..color = Colors.blue.shade200.withAlpha(80)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Latitude lines
    for (double lat = -60; lat <= 80; lat += 30) {
      final points = <Offset>[];
      for (double lon = -180; lon <= 180; lon += 5) {
        final p = proj.project(lon, lat);
        if (!p.hasNaN) points.add(Offset(p.x, p.y));
      }
      if (points.length > 1) {
        final path = Path()..moveTo(points.first.dx, points.first.dy);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        canvas.drawPath(path, graticulePaint);
      }
    }

    // Longitude lines
    for (double lon = -180; lon <= 180; lon += 30) {
      final points = <Offset>[];
      for (double lat = -85; lat <= 85; lat += 5) {
        final p = proj.project(lon, lat);
        if (!p.hasNaN) points.add(Offset(p.x, p.y));
      }
      if (points.length > 1) {
        final path = Path()..moveTo(points.first.dx, points.first.dy);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        canvas.drawPath(path, graticulePaint);
      }
    }

    // Draw equator
    final equatorPaint = Paint()
      ..color = Colors.red.shade300.withAlpha(100)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final equatorPoints = <Offset>[];
    for (double lon = -180; lon <= 180; lon += 5) {
      final p = proj.project(lon, 0);
      if (!p.hasNaN) equatorPoints.add(Offset(p.x, p.y));
    }
    if (equatorPoints.length > 1) {
      final path = Path()
        ..moveTo(equatorPoints.first.dx, equatorPoints.first.dy);
      for (int i = 1; i < equatorPoints.length; i++) {
        path.lineTo(equatorPoints[i].dx, equatorPoints[i].dy);
      }
      canvas.drawPath(path, equatorPaint);
    }

    // Draw location marker
    final markerPos = proj.project(longitude, latitude);
    if (!markerPos.hasNaN &&
        markerPos.x > 0 &&
        markerPos.x < size.width &&
        markerPos.y > 0 &&
        markerPos.y < size.height) {
      // Draw pulsing effect background
      canvas.drawCircle(
        Offset(markerPos.x, markerPos.y),
        20,
        Paint()..color = Colors.red.shade300.withAlpha(50),
      );
      canvas.drawCircle(
        Offset(markerPos.x, markerPos.y),
        12,
        Paint()..color = Colors.red.shade400.withAlpha(100),
      );

      // Draw marker pin shadow
      canvas.drawCircle(
        Offset(markerPos.x, markerPos.y),
        8,
        Paint()..color = Colors.black26,
      );

      // Draw marker pin
      canvas.drawCircle(
        Offset(markerPos.x, markerPos.y),
        7,
        Paint()..color = Colors.red.shade700,
      );
      canvas.drawCircle(
        Offset(markerPos.x, markerPos.y),
        3,
        Paint()..color = Colors.white,
      );

      // Draw label if provided
      if (label != null && label!.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Draw text background
        final textX = markerPos.x + 12;
        final textY = markerPos.y - textPainter.height / 2;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              textX - 4,
              textY - 2,
              textPainter.width + 8,
              textPainter.height + 4,
            ),
            const Radius.circular(4),
          ),
          Paint()..color = Colors.white.withAlpha(220),
        );

        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
  }

  @override
  bool shouldRepaint(_WorldMapPainter old) =>
      old.latitude != latitude ||
      old.longitude != longitude ||
      old.label != label;
}
