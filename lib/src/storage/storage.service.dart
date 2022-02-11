import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../fireflutter.dart';
import 'package:image_picker/image_picker.dart';
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

  /// TODO: change on init.
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

    final filename = "${getRandomString()}.$extension";
    print('filename; $filename');
    final ref = uploadsFolder.child(filename);

    /// Upload Task
    UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(customMetadata: {
          'basename': basename,
          'uid': UserService.instance.uid,
        }));

    /// Progress listener
    StreamSubscription? _sub;
    if (onProgress != null) {
      _sub = uploadTask.snapshotEvents.listen((event) {
        double progress = event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
        onProgress(progress);
      });
    }

    /// Wait for upload to finish.
    await uploadTask.whenComplete(() => _sub?.cancel());
    return ref.getDownloadURL();
  }

  /// Returns true if the file exists on storage. Or false.
  Future<bool> exists(String url) async {
    if (url.startsWith('http')) {
      try {
        await ref(url).getDownloadURL();
        return true;
      } catch (e) {
        // debugPrint('getDownloadUrl(); $e');
        return false;
      }
    } else {
      return false;
    }
  }

  /// Delete orignal and thumbnail files from storage.
  ///
  /// [url] must be the original image url.
  /// If [url] does exist on storage, then it will not delete.
  ///
  /// Ignore object-not-found exception.
  Future<void> delete(String url) async {
    final String thumbnailUrl = getThumbnailUrl(url);
    try {
      final re = await exists(url);
      if (re == false) return;
      await Future.wait(
        [
          if (url.startsWith('http')) ref(url).delete(),
          if (thumbnailUrl.startsWith('http')) ref(thumbnailUrl).delete(),
        ],
      );
    } on FirebaseException catch (e) {
      debugPrint('Exception happened on file delete; $e');
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
    String localFile = await getAbsoluteTemporaryFilePath(basename);
    File? file = await FlutterImageCompress.compressAndGetFile(
      filepath, // source file
      localFile, // target file. Overwrite the source with compressed.
      quality: quality,
    );

    return file;
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
