import 'package:flex_tabs/src/model/container.dart';
import 'package:flex_tabs/src/model/layout.dart';
import 'package:flex_tabs/src/model/tabs.dart';
import 'package:flex_tabs/src/ui/tab_group.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

class TabsArea extends StatefulWidget {
  final TabsContainer child;

  const TabsArea({
    super.key,
    required this.child,
  });

  @override
  State<TabsArea> createState() => _TabsAreaState();
}

class _TabsAreaState extends State<TabsArea> {
  final MultiSplitViewController _controller = MultiSplitViewController();

  @override
  void initState() {
    super.initState();
    widget.child.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(TabsArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != oldWidget.child) {
      oldWidget.child.removeListener(_onChanged);
      widget.child.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.child.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;

    if (child is Tabs) {
      return _build(child);
    }

    if (child is TabsLayout) {
      return MultiSplitView(
        axis: child.direction,
        controller: _controller,
      );
    }

    throw UnsupportedError('Unsupported child type: ${child.runtimeType}');
  }

  Widget _build(TabsContainer node) {
    switch (node.runtimeType) {
      case const (Tabs):
        return TabGroup(node as Tabs);
      case const (TabsRow):
        return TabsArea(child: node);
      case const (TabsColumn):
        return TabsArea(child: node);
      default:
        throw UnsupportedError('Unsupported node: ${node.runtimeType}');
    }
  }
}
