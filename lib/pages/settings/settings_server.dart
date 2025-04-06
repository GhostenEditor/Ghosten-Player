import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/future_builder_handler.dart';
import '../../components/scrollbar.dart';
import '../../utils/utils.dart';
import '../../validators/validators.dart';
import '../utils/notification.dart';

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
        title: Badge(label: const Text('Beta'), child: Text(AppLocalizations.of(context)!.settingsItemServer)),
        actions: [
          IconButton(
              onPressed: () async {
                final flag = await navigateTo<bool>(context, const _SystemSettingsAdd());
                if (flag ?? false) setState(() {});
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilderHandler(
          future: Api.serverQueryAll(),
          builder: (context, snapshot) => ScrollbarListView.builder(
                itemBuilder: (context, index) {
                  final item = snapshot.requireData[index];
                  return PopupMenuButton(
                    offset: const Offset(1, 0),
                    tooltip: '',
                    itemBuilder: (context) => [
                      if (!item.active)
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          onTap: () async {
                            final resp = await showNotification(context, Api.serverActiveById(item.id));
                            if (resp?.error == null && context.mounted) {
                              setState(() {});
                            }
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            leading: const Icon(Icons.check_rounded),
                            title: Text(AppLocalizations.of(context)!.buttonActivate),
                          ),
                        ),
                      if (!item.active)
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          onTap: () async {
                            final confirmed = await showConfirm(context, AppLocalizations.of(context)!.deleteConfirmText);
                            if (confirmed ?? false) {
                              await Api.serverDeleteById(item.id);
                              if (context.mounted) {
                                setState(() {});
                              }
                            }
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            leading: const Icon(Icons.delete_outline_rounded),
                            title: Text(AppLocalizations.of(context)!.buttonDelete),
                          ),
                        ),
                    ],
                    child: ListTile(
                      leading: Icon(item.active ? Icons.check_rounded : null),
                      trailing: item.invalid
                          ? Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.red),
                              child: const Icon(Icons.close, color: Colors.white, size: 12),
                            )
                          : null,
                      subtitle: Row(
                        spacing: 8,
                        children: [
                          Text(item.type.name),
                          if (item.username != null) Text(item.username!),
                        ],
                      ),
                      title: Text(item.host),
                    ),
                  );
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
  String _type = 'emby';
  late final _serverAddress = TextEditingController();
  late final _username = TextEditingController();
  late final _userPassword = TextEditingController();

  @override
  void dispose() {
    _serverAddress.dispose();
    _username.dispose();
    _userPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pageTitleAdd),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final resp = await showNotification(
                    context,
                    Api.serverInsert({
                      'type': _type,
                      'host': _serverAddress.text.trim(),
                      'username': _username.text.trim(),
                      'userPassword': _userPassword.text.trim(),
                    }));
                if (resp?.error == null && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              }
            },
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              DropdownButtonFormField(
                value: 'emby',
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.serverFormItemLabelServerType,
                  prefixIcon: const Icon(Icons.domain),
                  isDense: true,
                  hintText: '8.8.8.8',
                ),
                items: const [
                  DropdownMenuItem(value: 'emby', child: Text('Emby')),
                  DropdownMenuItem(value: 'jellyfin', child: Text('Jellyfin')),
                ],
                onChanged: (ty) => _type = ty!,
              ),
              TextFormField(
                controller: _serverAddress,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.link),
                  border: const UnderlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.serverFormItemLabelServer,
                  isDense: true,
                ),
                validator: (value) => urlValidator(context, value, true),
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
              ),
              TextFormField(
                controller: _username,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.account_circle_outlined),
                  border: const UnderlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.loginFormItemLabelUsername,
                  isDense: true,
                ),
                validator: (value) => requiredValidator(context, value),
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
              ),
              TextFormField(
                controller: _userPassword,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password),
                  border: const UnderlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.loginFormItemLabelPwd,
                  isDense: true,
                ),
                validator: (value) => requiredValidator(context, value),
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
