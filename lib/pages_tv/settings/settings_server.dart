import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../components/future_builder_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../validators/validators.dart';
import '../components/filled_button.dart';
import '../components/icon_button.dart';
import '../components/keyboard_reopen.dart';
import '../components/setting.dart';
import '../components/text_field_focus.dart';
import '../utils/notification.dart';
import '../utils/utils.dart';

class SystemSettingsServer extends StatefulWidget {
  const SystemSettingsServer({super.key});

  @override
  State<SystemSettingsServer> createState() => _SystemSettingsServerState();
}

class _SystemSettingsServerState extends State<SystemSettingsServer> {
  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemServer,
      child: FutureBuilderHandler(
        future: Api.serverQueryAll(),
        builder:
            (context, snapshot) => ListView(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
              children: [
                ...snapshot.requireData.map(
                  (item) =>
                      item.active
                          ? ButtonSettingItem(
                            leading: const Icon(Icons.check_rounded),
                            trailing:
                                item.invalid
                                    ? Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.red,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 12),
                                    )
                                    : null,
                            autofocus: item.active,
                            title: Text(item.host),
                            subtitle: Row(
                              spacing: 8,
                              children: [Text(item.type.name), if (item.username != null) Text(item.username!)],
                            ),
                            onTap: () {},
                          )
                          : SlidableSettingItem(
                            actions: [
                              if (!item.active)
                                TVIconButton(
                                  onPressed: () async {
                                    final resp = await showNotification(context, Api.serverActiveById(item.id));
                                    if (resp?.error == null && context.mounted) {
                                      setState(() {});
                                    }
                                  },
                                  icon: const Icon(Icons.check_rounded),
                                ),
                              if (!item.active && item.id != 0)
                                TVIconButton(
                                  onPressed: () async {
                                    final confirmed = await showConfirm(
                                      context,
                                      AppLocalizations.of(context)!.deleteConfirmText,
                                    );
                                    if (confirmed ?? false) {
                                      await Api.serverDeleteById(item.id);
                                      if (context.mounted) {
                                        setState(() {});
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.delete_outline_rounded),
                                ),
                            ],
                            leading: Icon(item.active ? Icons.check_rounded : null),
                            trailing:
                                item.invalid
                                    ? Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.red,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 12),
                                    )
                                    : null,
                            subtitle: Row(
                              spacing: 8,
                              children: [Text(item.type.name), if (item.username != null) Text(item.username!)],
                            ),
                            title: Text(item.host),
                          ),
                ),
                const GapSettingItem(height: 12),
                IconButtonSettingItem(
                  autofocus: snapshot.requireData.isEmpty,
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final flag = await navigateToSlideLeft<bool>(context, const _SystemSettingsAdd());
                    if (flag ?? false) setState(() {});
                  },
                ),
              ],
            ),
      ),
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
  late final _userAgent = TextEditingController();

  @override
  void dispose() {
    _serverAddress.dispose();
    _username.dispose();
    _userPassword.dispose();
    _userAgent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.pageTitleAdd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Form(
          key: _formKey,
          child: KeyboardReopen(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 12,
              children: [
                DropdownButtonFormField(
                  value: 'emby',
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.serverFormItemLabelServerType,
                    prefixIcon: const Icon(Icons.domain),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'emby', child: Text('Emby')),
                    DropdownMenuItem(value: 'jellyfin', child: Text('Jellyfin')),
                  ],
                  onChanged: (ty) => _type = ty!,
                ),
                TextFieldFocus(
                  child: TextFormField(
                    controller: _serverAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.link),
                      border: const UnderlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.serverFormItemLabelServer,
                      isDense: true,
                    ),
                    validator: (value) => urlValidator(context, value, true),
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                ),
                TextFieldFocus(
                  child: TextFormField(
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
                ),
                TextFieldFocus(
                  child: TextFormField(
                    controller: _userPassword,
                    autofocus: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.password),
                      border: const UnderlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.loginFormItemLabelPwd,
                      isDense: true,
                    ),
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                ),
                TextFieldFocus(
                  child: TextFormField(
                    controller: _userAgent,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.web_rounded),
                      border: const UnderlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.loginFormItemLabelUserAgent,
                      isDense: true,
                    ),
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                ),
                const Spacer(),
                TVFilledButton(
                  child: Text(AppLocalizations.of(context)!.buttonConfirm),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final userAgent = _userAgent.text.trim();
                      final resp = await showNotification(
                        context,
                        Api.serverInsert({
                          'type': _type,
                          'host': _serverAddress.text.trim(),
                          'username': _username.text.trim(),
                          'userPassword': _userPassword.text.trim(),
                          'userAgent': userAgent.isNotEmpty ? userAgent : null,
                        }),
                      );
                      if (resp?.error == null && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
