import 'dart:convert';
import 'dart:math';

import 'package:api/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PopupMenuItem;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:player_view/player.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/appbar_progress.dart';
import '../../../components/async_image.dart';
import '../../../components/future_builder_handler.dart';
import '../../../components/gap.dart';
import '../../../components/mobile_builder.dart';
import '../../../components/pop_to_top.dart';
import '../../../components/popup_menu.dart';
import '../../../dialogs/timer_picker.dart';
import '../../../utils/notification.dart';
import '../../../utils/utils.dart';
import '../../player/cast_adaptor.dart';
import '../components/drop_cap_text.dart';
import '../dialogs/prompt_filename.dart';

mixin DetailPageMixin<T extends MediaBase, S extends StatefulWidget> on State<S> {
  bool refresh = false;
  bool favoriteChecked = false;
  bool watchedChecked = false;
  T? initialData;
  double floatWidth = 200;
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopToTop(
      onPop: () => Navigator.of(context).pop(refresh),
      controller: _controller,
      child: Scaffold(
        body: FutureBuilderHandler(
          future: future(),
          initialData: initialData,
          builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
            final item = snapshot.requireData;
            favoriteChecked = item.favorite;
            watchedChecked = item.watched;
            return _DetailTheme(
              key: ValueKey(item.themeColor),
              themeColor: item.themeColor,
              child: _DetailLayout(
                controller: _controller,
                item: item,
                floatWidth: floatWidth,
                titleBuilder: (BuildContext context) => buildTitle(context, item),
                subTitleBuilder: (BuildContext context) => buildSubTitle(context, item),
                childBuilder: (BuildContext context) => buildChild(context, item),
                floatImageBuilder: (BuildContext context) => buildFloatImage(context, item),
                actionsBuilder: (BuildContext context) => buildActions(context, item),
              ),
            );
          },
        ),
      ),
    );
  }

  List<ActionEntry> buildActions(BuildContext context, T item) {
    return [];
  }

  ActionButton buildPlayAction(BuildContext context, VoidCallback? onPlay) {
    return ActionButton(
      autofocus: kIsAndroidTV,
      onPressed: onPlay,
      icon: const Icon(Icons.play_arrow_rounded),
    );
  }

  ActionButton buildCastAction(BuildContext context, Function(CastDevice device) onDeviceSelect) {
    return ActionButton(
      autoCollapse: true,
      text: Text(AppLocalizations.of(context)!.buttonCast),
      onPressed: () async {
        final device = await showModalBottomSheet<CastDevice>(
          context: context,
          builder: (context) => const PlayerCastSearcher(CastAdaptor()),
        );
        if (device != null) {
          onDeviceSelect(device);
        }
      },
      icon: const Icon(Icons.airplay_rounded),
    );
  }

  ActionButton buildWatchedAction(BuildContext context, T item, MediaType type) {
    return ActionButton(
      autoCollapse: true,
      text: Text(watchedChecked ? AppLocalizations.of(context)!.buttonMarkNotPlayed : AppLocalizations.of(context)!.buttonMarkPlayed),
      onPressed: () {
        Api.markWatched(type, item.id, !item.watched);
        refresh = true;
        setState(() => watchedChecked = !watchedChecked);
      },
      icon: Icon(Icons.check_rounded, color: watchedChecked ? Colors.redAccent : null),
    );
  }

  ActionButton buildFavoriteAction(BuildContext context, T item, MediaType type) {
    return ActionButton(
      text: Text(favoriteChecked ? AppLocalizations.of(context)!.buttonUnmarkFavorite : AppLocalizations.of(context)!.buttonMarkFavorite),
      autoCollapse: true,
      onPressed: () {
        Api.markFavorite(type, item.id, !item.favorite);
        refresh = true;
        setState(() => favoriteChecked = !favoriteChecked);
      },
      icon: Icon(Icons.favorite_border_rounded, color: favoriteChecked ? Colors.redAccent : null),
    );
  }

  ActionButton buildRefreshInfoAction(BuildContext context, Future<bool> Function() future) {
    return ActionButton(
        text: Text(AppLocalizations.of(context)!.buttonSyncMediaInfo),
        icon: const Icon(Icons.info_outline),
        collapsed: true,
        onPressed: () async {
          final resp = await showNotification(context, future());
          if (resp?.data == true) setState(() => refresh = true);
        });
  }

  ActionButton buildSkipFromStartAction(BuildContext context, T item, MediaType type, Duration value) {
    return ActionButton(
        text: Text(AppLocalizations.of(context)!.buttonSkipFromStart),
        icon: const Icon(Icons.access_time),
        collapsed: true,
        onPressed: () async {
          final time = await showDialog(
              context: context, builder: (context) => TimerPickerDialog(value: value, title: AppLocalizations.of(context)!.buttonSkipFromStart));
          if (time != null) {
            Api.setSkipTime(SkipTimeType.intro, type, item.id, time);
            setState(() {});
          }
        });
  }

  ActionButton buildSkipFromEndAction(BuildContext context, T item, MediaType type, Duration value) {
    return ActionButton(
        text: Text(AppLocalizations.of(context)!.buttonSkipFromEnd),
        icon: const Icon(Icons.access_time),
        collapsed: true,
        onPressed: () async {
          final time =
              await showDialog(context: context, builder: (context) => TimerPickerDialog(value: value, title: AppLocalizations.of(context)!.buttonSkipFromEnd));
          if (time != null) {
            Api.setSkipTime(SkipTimeType.ending, type, item.id, time);
            setState(() {});
          }
        });
  }

  ActionButton buildEditMetadataAction(BuildContext context, VoidCallback? onPressed) {
    return ActionButton(
        text: Text(AppLocalizations.of(context)!.buttonEditMetadata), icon: const Icon(Icons.edit_outlined), collapsed: true, onPressed: onPressed);
  }

  ActionButton buildDeleteAction(BuildContext context, Future<void> Function() future) {
    return ActionButton(
        text: Text(AppLocalizations.of(context)!.buttonDelete),
        icon: const Icon(Icons.delete_outline),
        collapsed: true,
        onPressed: () async {
          final confirmed = await showConfirm(context, AppLocalizations.of(context)!.deleteConfirmText);
          if (confirmed != true) return;
          await future();
          if (!context.mounted) return;
          refresh = true;
          Navigator.of(context).pop(refresh);
        });
  }

  ActionButton buildHomeAction(BuildContext context, Uri uri) {
    return ActionButton(
        text: Text(AppLocalizations.of(context)!.buttonHome),
        icon: const Icon(Icons.home_outlined),
        collapsed: true,
        onPressed: () => launchUrl(uri, mode: LaunchMode.inAppBrowserView, browserConfiguration: const BrowserConfiguration(showTitle: true)));
  }

  Widget buildFloatImage(BuildContext context, T item) {
    return AspectRatio(
        aspectRatio: .667,
        child: item.poster != null
            ? AsyncImage(item.poster!)
            : Icon(
                Icons.image_not_supported,
                size: 50,
                color: Theme.of(context).colorScheme.primaryFixedDim,
              ));
  }

  Widget buildTitle(BuildContext context, T item);

  Widget buildSubTitle(BuildContext context, T item);

  SliverChildDelegate buildChild(BuildContext context, T item);

  Future<T> future();

  Future<void> navigate(BuildContext context, Widget destination) async {
    final flag = await navigateTo<bool>(context, destination);
    if (flag == true) {
      setState(() {});
      refresh = true;
    }
  }

  Future<bool> search(Future<void> Function({required String title, int? year, int? index}) future, {required String title, int? year, int? index}) async {
    try {
      await future(title: title, year: year, index: index);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.badResponse:
          switch (e.response?.statusCode) {
            case 404:
              if (!mounted) return false;
              final res =
                  await showDialog<(String, int?)>(context: context, barrierDismissible: false, builder: (context) => PromptFilename(text: title, year: year));
              if (res != null) {
                return search(future, title: res.$1, year: res.$2);
              } else {
                rethrow;
              }
            case 300:
              if (!mounted) return false;
              final data = (e.response?.data! as List<dynamic>).map((e) => SearchResult.fromJson(e)).toList();
              final res = await showDialog<int>(context: context, barrierDismissible: false, builder: (context) => _SearchResultSelect(data));
              if (res != null) {
                return search(future, title: title, year: year, index: res);
              } else {
                rethrow;
              }
            default:
              rethrow;
          }
        default:
          rethrow;
      }
    } on ApiException catch (e) {
      switch (e.type) {
        case ApiExceptionType.notFound:
          if (!mounted) return false;
          final res =
              await showDialog<(String, int?)>(context: context, barrierDismissible: false, builder: (context) => PromptFilename(text: title, year: year));
          if (res != null) {
            return search(future, title: res.$1, year: res.$2);
          } else {
            rethrow;
          }
        case ApiExceptionType.multiChoices:
          if (!mounted) return false;
          final data = (jsonDecode(e.details!) as List<dynamic>).map((e) => SearchResult.fromJson(e)).toList();
          final res = await showDialog<int>(context: context, barrierDismissible: false, builder: (context) => _SearchResultSelect(data));
          if (res != null) {
            return search(future, title: title, year: year, index: res);
          } else {
            rethrow;
          }
        default:
          rethrow;
      }
    }
    refresh = true;
    return true;
  }
}

class ActionEntry {}

class ActionDivider implements ActionEntry {}

class ActionButton implements ActionEntry {
  final bool autofocus;
  final bool autoCollapse;
  final bool collapsed;
  final Widget? icon;
  final Widget? text;
  final Widget? trailing;
  final VoidCallback? onPressed;

  const ActionButton({
    this.autofocus = false,
    this.autoCollapse = false,
    this.collapsed = false,
    this.icon,
    this.text,
    this.trailing,
    required this.onPressed,
  });
}

class _SearchResultSelect extends StatefulWidget {
  final List<SearchResult> items;

  const _SearchResultSelect(this.items);

  @override
  State<_SearchResultSelect> createState() => _SearchResultSelectState();
}

class _SearchResultSelectState extends State<_SearchResultSelect> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.modalTitleNotification),
      content: SizedBox(
        width: 600,
        child: Scrollbar(
          child: ListView.separated(
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return InkWell(
                autofocus: kIsAndroidTV && index == 0,
                onTap: () => Navigator.of(context).pop(index),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                                if (item.originalTitle != null)
                                  Text(item.originalTitle!, style: Theme.of(context).textTheme.labelSmall, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          if (item.airDate != null) Text(item.airDate!.format(), style: Theme.of(context).textTheme.labelMedium),
                        ],
                      ),
                      Gap.vSM,
                      MobileBuilder(builder: (context, isMobile, _) {
                        return DropCapText(
                          item.overview ?? ' ',
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                          style: DefaultTextStyle.of(context).style,
                          dropCapPadding: const EdgeInsets.only(right: 8, top: 4),
                          dropCap: DropCap(
                            width: isMobile ? 86 : 160,
                            height: isMobile ? 128 : 240,
                            child: item.poster != null
                                ? AsyncImage(item.poster!)
                                : Container(
                                    color: Theme.of(context).colorScheme.onSurface.withAlpha(0x11),
                                    child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 50))),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
            itemCount: widget.items.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(),
          ),
        ),
      ),
    );
  }
}

class _DetailTheme extends StatelessWidget {
  final int? themeColor;
  final Widget child;

  const _DetailTheme({super.key, this.themeColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: themeColor == null ? null : ColorScheme.fromSeed(seedColor: Color(themeColor!), brightness: Theme.of(context).brightness),
      ),
      child: child,
    );
  }
}

class _DetailLayout<T extends MediaBase> extends StatefulWidget {
  final ScrollController controller;
  final T item;
  final WidgetBuilder titleBuilder;
  final WidgetBuilder subTitleBuilder;
  final WidgetBuilder floatImageBuilder;
  final SliverChildDelegate Function(BuildContext context) childBuilder;
  final List<ActionEntry> Function(BuildContext context) actionsBuilder;
  final double floatWidth;

  const _DetailLayout({
    super.key,
    required this.controller,
    required this.item,
    required this.titleBuilder,
    required this.subTitleBuilder,
    required this.childBuilder,
    required this.floatImageBuilder,
    required this.actionsBuilder,
    required this.floatWidth,
  });

  @override
  State<_DetailLayout<T>> createState() => _DetailLayoutState<T>();
}

class _DetailLayoutState<T extends MediaBase> extends State<_DetailLayout<T>> {
  final _scrollTop = ValueNotifier<double>(0);
  late final _controller = widget.controller;

  @override
  void initState() {
    _controller.addListener(_updateScrollOffset);
    super.initState();
  }

  @override
  void dispose() {
    _scrollTop.dispose();
    _controller.removeListener(_updateScrollOffset);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scrollbar(
          controller: widget.controller,
          child: CustomScrollView(
            controller: widget.controller,
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: MobileBuilder(builder: (context, isMobile, _) {
                  return FlexibleSpaceBar(
                    centerTitle: true,
                    background: _DetailFlexibleSpaceBarBackground(
                      item: widget.item,
                      isMobile: isMobile,
                    ),
                    title: ListenableBuilder(
                      listenable: _scrollTop,
                      builder: (BuildContext context, Widget? child) => _DetailTitleBackground(
                        floatWidth: widget.floatWidth,
                        isMobile: isMobile,
                        scrollTop: _scrollTop.value,
                        child: child!,
                      ),
                      child: _DetailTitleLayout(
                        title: widget.titleBuilder(context),
                        subTitle: widget.subTitleBuilder(context),
                        actions: widget.actionsBuilder(context),
                        isMobile: isMobile,
                      ),
                    ),
                    titlePadding: EdgeInsets.zero,
                    expandedTitleScale: 1,
                  );
                }),
                bottom: const AppbarProgressIndicator(),
              ),
              MobileBuilder(
                builder: (context, isMobile, child) {
                  return SliverSafeArea(
                      top: false,
                      sliver: SliverPadding(
                          padding: EdgeInsets.fromLTRB((isMobile ? 0 : widget.floatWidth + 16) + 16, 16, 16, 16), sliver: SliverList(delegate: child!)));
                },
                child: widget.childBuilder(context),
              ),
            ],
          ),
        ),
        MobileBuilder(builder: (context, isMobile, _) {
          return isMobile
              ? null
              : IgnorePointer(
                  child: SafeArea(
                    bottom: false,
                    child: ListenableBuilder(
                      listenable: _scrollTop,
                      builder: (context, child) => Container(
                        width: widget.floatWidth,
                        margin: EdgeInsets.only(top: max(180 - _scrollTop.value, 70), left: 20),
                        child: child,
                      ),
                      child: Material(
                        color: Theme.of(context).colorScheme.surface,
                        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                        shape: Theme.of(context).cardTheme.shape,
                        elevation: 6,
                        clipBehavior: Clip.antiAlias,
                        child: widget.floatImageBuilder(context),
                      ),
                    ),
                  ),
                );
        }),
      ],
    );
  }

  _updateScrollOffset() {
    if (_scrollTop.value != min(280, _controller.offset)) {
      _scrollTop.value = min(280, _controller.offset);
    }
  }
}

class _DetailTitleBackground extends StatelessWidget {
  final Widget child;
  final double scrollTop;
  final double floatWidth;
  final bool isMobile;

  const _DetailTitleBackground({
    required this.child,
    required this.scrollTop,
    required this.floatWidth,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha((0xCC * max(0, 280 - scrollTop) / 280).round()),
      padding: EdgeInsets.only(left: (isMobile ? 40 - 28 * max(0, 220 - scrollTop) / 220 : floatWidth + 16) + 12, right: 12),
      child: child,
    );
  }
}

class _DetailTitleLayout extends StatelessWidget {
  final Widget title;
  final Widget subTitle;
  final List<ActionEntry> actions;
  final bool isMobile;

  const _DetailTitleLayout({
    required this.title,
    required this.subTitle,
    required this.actions,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.titleMedium!,
                      child: title,
                    )),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: subTitle,
                ),
              ],
            ),
          ),
          _DetailActions(
            actions: actions,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }
}

class _DetailActions extends StatelessWidget {
  final List<ActionEntry> actions;
  final bool isMobile;

  const _DetailActions({required this.actions, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final List<Widget> iconButtons = [];
    late final List<PopupMenuEntry<void>> popupMenuItems = [];
    for (var entry in actions) {
      if (entry is ActionButton) {
        if (!entry.collapsed && (!entry.autoCollapse || !isMobile)) {
          assert(entry.icon is Icon);
          iconButtons.add(IconButton(autofocus: entry.autofocus, onPressed: entry.onPressed, icon: entry.icon!));
        } else {
          assert(!entry.collapsed || !entry.autoCollapse, 'collapsed 和 autoCollapse 不能同时为 true');
          popupMenuItems.add(PopupMenuItem(
            autofocus: kIsAndroidTV && popupMenuItems.isEmpty,
            onTap: entry.onPressed,
            enabled: entry.onPressed != null,
            title: entry.text!,
            leading: entry.icon!,
            trailing: entry.trailing,
          ));
        }
      } else {
        if (popupMenuItems.isNotEmpty && popupMenuItems.last is! PopupMenuDivider) popupMenuItems.add(const PopupMenuDivider());
      }
    }
    if (popupMenuItems.last is PopupMenuDivider) {
      popupMenuItems.removeLast();
    }

    return Row(children: [
      ...iconButtons,
      if (popupMenuItems.isNotEmpty) PopupMenuButton(itemBuilder: (BuildContext context) => popupMenuItems),
    ]);
  }
}

class _DetailFlexibleSpaceBarBackground<T extends MediaBase> extends StatelessWidget {
  final T item;
  final bool isMobile;

  const _DetailFlexibleSpaceBarBackground({super.key, required this.item, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Theme.of(context).colorScheme.primary),
        if (item.backdrop != null)
          Stack(
            fit: StackFit.expand,
            children: [
              AsyncImage(item.backdrop!, alignment: Alignment.topCenter),
              Container(color: Colors.black54),
            ],
          ),
        if (item.logo != null)
          Positioned(
              top: isMobile ? 50 : 20,
              right: isMobile ? 30 : 60,
              child: AsyncImage(
                item.logo!,
                needLoading: false,
                width: isMobile ? 100 : 200,
                height: isMobile ? 100 : 200,
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
              )),
        Container(color: Theme.of(context).colorScheme.surface.withAlpha(0x33)),
      ],
    );
  }
}
