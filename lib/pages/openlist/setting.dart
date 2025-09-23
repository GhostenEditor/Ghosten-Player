import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:openlist/openlist.dart';

import '../../l10n/app_localizations.dart';
import '../../validators/validators.dart';
import '../utils/notification.dart';

class OpenlistSetting extends StatefulWidget {
  const OpenlistSetting({super.key});

  @override
  State<OpenlistSetting> createState() => _OpenlistSettingState();
}

class _OpenlistSettingState extends State<OpenlistSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      floatingActionButton: FutureBuilder(
        initialData: false,
        future: Openlist.isRunning(),
        builder: (context, snapshot) {
          return FloatingActionButton(
            onPressed: () async {
              if (snapshot.requireData) {
                await Openlist.shutdown();
              } else {
                await Openlist.init();
              }
              setState(() {});
            },
            shape: const CircleBorder(),
            child: Icon(snapshot.requireData ? Icons.pause : Icons.play_arrow_rounded),
          );
        },
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.password_rounded),
            title: const Text('修改密码'),
            onTap: () {
              showDialog(context: context, builder: (context) => const AdminPasswordDialog());
            },
          ),
          ListTile(leading: const Icon(Icons.info_outline_rounded), title: const Text('关于'), onTap: () {}),
          SwitchListTile(
            title: const Row(spacing: 16, children: [Icon(Icons.web_outlined), Text('自动启动')]),
            value: true,
            onChanged: (bool value) {},
          ),
        ],
      ),
    );
  }
}

class AdminPasswordDialog extends StatefulWidget {
  const AdminPasswordDialog({super.key});

  @override
  State<AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<AdminPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改密码'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          autofocus: true,
          controller: _controller,
          obscureText: obscureText,
          maxLength: 18,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            labelText: '管理员密码',
            suffix: InkWell(
              onTap: () {
                setState(() => obscureText = !obscureText);
              },
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child:
                    obscureText
                        ? const Icon(Icons.visibility_outlined, size: 16)
                        : const Icon(Icons.visibility_off_outlined, size: 16),
              ),
            ),
          ),
          validator: (value) => requiredValidator(context, value),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await showNotification(context, Openlist.setAdminPassword(_controller.text));
              await Api.driverInsert({
                'type': 'openlist',
                'url': 'http://127.0.0.1:5244',
                'username': 'admin',
                'password': _controller.text,
              });
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: Text(AppLocalizations.of(context)!.buttonConfirm),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.buttonCancel)),
      ],
    );
  }
}
