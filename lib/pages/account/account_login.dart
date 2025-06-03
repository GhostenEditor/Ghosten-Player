import 'package:api/api.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:webview_cookie_manager_plus/webview_cookie_manager_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../components/error_message.dart';
import '../../components/gap.dart';
import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../../validators/validators.dart';
import '../components/form_group.dart';

class AccountLoginPage extends StatefulWidget {
  const AccountLoginPage({super.key});

  @override
  State<AccountLoginPage> createState() => _AccountLoginPageState();
}

class _AccountLoginPageState extends State<AccountLoginPage> {
  late final FormGroupController _alipan;
  late final FormGroupController _webdav;

  DriverType _driverType = DriverType.alipan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _alipan = FormGroupController([
      FormItem(
        'token',
        labelText: AppLocalizations.of(context)!.accountCreateFormItemLabelRefreshToken,
        prefixIcon: Icons.shield_outlined,
        maxLines: 5,
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
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _login)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children:
                    [DriverType.alipan, DriverType.quark, DriverType.webdav]
                        .map(
                          (ty) => [
                            Radio(
                              value: ty,
                              groupValue: _driverType,
                              onChanged: (t) => setState(() => _driverType = t!),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _driverType = ty),
                              child: Text(AppLocalizations.of(context)!.driverType(ty.name)),
                            ),
                            Gap.hSM,
                          ],
                        )
                        .flattened
                        .toList(),
              ),
            ),
          ),
          if (_driverType == DriverType.alipan) Expanded(child: FormGroup(controller: _alipan)),
          if (_driverType == DriverType.quark)
            Expanded(
              child: WebViewWidget(
                controller:
                    WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..setUserAgent(ua)
                      ..scrollBy(10000, 0)
                      ..loadRequest(Uri.parse('https://pan.quark.cn')),
              ),
            ),
          if (_driverType == DriverType.webdav) Expanded(child: FormGroup(controller: _webdav)),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (switch (_driverType) {
      DriverType.alipan => _alipan.validate(),
      DriverType.webdav => _webdav.validate(),
      DriverType.quark => true,
      _ => throw UnimplementedError(),
    }) {
      final data = switch (_driverType) {
        DriverType.alipan => _alipan.data,
        DriverType.webdav => _webdav.data,
        DriverType.quark => await _quarkCookie(),
        _ => throw UnimplementedError(),
      };
      if (!mounted) return;
      data['type'] = _driverType.name;
      final flag = await showDialog<bool>(
        context: context,
        builder: (context) => _buildLoginLoading(Api.driverInsert(data)),
      );
      if ((flag ?? false) && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<Map<String, dynamic>> _quarkCookie() async {
    final cookieManager = WebviewCookieManager();
    final gotCookies = await cookieManager.getCookies('https://pan.quark.cn');
    final cookies = gotCookies.map((c) => '${c.name}=${c.value}').join('; ');
    return {'token': cookies};
  }

  Widget _buildLoginLoading(Stream<dynamic> stream) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.modalTitleNotification),
      content: StreamBuilder(
        stream: stream,
        builder:
            (context, snapshot) => PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop &&
                    (snapshot.connectionState == ConnectionState.done ||
                        snapshot.connectionState == ConnectionState.none ||
                        snapshot.hasData)) {
                  Navigator.of(context).pop();
                }
              },
              child: Builder(
                builder: (context) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final data = snapshot.requireData as Map<String, dynamic>;
                        if (data['type'] == 'qrcode') {
                          return SizedBox(
                            width: kQrSize,
                            height: kQrSize,
                            child: QrImageView(backgroundColor: Colors.white, data: data['qrcode_data'], size: kQrSize),
                          );
                        } else {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Padding(padding: EdgeInsets.all(17), child: CircularProgressIndicator()),
                              Text(AppLocalizations.of(context)!.modalNotificationLoadingText),
                            ],
                          );
                        }
                      } else {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(padding: EdgeInsets.all(17), child: CircularProgressIndicator()),
                            Text(AppLocalizations.of(context)!.modalNotificationLoadingText),
                          ],
                        );
                      }
                    case ConnectionState.none:
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return ErrorMessage(
                          error: snapshot.error,
                          leading: const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        );
                      } else {
                        Future.delayed(const Duration(seconds: 1)).then((value) {
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        });
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
                            Gap.vMD,
                            Text(AppLocalizations.of(context)!.modalNotificationSuccessText),
                          ],
                        );
                      }
                  }
                },
              ),
            ),
      ),
    );
  }
}
