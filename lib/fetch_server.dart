import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FetchServer extends StatefulWidget {
  const FetchServer({super.key});

  @override
  State<FetchServer> createState() => _FetchServerState();
}

class _FetchServerState extends State<FetchServer> {
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
              padding: const EdgeInsets.all(10),
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  Map item = items[index];
                  return Row(
                    children: [
                      if (item.containsKey('image'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (BuildContext context) {
                                      return Scaffold(
                                        backgroundColor:
                                            Colors.lightGreen.shade100,
                                        body: SafeArea(
                                          child: GestureDetector(
                                            child: Center(
                                              child: SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.9,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                child: Hero(
                                                  tag: 'imageHero',
                                                  child: Image.network(
                                                    '${item['image']}',
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      );
                                    }));
                          },
                          child: Image.network(
                            '${item['image']}',
                            fit: BoxFit.cover,
                            frameBuilder: (_, image, loadingBuilder, __) {
                              if (loadingBuilder == null) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green),
                                ),
                                width: 90,
                                height: 120,
                                child: image,
                              );
                            },
                          ),
                        )
                      else
                        const Text('Нет изображения!'),
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
