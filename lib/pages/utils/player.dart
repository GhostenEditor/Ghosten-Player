import 'package:flutter/material.dart';
import 'package:video_player/player.dart';

import '../../utils/utils.dart';
import '../player/singleton_player.dart';
import 'utils.dart';

Future<void> toPlayer<T>(
  BuildContext context,
  List<PlaylistItemDisplay<T>> playlist, {
  int index = 0,
  int? theme,
}) async {
  assert(index.clamp(0, playlist.length - 1) == index);
  setPreferredOrientations(true);
  await navigateTo(context, SingletonPlayer<T>(playlist: playlist, index: index, theme: theme));
  setPreferredOrientations(false);
}
