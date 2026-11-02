import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/navigator.dart';
import '../../viewers/singleton_player.dart';

export 'package:flutter/src/material/list_tile.dart';
export 'package:flutter/src/material/radio_list_tile.dart';
export 'package:flutter/src/material/scrollbar.dart';
export 'package:flutter/src/material/switch_list_tile.dart';
export 'package:flutter/src/material/text_form_field.dart';

export 'components/action_list_tile.dart';
export 'components/carousel.dart';
export 'components/carousel_item.dart';
export 'components/edit_page.dart';
export 'components/image_card.dart';
export 'components/menu_list_tile.dart';
export 'components/orientation_page.dart';
export 'components/player_subtitle_setting.dart';
export 'components/setting_page.dart';
export 'details/episode.dart';
export 'details/movie.dart';
export 'details/season.dart';
export 'details/series.dart';
export 'dialogs/confirm.dart';
export 'home.dart';
export 'player/player_controls.dart';
export 'theme.dart';
export 'wrapper.dart';

const bool kIsTV = false;

final settingNavigatorKey = GlobalKey<NavigatorState>();

class Series2Page extends StatelessWidget {
  const Series2Page({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox();
}

class LivePlayerPage extends StatelessWidget {
  const LivePlayerPage({super.key, required this.data});

  final PlaylistData data;

  @override
  Widget build(BuildContext context) {
    return SingletonPlayer(data: data);
  }
}

RouteType getRouteType(RouteName routeName) => switch (routeName) {
  .metadataSeries ||
  .metadataSeason ||
  .metadataEpisode ||
  .metadataMovie ||
  .fileRename ||
  .setSkipTime ||
  .subtitleAdd ||
  .liveEdit ||
  .settingsStorageAdd ||
  .settingsStoragePreference ||
  .settingsServerAdd ||
  .settingsPlay ||
  .settingsDnsEdit => .modalBottomSheet,
  .castSearcher || .storagePicker => .modalBottomSheetWithHandle,
  .castPlayer => .modalBottomSheetFull,
  .tv || .movie || .live || .settings => .noTransition,
  .player || .livePlayer => .player,
  _ => .material,
};

Future<NavigatorState> getNavigatorState(BuildContext context, RouteName routeName) async {
  return switch (routeName) {
    .tv || .movie || .live || .settings => Navigator.of(context),
    _ => Navigator.of(context, rootNavigator: true),
  };
}

class StaticFunctions {
  static const bool settingsShortcuts = false;
  static const bool settingsDisplaySize = true;
  static const bool settingsAutoPip = true;
  static const bool settingsAutoForceLandscape = true;
  static const bool menuShortcuts = true;
}
