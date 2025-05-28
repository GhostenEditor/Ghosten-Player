import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class PlayerAppbar extends AppBar {
  PlayerAppbar({super.key, super.title, super.actions, required this.show, this.padding});

  final ValueNotifier<bool> show;
  final EdgeInsetsGeometry? padding;

  @override
  State<PlayerAppbar> createState() => _PlayerAppbarState();

  @override
  Size get preferredSize =>
      padding == null
          ? super.preferredSize
          : (Size(super.preferredSize.width + padding!.horizontal, super.preferredSize.height + padding!.vertical));
}

class _PlayerAppbarState extends State<PlayerAppbar> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.show,
      builder: (context, _) {
        return PageTransitionSwitcher(
          reverse: widget.show.value,
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation, Animation<double> secondaryAnimation) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.vertical,
              fillColor: Colors.transparent,
              child: child,
            );
          },
          child:
              widget.show.value
                  ? Padding(
                    padding: widget.padding ?? EdgeInsets.zero,
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      title: widget.title,
                      actions: widget.actions,
                    ),
                  )
                  : const SizedBox(),
        );
      },
    );
  }
}
