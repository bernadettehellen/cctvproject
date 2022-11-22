import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider_ex/path_provider_ex.dart';

import '../../globals/database.dart';
import '../../globals/history.dart';
import '../../globals/preferences.dart';
import '../../globals/storage.dart';

class ListPhoto extends StatefulWidget {
  const ListPhoto({Key? key}) : super(key: key);

  @override
  _ListPhotoState createState() => _ListPhotoState();
}

class _ListPhotoState extends State<ListPhoto> {
  late Future<firebase_storage.ListResult> _result;
  late bool onLoading;
  String _uid = "";

  void _onDownload() async {
    await Permission.manageExternalStorage.request();
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    String path = "";
    // kalau ke SD card => storageInfo.length > 1, storageInfo[1]
    // kalau ke internal memory => storageInfo.length > 0, storageInfo[0]
    // 1 => SD Card
    // 0 => Internal Memory
    if (storageInfo.isNotEmpty) {
      path = (storageInfo.length == 2) ? "${storageInfo[1].rootDir}/cctv/$_uid" : "${storageInfo[0].rootDir}/cctv/$_uid";
      if (await Permission.manageExternalStorage.request().isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Downloading..."),
            )
        );
        storage.download(_uid, path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Permission not granted, please allow this apps to access storage"),
            )
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    onLoading = true;
    getUID().then((value) {
      setState(() {
        _uid = value;
        _result = storage.listFiles(value);
        onLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return (onLoading == true) ?
    const Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator()
        )
    ) :
    ListView(
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
                            crossAxisCount: 2,
                            childAspectRatio:
                            MediaQuery.of(context).size.width /
                                (MediaQuery.of(context).size.height)),
                        itemCount: snapshot.data!.items.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder(
                              future: storage.toUrl(
                                  _uid, snapshot.data!.items[index].name),
                              builder: (context, AsyncSnapshot<String> snap) {
                                if (snap.connectionState ==
                                    ConnectionState.done) {
                                  return Card(
                                    imageName: snapshot.data!.items[index].name,
                                    imageUrl: snap.data!,
                                    onButtonPressed: () {
                                      setState(() {
                                        _result = storage.delete(
                                            _uid,
                                            snapshot.data!.items[index].name);
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Deleted"),
                                          )
                                      );
                                      dbn.insertNotification(Log(title: "delete photo", message: "success deleting ${snapshot.data!.items[index].name}", type: 2, date: DateTime.now().millisecondsSinceEpoch));
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
                    return const Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      )
                    );
                  }
                  return Container();
                })),
        Container(
          margin: const EdgeInsets.fromLTRB(64, 16, 64, 8),
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
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black
        )
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 300,
              child: Image.network(widget.imageUrl, fit: BoxFit.contain),
            ),
            Text(widget.imageName,
                softWrap: false, textAlign: TextAlign.center),
            ElevatedButton(
                onPressed: widget.onButtonPressed, child: const Text("Delete"))
          ],
        ),
      )
    );
  }
}
