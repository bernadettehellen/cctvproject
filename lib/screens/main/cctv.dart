import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gesture_zoom_box/gesture_zoom_box.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CCTV extends StatefulWidget {
  const CCTV({super.key, required this.channel});
  final WebSocketChannel channel;

  @override
  State<CCTV> createState() => _CCTVState();
}

class _CCTVState extends State<CCTV> {
  final vidWidth = 640;
  final vidHeight = 480;

  double newVidSizeWidth = 480;
  double newVidSizeHeight = 640;

  bool isLandscape = false;

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft
      ]
    );
    isLandscape = false;
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp]
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation){
        var screenWidth = MediaQuery.of(context).size.width;
        var screenHeight = MediaQuery.of(context).size.height;

        if (orientation == Orientation.portrait) {
          isLandscape = false;
          newVidSizeWidth = (screenWidth > vidWidth ? vidWidth : screenWidth) as double;
          newVidSizeHeight = (vidHeight * newVidSizeWidth / vidWidth );
        } else {
          isLandscape = true;
          newVidSizeHeight = (screenHeight > vidHeight ? vidHeight : screenHeight) as double;
          newVidSizeWidth = (vidWidth * newVidSizeHeight / vidHeight );
        }

        return GestureZoomBox(
          maxScale: 5.0,
          doubleTapScale: 2.0,
          child: StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Image.memory(
                      snapshot.data,
                      gaplessPlayback: true,
                      width: newVidSizeWidth,
                      height: newVidSizeHeight,
                  );
                }
              }),
        );
      },
    );
  }
}