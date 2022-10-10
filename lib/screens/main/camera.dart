import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

import 'main_screen.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras.first, ResolutionPreset.max);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a Picture')),
      body: FutureBuilder(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();
            String imagePath = image.path;

            if (!mounted) return;

            await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HomeScreen(
                  imageFromCamera: imagePath,
                  initialIndex: 0,
                )
            ));
          } catch (e) {
            log(e.toString());
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
