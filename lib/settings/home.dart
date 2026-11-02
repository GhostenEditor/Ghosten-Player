import 'dart:io';

import 'package:flutter/material.dart' hide ListTile, TextFormField;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_cookie_manager_plus/webview_cookie_manager_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../adaptive/adaptive.dart';
import '../providers/function.dart';
import '../validators/validators.dart';

class SettingsHomePage extends StatelessWidget {
  const SettingsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final FunctionConfig function = context.watch<FunctionConfig>();
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return SettingPage.list(
      title: Text(localizations.settingsTitle),
      children: [
        ListTile(title: Text(localizations.settingsGroupManagement), dense: true),
        if (function.settingsStorage)
          ListTile(
            title: Text(localizations.settingsItemAccount),
            leading: const Icon(Icons.manage_accounts_outlined),
            onTap: () => context.pushNamed(.settingsStorage),
          ),
        ListTile(
          title: Text(localizations.settingsItemTV),
          leading: const Icon(Icons.tv),
          onTap: () => context.pushNamed(.settingsLibraryTv),
        ),
        ListTile(
          title: Text(localizations.settingsItemMovie),
          leading: const Icon(Icons.movie_creation_outlined),
          onTap: () => context.pushNamed(.settingsLibraryMovie),
        ),
        ListTile(
          title: Text(localizations.settingsItemServer),
          leading: const Icon(Icons.public_rounded),
          onTap: () => context.pushNamed(.settingsServer),
        ),
        const Divider(),
        ListTile(title: Text(localizations.settingsGroupPlay), dense: true),
        ListTile(
          title: Text(localizations.buttonPlay),
          leading: const Icon(Icons.play_arrow_outlined),
          onTap: () => context.pushNamed(.settingsPlay),
        ),
        if (function.settingsHistory)
          ListTile(
            title: Text(localizations.settingsItemPlayerHistory),
            leading: const Icon(Icons.history_rounded),
            onTap: () => context.pushNamed(.settingsHistory),
          ),
        if (function.settingsDownload)
          ListTile(
            title: Text(localizations.settingsItemDownload),
            leading: const Icon(Icons.download_outlined),
            enabled: false,
            // onTap: () => context.pushNamed(.settingsDownload),
          ),
        ListTile(
          title: Text(localizations.settingsItemPlayerSettings),
          leading: const Icon(Icons.video_settings),
          onTap: () => context.pushNamed(.settingsPlayer),
        ),
        const Divider(),
        ListTile(title: Text(localizations.settingsGroupTools), dense: true),
        if (function.settingsDiagnostics)
          ListTile(
            title: Text(localizations.settingsItemNetworkDiagnostics),
            leading: const Icon(Icons.rule_rounded),
            onTap: () => context.pushNamed(.settingsDiagnostics),
          ),
        ListTile(
          title: Text(localizations.settingsItemLog),
          leading: const Icon(Icons.article_outlined),
          onTap: () => context.pushNamed(.settingsLog),
        ),
        ListTile(
          title: Text(localizations.settingsItemHelp),
          leading: const Icon(Icons.help_outline_rounded),
          onTap: () => context.pushNamed(.settingsHelp),
        ),
        ListTile(
          title: Text(localizations.settingsItemCookie),
          leading: const Icon(Icons.cookie_outlined),
          onTap: () => Navigator.of(
            context,
            rootNavigator: true,
          ).push(MaterialPageRoute(builder: (context) => const _CookiePage())),
        ),
        const Divider(),
        ListTile(title: Text(localizations.settingsGroupMiscellaneous), dense: true),
        ListTile(
          title: Text(localizations.settingsItemOthers),
          leading: const Icon(Icons.more_horiz_rounded),
          onTap: () => context.pushNamed(.settingsOther),
        ),
        ListTile(
          title: Text(localizations.settingsItemFeedback),
          leading: const Icon(Icons.feedback_outlined),
          onTap: () => context.pushNamed(.external, arguments: issueUrl),
        ),
        ListTile(
          title: Text(localizations.settingsItemSponsor),
          leading: const Icon(Icons.card_giftcard_rounded),
          onTap: () => context.pushNamed(.settingsSponsor),
        ),
        ListTile(
          title: Text(localizations.settingsItemInfo),
          leading: const Icon(Icons.info_outline),
          onTap: () => context.pushNamed(.settingsAbout),
        ),
      ],
    );
  }
}

class _CookiePage extends StatefulWidget {
  const _CookiePage();

  @override
  State<_CookiePage> createState() => _CookiePageState();
}

class _CookiePageState extends State<_CookiePage> {
  final _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setUserAgent(ua);

  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final cookieManager = WebviewCookieManager();
    cookieManager.clearCookies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Form(
          key: _formKey,
          child: TextFormField(
            autofocus: true,
            controller: _urlController,
            decoration: const InputDecoration(
              hintText: '请输入网址',
              prefixIcon: Icon(Icons.link_rounded),
              visualDensity: .compact,
            ),
            validator: (value) => urlValidator(context, value, true),
            onEditingComplete: () {
              if (_formKey.currentState!.validate()) {
                _controller.loadRequest(Uri.parse(_urlController.text.trim()));
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
          ),
        ),
        actions: [IconButton(onPressed: _quarkCookie, icon: const Icon(Icons.cookie_outlined))],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }

  Future<void> _quarkCookie() async {
    final cookieManager = WebviewCookieManager();
    final List<Cookie> gotCookies = await cookieManager.getCookies(await _controller.currentUrl());
    final String cookies = gotCookies.map((c) => '${c.name}=${c.value}').join('; ');
    await Clipboard.setData(ClipboardData(text: cookies));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.tipsForCopiedSuccessfully, textAlign: TextAlign.center),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
