import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ImageGallery extends StatefulWidget {
  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final List<File> images = [];
  final ImagePicker _picker = ImagePicker();
  AccelerometerEvent? _accelerometerEvent;

  Future<void> _uploadImage(String filePath) async {
    File file = File(filePath);
    try {
      String fileName = file.path.split('/').last;

      await FirebaseStorage.instance.ref('uploads/$fileName').putFile(file);
    } catch (e) {
      print('Upload failed: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        images.add(File(pickedFile.path));
      });
      _uploadImage(pickedFile.path);
    }
  }

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerEvent = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Gallery'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Accelerometer: \n'
              'X: ${_accelerometerEvent?.x.toStringAsFixed(2) ?? "0.00"}, \n'
              'Y: ${_accelerometerEvent?.y.toStringAsFixed(2) ?? "0.00"}, \n'
              'Z: ${_accelerometerEvent?.z.toStringAsFixed(2) ?? "0.00"}',
              style: TextStyle(fontSize: 18),
            ),
            Expanded(
              child: _CustomImages(images: images),
            ),
          ],
        ),
      ),
    );
  }
}
