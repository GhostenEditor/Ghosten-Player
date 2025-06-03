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
      child: SpinKitFadingCircle(
        color:
            widget.color ??
            switch (Theme.of(context).brightness) {
              Brightness.dark => Colors.white,
              Brightness.light => Colors.black,
            },
        controller: _loadingController,
      ),
    );
  }
}
