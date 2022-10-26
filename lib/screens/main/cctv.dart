import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gesture_zoom_box/gesture_zoom_box.dart';
import 'package:intl/intl.dart';
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
  late String _timeString;

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
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (timer) => _getTime());
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp]
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat("MM/dd hh:mm:ss aaa").format(dateTime);
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    setState(() {
      _timeString = _formatDateTime(now);
    });
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

        return Container(
          color: Colors.blueAccent,
          child: StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: <Widget>[
                          GestureZoomBox(
                            maxScale: 5.0,
                            doubleTapScale: 2.0,
                            child: Image.memory(
                              snapshot.data,
                              gaplessPlayback: true,
                              width: newVidSizeWidth,
                              height: newVidSizeHeight,
                            ),
                          ),

                          Positioned.fill(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Column(
                                  children: <Widget>[
                                    const SizedBox(height: 16,),
                                    const Text("Camera View", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),),
                                    const SizedBox(height: 4,),
                                    Text("Live | $_timeString", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),),
                                  ],
                              ),
                            )
                          )
                        ],
                      ),
                    ],
                  );
                }
              }),
        );
      },
    );
  }
}