/*..............................................................................
 . Copyright (c)
 .
 . The download_service.dart class was created by : Alex Bolot and Pierre Bolot
 .
 . As part of the PhotoStore project
 .
 . Last modified : 1/27/21 3:48 PM
 .
 . Contact : contact.alexandre.bolot@gmail.com
 .............................................................................*/

import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:photo_store/model/firebase_album.dart';
import 'package:photo_store/model/save_path.dart';
import 'package:photo_store/services/account_service.dart';
import 'package:photo_store/services/firebase/firebase_file_service.dart';
import 'package:photo_store/services/logging_service.dart';

class DownloadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final HttpClient _httpClient = HttpClient();

  static Future<List<FirebaseAlbum>> downloadAlbums() async {
    ListResult list = await _getStorageRef().listAll();

    logInfo('Loaded albums from Firebase :: ${list.names.join(' - ')}');

    return list.prefixes.map((ref) => FirebaseAlbum(ref)).toList();
  }

  static Future<File> downloadFile(String url, SavePath savePath) async {
    HttpClientRequest request = await _httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    logDebug('downloaded file ${savePath.formatted}');

    return FirebaseFileService.saveFile(bytes, savePath);
  }

  // ------------------ Private methods ------------------ //

  /// Return a Storage reference (folder) based on the active user and the given directory path
  ///
  static Reference _getStorageRef() {
    return _storage.ref(AccountService.currentAccount.name);
  }
}

extension Folders on ListResult {
  forEach(Function(Reference folder) function) => this.prefixes.forEach(function);

  List<String> get names => this.prefixes.map((ref) => ref.name).toList();
}
