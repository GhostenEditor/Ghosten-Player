import 'package:flutter/material.dart';

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
      appBar: (title != null)
          ? AppBar(
              title: title,
              automaticallyImplyLeading: false,
              surfaceTintColor: Colors.transparent,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              titleSpacing: 24,
              toolbarHeight: 80,
            )
          : null,
      floatingActionButton: floatingActionButton,
      backgroundColor: Colors.transparent,
      persistentFooterButtons: actions?.isNotEmpty ?? false ? actions : null,
      body:
          child ??
          ListView(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 12,
              bottom: 32,
            ).add(.only(bottom: MediaQuery.paddingOf(context).bottom)),
            children: children!,
          ),
    );
  }
}
