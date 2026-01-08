import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIconSvg extends StatelessWidget {
  const AppIconSvg({
    super.key,
    this.width,
    this.height,
    this.color,
  });

  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icon/icon.svg',
      package: 'app_artwork',
      width: width,
      height: height,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
