import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_cookie_manager_plus/webview_cookie_manager_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../components/error_message.dart';
import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../../validators/validators.dart';
import '../components/filled_button.dart';
import '../components/input_assistance.dart';
import '../components/loading.dart';
import '../components/stepper_form.dart';
import '../components/text_button.dart';

class SettingsLoginPage extends StatefulWidget {
  const SettingsLoginPage({super.key});

  @override
  State<SettingsLoginPage> createState() => _SettingsLoginPageState();
}

class _SettingsLoginPageState extends State<SettingsLoginPage> {
  DriverType _driverType = DriverType.alipan;
  late final List<FormItem> _alipan;
  late final List<FormItem> _webdav;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _alipan = [
      FormItem(
        'token',
        labelText: AppLocalizations.of(context)!.accountCreateFormItemLabelRefreshToken,
        prefixIcon: const Icon(Icons.shield_outlined),
        validator: (value) => requiredValidator(context, value),
      ),
      FormItem(
        'url',
        labelText: AppLocalizations.of(context)!.accountCreateFormItemLabelOauthUrl,
        prefixIcon: const Icon(Icons.link),
        validator: (value) => urlValidator(context, value, true),
      ),
      FormItem(
        'username',
        labelText: AppLocalizations.of(context)!.accountCreateFormItemLabelClientId,
        helperText: AppLocalizations.of(context)!.formItemNotRequiredHelper,
        prefixIcon: const Icon(Icons.abc),
      ),
      FormItem(
        'password',
        labelText: AppLocalizations.of(context)!.accountCreateFormItemLabelClientPwd,
        helperText: AppLocalizations.of(context)!.formItemNotRequiredHelper,
        prefixIcon: const Icon(Icons.password),
      ),
    ];
    _webdav = [
      FormItem(
        'url',
        labelText: 'Host',
        hintText: 'http://127.0.0.1:8090',
        prefixIcon: const Icon(Icons.link),
        validator: (value) => urlValidator(context, value, true),
      ),
      FormItem(
        'username',
        labelText: AppLocalizations.of(context)!.loginFormItemLabelUsername,
        prefixIcon: const Icon(Icons.account_circle_outlined),
      ),
      FormItem(
        'password',
        labelText: AppLocalizations.of(context)!.loginFormItemLabelPwd,
        prefixIcon: const Icon(Icons.password),
        obscureText: true,
      ),
    ];
  }

  @override
  void dispose() {
    for (final item in _alipan) {
      item.controller.dispose();
    }
    for (final item in _webdav) {
      item.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/tv/images/bg-wheat.webp'), repeat: ImageRepeat.repeat),
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: InputAssistance(
                  disabled: switch (_driverType) {
                    DriverType.webdav || DriverType.alipan => false,
                    DriverType.quark => true,
                    _ => throw UnimplementedError(),
                  },
                  onData: (data) {
                    final ctx = FocusManager.instance.primaryFocus?.context;
                    final textField = ctx?.findAncestorWidgetOfExactType<TextField>();
                    if (textField?.controller != null) {
                      textField!.controller!.text += data;
                    }
                  },
                ),
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      [DriverType.alipan, DriverType.quark, DriverType.webdav]
                          .map(
                            (ty) => Padding(
                              padding: const EdgeInsets.all(4),
                              child:
                                  _driverType == ty
                                      ? TVFilledButton(
                                        onPressed: () => setState(() => _driverType = ty),
                                        child: Text(AppLocalizations.of(context)!.driverType(ty.name)),
                                      )
                                      : TVTextButton(
                                        onPressed: () => setState(() => _driverType = ty),
                                        child: Text(AppLocalizations.of(context)!.driverType(ty.name)),
                                      ),
                            ),
                          )
                          .toList(),
                ),
                Expanded(
                  child: switch (_driverType) {
                    DriverType.alipan => Center(
                      child: StepperForm(
                        key: ValueKey(_alipan),
                        items: _alipan,
                        onComplete: (data) async {
                          data['type'] = DriverType.alipan.name;
                          final flag = await showDialog<bool>(
                            context: context,
                            builder: (context) => _buildLoginLoading(Api.driverInsert(data)),
                          );
                          if ((flag ?? false) && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                      ),
                    ),
                    DriverType.webdav => Center(
                      child: StepperForm(
                        key: ValueKey(_webdav),
                        items: _webdav,
                        onComplete: (data) async {
                          data['type'] = DriverType.webdav.name;
                          final flag = await showDialog<bool>(
                            context: context,
                            builder: (context) => _buildLoginLoading(Api.driverInsert(data)),
                          );
                          if ((flag ?? false) && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                      ),
                    ),
                    DriverType.quark =>
                      kIsWeb
                          ? const SizedBox()
                          : _QuarkLogin(
                            onComplete: (data) async {
                              final flag = await showDialog<bool>(
                                context: context,
                                builder: (context) => _buildLoginLoading(Api.driverInsert(data)),
                              );
                              if ((flag ?? false) && context.mounted) {
                                Navigator.of(context).pop(true);
                              }
                            },
                          ),
                    _ => throw UnimplementedError(),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLoading(Stream<dynamic> stream) {
    return StreamBuilder(
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
                    return const Loading();
                  case ConnectionState.none:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context)!.modalTitleNotification),
                        content: ErrorMessage(
                          error: snapshot.error,
                          leading: const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        ),
                      );
                    } else {
                      Navigator.of(context).pop(true);
                      return const SizedBox();
                    }
                }
              },
            ),
          ),
    );
  }
}

class _QuarkLogin extends StatefulWidget {
  const _QuarkLogin({required this.onComplete});

  final ValueChanged<dynamic> onComplete;

  @override
  State<_QuarkLogin> createState() => _QuarkLoginState();
}

class _QuarkLoginState extends State<_QuarkLogin> {
  StreamSubscription<void>? _subscription;

  @override
  void initState() {
    super.initState();
    final cookieManager = WebviewCookieManager();
    cookieManager.clearCookies();
    _subscription = Stream.periodic(const Duration(seconds: 1)).listen((_) async {
      final gotCookies = await cookieManager.getCookies('https://pan.quark.cn');
      final cookies = gotCookies.map((c) => '${c.name}=${c.value}').join('; ');
      if (cookies.split(';').map((s) => s.split('=').first.trim()).contains('__puus')) {
        widget.onComplete({'token': cookies, 'type': DriverType.quark.name});
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller:
          WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setUserAgent(ua)
            ..scrollBy(10000, 0)
            ..loadRequest(Uri.parse('https://pan.quark.cn')),
    );
  }
}
