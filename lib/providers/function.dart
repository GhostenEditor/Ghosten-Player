import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../adaptive/adaptive.dart';

class FunctionConfig extends ChangeNotifier {
  FunctionConfig() {
    _subscription = EventDispatcher.where(type: .server, subType: .update).listen((_) => _update());
    Future.microtask(() => _update());
  }

  Server? server;
  bool multiServers = false;

  StreamSubscription<dynamic>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _update() async {
    final List<Server> servers = await Api.serverQueryAll();
    final Server server = servers.firstWhere((server) => server.active);
    multiServers = servers.length > 1;
    this.server = server;
    switch (server.type) {
      case ServerType.local:
        settingsStorage = true;
        settingsLibraryAdd = true;
        settingsLibrarySync = true;
        settingsLibraryDisable = true;
        settingsLibraryDelete = true;
        settingsHistory = true;
        settingsDownload = true;
        settingsDiagnostics = true;
        settingsDns = true;
        menuSync = true;
        menuScrape = true;
        menuSaveInfo = true;
        menuSetSkipTime = true;
        menuSubtitle = true;
        menuDownload = false;
      case ServerType.emby:
      case ServerType.jellyfin:
        settingsStorage = false;
        settingsLibraryAdd = false;
        settingsLibrarySync = false;
        settingsLibraryDisable = false;
        settingsLibraryDelete = false;
        settingsHistory = false;
        settingsDownload = false;
        settingsDiagnostics = false;
        settingsDns = false;
        menuSync = false;
        menuScrape = false;
        menuSaveInfo = false;
        menuSetSkipTime = false;
        menuSubtitle = false;
        menuDownload = false;
      case ServerType.remote:
    }
    notifyListeners();
  }

  bool settingsStorage = false;
  bool settingsLibraryAdd = false;
  bool settingsLibrarySync = false;
  bool settingsLibraryDisable = false;
  bool settingsLibraryDelete = false;
  bool settingsHistory = false;
  bool settingsDownload = false;
  bool settingsDiagnostics = false;
  bool settingsDns = false;
  final bool settingsShortcuts = StaticFunctions.settingsShortcuts;
  final bool settingsDisplaySize = StaticFunctions.settingsDisplaySize;
  final bool settingsAutoPip = StaticFunctions.settingsAutoPip;
  final bool settingsAutoForceLandscape = StaticFunctions.settingsAutoForceLandscape;
  final bool menuShortcuts = StaticFunctions.menuShortcuts;
  bool menuSync = false;
  bool menuScrape = false;
  bool menuSaveInfo = false;
  bool menuSetSkipTime = false;
  bool menuSubtitle = false;
  bool menuDownload = false;
}
