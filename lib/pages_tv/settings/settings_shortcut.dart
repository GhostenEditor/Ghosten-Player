import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/shortcut_tv.dart';
import '../components/setting.dart';

class SystemSettingsShortcut extends StatefulWidget {
  const SystemSettingsShortcut({super.key});

  @override
  State<SystemSettingsShortcut> createState() => _SystemSettingsShortcutState();
}

class _SystemSettingsShortcutState extends State<SystemSettingsShortcut> {
  @override
  Widget build(BuildContext context) {
    final shortcuts = context.watch<ShortcutTV>();
    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemShortcuts,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        children: [
          _ShortcutButton(
            autofocus: true,
            title: Text(AppLocalizations.of(context)!.settingsItemShortcutsKey('menu')),
            shortcut: shortcuts.menu,
            onChanged: shortcuts.setMenu,
          ),
          _ShortcutButton(
            title: Text(AppLocalizations.of(context)!.settingsItemShortcutsKey('previousChannel')),
            shortcut: shortcuts.previousChannel,
            onChanged: shortcuts.setPreviousChannel,
          ),
          _ShortcutButton(
            title: Text(AppLocalizations.of(context)!.settingsItemShortcutsKey('nextChannel')),
            shortcut: shortcuts.nextChannel,
            onChanged: shortcuts.setNextChannel,
          ),
          _ShortcutButton(
            title: Text(AppLocalizations.of(context)!.settingsItemShortcutsKey('switchLinePanel')),
            shortcut: shortcuts.switchLinePanel,
            onChanged: shortcuts.setSwitchLinePanel,
          ),
          _ShortcutButton(
            title: Text(AppLocalizations.of(context)!.settingsItemShortcutsKey('channelsPanel')),
            shortcut: shortcuts.channelsPanel,
            onChanged: shortcuts.setChannelsPanel,
          ),
        ],
      ),
    );
  }
}

class _ShortcutButton extends StatefulWidget {
  const _ShortcutButton({this.title, this.autofocus = false, required this.shortcut, required this.onChanged});

  final Widget? title;
  final LogicalKeyboardKey shortcut;
  final ValueChanged<LogicalKeyboardKey> onChanged;
  final bool autofocus;

  @override
  State<_ShortcutButton> createState() => _ShortcutButtonState();
}

class _ShortcutButtonState extends State<_ShortcutButton> {
  bool editing = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      skipTraversal: true,
      onKeyEvent:
          editing
              ? (node, event) {
                if (event is KeyDownEvent) {
                  setState(() => editing = false);
                  widget.onChanged(event.logicalKey);
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              }
              : null,
      child: ButtonSettingItem(
        autofocus: widget.autofocus,
        title: widget.title,
        trailing: editing ? _AnimatedEditing(child: Text(widget.shortcut.keyLabel)) : Text(widget.shortcut.keyLabel),
        onTap: () => setState(() => editing = true),
      ),
    );
  }
}

class _AnimatedEditing extends StatefulWidget {
  const _AnimatedEditing({required this.child});

  final Widget? child;

  @override
  State<_AnimatedEditing> createState() => _AnimatedEditingState();
}

class _AnimatedEditingState extends State<_AnimatedEditing> with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder:
          (context, child) => DecoratedBox(
            decoration: BoxDecoration(
              color: Color.lerp(
                Theme.of(context).colorScheme.inversePrimary,
                Theme.of(context).colorScheme.inverseSurface,
                _animationController.value,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: child,
          ),
      child: Container(padding: const EdgeInsets.all(8), child: widget.child),
    );
  }
}
