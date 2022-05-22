import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  Future<void> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);
    // file.rename('gambar');
    File newFile = await changeFileNameOnly(file, 'gamber');
    try {
      await storage.ref('tes/$fileName').putFile(newFile);
    } on firebase_core.FirebaseException catch (e) {
      print(e.message);
    }
  }

  Future<File> changeFileNameOnly(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    print('rename file  , ${file}{');
    return file.rename(newPath);
  }

  Future<firebase_storage.ListResult> listFiles() async {
    firebase_storage.ListResult results = await storage.ref('tes').listAll();
    results.items.forEach((firebase_storage.Reference ref) {
      print('found file : ${ref.name}');
    });
    return results;
  }

  Future<String> downloadURL(String fileName) async {
    String downloadURL = await storage.ref('tes/$fileName').getDownloadURL();

    return downloadURL;
  }
}
