import 'dart:async';

import 'package:app_artwork/logo/gsmlg_dev.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/screens/home/home_screen.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  static const name = 'Splash Screen';
  static const path = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 1), () {
      if (mounted && GoRouterState.of(context).uri.path == SplashScreen.path) {
        context.goNamed(HomeScreen.name);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double w = screenWidth;
    if (screenHeight < screenWidth) {
      w = screenHeight;
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SizedBox(
          width: w * 0.618,
          height: w * 0.618,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(child: LogoGSMLGDEV()),
          ),
        ),
      ),
    );
  }
}
