import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/future_builder_handler.dart';
import '../../components/scrollbar.dart';
import '../../utils/notification.dart';

class SystemSettingsServer extends StatefulWidget {
  const SystemSettingsServer({super.key});

  @override
  State<SystemSettingsServer> createState() => _SystemSettingsServerState();
}

class _SystemSettingsServerState extends State<SystemSettingsServer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Badge(label: const Text('Alpha'), child: Text(AppLocalizations.of(context)!.settingsItemServer)),
        actions: [
          IconButton(
              onPressed: () async {
                final flag = await showDialog<bool>(context: context, builder: (context) => const _SystemSettingsAdd());
                if (flag == true) setState(() {});
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilderHandler(
          future: Api.serverQueryAll(),
          builder: (context, snapshot) => ScrollbarListView.builder(
                itemBuilder: (context, index) {
                  final item = snapshot.requireData[index];
                  final selected = snapshot.requireData.firstWhere((el) => el.active).id;
                  return RadioListTile(
                      value: item.id,
                      groupValue: selected,
                      onChanged: (id) async {
                        if (id != null) {
                          final resp = await showNotification(context, Api.serverActiveById(id));
                          if (resp?.error == null && context.mounted) {
                            setState(() {});
                          }
                        }
                      },
                      title: Text(item.host));
                },
                itemCount: snapshot.requireData.length,
              )),
    );
  }
}

class _SystemSettingsAdd extends StatefulWidget {
  const _SystemSettingsAdd();

  @override
  State<_SystemSettingsAdd> createState() => _SystemSettingsAddState();
}

class _SystemSettingsAddState extends State<_SystemSettingsAdd> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.pageTitleAdd),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.public_outlined),
                border: const UnderlineInputBorder(),
                filled: true,
                labelText: AppLocalizations.of(context)!.serverFormItemLabelServer,
                isDense: true,
              ),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            )
          ],
        ),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final resp = await showNotification(context, Api.serverInsert(_controller.text));
              if (resp?.error == null && context.mounted) {
                Navigator.of(context).pop(true);
              }
            }
          },
          child: Text(AppLocalizations.of(context)!.buttonConfirm),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.buttonCancel),
        ),
      ],
    );
  }
}
