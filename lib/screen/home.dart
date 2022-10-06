// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:io';
import 'package:aplikasi/screen/camera.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplikasi/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi/storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:camera/camera.dart';

final Storage storage = Storage();
late String uid;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screen = <Widget>[
    InputPhoto(),
    const ListPhoto(),
    CCTV(),
  ];

  void _onGButtonTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        appBar: AppBar(title: const Text('SEGURO')),
        body: _screen.elementAt(_selectedIndex),
        bottomNavigationBar: GNav(
          gap: 8,
          backgroundColor: Colors.black,
          color: Colors.white,
          activeColor: Colors.white,
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.photo_library,
              text: 'My Picture',
            ),
            GButton(
              icon: Icons.remove_red_eye,
              text: 'CCTV',
            )
          ],
          selectedIndex: _selectedIndex,
          onTabChange: _onGButtonTapped,
        ));
  }
}

class InputPhoto extends StatefulWidget {
  const InputPhoto({Key? key, this.imageFromCamera}) : super(key: key);
  final String? imageFromCamera;
  @override
  _InputPhotoState createState() => _InputPhotoState();
}

class _InputPhotoState extends State<InputPhoto> {
  final fileEditController = TextEditingController();

  String fileName = "";
  List<String> filePaths = [];

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
    result.paths.forEach((element) {
      if (element != null) {
        validPaths.add(element);
      }
    });
    _setFilePaths(validPaths);
  }

  void _upload() {
    filePaths.asMap().forEach((index, value) {
      storage
          .uploadFile(uid, value, "$fileName$index")
          .then((value) => print("done"));
    });
  }

  void _camera() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Camera()));
  }

  Widget _banner() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: Image.asset('lib/assets/image/imgicon.png'),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: const Text("Please upload your image"),
        )
      ],
    );
  }

  Widget _listPhoto() {
    return ListView.separated(
        separatorBuilder: (context, index) {
          return const SizedBox(width: 10);
        },
        itemCount: filePaths.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: ((context, index) {
          return Image.file(
            File(filePaths[index]),
          );
        }));
  }

  Widget _showPhoto() {
    return Center(
      child: Image.file(File(widget.imageFromCamera!)),
    );
  }

  Widget photo() {
    if (filePaths.isEmpty || widget.imageFromCamera == null) {
      return _banner();
    } else if (filePaths.isNotEmpty) {
      return _listPhoto();
    } else {
      return _showPhoto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: photo()),
            Container(
              margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 88,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _pickFiles,
                      child: const Text("Pick File"),
                    ),
                  ),
                  SizedBox(
                    width: 88,
                    height: 36,
                    child: ElevatedButton(
                        onPressed: _camera, child: const Text("Camera")),
                  )
                ],
              ),
            )
          ]),
    );
  }
}

class ListPhoto extends StatefulWidget {
  const ListPhoto({Key? key}) : super(key: key);

  @override
  _ListPhotoState createState() => _ListPhotoState();
}

class _ListPhotoState extends State<ListPhoto> {
  late Future<firebase_storage.ListResult> _result;

  void _onDownload() async {
    await Permission.manageExternalStorage.request();
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    String path = "";
    // kalau ke SD card => storageInfo.length > 1, storageInfo[1]
    // kalau ke internal memory => storageInfo.length > 0, storageInfo[0]
    // 1 => SD Card
    // 0 => Internal Memory
    if (storageInfo.length > 0) {
      path = "${storageInfo[0].rootDir}/cctv/$uid";
      if (await Permission.manageExternalStorage.request().isGranted) {
        storage.download(uid, path);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _result = storage.listFiles(uid);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
            padding: const EdgeInsets.only(top: 8),
            child: FutureBuilder(
                future: _result,
                builder: (context,
                    AsyncSnapshot<firebase_storage.ListResult> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return GridView.builder(
                        scrollDirection: Axis.vertical,
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 0.5,
                            crossAxisSpacing: 0.2,
                            childAspectRatio:
                                MediaQuery.of(context).size.width /
                                    (MediaQuery.of(context).size.height)),
                        itemCount: snapshot.data!.items.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder(
                              future: storage.toUrl(
                                  uid, snapshot.data!.items[index].name),
                              builder: (context, AsyncSnapshot<String> snap) {
                                if (snap.connectionState ==
                                    ConnectionState.done) {
                                  return Card(
                                    imageName: snapshot.data!.items[index].name,
                                    imageUrl: snap.data!,
                                    onButtonPressed: () {
                                      setState(() {
                                        _result = storage.delete(uid,
                                            snapshot.data!.items[index].name);
                                      });
                                    },
                                  );
                                } else {
                                  return Container();
                                }
                              });
                        });
                  }
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return Container();
                })),
        Container(
          margin: const EdgeInsets.only(top: 16),
          width: 300,
          child: ElevatedButton(
            onPressed: _onDownload,
            child: const Text("Save to SD Card"),
          ),
        )
      ],
    );
  }
}

class Card extends StatefulWidget {
  const Card(
      {super.key,
      required this.imageUrl,
      required this.imageName,
      required this.onButtonPressed});
  final String imageUrl;
  final String imageName;
  final void Function() onButtonPressed;

  @override
  State<Card> createState() => _CardState();
}

class _CardState extends State<Card> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 150,
            child: Image.network(widget.imageUrl, fit: BoxFit.contain),
          ),
          Container(
              child: Text(widget.imageName,
                  softWrap: false, textAlign: TextAlign.center)),
          Container(
            child: ElevatedButton(
                onPressed: widget.onButtonPressed, child: const Text("Delete")),
          )
        ],
      ),
    );
  }
}

class CCTV extends StatefulWidget {
  const CCTV({super.key});

  @override
  State<CCTV> createState() => _CCTVState();
}

class _CCTVState extends State<CCTV> {
  initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return const WebView(
      initialUrl:
          'https://media.geeksforgeeks.org/wp-content/uploads/20201217192146/Screenrecorder-2020-12-17-19-17-36-828.mp4?_=1',
    );
  }
}

//child:  ElevatedButton(
//child: Text("Register Face"),
//onPressed: () {
//FirebaseAuth.instance.signOut().then((value) {
//print("Signed Out");
//Navigator.push(context,
//MaterialPageRoute(builder: (context) => SignInScreen()));
//});
//},
//)