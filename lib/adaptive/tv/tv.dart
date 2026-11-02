import 'package:flutter/material.dart' hide Scrollbar;

import '../../utils/navigator.dart';

export 'components/action_list_tile.dart';
export 'components/carousel.dart';
export 'components/carousel_item.dart';
export 'components/edit_page.dart';
export 'components/image_card.dart';
export 'components/list_tile.dart';
export 'components/menu_list_tile.dart';
export 'components/orientation_page.dart';
export 'components/player_subtitle_setting.dart';
export 'components/radio_list_tile.dart';
export 'components/setting_page.dart';
export 'components/switch_list_tile.dart';
export 'components/text_form_field.dart';
export 'details/episode.dart';
export 'details/movie.dart';
export 'details/season.dart';
export 'details/series.dart';
export 'details/series2.dart';
export 'dialogs/confirm.dart';
export 'home.dart';
export 'player/live_player.dart';
export 'player/player_controls.dart';
export 'theme.dart';
export 'wrapper.dart';

const bool kIsTV = true;
final settingNavigatorKey = GlobalKey<NavigatorState>();

class Scrollbar extends StatelessWidget {
  const Scrollbar({super.key, required this.child, this.controller});

  final Widget child;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

RouteType getRouteType(RouteName routeName) => switch (routeName) {
  .tv ||
  .movie ||
  .live ||
  .setSkipTime ||
  .settings ||
  .settingsStorage ||
  .settingsStoragePreference ||
  .settingsLibraryTv ||
  .settingsLibraryMovie ||
  .settingsHistory ||
  .settingsDownload ||
  .settingsServer ||
  .settingsDiagnostics ||
  .settingsLog ||
  .settingsOther ||
  .settingsHelp ||
  .settingsHelpDetail ||
  .settingsPlayer ||
  .settingsPlayerKernel ||
  .settingsDns ||
  .settingsDnsEdit ||
  .settingsShortcut ||
  .subtitle ||
  .settingsAbout => .fadeIn,
  .storagePicker => .modalBottomSheetWithHandle,
  .player || .livePlayer => .player,
  _ => .material,
};

Future<NavigatorState> getNavigatorState(BuildContext context, RouteName routeName) async {
  switch (routeName) {
    case .player:
    case .livePlayer:
    case .castPlayer:
    case .castSearcher:
    case .liveEdit:
    case .storagePicker:
    case .imageViewer:
    case .detailSeries:
    case .detailSeries2:
    case .detailEpisode:
    case .detailMovie:
    case .search:
    case .scrape:
    case .media:
    case .settingsDnsEdit:
    case .subtitleAdd:
    case .metadataSeries:
    case .metadataSeason:
    case .metadataEpisode:
    case .metadataMovie:
    case .fileRename:
    case .settingsStorageAdd:
    case .settingsPlay:
    case .settingsServerAdd:
    case .settingsSponsor:
    case .settingsSync:
    case .settingsUpdater:
      return Navigator.of(context, rootNavigator: true);
    case .settingsHistory:
    case .settingsLibraryTv:
    case .settingsLibraryMovie:
      Scaffold.of(context).openEndDrawer();
      await WidgetsBinding.instance.endOfFrame;
      return Navigator.of(settingNavigatorKey.currentContext!);
    default:
      return Navigator.of(context);
  }
}

class StaticFunctions {
  static const bool settingsShortcuts = true;
  static const bool settingsDisplaySize = false;
  static const bool settingsAutoPip = false;
  static const bool settingsAutoForceLandscape = false;
  static const bool menuShortcuts = false;
}
