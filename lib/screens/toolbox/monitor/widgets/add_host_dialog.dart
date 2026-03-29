import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddHostDialog extends StatefulWidget {
  const AddHostDialog({super.key});

  @override
  State<AddHostDialog> createState() => _AddHostDialogState();
}

class _AddHostDialogState extends State<AddHostDialog> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '9723');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Host'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP Address',
                hintText: '192.168.1.100',
              ),
              keyboardType: TextInputType.text,
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'IP address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '9723',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Port is required';
                }
                final port = int.tryParse(value);
                if (port == null || port < 1 || port > 65535) {
                  return 'Enter a valid port (1-65535)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'ip': _ipController.text.trim(),
                'port': int.parse(_portController.text.trim()),
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
