import 'package:flutter/material.dart';

import '../const.dart';

class Logo extends StatelessWidget {
  final double? size;

  const Logo({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(assetsLogo, width: size, height: size);
  }
}
