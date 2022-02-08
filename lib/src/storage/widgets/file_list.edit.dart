import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

class FileListEdit extends StatefulWidget {
  const FileListEdit({required this.files, required this.onError, Key? key}) : super(key: key);

  final List<String> files;
  final Function(dynamic) onError;

  @override
  State<FileListEdit> createState() => _FileListEditState();
}

class _FileListEditState extends State<FileListEdit> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (String fileUrl in widget.files)
          Stack(
            children: [
              Image.network(fileUrl, height: 100, width: 100, fit: BoxFit.cover),
              Positioned(
                top: 10,
                left: 10,
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
          )
      ],
    );
  }
}
