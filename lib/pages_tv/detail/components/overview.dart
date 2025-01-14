import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/async_image.dart';
import '../../../components/gap.dart';
import '../../../utils/utils.dart';
import '../../utils/utils.dart';

class OverviewSection<T extends MediaBase> extends StatefulWidget {
  final T item;
  final Widget? description;
  final GlobalKey<NavigatorState> navigatorKey;
  final GestureTapCallback? onTap;

  const OverviewSection({
    super.key,
    required this.item,
    this.description,
    required this.navigatorKey,
    this.onTap,
  });

  @override
  State<OverviewSection<T>> createState() => _OverviewSectionState<T>();
}

class _OverviewSectionState<T extends MediaBase> extends State<OverviewSection<T>> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: focused ? BorderSide(width: 4, color: Theme.of(context).colorScheme.inverseSurface, strokeAlign: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => showFull(context),
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        onFocusChange: (f) {
          if (focused != f) {
            setState(() => focused = f);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            widget.item.overview ?? AppLocalizations.of(context)!.noOverview,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  showFull(BuildContext context) {
    Navigator.pushAndRemoveUntil(widget.navigatorKey.currentContext!, FadeInPageRoute(builder: (context) {
      return Align(
        alignment: Alignment.topRight,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Overview(
            item: widget.item,
            description: widget.description,
          ),
        ),
      );
    }), (_) => false);
    if (widget.onTap != null) widget.onTap!();
  }
}

class Overview<T extends MediaBase> extends StatefulWidget {
  final T item;
  final Widget? description;

  const Overview({super.key, required this.item, this.description});

  @override
  State<Overview<T>> createState() => _OverviewState<T>();
}

class _OverviewState<T extends MediaBase> extends State<Overview<T>> {
  final _scrollController = ScrollController();
  bool focused = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onFocusChange: (f) {
        if (focused != f) {
          setState(() {
            focused = f;
          });
        }
      },
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
              _scrollController.animateTo(
                max(_scrollController.offset - 200, 0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowDown:
              _scrollController.animateTo(
                _scrollController.offset + 200,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: focused,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(32),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.item.poster != null) AsyncImage(widget.item.poster!, width: 140, radius: const BorderRadius.all(Radius.circular(8))),
                if (widget.item.poster != null) Gap.hLG,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.item.title != null)
                        Text(widget.item.title!, style: Theme.of(context).textTheme.titleLarge!.copyWith(height: 2, fontWeight: FontWeight.bold)),
                      if (widget.item.airDate != null)
                        Text(widget.item.airDate!.format(), style: Theme.of(context).textTheme.labelSmall!.copyWith(height: 2, fontWeight: FontWeight.bold)),
                      if (widget.description != null) widget.description!,
                    ],
                  ),
                ),
              ],
            ),
            Gap.vLG,
            const Divider(),
            Gap.vLG,
            Text(
              widget.item.overview ?? AppLocalizations.of(context)!.noOverview,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SafeArea(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}
