import 'dart:io';

import 'package:seguro/globals/database.dart';
import 'package:seguro/globals/history.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../globals/preferences.dart';
import '../../globals/storage.dart';

import 'camera.dart';
import 'list_photo.dart';

class InputPhoto extends StatefulWidget {
  const InputPhoto({Key? key, this.imageFromCamera}) : super(key: key);
  final String? imageFromCamera;

  @override
  _InputPhotoState createState() => _InputPhotoState();
}

class _InputPhotoState extends State<InputPhoto> {
  final fileEditController = TextEditingController();
  late String imageFromCamera;
  String fileName = "";
  List<String> filePaths = [];
  String _uid = "";

  @override
  void initState() {
    super.initState();
    imageFromCamera =
        (widget.imageFromCamera == null) ? "" : widget.imageFromCamera!;
    getUID().then((value) {
      setState(() {
        _uid = value;
      });
    });
  }

  void _onRename(String name) {
    setState(() {
      fileName = name;
    });
  }

  void _setFilePaths(List<String> path) {
    setState(() {
      filePaths = path;
    });
  }

  void _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
    );

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file selected'),
        ),
      );
      return null;
    }
    List<String> validPaths = [];
    for (var element in result.paths) {
      if (element != null) {
        validPaths.add(element);
      }
    }
    _setFilePaths(validPaths);
  }

  void _upload() {
    if (filePaths.isNotEmpty) {
      filePaths.asMap().forEach((index, item) {
        storage.checkIfNameAvailable(_uid, fileName).then((value) {
          if (value == true) {
            storage.uploadFile(_uid, item, "$fileName$index").then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${filePaths.length} photos uploaded"),
                ),
              );
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ListPhoto())
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Item with this name already exists"),
              ),
            );
          }
        });
      });
      dbn.insertNotification(Log(
          title: "upload photo",
          message: "success uploading ${filePaths.length}",
          type: 1,
          date: DateTime.now().millisecondsSinceEpoch));
    } else if (imageFromCamera != "") {
      storage.checkIfNameAvailable(_uid, fileName).then((value) {
        if (value == true) {
          storage.uploadFile(_uid, imageFromCamera, fileName).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Photo Uploaded"),
              ),
            );
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ListPhoto())
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Item with this name already exists"),
            ),
          );
        }
      });
      dbn.insertNotification(Log(
          title: "upload photo",
          message: "success uploading 1 photo",
          type: 1,
          date: DateTime.now().millisecondsSinceEpoch));
    }
  }

  void _camera() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Camera()));
  }

  Widget _banner() {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        height: 100,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: Image.asset('lib/assets/image/imgicon.png'),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: const Text("Please upload your image"),
            )
          ],
        ));
  }

  Widget _listPhoto() {
    return Container(
        margin: const EdgeInsets.only(bottom: 32),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(width: 10);
            },
            itemCount: filePaths.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: ((context, index) {
              return Image.file(
                File(filePaths[index]),
              );
            })));
  }

  Widget _showPhoto() {
    return Container(
        margin: const EdgeInsets.only(bottom: 32),
        height: 400,
        child: Center(
          child: Image.file(
            File(imageFromCamera),
            fit: BoxFit.contain,
          ),
        ));
  }

  Widget photo() {
    if (filePaths.isEmpty && imageFromCamera == "") {
      return _banner();
    } else if (filePaths.isNotEmpty) {
      return _listPhoto();
    } else {
      return _showPhoto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Input Photo"),
      ),
      body: Center(
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    photo(),
                    Container(
                      margin: const EdgeInsets.fromLTRB(32, 8.0, 32, 16),
                      child: TextField(
                        controller: fileEditController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter file name',
                        ),
                        onChanged: _onRename,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 36,
                            child: ElevatedButton(
                              onPressed: _pickFiles,
                              child: const Text("Pick File"),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 100,
                            height: 36,
                            child: ElevatedButton(
                                onPressed: _camera,
                                child: const Text("Camera")
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 100,
                            height: 36,
                            child: ElevatedButton(
                                onPressed: _camera,
                                child: const Text("CCTV")
                            ),
                          )
                        ],
                      ),
                    ),
                    (filePaths.isNotEmpty || imageFromCamera != "") ?
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: SizedBox(
                        width: 320,
                        height: 36,
                        child: ElevatedButton(
                            onPressed: _upload,
                            child: const Text("Upload")
                        ),
                      ),
                    ) :
                    Container()
                  ]
              )
          )
      ),
    );
  }
}
