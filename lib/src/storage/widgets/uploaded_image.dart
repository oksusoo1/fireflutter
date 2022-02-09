import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UploadedImage
///
/// [url] is always the original image. Not thumbnail image.
///
/// When [useThumbnail] is set to true, it will look for thumbnail image, first.
///   - and when thumbnail image does not exist, then it will show original image
///     and if original image does not exists, then it will display error widget.
/// When [useThumbnail] is set to false, it will display original image.
///   - and if original image does not exists then it will display error widget.
class UploadedImage extends StatelessWidget {
  UploadedImage(
      {Key? key,
      required this.url,
      this.useThumbnail = true,
      this.errorWidget = const Icon(Icons.error)})
      : super(key: key);

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
        /// if it is original image and there is an error, then display error widget.
        if (useThumbnail == false) {
          return errorWidget;
        } else {
          /// If it failed on displaying thumbnail image, then try to display
          /// original image.
          return UploadedImage(
            url: url,
            useThumbnail: false,
            errorWidget: errorWidget,
          );
        }
      },
    );
  }
}
