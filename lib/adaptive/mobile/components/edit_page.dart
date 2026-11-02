import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../previews/previews.dart';

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
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: title,
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          centerTitle: true,
          leading: Align(
            alignment: .centerLeft,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.buttonCancel),
            ),
          ),
          leadingWidth: 100,
          backgroundColor: Colors.transparent,
          bottom: bottom,
          actions: [
            if (onResetButtonPressed != null)
              TextButton(onPressed: onResetButtonPressed, child: Text(AppLocalizations.of(context)!.buttonReset)),
            if (onConfirmButtonPressed != null)
              TextButton(
                onPressed: onConfirmButtonPressed,
                child: Text(
                  AppLocalizations.of(context)!.buttonConfirm,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
        body: child,
      ),
    );
  }
}

@AppPreview(size: Size.square(200))
Widget editPagePreview() {
  return const EditPage(child: SizedBox());
}
