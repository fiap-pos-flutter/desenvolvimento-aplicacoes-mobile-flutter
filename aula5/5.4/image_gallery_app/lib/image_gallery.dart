import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_gallery_app/routes.dart';
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
  final List<String> imageUrls = [];
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AccelerometerEvent? _accelerometerEvent;

  Future<void> _listImages() async {
    final ListResult result =
        await FirebaseStorage.instance.ref('uploads').listAll();
    final List<String> urls =
        await Future.wait(result.items.map((Reference ref) async {
      return await ref.getDownloadURL();
    }).toList());
    setState(() {
      imageUrls.addAll(urls);
    });
  }

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
    _user = _auth.currentUser;
    if (_user == null) {
      Navigator.pushReplacementNamed(context, Routes.login);
    } else {
      _listImages();
    }

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
      body: Column(
        children: [
          Text(
            'Accelerometer: \n'
            'X: ${_accelerometerEvent?.x.toStringAsFixed(2) ?? "0.00"}, \n'
            'Y: ${_accelerometerEvent?.y.toStringAsFixed(2) ?? "0.00"}, \n'
            'Z: ${_accelerometerEvent?.z.toStringAsFixed(2) ?? "0.00"}',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Imagens remotas: \n',
            style: TextStyle(fontSize: 18),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Image.network(imageUrls[index]),
                );
              },
            ),
          ),
          Text(
            'Imagens locais: \n',
            style: TextStyle(fontSize: 18),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Image.file(images[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
