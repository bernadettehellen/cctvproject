import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<void> uploadFile(
    String uid,
    String filePath,
    String fileName,
  ) async {
    File file = File(filePath);
    try {
      await storage
          .ref('$uid/$fileName')
          .putFile(file)
          .then((p0) => print('$uid/$fileName'));
    } on firebase_storage.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<firebase_storage.ListResult> listFiles(String uid) async {
    firebase_storage.ListResult result = await storage.ref(uid).listAll();
    for (var ref in result.items) {
      ref.getDownloadURL();
    }
    return result;
  }

  Future<String> toUrl(String uid, String imageName) async {
    String url = await storage.ref('$uid/$imageName').getDownloadURL();
    return url;
  }

  Future<bool> checkIfNameAvailable(String uid, String imageName) async {
    try {
      await storage.ref('$uid/$imageName').getDownloadURL();
    } on firebase_storage.FirebaseException catch (e) {
      if (e.code == "object-not-found") {
        debugPrint("code : ${e.code}");
        return true;
      }
    }
    return false;
  }

  Future<firebase_storage.ListResult> delete(
      String uid, String imageName) async {
    await storage.ref('$uid/$imageName').delete();
    final Future<firebase_storage.ListResult> newList = listFiles(uid);
    return newList;
  }

  Future<void> download(String uid, String path) async {
    listFiles(uid).then(
        (value) => value.items.forEach((firebase_storage.Reference element) {
              final imageName = element.name;
              final targetDir = "$path/$imageName.jpg";
              final ref = storage.ref().child("$uid/$imageName");
              File(targetDir).create(recursive: true).then((File file) {
                final downloadTask = ref.writeToFile(file);
                downloadTask.snapshotEvents.listen((event) {
                  switch (event.state) {
                    case firebase_storage.TaskState.running:
                      print("running");
                      break;
                    case firebase_storage.TaskState.paused:
                      print("paused");
                      break;
                    case firebase_storage.TaskState.success:
                      print("success");
                      break;
                    case firebase_storage.TaskState.canceled:
                      print("canceled");
                      break;
                    case firebase_storage.TaskState.error:
                      print("error");
                      break;
                  }
                });
              });
            }));
  }
}
