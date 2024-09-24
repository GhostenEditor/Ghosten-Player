import 'package:api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/async_image.dart';
import '../../../components/focus_card.dart';
import '../../../components/gap.dart';
import '../../../components/image_card.dart';
import '../../../utils/utils.dart';

class MediaCard<T extends Media> extends StatefulWidget {
  final ValueChanged<bool>? onFocusChange;
  final T item;
  final GestureTapCallback? onTap;
  final bool? autofocus;

  const MediaCard({super.key, this.onFocusChange, required this.item, this.onTap, this.autofocus});

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  late final item = widget.item;
  late bool focused = widget.autofocus ?? false;

  @override
  Widget build(BuildContext context) {
    final child = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
            child: item.poster != null
                ? AsyncImage(item.poster!, ink: true)
                : Container(
                    color: Theme.of(context).colorScheme.primary.withAlpha(0x11),
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 42,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                  )),
        Container(
          decoration: kIsAndroidTV && focused
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green,
                      Colors.blueAccent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                )
              : null,
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.displayTitle(),
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  if (item.airDate != null)
                    Text(item.airDate!.year.toString(), style: Theme.of(context).textTheme.labelSmall)
                  else
                    Text(AppLocalizations.of(context)!.tagUnknown, style: Theme.of(context).textTheme.labelSmall),
                  const Spacer(),
                  if (item.favorite)
                    Icon(
                      Icons.favorite,
                      size: 12,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  if (item.watched) const SizedBox(width: 4),
                  if (item.watched) Icon(Icons.check, size: 12, color: Theme.of(context).colorScheme.primary),
                ],
              )
            ],
          ),
        )
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: FocusCard(
        scale: 1.1,
        autofocus: focused,
        onFocusChange: (flag) {
          setState(() => focused = flag);
          if (widget.onFocusChange != null) widget.onFocusChange!(focused);
        },
        onTap: widget.onTap,
        child: item.lastPlayedTime == null
            ? Banner(
                message: AppLocalizations.of(context)!.tagNew,
                location: BannerLocation.topEnd,
                color: item.themeColor == null ? Theme.of(context).colorScheme.primary : Color(item.themeColor!).withAlpha(255),
                child: child,
              )
            : child,
      ),
    );
  }
}

class RecentMediaCard<T extends Media> extends StatelessWidget {
  final T item;
  final GestureTapCallback? onTap;
  final double? width;
  final bool autofocus;

  const RecentMediaCard({super.key, required this.item, this.onTap, this.width, this.autofocus = false});

  @override
  Widget build(BuildContext context) {
    return ImageCard(
      key: ValueKey(item.id),
      width: width ?? 265,
      scale: 1.1,
      autofocus: autofocus,
      onTap: onTap,
      image: item.poster,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.displayRecentTitle(),
            style: Theme.of(context).textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(item.airDate?.format() ?? AppLocalizations.of(context)!.tagUnknown,
                    style: Theme.of(context).textTheme.labelSmall, overflow: TextOverflow.ellipsis),
              ),
              Gap.hMD,
              if (item.lastPlayedTime != null)
                Text(AppLocalizations.of(context)!.timeAgo(item.lastPlayedTime!.fromNow().fromNowFormat(context)),
                    style: Theme.of(context).textTheme.labelSmall)
            ],
          )
        ],
      ),
    );
  }
}
