import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../adaptive/adaptive.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key, required this.url, this.title});

  final String? title;
  final Uri url;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: darkTheme,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: title != null ? Text(title!) : null,
              forceMaterialTransparency: true,
              leading: const CloseButton(),
            ),
            extendBodyBehindAppBar: true,
            body: PhotoView(imageProvider: CachedNetworkImageProvider(url.toString())),
          );
        },
      ),
    );
  }
}
