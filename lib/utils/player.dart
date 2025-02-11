import 'package:flutter/material.dart';
import 'package:video_player/player.dart';

import '../models/models.dart';
import '../pages/player/common_player.dart';
import 'utils.dart';

Future<void> toPlayer(BuildContext context, List<ExPlaylistItem> playlist, {int? id, int? theme, required PlayerType playerType}) async {
  assert(playlist.isNotEmpty);
  int index = playlist.indexWhere((element) => element.id == id);
  if (index == -1) {
    index = 0;
  }
  setPreferredOrientations(true);
  await navigateTo(context, CommonPlayerPage(playlist: playlist, index: index, theme: theme, playerType: playerType));
  setPreferredOrientations(false);
}

Future<void> toPlayerCast(BuildContext context, CastDevice device, List<ExPlaylistItem> playlist, {int? id, int? theme}) async {
  assert(playlist.isNotEmpty);
  int index = playlist.indexWhere((element) => element.id == id);
  if (index == -1) {
    index = 0;
  }
  setPreferredOrientations(true);
  await navigateToSlideUp(context, PlayerCast(playlist: playlist, index: index, theme: theme, device: device));
  setPreferredOrientations(false);
}
