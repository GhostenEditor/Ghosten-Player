import 'package:flutter/material.dart';

const double _defaultGapSizeSm = 8;
const double _defaultGapSizeMd = 12;
const double _defaultGapSizeLg = 16;

class Gap extends StatelessWidget {
  const Gap({super.key, this.width, this.height});

  const Gap.vertical({super.key, double size = _defaultGapSizeMd}) : width = null, height = size;

  const Gap.horizontal({super.key, double size = _defaultGapSizeMd}) : width = size, height = null;
  final double? width;
  final double? height;

  static const vLG = Gap.vertical(size: _defaultGapSizeLg);
  static const vMD = Gap.vertical();
  static const vSM = Gap.vertical(size: _defaultGapSizeSm);
  static const hLG = Gap.horizontal(size: _defaultGapSizeLg);
  static const hMD = Gap.horizontal();
  static const hSM = Gap.horizontal(size: _defaultGapSizeSm);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }
}
