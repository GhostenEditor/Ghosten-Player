import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../components/components.dart';
import '../models/models.dart';
import 'utils.dart';

Future<void> toMediaPlayer<T extends MediaBase>(BuildContext context, MediaType type, dynamic id) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    PlayerPageRoute(
      builder: (context) => _PlayerPreparePage(type: type, id: id),
    ),
  );
}

class _PlayerPreparePage extends StatefulWidget {
  const _PlayerPreparePage({required this.type, required this.id});

  final MediaType type;
  final dynamic id;

  @override
  State<_PlayerPreparePage> createState() => _PlayerPreparePageState();
}

class _PlayerPreparePageState extends State<_PlayerPreparePage> {
  Object? error;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        final PlaylistData data = await getPlaylistById(widget.type, widget.id);
        if (mounted) {
          final Future<void> _ = context.pushReplacementNamed(.player, arguments: data);
        }
      } catch (e) {
        if (mounted) {
          setState(() => error = e);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(forceMaterialTransparency: true, automaticallyImplyLeading: false),
      extendBodyBehindAppBar: true,
      body: Center(child: error != null ? ErrorMessage(error: error) : const Loading()),
    );
  }
}
