// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'display_photo_screen.dart';
import 'fetch_server.dart';
import 'location.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.camera});
  final CameraDescription camera;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  late Future<void> initializeControllerFuture;
  XFile? image;
  String imagePath = '';
  String imageUrl = '';
  final commentController = TextEditingController();
  double latitude = 0;
  double longitude = 0;

  Future getImage() async {
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');

    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      await initializeControllerFuture;
      controller.setFlashMode(FlashMode.off);
      final image = await controller.takePicture();

      if (!mounted) return;

      imagePath = image.path;

      await referenceImageToUpload.putFile(File(imagePath));
      imageUrl = await referenceImageToUpload.getDownloadURL();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future uploadData() async {
    Map<String, String> uploadData = {
      'comment': commentController.text.trim() == ''
          ? 'Без комментариев'
          : commentController.text,
      'image': imageUrl,
      'latitude': '$latitude',
      'longitude': '$longitude',
    };
    try {
      await FirebaseFirestore.instance
          .collection('camera_capture')
          .add(uploadData);
    } catch (e) {
      debugPrint('$e');
    }
  }

  void getCameraLocation() async {
    final location = await Location().getLocation();
    latitude = location.latitude;
    longitude = location.longitude;
  }

  @override
  void initState() {
    super.initState();
    getCameraLocation();
    controller = CameraController(widget.camera, ResolutionPreset.high);
    initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              elevation: 10,
              title: const Text('На долгую память!'),
            ),
            body: Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FutureBuilder<void>(
                        future: initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return AspectRatio(
                              aspectRatio: 3 / 4,
                              child: CameraPreview(controller),
                            );
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          controller: commentController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Комментарий:',
                            hintText: 'На память...',
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            label: const Text('Фотографировать\nи сохранить'),
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () async {
                              const snackBar = SnackBar(
                                  duration: Duration(seconds: 5),
                                  content: Text(
                                    'Загрузка... Пожалуйста, подождите!',
                                    textAlign: TextAlign.center,
                                  ));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              await getImage();
                              await uploadData();
                              commentController.text = '';
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DisplayPhotoScreen(
                                    imagePath: imagePath,
                                  ),
                                ),
                              );
                            },
                          ),
                          ElevatedButton.icon(
                            label: const Text('Посмотреть\nвсе фото'),
                            icon: const Icon(Icons.photo),
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FetchServer(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          );
        },
      ),
    );
  }
}
