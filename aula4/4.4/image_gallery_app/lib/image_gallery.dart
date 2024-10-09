import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sensors_plus/sensors_plus.dart';

import './routes.dart';
part './custom_images.dart';

class ImageGallery extends StatefulWidget {
  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  bool _loading = false;
  final List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();
  AccelerometerEvent? _accelerometerEvent;

  Future<void> _listImages() async {
    setState(() {
      _loading = true;
    });

    final ListResult result =
        await FirebaseStorage.instance.ref('uploads').listAll();
    final List<String> urls =
        await Future.wait(result.items.map((Reference ref) async {
      return await ref.getDownloadURL();
    }).toList());
    setState(() {
      _loading = false;
      _imageUrls.addAll(urls);
    });
  }

  Future<void> _uploadImage(String filePath) async {
    File file = File(filePath);
    try {
      setState(() {
        _loading = true;
      });
      String fileName = file.path.split('/').last;

      var storageRef = FirebaseStorage.instance.ref('uploads/$fileName');

      await storageRef.putFile(file);
      var url = await storageRef.getDownloadURL();

      setState(() {
        _loading = false;
        _imageUrls.add(url);
      });
    } catch (e) {
      print('Upload failed: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _uploadImage(pickedFile.path);
    }
  }

  @override
  void initState() {
    super.initState();
    _listImages();

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
            icon: Icon(Icons.add),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Accelerometer: \n'
              'X: ${_accelerometerEvent?.x.toStringAsFixed(2) ?? "0.00"}, \n'
              'Y: ${_accelerometerEvent?.y.toStringAsFixed(2) ?? "0.00"}, \n'
              'Z: ${_accelerometerEvent?.z.toStringAsFixed(2) ?? "0.00"}',
              style: TextStyle(fontSize: 18),
            ),
          ),
          if (_loading)
            const CircularProgressIndicator()
          else
            Expanded(
              child: _CustomImages(
                images: _imageUrls,
              ),
            ),
        ],
      ),
    );
  }
}
