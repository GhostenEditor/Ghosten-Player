import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../components/future_builder_handler.dart';

mixin ChannelMixin {
  Widget buildChannel<T extends Media>(
    BuildContext context, {
    required String label,
    required Future<List<T>> future,
    required double height,
    required Widget Function(BuildContext, T) builder,
  }) {
    return FutureBuilderSliverHandler(
        future: future,
        builder: (context, snapshot) => SliverToBoxAdapter(
              child: snapshot.requireData.isNotEmpty
                  ? Actions(
                      actions: {
                        DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(onInvoke: (indent) {
                          final currentNode = FocusManager.instance.primaryFocus;
                          if (currentNode != null) {
                            final nearestScope = currentNode.nearestScope!;
                            final focusedChild = nearestScope.focusedChild;
                            switch (indent.direction) {
                              case TraversalDirection.up:
                              case TraversalDirection.down:
                                if (focusedChild == null || !focusedChild.focusInDirection(indent.direction)) {
                                  FocusTraversalGroup.of(context).inDirection(nearestScope.parent!, indent.direction);
                                }
                              case TraversalDirection.right:
                              case TraversalDirection.left:
                                focusedChild?.focusInDirection(indent.direction);
                            }
                          }
                          return null;
                        }),
                      },
                      child: FocusScope(
                        onFocusChange: (f) {
                          if (f) {
                            FocusManager.instance.primaryFocus?.nearestScope?.children.first.requestFocus();
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 48, right: 48, top: 12),
                              child: Text(label),
                            ),
                            SizedBox(
                              height: height,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                                itemCount: snapshot.requireData.length,
                                itemBuilder: (context, index) => builder(context, snapshot.requireData[index]),
                                separatorBuilder: (context, _) => const SizedBox(width: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            ));
  }

  Widget buildGridChannel<T extends Media>(
    BuildContext context, {
    required String label,
    required Future<List<T>> future,
    required Widget Function(BuildContext, T) builder,
  }) {
    return FutureBuilderSliverHandler(
      future: future,
      builder: (context, snapshot) => SliverMainAxisGroup(
        slivers: snapshot.requireData.isNotEmpty
            ? [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 48, right: 48, top: 12),
                    child: Text(label),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  sliver: SliverGrid.builder(
                    itemCount: snapshot.requireData.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      childAspectRatio: 0.5,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) => builder(context, snapshot.requireData[index]),
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}
