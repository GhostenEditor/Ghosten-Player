import 'package:flutter/material.dart';

class PlayerScaffold extends StatelessWidget {
  const PlayerScaffold({super.key, required this.playerControls, required this.sidebar, required this.child});

  final Widget playerControls;
  final Widget sidebar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          Flexible(flex: 3, fit: FlexFit.tight, child: Column(children: [playerControls, Expanded(child: child)])),
          Builder(
            builder:
                (context) =>
                    MediaQuery.of(context).size.aspectRatio > 1 ? Flexible(flex: 2, child: sidebar) : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
