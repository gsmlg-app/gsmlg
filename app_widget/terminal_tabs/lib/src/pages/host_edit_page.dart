import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:terminal_tabs/src/shared/fluent_back_button.dart';

class HostEditPage extends StatefulWidget {
  const HostEditPage({super.key});

  @override
  State<HostEditPage> createState() => _HostEditDialogState();
}

class _HostEditDialogState extends State<HostEditPage> {
  bool get isEditing => false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Host' : 'Add Host'),
        leading: Navigator.of(context).canPop()
            ? const FluentBackButton()
            : null,
        actions: [
          if (isEditing)
            TextButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
              onPressed: () async {
                close();
              },
            ),
        ],
      ),
      body: const Column(
        children: [
          Row(
            children: [Icon(Icons.computer), SizedBox(width: 8), Text('Host')],
          ),
        ],
      ),

      // content: SSHHostEditForm(
      //   record: widget.record,
      //   onSaved: _onSaved,
      // ),
    );
  }

  // ignore: unused_element
  Future<void> _onSaved(dynamic record) async {
    close();
  }

  void close() {
    if (mounted) {
      if (Navigator.of(context).canPop()) {
        return Navigator.of(context).pop();
      }

      if (TabScope.of(context) != null) {
        return TabScope.of(context)!.dispose();
      }
    }
  }
}
