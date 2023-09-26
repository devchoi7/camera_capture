import 'dart:io';

import 'package:flutter/material.dart';

class DisplayPhotoScreen extends StatelessWidget {
  const DisplayPhotoScreen({super.key, required this.imagePath});
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Только что сделанное фото'),
        elevation: 10,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                ),
              ),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Фото и комментарий сохранены на сервере с местоположением камеры!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
