import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../previews/previews.dart';

class Loading extends StatefulWidget {
  const Loading({super.key, this.color});

  final Color? color;

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late final AnimationController _loadingController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCircle(controller: _loadingController, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

@AppPreview(group: 'Loading (Mobile)', size: Size.square(100))
Widget loadingPreview() {
  return const Loading();
}
