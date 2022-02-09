import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';
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

  final storage = FirebaseStorage.instance;
  Reference get uploadsFolder => storage.ref().child(_uploadsPath);
  Reference ref(String url) {
    return storage.refFromURL(url);
  }

  Future<String> pickUpload({
    required ImageSource source,
    int quality = 90,
    Function(double)? onProgress,
  }) async {
    if (UserService.instance.notSignIn) throw ERROR_SIGN_IN;

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
    final String extension = basename.split('.').last;

    final dt = DateFormat('yMMddHHmmss').format(DateTime.now());
    final uid = UserService.instance.uid!;
    final randomString = _getRandomString();
    final filename = "$uid-$dt-$randomString.$extension";
    print('filename; $filename');
    final ref = uploadsFolder.child(filename);

    /// Upload Task
    UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(customMetadata: {
          'basename': basename,
          'uid': uid,
        }));
    StreamSubscription sub;

    /// Progress listener
    StreamSubscription? _sub;
    if (onProgress != null) {
      /// TODO: memory leak here. when it is 100, cancel the listener.
      _sub = uploadTask.snapshotEvents.listen((event) {
        double progress = event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
        onProgress(progress);
        print('progress; $progress');
      });

      print('_sub ==> ${_sub.toString()}');
    }

    /// Wait for upload to finish.
    await uploadTask.whenComplete(() => _sub?.cancel());
    print('_sub ==> ${_sub.toString()}');

    return ref.getDownloadURL();
  }

  /// Delete orignal and thumbnail files from storage.
  ///
  /// [url] must be the original image url.
  ///
  /// Ignore object-not-found exception.
  Future<void> delete(String url) async {
    try {
      await Future.wait(
        [
          storage.refFromURL(url).delete(),
          storage.refFromURL(getThumbnailUrl(url)).delete(),
        ],
      );
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        debugPrint('object-not-found exception happened with: $url');
      } else {
        rethrow;
      }
    }
  }

  ///
  /// HELPER FUNCTIONS
  ///

  /// 파일을 압축하고, 가로/세로를 맞춘다.
  _imageCompressor(String filepath, int quality) async {
    /// This method will be called when image was taken by [Api.takeUploadFile].
    /// It can compress the image and then return it as a File object.

    final String basename = filepath.split('/').last;
    String localFile =
        await _getAbsoluteTemporaryFilePath('$basename-' + _getRandomString() + '.jpeg');
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

  /// Get thumbnail url.
  ///
  /// [url] is the original url.
  /// Refer readme for details.
  getThumbnailUrl(String url) {
    String _tempUrl = url;
    if (_tempUrl.indexOf('?') > 0) {
      _tempUrl = _tempUrl.split('?').first;
    }
    final String basename = _tempUrl.split('/').last;
    final String filename = basename.split('.').first;
    return _tempUrl.replaceFirst(basename, '${filename}_200x200.webp') + '?alt=media';
  }
}
