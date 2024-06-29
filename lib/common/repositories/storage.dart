import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsup/common/providers.dart';

final storageRepositoryProvider = Provider((ref) {
  return StorageRepository(storage: ref.read(storageProvider));
});

class StorageRepository {
  final FirebaseStorage _storage;

  const StorageRepository({
    required FirebaseStorage storage,
  }) : _storage = storage;

  Future<String> uploadFile({
    required String path,
    required File file,
  }) async {
    try {
      // Check if the file exists
      if (!file.existsSync()) {
        throw Exception('File does not exist');
      }

      // Log the file path and file information
      print('Uploading file: ${file.path}');

      // Attempt to upload the file
      final snapshot = await _storage.ref().child(path).putFile(file);
      print('Uploading filesnapshot: ${snapshot.state.toString()}');
      final url = await snapshot.ref.getDownloadURL();

      // Log the URL
      print('File uploaded successfully. URL: $url');

      return url;
    } catch (e, t) {
      // Log the error
      print('Error uploading file: $e $t');
      throw ('error$e');
    }
  }
}
