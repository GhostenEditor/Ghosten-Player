import 'package:api/api.dart';
import 'package:flutter/material.dart' hide ListTile;

import '../utils/utils.dart';
import 'abstract.dart';

class SubtitleMenu extends Menu {
  const SubtitleMenu(this.item);

  final SubtitleData item;

  @override
  List<Widget> build(BuildContext context) {
    return [buildDeleteAction(context, () => showNotification(context, Api.subtitleDeleteById(item.id)))];
  }
}
