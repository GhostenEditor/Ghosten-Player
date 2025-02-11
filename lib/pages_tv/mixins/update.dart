import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

final updateController = StreamController();
final updateStream = updateController.stream.asBroadcastStream();
mixin NeedUpdateMixin<S extends StatefulWidget> on State<S> {
  StreamSubscription<dynamic>? _subscription;

  @override
  void initState() {
    _subscription = MergeStream([Api.needUpdate$, updateStream]).listen((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
