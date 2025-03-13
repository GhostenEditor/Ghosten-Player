import 'package:flutter/material.dart';
import 'package:video_player/player.dart';

import '../../utils/utils.dart';
import '../player/common_player.dart';

Future<void> toPlayer<T>(BuildContext context, List<PlaylistItem<T>> playlist, {int index = 0, int? theme}) async {
  assert(index.clamp(0, playlist.length - 1) == index);
  await navigateTo(context, CommonPlayerPage<T>(playlist: playlist, index: index, theme: theme, isTV: true));
}
