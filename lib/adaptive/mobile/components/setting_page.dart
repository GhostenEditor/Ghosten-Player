import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key, this.title, required this.child, this.actions, this.floatingActionButton})
    : children = null;

  const SettingPage.list({super.key, this.title, required this.children, this.actions, this.floatingActionButton})
    : child = null;

  final Widget? title;
  final Widget? child;
  final List<Widget>? children;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    assert(child != null || children != null);
    return Scaffold(
      appBar: (title != null || actions != null)
          ? AppBar(
              title: title,
              actions: actions,
              systemOverlayStyle: switch (Theme.brightnessOf(context)) {
                Brightness.dark => const SystemUiOverlayStyle(
                  systemNavigationBarIconBrightness: Brightness.light,
                  systemNavigationBarColor: Color(0x01000000),
                  statusBarIconBrightness: Brightness.light,
                  statusBarColor: Colors.transparent,
                ),
                Brightness.light => const SystemUiOverlayStyle(
                  systemNavigationBarIconBrightness: Brightness.dark,
                  systemNavigationBarColor: Color(0x01FFFFFF),
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: Colors.transparent,
                ),
              },
            )
          : null,
      floatingActionButton: floatingActionButton,
      body:
          child ??
          Scrollbar(
            child: ListView(
              padding: .only(bottom: MediaQuery.paddingOf(context).bottom + 16),
              children: children!,
            ),
          ),
    );
  }
}
