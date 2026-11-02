import 'dart:io';

import 'package:api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/player.dart';

import 'adaptive/adaptive.dart';
import 'app.dart';
import 'components/components.dart ';
import 'platform_api.dart';
import 'providers/function.dart';
import 'providers/player.dart';
import 'providers/shortcut_tv.dart';
import 'providers/user_config.dart';
import 'viewers/singleton_player.dart';

void main() async {
  ScaledWidgetsFlutterBinding.ensureInitialized();
  final List<dynamic>? args = kIsWeb ? [] : await PlatformApi.initialized();
  PlatformApi.deviceType = kIsWeb || kIsTV ? .other : DeviceType.fromString(args![0]);
  if (kIsWeb) {
    await BrowserContextMenu.disableContextMenu();
  } else {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (PlatformApi.deviceType == DeviceType.androidPhone) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    HttpOverrides.global = _MyHttpOverrides();
  }
  final bool initialized = await Api.initialized();
  // await Api.setTmdbApiKey("");
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final shortcutTV = ShortcutTV(prefs);
  final userConfig = UserConfig(prefs);
  final playerConfig = PlayerConfig(prefs);
  final FunctionConfig? functionConfig = initialized ? FunctionConfig() : null;
  ScaledWidgetsFlutterBinding.instance.scaleFactor = kIsTV
      ? (deviceSize) => deviceSize.width / 960
      : (deviceSize) => userConfig.displayScale;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userConfig),
        ChangeNotifierProvider(create: (_) => playerConfig),
        if (initialized) ChangeNotifierProvider(create: (_) => functionConfig),
        if (kIsTV) ChangeNotifierProvider(create: (_) => shortcutTV),
      ],
      child: MainApp(
        initialized: initialized,
        onGenerateInitialRoutes: args!.length == 2
            ? (initialRoute) => [
                MaterialPageRoute(
                  builder: (_) => QuitConfirm(
                    child: SingletonPlayer(
                      data: .new(playlist: [PlaylistItem(url: Uri.parse(args[1]))]),
                    ),
                  ),
                ),
              ]
            : null,
      ),
    ),
  );
}

class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) =>
          host == 'image.tmdb.org' || host == 'media.themoviedb.org';
  }
}
