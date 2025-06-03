import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShortcutTV extends ChangeNotifier {
  ShortcutTV._fromPrefs(this.prefs)
    : menu = LogicalKeyboardKey(prefs.getInt('shortcut.tv.menu') ?? LogicalKeyboardKey.contextMenu.keyId),
      previousChannel = LogicalKeyboardKey(
        prefs.getInt('shortcut.tv.previousChannel') ?? LogicalKeyboardKey.arrowDown.keyId,
      ),
      nextChannel = LogicalKeyboardKey(prefs.getInt('shortcut.tv.nextChannel') ?? LogicalKeyboardKey.arrowUp.keyId),
      switchLinePanel = LogicalKeyboardKey(
        prefs.getInt('shortcut.tv.switchLinePanel') ?? LogicalKeyboardKey.arrowRight.keyId,
      ),
      channelsPanel = LogicalKeyboardKey(
        prefs.getInt('shortcut.tv.channelsPanel') ?? LogicalKeyboardKey.arrowLeft.keyId,
      );

  SharedPreferences prefs;
  LogicalKeyboardKey menu;
  LogicalKeyboardKey previousChannel;
  LogicalKeyboardKey nextChannel;
  LogicalKeyboardKey switchLinePanel;
  LogicalKeyboardKey channelsPanel;

  static Future<ShortcutTV> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ShortcutTV._fromPrefs(prefs);
  }

  void setMenu(LogicalKeyboardKey k) {
    menu = k;
    notifyListeners();
    prefs.setInt('shortcut.tv.menu', menu.keyId);
  }

  void setPreviousChannel(LogicalKeyboardKey k) {
    previousChannel = k;
    notifyListeners();
    prefs.setInt('shortcut.tv.previousChannel', previousChannel.keyId);
  }

  void setNextChannel(LogicalKeyboardKey k) {
    nextChannel = k;
    notifyListeners();
    prefs.setInt('shortcut.tv.nextChannel', nextChannel.keyId);
  }

  void setSwitchLinePanel(LogicalKeyboardKey k) {
    switchLinePanel = k;
    notifyListeners();
    prefs.setInt('shortcut.tv.switchLinePanel', switchLinePanel.keyId);
  }

  void setChannelsPanel(LogicalKeyboardKey k) {
    channelsPanel = k;
    notifyListeners();
    prefs.setInt('shortcut.tv.channelsPanel', channelsPanel.keyId);
  }
}
