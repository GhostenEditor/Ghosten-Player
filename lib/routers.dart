// ignore_for_file: avoid_dynamic_calls

import 'package:api/api.dart';
import 'package:flutter/material.dart';

import 'adaptive/adaptive.dart';
import 'details/playlist.dart';
import 'dialogs/episode_metadata.dart';
import 'dialogs/file_rename.dart';
import 'dialogs/live_edit.dart';
import 'dialogs/movie_metadata.dart';
import 'dialogs/scraper.dart';
import 'dialogs/season_metadata.dart';
import 'dialogs/series_metadata.dart';
import 'dialogs/storage_picker.dart';
import 'dialogs/subtitle.dart';
import 'dialogs/timer_picker.dart';
import 'medias/media_list.dart';
import 'settings/about.dart';
import 'settings/diagnostics.dart';
import 'settings/dns.dart';
import 'settings/downloader.dart';
import 'settings/help.dart';
import 'settings/home.dart';
import 'settings/library.dart';
import 'settings/log.dart';
import 'settings/other.dart';
import 'settings/play.dart';
import 'settings/player.dart';
import 'settings/player_history.dart';
import 'settings/player_kernel.dart';
import 'settings/server.dart';
import 'settings/server_add.dart';
import 'settings/shortcut.dart';
import 'settings/sponsor.dart';
import 'settings/storage.dart';
import 'settings/storage_add.dart';
import 'settings/storage_preference.dart';
import 'settings/sync.dart';
import 'settings/updater.dart';
import 'utils/navigator.dart';
import 'view_models/view_models.dart';
import 'viewers/image_viewer.dart';
import 'viewers/player_cast.dart';
import 'viewers/singleton_player.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final RouteName? routeName = RouteName.fromStringOrNull(settings.name);
  if (routeName == null) {
    return null;
  }
  final Widget Function(BuildContext, dynamic)? pageBuilder = _routesMap[routeName];
  if (pageBuilder != null) {
    Widget builder(context) => pageBuilder(context, settings.arguments as dynamic);
    final RouteType type = getRouteType(routeName);
    return switch (type) {
      RouteType.material => MaterialPageRoute(builder: builder, settings: settings),
      RouteType.player => PlayerPageRoute(builder: builder, settings: settings),
      RouteType.noTransition => NoTransitionPageRoute(builder: builder, settings: settings),
      RouteType.fadeIn => FadeInPageRoute(builder: builder, settings: settings),
      RouteType.modalBottomSheet => ModalBottomSheetRoute(
        builder: builder,
        settings: settings,
        isScrollControlled: true,
        useSafeArea: true,
      ),
      RouteType.modalBottomSheetWithHandle => ModalBottomSheetRoute(
        builder: builder,
        settings: settings,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
      ),
      RouteType.modalBottomSheetFull => ModalBottomSheetRoute(
        builder: (context) => MediaQuery(data: MediaQuery.of(navigatorKey.currentContext!), child: builder(context)),
        constraints: const .expand(),
        settings: settings,
        isScrollControlled: true,
      ),
    };
  } else {
    return null;
  }
}

final Map<RouteName, Widget Function(BuildContext, dynamic)> _routesMap = {
  .home: (context, arguments) => const HomePage(),
  .tv: (context, arguments) => TvListViewModel().build(),
  .movie: (context, arguments) => MovieListViewModel().build(),
  .live: (context, arguments) => LiveListViewModel().build(),
  .liveEdit: (context, arguments) => const LiveEditPage(),
  .liveDetail: (context, arguments) => PlaylistChannelsPage(item: arguments),
  .settings: (context, arguments) => const SettingsHomePage(),
  .detailSeries: (context, arguments) => SeriesViewModel(context, id: arguments['id'], data: arguments['data']).build(),
  .detailSeries2: (context, arguments) =>
      Series2ViewModel(context, id: arguments['id'], data: arguments['data']).build(),
  .detailSeason: (context, arguments) => SeasonViewModel(context, id: arguments['id'], data: arguments['data']).build(),
  .detailEpisode: (context, arguments) =>
      EpisodeViewModel(context, id: arguments['id'], data: arguments['data']).build(),
  .detailMovie: (context, arguments) => MovieViewModel(context, id: arguments['id'], data: arguments['data']).build(),
  .search: (context, arguments) => SearchViewModel().build(),
  .scrape: (context, arguments) => ScraperDialog(item: arguments),
  .media: (context, arguments) => MediaListPage(data: arguments),
  .player: (context, arguments) => SingletonPlayer(data: arguments),
  .livePlayer: (context, arguments) => LivePlayerPage(data: arguments),
  .castPlayer: (context, arguments) => PlayerCast(data: arguments['data'], device: arguments['device']),
  .castSearcher: (context, arguments) => const PlayerCastSearcher(),
  .subtitle: (context, arguments) => SubtitleListViewModel(fileId: arguments).build(),
  .subtitleAdd: (context, arguments) => SubtitleDialog(fileId: arguments),
  .setSkipTime: (context, arguments) => TimerPickerDialog(data: arguments),
  .imageViewer: (context, arguments) => ImageViewer(url: arguments['url'], title: arguments['title']),
  .storagePicker: (context, arguments) => const StoragePickDialog(),
  .metadataSeries: (context, arguments) => SeriesMetadata(series: arguments),
  .metadataSeason: (context, arguments) => SeasonMetadata(season: arguments),
  .metadataEpisode: (context, arguments) => EpisodeMetadata(episode: arguments),
  .metadataMovie: (context, arguments) => MovieMetadata(movie: arguments),
  .fileRename: (context, arguments) =>
      FilenameDialog(dialogTitle: arguments['dialogTitle'], filename: arguments['filename']),
  .settingsStorage: (context, arguments) => StorageListViewModel().build(),
  .settingsStorageAdd: (context, arguments) => const SettingsStorageAddPage(),
  .settingsStoragePreference: (context, arguments) => SettingsStoragePreferencePage(storage: arguments),
  .settingsLibraryTv: (context, arguments) => LibraryListViewModel(type: LibraryType.tv).build(),
  .settingsLibraryMovie: (context, arguments) => LibraryListViewModel(type: LibraryType.movie).build(),
  .settingsPlay: (context, arguments) => const SettingsPlayPage(),
  .settingsHistory: (context, arguments) => PlayerHistoryListViewModel().build(),
  .settingsDownload: (context, arguments) => const SystemSettingsDownloader(),
  .settingsServer: (context, arguments) => ServerListViewModel().build(),
  .settingsServerAdd: (context, arguments) => const SettingsServerAddPage(),
  .settingsDiagnostics: (context, arguments) => const SettingsDiagnostics(),
  .settingsLog: (context, arguments) => const SettingsLogPage(),
  .settingsOther: (context, arguments) => const SystemSettingsOther(),
  .settingsPlayer: (context, arguments) => const SettingsPlayer(),
  .settingsPlayerKernel: (context, arguments) => const SettingsPlayerKernel(),
  .settingsSync: (context, arguments) => const SettingsSyncPage(),
  .settingsDns: (context, arguments) => DNDListViewModel().build(),
  .settingsShortcut: (context, arguments) => const SystemSettingsShortcut(),
  .settingsDnsEdit: (context, arguments) => SystemSettingsDNSEdit(item: arguments),
  .settingsHelp: (context, arguments) => HelpListViewModel().build(),
  .settingsHelpDetail: (context, arguments) => HelperDetail(page: arguments),
  .settingsSponsor: (context, arguments) => const SettingsSponsor(),
  .settingsAbout: (context, arguments) => const SettingsAboutPage(),
  .settingsUpdater: (context, arguments) => const SettingsUpdater(),
};
