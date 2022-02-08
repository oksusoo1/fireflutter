import 'dart:io';
import 'dart:math';

import 'package:intl/intl.dart';

import '../../fireflutter.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage Service
///
/// Refer readme file for details.
class StorageService {
  static StorageService? _instance;
  static StorageService get instance {
    _instance ??= StorageService();
    return _instance!;
  }

  /// todo change on init.
  final String _uploadsPath = 'uploads';
  // final String _thumbnailSize = '200';
  // final String _thumbnailType = 'webp';

  final firebaseStorage = FirebaseStorage.instance;
  Reference get uploadsFolder => firebaseStorage.ref().child(_uploadsPath);

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

    /// Get generated filename.
    final String basename = file.path.split('/').last;
    // final String filename = basename.split('.').first;

    final dt = DateFormat('yMMddHHmmss').format(DateTime.now());
    final ref = uploadsFolder.child("$dt$basename");

    /// Upload Task
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

    return ref.getDownloadURL();

    /// Return uploaded file thumbnail Url.
    // return generatedThumbnailUrl(filename, 10);
  }

  /// Returns url of generated thumbnail.
  ///
  /// It will retry until the thumbnail is generated on storage.
  ///
  /// https://stackoverflow.com/a/58978012
  // Future<String> generatedThumbnailUrl(String filename, [int retry = 5]) async {
  //   final ref = uploadsFolder.child(filename + "_200x200.webp");

  //   /// Retries
  //   if (retry == 0) {
  //     return Future.error(ERROR_IMAGE_NOT_FOUND);
  //   }

  //   try {
  //     await Future.delayed(Duration(seconds: 2));
  //     return ref.getDownloadURL();
  //   } on FirebaseException catch (e) {
  //     if (e.code == 'object-not-found' && retry != 0) {
  //       return generatedThumbnailUrl(filename, retry - 1);
  //     } else {
  //       rethrow;
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  /// Delete files from storage.
  ///
  /// Todo delete original and thumbnail image on storage.
  Future<void> delete(String url) async {
    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } on FirebaseException catch (e) {
      print('firebase storage error ====> $e');
      if (e.code != 'object-not-found') rethrow;
    } catch (e) {
      rethrow;
    }
  }

  ///
  /// HELPER FUNCTIONS
  ///

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
}
