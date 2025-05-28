import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../dialogs/timer_picker.dart';
import '../../utils/notification.dart';

abstract class MediaCubit<T> extends Cubit<T?> {
  MediaCubit(super.initialState);

  Future<void> update();
}

mixin ActionMixin<S extends StatefulWidget> on State<S> {
  PopupMenuEntry<Never> buildWatchedAction<B extends MediaCubit<AsyncSnapshot<T>>, T extends MediaBase>(
    BuildContext context,
    T item,
    MediaType type,
  ) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      onTap: () async {
        await Api.markWatched(type, item.id, !item.watched);
        if (context.mounted) {
          final state = context.read<B>();
          state.update();
        }
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          item.watched
              ? AppLocalizations.of(context)!.buttonMarkNotPlayed
              : AppLocalizations.of(context)!.buttonMarkPlayed,
        ),
        leading: Icon(Icons.check_rounded, color: item.watched ? Theme.of(context).colorScheme.primary : null),
      ),
    );
  }

  PopupMenuEntry<Never> buildFavoriteAction<B extends MediaCubit<AsyncSnapshot<T>>, T extends MediaBase>(
    BuildContext context,
    T item,
    MediaType type,
  ) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      onTap: () async {
        await Api.markFavorite(type, item.id, !item.favorite);
        if (context.mounted) {
          final state = context.read<B>();
          state.update();
        }
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          item.favorite
              ? AppLocalizations.of(context)!.buttonUnmarkFavorite
              : AppLocalizations.of(context)!.buttonMarkFavorite,
        ),
        leading: Icon(
          Icons.favorite_border_rounded,
          color: item.favorite ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
    );
  }

  PopupMenuEntry<Never> buildScraperAction<B extends MediaCubit<AsyncSnapshot<T>>, T extends MediaBase>(
    BuildContext context,
    Future<bool?> Function() future,
  ) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      onTap: () async {
        final flag = await future();
        if (context.mounted && (flag ?? false)) {
          final state = context.read<B>();
          state.update();
        }
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(AppLocalizations.of(context)!.buttonScraperMediaInfo),
        leading: const Icon(Icons.info_outline),
      ),
    );
  }

  PopupMenuEntry<Never> buildSkipFromStartAction<B extends MediaCubit<AsyncSnapshot<T>>, T extends MediaBase>(
    BuildContext context,
    T item,
    MediaType type,
    Duration value,
  ) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      onTap: () async {
        final time = await showDialog(
          context: context,
          builder:
              (context) => TimerPickerDialog(value: value, title: AppLocalizations.of(context)!.buttonSkipFromStart),
        );
        if (time != null) {
          await Api.setSkipTime(SkipTimeType.intro, type, item.id, time);
          if (context.mounted) {
            final state = context.read<B>();
            state.update();
          }
        }
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(AppLocalizations.of(context)!.buttonSkipFromStart),
        leading: const Icon(Icons.access_time),
      ),
    );
  }

  PopupMenuEntry<Never> buildSkipFromEndAction<B extends MediaCubit<AsyncSnapshot<T>>, T extends MediaBase>(
    BuildContext context,
    T item,
    MediaType type,
    Duration value,
  ) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      onTap: () async {
        final time = await showDialog(
          context: context,
          builder: (context) => TimerPickerDialog(value: value, title: AppLocalizations.of(context)!.buttonSkipFromEnd),
        );
        if (time != null) {
          await Api.setSkipTime(SkipTimeType.ending, type, item.id, time);
          if (context.mounted) {
            final state = context.read<B>();
            state.update();
          }
        }
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(AppLocalizations.of(context)!.buttonSkipFromEnd),
        leading: const Icon(Icons.access_time),
      ),
    );
  }

  PopupMenuEntry<Never> buildEditMetadataAction(BuildContext context, VoidCallback? onPressed) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      onTap: onPressed,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(AppLocalizations.of(context)!.buttonEditMetadata),
        leading: const Icon(Icons.edit_outlined),
      ),
    );
  }

  PopupMenuEntry<Never> buildDeleteAction(BuildContext context, Future<void> Function() future) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      onTap: () async {
        final confirmed = await showConfirm(context, AppLocalizations.of(context)!.deleteConfirmText);
        if (confirmed != true) return;
        await future();
        if (!context.mounted) return;
        Navigator.pop(context);
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(AppLocalizations.of(context)!.buttonDelete),
        leading: const Icon(Icons.delete_outline),
      ),
    );
  }

  PopupMenuEntry<Never> buildHomeAction(BuildContext context, Uri uri) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      onTap:
          () => launchUrl(
            uri,
            mode: LaunchMode.inAppBrowserView,
            browserConfiguration: const BrowserConfiguration(showTitle: true),
          ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(AppLocalizations.of(context)!.buttonHome),
        leading: const Icon(Icons.home_outlined),
      ),
    );
  }
}
