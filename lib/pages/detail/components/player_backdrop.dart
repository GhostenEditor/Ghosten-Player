import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../components/async_image.dart';
import '../../components/mobile_builder.dart';

class PlayerBackdrop<T extends MediaBase> extends StatelessWidget {
  const PlayerBackdrop({super.key, this.logo, this.backdrop});

  final String? logo;
  final String? backdrop;

  @override
  Widget build(BuildContext context) {
    return MobileBuilder(
      builder: (context, isMobile, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Theme.of(context).colorScheme.primary),
            if (backdrop != null)
              Stack(
                fit: StackFit.expand,
                children: [
                  AsyncImage(backdrop!, alignment: Alignment.topCenter, showErrorWidget: false),
                  Container(color: Colors.black54),
                ],
              ),
            if (logo != null)
              Positioned(
                top: isMobile ? 50 : 20,
                right: isMobile ? 30 : 60,
                child: AsyncImage(
                  logo!,
                  needLoading: false,
                  width: isMobile ? 100 : 200,
                  height: isMobile ? 100 : 200,
                  fit: BoxFit.contain,
                  alignment: Alignment.topRight,
                  showErrorWidget: false,
                ),
              ),
            Container(color: Theme.of(context).colorScheme.surface.withAlpha(0x33)),
          ],
        );
      },
    );
  }
}
