import 'package:flutter/material.dart';

class HeaderedContent extends StatelessWidget {
  const HeaderedContent({
    super.key,
    required this.header,
    required this.child,
    this.headerPadding = const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
    this.onTap,
  });

  final Widget header;
  final EdgeInsetsGeometry headerPadding;
  final Widget child;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: headerPadding,
          child: onTap != null
              ? Row(
                  children: [
                    DefaultTextStyle(style: Theme.of(context).textTheme.titleMedium!, child: header),
                    IconButton(
                      onPressed: onTap,
                      icon: const Icon(Icons.chevron_right_rounded),
                      visualDensity: .compact,
                      style: const ButtonStyle(minimumSize: WidgetStatePropertyAll(Size.zero)),
                      padding: .zero,
                    ),
                  ],
                )
              : DefaultTextStyle(style: Theme.of(context).textTheme.titleMedium!, child: header),
        ),
        child,
      ],
    );
  }
}

class SliverHeaderedContent extends StatelessWidget {
  const SliverHeaderedContent({super.key, this.header, required this.sliver, this.onTap, this.headerPadding});

  final Widget? header;
  final EdgeInsetsGeometry? headerPadding;
  final Widget sliver;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (header == null) {
      return sliver;
    }
    final title = DefaultTextStyle(style: Theme.of(context).textTheme.titleMedium!, child: header!);
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: headerPadding ?? .zero,
          sliver: SliverToBoxAdapter(
            child: onTap != null
                ? Row(
                    spacing: 4,
                    children: [
                      title,
                      IconButton(
                        onPressed: onTap,
                        icon: const Icon(Icons.chevron_right_rounded),
                        visualDensity: const VisualDensity(vertical: VisualDensity.minimumDensity),
                        style: const ButtonStyle(
                          minimumSize: WidgetStatePropertyAll(Size.square(24)),
                          tapTargetSize: .shrinkWrap,
                        ),
                        padding: .zero,
                      ),
                    ],
                  )
                : title,
          ),
        ),
        sliver,
      ],
    );
  }
}
