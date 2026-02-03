import 'package:flutter/material.dart';

class FocusScopeManager {
  FocusScopeManager(int length) : scopeList = List.generate(length, (_) => FocusScopeNode());

  final List<FocusScopeNode> scopeList;
  int currentIndex = 0;

  bool handleDirectionKey(TraversalDirection direction, FocusNode node) {
    final moved = node.focusInDirection(direction);
    if (moved) {
      return false;
    }

    final curr = scopeList.indexWhere((scope) => scope.hasFocus);

    if (direction == TraversalDirection.up || direction == TraversalDirection.left) {
      currentIndex = (curr - 1 + scopeList.length) % scopeList.length;
    } else if (direction == TraversalDirection.down || direction == TraversalDirection.right) {
      currentIndex = (curr + 1 + scopeList.length) % scopeList.length;
    }
    scopeList[currentIndex].requestFocus();
    return true;
  }

  void resetItem(int index) {
    scopeList[index].dispose();
    scopeList[index] = FocusScopeNode();
  }

  void dispose() {
    for (final scope in scopeList) {
      scope.dispose();
    }
  }
}
