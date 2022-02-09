import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UploadedImage extends StatelessWidget {
  UploadedImage({
    Key? key,
    required this.url,
    this.useThumbnail = true,
    this.errorWidget = const Icon(Icons.error),
  }) : super(key: key);

  final String url;
  final bool useThumbnail;
  final Widget errorWidget;

  @override
  Widget build(BuildContext context) {
    final _finalUrl = useThumbnail ? StorageService.instance.getThumbnailUrl(url) : url;
    print('_finalUrl; $_finalUrl');

    return CachedNetworkImage(
      imageUrl: _finalUrl,
      placeholder: (context, _recursiveUrl) => CircularProgressIndicator(),
      errorWidget: (context, _recursiveUrl, error) {
        return UploadedImage(
          url: url,
          useThumbnail: false,
          errorWidget: errorWidget,
        );
      },
    );
  }
}
