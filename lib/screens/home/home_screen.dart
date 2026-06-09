import 'package:flutter/material.dart';
import 'package:gsmlg/screens/chat/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  static const name = 'Home';
  static const path = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatScreen();
  }
}
