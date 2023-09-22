import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PhotoView extends StatefulWidget {
  const PhotoView({super.key});

  @override
  State<PhotoView> createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {
  CollectionReference referenceCameraCapture =
      FirebaseFirestore.instance.collection('camera_capture');

  late Stream<QuerySnapshot> streamCameraCaputure;

  @override
  void initState() {
    streamCameraCaputure = referenceCameraCapture.snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Посмотреть фотографии'),
        elevation: 10,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: streamCameraCaputure,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Произошла какая-то ошибка. ${snapshot.error}',
              ),
            );
          }
          if (snapshot.hasData) {
            QuerySnapshot<Object?>? querySnapshot = snapshot.data;
            List<QueryDocumentSnapshot> documents = querySnapshot!.docs;

            List<Map> items = documents
                .map((e) => {
                      'comment': e['comment'],
                      'image': e['image'],
                      'latitude': e['latitude'],
                      'longitude': e['longitude']
                    })
                .toList();

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  Map item = items[index];
                  return Row(
                    children: [
                      item.containsKey('image')
                          ? SizedBox(
                              width: 100,
                              height: 150,
                              child: Image.network(
                                '${item['image']}',
                                frameBuilder: (_, image, loadingBuilder, __) {
                                  if (loadingBuilder == null) {
                                    return const SizedBox(
                                      width: 100,
                                      height: 150,
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }
                                  return image;
                                },
                              ),
                            )
                          : const Text('Нет изображения!'),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['comment'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              softWrap: true,
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              item['latitude'],
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              item['longitude'],
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
