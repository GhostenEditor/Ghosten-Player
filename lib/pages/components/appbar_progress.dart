import 'package:api/api.dart';
import 'package:flutter/material.dart';

class AppbarProgressIndicator extends StatelessWidget implements PreferredSizeWidget {
  const AppbarProgressIndicator({super.key, this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Api.progress$,
        builder: (context, snapshot) => switch (snapshot.data) {
              null => SizedBox(height: preferredSize.height),
              0 => const LinearProgressIndicator(backgroundColor: Colors.transparent),
              -1 => LinearProgressIndicator(color: Theme.of(context).colorScheme.error, value: 1),
              _ => TweenAnimationBuilder(
                  tween: Tween(end: snapshot.data),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  builder: (BuildContext context, double value, Widget? child) => LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.transparent,
                  ),
                )
            });
  }

  @override
  Size get preferredSize => const Size.fromHeight(4);
}
