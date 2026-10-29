import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:terminal_tabs/src/pages/host_edit_page.dart';

class AddHostTab extends TabItem {
  AddHostTab() {
    title.value = const Text('Connect');
    content.value = const AddHostTabView();
  }
}

class AddHostTabView extends StatefulWidget {
  const AddHostTabView({super.key});

  @override
  State<AddHostTabView> createState() => _AddHostTabViewState();
}

class _AddHostTabViewState extends State<AddHostTabView> {
  @override
  Widget build(BuildContext context) {
    return const HostEditPage();
  }
}
