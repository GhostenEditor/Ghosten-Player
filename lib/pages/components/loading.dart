import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  const Loading({super.key, this.color});

  final Color? color;

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late final AnimationController _loadingController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitThreeBounce(
        size: 24,
        controller: _loadingController,
        itemBuilder:
            (context, index) => DecoratedBox(
              decoration: BoxDecoration(
                color: switch (index) {
                  0 => Theme.of(context).colorScheme.primary,
                  1 => Theme.of(context).colorScheme.primaryFixedDim,
                  _ => Theme.of(context).colorScheme.primaryFixed,
                },
                shape: BoxShape.circle,
              ),
            ),
      ),
    );
  }
}
