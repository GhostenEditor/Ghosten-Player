import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({super.key, required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // TODO(GhostenEditor): 性能问题
          // RepaintBoundary(
          //   child: ShaderMask(
          //     blendMode: .colorBurn,
          //     shaderCallback: (Rect bounds) => RadialGradient(
          //       colors: switch (Theme.of(context).brightness) {
          //         Brightness.dark => [Colors.black38, Colors.black],
          //         Brightness.light => [Colors.white60, Colors.white],
          //       },
          //       stops: const [0.2, 1],
          //       radius: 1,
          //     ).createShader(bounds),
          //     child: DecoratedBox(
          //       decoration: BoxDecoration(
          //         image: DecorationImage(
          //           image: AssetImage(
          //             'assets/tv/images/${switch (Theme.of(context).brightness) {
          //               Brightness.dark => 'bg-stripe.png',
          //               Brightness.light => 'bg-stripe-light.png',
          //             }}',
          //           ),
          //           repeat: ImageRepeat.repeat,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/${switch (Theme.of(context).brightness) {
                    Brightness.dark => 'bg-stripe.png',
                    Brightness.light => 'bg-stripe-light.png',
                  }}',
                ),
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: switch (Theme.of(context).brightness) {
                  Brightness.dark => [Colors.black38, Colors.black],
                  Brightness.light => [Colors.white60, Colors.white],
                },
                stops: const [0.2, 1],
                radius: 1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 32,
              children: [
                Text(title, style: Theme.of(context).textTheme.displaySmall!.copyWith(height: 2)),
                if (description?.isNotEmpty ?? false)
                  Text(
                    description!,
                    style: Theme.of(context).textTheme.titleLarge!
                        .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                        foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
                        minimumSize: .zero,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                      ),
                      child: Text(AppLocalizations.of(context)!.buttonConfirm),
                    ),
                    TextButton(
                      autofocus: true,
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        minimumSize: .zero,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(AppLocalizations.of(context)!.buttonCancel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
