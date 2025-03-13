import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key, required this.url, this.title});

  final String? title;
  final Uri url;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: title != null ? Text(title!, style: Theme.of(context).textTheme.titleMedium) : null,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
          ),
          extendBodyBehindAppBar: true,
          body: PhotoView(
            imageProvider: CachedNetworkImageProvider(url.toString()),
          ),
        );
      }),
    );
  }
}
