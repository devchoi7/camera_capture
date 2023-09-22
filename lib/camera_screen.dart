import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'location.dart';
import 'photo_view.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  XFile? file;
  String imageUrl = '';
  final commentController = TextEditingController();
  double latitude = 0;
  double longitude = 0;

  Future getImage() async {
    XFile? file = await ImagePicker().pickImage(source: ImageSource.camera);

    if (file == null) return;

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');

    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      await referenceImageToUpload.putFile(File(file.path));
      imageUrl = await referenceImageToUpload.getDownloadURL();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future uploadData() async {
    Map<String, String> uploadData = {
      'comment': commentController.text,
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

  Widget showImage() {
    return Container(
      color: Colors.lightGreen.shade100,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
          child: (file == null)
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Сначала напишите комментарий, а потом фотографируйте!\n\n\nИ посмотрите на свою работу!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Здесь будут отображаться фотографии, комментарии и информация о местоположении камеры, хранящиеся на сервере Firebase.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
    );
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
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            elevation: 10,
            title: const Text('На долгую память!'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: showImage(),
                ),
                const SizedBox(height: 20),
                TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: commentController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Комментарий:',
                    hintText: 'Одно слово на память...',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      label: const Text('Фотографировать'),
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () async {
                        await getImage();
                        await uploadData();
                        commentController.text = '';
                      },
                    ),
                    ElevatedButton.icon(
                      label: const Text('Посмотреть'),
                      icon: const Icon(Icons.photo),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PhotoView(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
