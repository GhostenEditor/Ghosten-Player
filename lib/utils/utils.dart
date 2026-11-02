import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

export 'context_menu.dart';
export 'date_time.dart';
export 'download.dart';
export 'duration.dart';
export 'file_picker.dart';
export 'int.dart';
export 'navigator.dart';
export 'notification.dart';
export 'player.dart';
export 'uri.dart';

final cacheHttpClient = Dio(BaseOptions(connectTimeout: const Duration(seconds: 30)))
  ..interceptors.add(DioCacheInterceptor(options: CacheOptions(store: MemCacheStore())));

// const _lightSystemUiOverlayStyle = SystemUiOverlayStyle(
//   systemNavigationBarIconBrightness: Brightness.dark,
//   // 设置为全透明时，在某些设备上NavigationBar并不会完全透明
//   systemNavigationBarColor: Color(0x01FFFFFF),
//   statusBarIconBrightness: Brightness.dark,
//   statusBarColor: Colors.transparent,
// );
//
// const _darkSystemUiOverlayStyle = SystemUiOverlayStyle(
//   systemNavigationBarIconBrightness: Brightness.light,
//   // 设置为全透明时，在某些设备上NavigationBar并不会完全透明
//   systemNavigationBarColor: Color(0x01000000),
//   statusBarIconBrightness: Brightness.light,
//   statusBarColor: Colors.transparent,
// );
//
// SystemUiOverlayStyle? getSystemUiOverlayStyle(BuildContext context, [ThemeMode? mode]) {
//   return switch (mode ?? context.read<UserConfig>().themeMode) {
//     ThemeMode.light => _lightSystemUiOverlayStyle,
//     ThemeMode.dark => _darkSystemUiOverlayStyle,
//     ThemeMode.system => switch (MediaQuery.platformBrightnessOf(context)) {
//       Brightness.light => _lightSystemUiOverlayStyle,
//       Brightness.dark => _darkSystemUiOverlayStyle,
//     },
//   };
// }
