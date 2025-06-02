import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/player.dart';

import '../../utils/utils.dart';
import '../player/common_player.dart';

Future<void> toPlayer<T>(
  BuildContext context,
  FutureOr<(List<PlaylistItemDisplay<T>>, int)> playlist, {
  int? theme,
}) async {
  await navigateTo(context, CommonPlayerPage<T>(playlist: playlist, theme: theme));
}
