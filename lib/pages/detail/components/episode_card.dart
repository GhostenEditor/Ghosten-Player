import 'package:flutter/material.dart';

import '../../../components/image_card.dart';

class EpisodeCard extends StatelessWidget {
  final GestureTapCallback? onTap;
  final String? image;
  final String? text;
  final String? subText;
  final bool isMobile;
  final bool autofocus;

  const EpisodeCard({
    super.key,
    this.onTap,
    this.image,
    this.text,
    this.subText,
    this.isMobile = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return ImageCard(
      scale: 1.05,
      autofocus: autofocus,
      image: image,
      onTap: onTap,
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (text != null) Text(text!, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
          if (subText != null) Text(subText!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
