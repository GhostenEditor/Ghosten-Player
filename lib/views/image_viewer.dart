import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  final String? title;
  final Uri url;

  const ImageViewer({super.key, required this.url, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? AppLocalizations.of(context)!.tagUnknown),
      ),
      body: PhotoView(
        imageProvider: CachedNetworkImageProvider(url.toString()),
      ),
    );
  }
}
