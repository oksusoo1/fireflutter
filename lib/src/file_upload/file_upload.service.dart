import 'dart:io';
import 'dart:math';

import '../../fireflutter.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:firebase_storage/firebase_storage.dart';

class FileUploadService {
  static FileUploadService? _instance;
  static FileUploadService get instance {
    _instance ??= FileUploadService();
    return _instance!;
  }

  final firebaseStorage = FirebaseStorage.instance;

  Future<String> pickUpload({
    required ImageSource source,
    int quality = 90,
    Function(double)? onProgress,
  }) async {
    // print('pickUpload;');

    /// Pick image
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    /// No image picked. Throw error.
    if (pickedFile == null) throw ERROR_IMAGE_NOT_SELECTED;

    /// Compress image. Fix Exif data.
    File file = await _imageCompressor(pickedFile.path, quality);

    /// Reference
    final String fileName = file.path.split('/').last;
    Reference ref = firebaseStorage.ref("uploads/$fileName");

    UploadTask uploadTask = ref.putFile(file);

    /// Progress listener
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((event) {
        double progress = event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
        onProgress(progress);
      });
    }

    /// Wait for upload to finish.
    await uploadTask;

    /// Return uploaded file Url.
    return ref.getDownloadURL();
  }

  /// 파일을 압축하고, 가로/세로를 맞춘다.
  _imageCompressor(String filepath, int quality) async {
    /// This method will be called when image was taken by [Api.takeUploadFile].
    /// It can compress the image and then return it as a File object.

    String localFile = await _getAbsoluteTemporaryFilePath(_getRandomString() + '.jpeg');
    File? file = await FlutterImageCompress.compressAndGetFile(
      filepath, // source file
      localFile, // target file. Overwrite the source with compressed.
      quality: quality,
    );

    return file;
  }

  Future<String> _getAbsoluteTemporaryFilePath(String relativePath) async {
    var directory = await getTemporaryDirectory();
    return p.join(directory.path, relativePath);
  }

  String _getRandomString({int len = 16, String? prefix}) {
    const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
    var t = '';
    for (var i = 0; i < len; i++) {
      t += charset[(Random().nextInt(charset.length))];
    }
    if (prefix != null && prefix.isNotEmpty) t = prefix + t;
    return t;
  }

  Future<void> delete(String url) async {
    return firebaseStorage.refFromURL(url).delete();
  }
}
