import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

class ImageListEdit extends StatefulWidget {
  const ImageListEdit({
    required this.files,
    required this.onError,
    this.imageSize = 100,
    Key? key,
  }) : super(key: key);

  final List<String> files;
  final Function(dynamic) onError;
  final double imageSize;

  @override
  State<ImageListEdit> createState() => _ImageListEditState();
}

class _ImageListEditState extends State<ImageListEdit> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Wrap(
        spacing: 4.0,
        children: [
          for (String fileUrl in widget.files)
            Stack(
              children: [
                UploadedImage(
                  url: fileUrl,
                  height: widget.imageSize,
                  width: widget.imageSize,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                    onTap: () async {
                      bool? re = await showDialog<bool?>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Delete file?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context), child: Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Yes'),
                            ),
                          ],
                        ),
                      );
                      if (re == null) return;
                      try {
                        await StorageService.instance.delete(fileUrl);
                        widget.files.remove(fileUrl);
                        print('file deleted $fileUrl');
                        if (mounted) setState(() {});
                      } catch (e) {
                        widget.onError(e);
                      }
                    },
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }
}
