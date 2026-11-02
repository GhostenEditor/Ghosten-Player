import 'package:flutter/material.dart';

import '../../../components/keyboard_reopen.dart';
import '../../../components/setting_page_theme.dart';
import '../../../l10n/app_localizations.dart';
import '_input_assistance.dart';
import 'setting_page.dart';

class EditPage extends StatelessWidget {
  const EditPage({
    super.key,
    required this.child,
    this.title,
    this.bottom,
    this.onConfirmButtonPressed,
    this.onResetButtonPressed,
    this.useAssistance,
  });

  final Widget? title;
  final PreferredSizeWidget? bottom;
  final Widget child;
  final VoidCallback? onConfirmButtonPressed;
  final VoidCallback? onResetButtonPressed;
  final bool? useAssistance;

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = [
      if (onResetButtonPressed != null)
        TextButton(
          onPressed: onResetButtonPressed,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            minimumSize: .zero,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          ),
          child: Text(AppLocalizations.of(context)!.buttonReset),
        ),
      if (onConfirmButtonPressed != null)
        FilledButton(
          onPressed: onConfirmButtonPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
            minimumSize: .zero,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          ),
          child: Text(AppLocalizations.of(context)!.buttonConfirm),
        ),
    ];
    return useAssistance ?? true
        ? Row(
            children: [
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/bg-wheat.webp'),
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: .center,
                    spacing: 20,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                        child: InputAssistance(
                          onData: (data) {
                            final BuildContext? ctx = FocusManager.instance.primaryFocus?.context;
                            final TextField? textField = ctx?.findAncestorWidgetOfExactType<TextField>();
                            if (textField?.controller != null) {
                              textField!.controller!.text += data;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: ScaffoldMessenger(
                  child: Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      title: title,
                      backgroundColor: Colors.transparent,
                      bottom: bottom,
                    ),
                    persistentFooterButtons: actions,
                    body: KeyboardReopen(child: child),
                  ),
                ),
              ),
            ],
          )
        : SettingPage(
            title: title,
            actions: actions,
            child: KeyboardReopen(
              child: Padding(
                padding: SettingPageTheme.of(context).contentPadding?.copyWith(bottom: 12) ?? .zero,
                child: child,
              ),
            ),
          );
  }
}
