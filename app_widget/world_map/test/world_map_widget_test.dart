import 'dart:math' as math;

import 'package:app_world_map/src/world_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('worldMapProjectionScaleForSize', () {
    test('uses the full equirectangular map height in wide containers', () {
      const size = Size(1200, 240);

      final scale = worldMapProjectionScaleForSize(size);
      final projectedMapWidth = scale * 2 * math.pi;
      final projectedMapHeight = scale * math.pi;

      expect(projectedMapWidth, lessThanOrEqualTo(size.width));
      expect(projectedMapHeight, closeTo(size.height, 0.001));
    });

    test('uses the full equirectangular map width in tall containers', () {
      const size = Size(240, 1200);

      final scale = worldMapProjectionScaleForSize(size);
      final projectedMapWidth = scale * 2 * math.pi;
      final projectedMapHeight = scale * math.pi;

      expect(projectedMapWidth, closeTo(size.width, 0.001));
      expect(projectedMapHeight, lessThanOrEqualTo(size.height));
    });
  });
}
