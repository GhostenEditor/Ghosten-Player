import 'package:flutter/material.dart';

class FocusScopeManager {
  FocusScopeManager(int length) : _scopeList = List.generate(length, (_) => FocusScopeNode());

  final List<FocusScopeNode> _scopeList;
  int currentIndex = 0;

  FocusScopeNode scopeAt(int index) => _scopeList[index];

  bool handleDirectionKey(TraversalDirection direction, FocusNode node) {
    final moved = node.focusInDirection(direction);
    if (moved) {
      return false;
    }

    var curr = _scopeList.indexWhere((scope) => scope.hasFocus);
    if (curr == -1) {
      curr = currentIndex;
    }

    if (direction == TraversalDirection.up || direction == TraversalDirection.left) {
      currentIndex = (curr - 1 + _scopeList.length) % _scopeList.length;
    } else if (direction == TraversalDirection.down || direction == TraversalDirection.right) {
      currentIndex = (curr + 1 + _scopeList.length) % _scopeList.length;
    }
    _scopeList[currentIndex].requestFocus();
    return true;
  }

  FocusScopeNode resetItem(int index) {
    final oldNode = _scopeList[index];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldNode.dispose();
    });

    _scopeList[index] = FocusScopeNode();
    return _scopeList[index];
  }

  void dispose() {
    for (final scope in _scopeList) {
      scope.dispose();
    }
  }
}
