import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

class ImageListEdit extends StatefulWidget {
  const ImageListEdit({
    required this.files,
    required this.onError,
    Key? key,
  }) : super(key: key);

  final List<String> files;
  final Function(dynamic) onError;

  @override
  State<ImageListEdit> createState() => _ImageListEditState();
}

class _ImageListEditState extends State<ImageListEdit> {
  @override
  Widget build(BuildContext context) {
    if (widget.files.length == 0) return SizedBox.shrink();

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      children: [
        for (String fileUrl in widget.files)
          Stack(
            children: [
              Container(width: double.infinity, child: UploadedImage(url: fileUrl)),
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
    );
  }
}
