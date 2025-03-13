import 'package:flutter/material.dart';

import '../const.dart';

class Logo extends StatelessWidget {
  const Logo({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(assetsLogo, width: size, height: size);
  }
}
