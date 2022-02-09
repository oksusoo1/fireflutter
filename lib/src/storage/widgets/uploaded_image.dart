import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

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
  UploadedImage({
    Key? key,
    required this.url,
    this.useThumbnail = true,
    this.errorWidget = const Icon(Icons.error),
    this.height,
    this.width,
    this.onTap,
  }) : super(key: key);

  final String url;
  final bool useThumbnail;
  final Widget errorWidget;
  final Function()? onTap;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final _finalUrl = useThumbnail ? StorageService.instance.getThumbnailUrl(url) : url;
    // print('_finalUrl; $_finalUrl');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        height: height,
        width: width,
        imageUrl: _finalUrl,
        placeholder: (context, _recursiveUrl) => Center(child: CircularProgressIndicator()),
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
      ),
    );
  }
}
