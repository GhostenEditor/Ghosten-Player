import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/connect_button.dart';
import '../../components/form_group.dart';
import '../../components/gap.dart';
import '../../utils/notification.dart';
import '../../validators/validators.dart';

class AccountLoginPage extends StatefulWidget {
  const AccountLoginPage({super.key});

  @override
  State<AccountLoginPage> createState() => _AccountLoginPageState();
}

class _AccountLoginPageState extends State<AccountLoginPage> {
  late final FormGroupController _alipan;
  late final FormGroupController _webdav;
  DriverType driverType = DriverType.alipan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _alipan = FormGroupController([
      FormItem(
        'token',
        labelText: AppLocalizations.of(context)!.accountCreateFormItemLabelRefreshToken,
        prefixIcon: Icons.shield_outlined,
        validator: (value) => requiredValidator(context, value),
      ),
      FormItem(
        'url',
        labelText: AppLocalizations.of(context)!.accountCreateFormItemLabelOauthUrl,
        prefixIcon: Icons.link,
        validator: (value) => urlValidator(context, value, true),
      ),
      FormItem(
        'username',
        labelText: AppLocalizations.of(context)!.accountCreateFormItemLabelClientId,
        helperText: AppLocalizations.of(context)!.formItemNotRequiredHelper,
        prefixIcon: Icons.abc,
      ),
      FormItem(
        'password',
        labelText: AppLocalizations.of(context)!.accountCreateFormItemLabelClientPwd,
        helperText: AppLocalizations.of(context)!.formItemNotRequiredHelper,
        prefixIcon: Icons.password,
      ),
    ]);
    _webdav = FormGroupController([
      FormItem(
        'url',
        labelText: 'Host',
        hintText: 'http://127.0.0.1:8090',
        prefixIcon: Icons.link,
        validator: (value) => urlValidator(context, value, true),
      ),
      FormItem(
        'username',
        labelText: AppLocalizations.of(context)!.loginFormItemLabelUsername,
        prefixIcon: Icons.account_circle_outlined,
      ),
      FormItem(
        'password',
        labelText: AppLocalizations.of(context)!.loginFormItemLabelPwd,
        prefixIcon: Icons.password,
        obscureText: true,
      ),
    ]);
  }

  @override
  void dispose() {
    _alipan.dispose();
    _webdav.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pageTitleLogin),
        actions: [
          ConnectButton(onData: onConnectData),
          IconButton(icon: const Icon(Icons.check), onPressed: login),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Radio(value: DriverType.alipan, groupValue: driverType, onChanged: (t) => setState(() => driverType = t!)),
                GestureDetector(
                  onTap: () => setState(() => driverType = DriverType.alipan),
                  child: Text(AppLocalizations.of(context)!.driverType(DriverType.alipan.name)),
                ),
                Gap.hSM,
                Radio(value: DriverType.webdav, groupValue: driverType, onChanged: (t) => setState(() => driverType = t!)),
                GestureDetector(
                  onTap: () => setState(() => driverType = DriverType.webdav),
                  child: Text(AppLocalizations.of(context)!.driverType(DriverType.webdav.name)),
                ),
              ],
            ),
          ),
          if (driverType == DriverType.alipan) Expanded(child: FormGroup(controller: _alipan)),
          if (driverType == DriverType.webdav) Expanded(child: FormGroup(controller: _webdav)),
        ],
      ),
    );
  }

  login() async {
    if (switch (driverType) {
      DriverType.alipan => _alipan.validate(),
      DriverType.webdav => _webdav.validate(),
      _ => throw UnimplementedError(),
    }) {
      final data = switch (driverType) {
        DriverType.alipan => _alipan.data,
        DriverType.webdav => _webdav.data,
        _ => throw UnimplementedError(),
      };
      data['type'] = driverType.name;
      final resp = await showNotification(context, Api.driverInsert(data));
      if (resp!.error == null && mounted) Navigator.of(context).pop(true);
    }
  }

  onConnectData(String data) {
    final formGroup = switch (driverType) {
      DriverType.alipan => _alipan,
      DriverType.webdav => _webdav,
      _ => throw UnimplementedError(),
    };
    final focusedItem = formGroup.focusedItem;
    if (focusedItem != null) {
      focusedItem.controller.text += data;
    }
  }
}
