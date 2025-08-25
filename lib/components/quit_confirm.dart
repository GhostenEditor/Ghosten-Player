import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

class QuitConfirm extends StatefulWidget {
  const QuitConfirm({super.key, required this.child});

  final Widget child;

  @override
  State<QuitConfirm> createState() => _QuitConfirmState();
}

class _QuitConfirmState extends State<QuitConfirm> {
  bool confirmed = false;

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? widget.child
        : PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        if (Navigator.of(context).canPop()) {
          return;
        }
        if (confirmed) {
          confirmed = false;
          SystemNavigator.pop();
        } else {
          confirmed = true;
          final controller = ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.confirmTextExit, textAlign: TextAlign.center),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              width: 200,
            ),
          );
          controller.closed.then((_) => confirmed = false);
        }
      },
      child: widget.child,
    );
  }
}