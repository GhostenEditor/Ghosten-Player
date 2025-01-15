import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/utils.dart';
import '../player/common_player.dart';

Future<void> toPlayer(BuildContext context, List<ExPlaylistItem> playlist, {int? id, int? theme, required PlayerType playerType}) async {
  assert(playlist.isNotEmpty);
  int index = playlist.indexWhere((element) => element.id == id);
  if (index == -1) {
    index = 0;
  }
  await navigateTo(context, CommonPlayerPage(playlist: playlist, index: index, theme: theme, playerType: playerType, isTV: true));
}
