import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';


mixin NeedUpdateMixin<S extends StatefulWidget> on State<S> {
  StreamSubscription<double?>? _subscription;

  @override
  void initState() {
    _subscription = Api.needUpdate$.listen((event) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
