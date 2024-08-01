import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ImageGallery extends StatefulWidget {
  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final List<File> images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadImage(String filePath) async {
    File file = File(filePath);
    try {
      String fileName = file.path.split('/').last;

      await FirebaseStorage.instance
          .ref('uploads/$fileName')
          .putFile(file);
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
      body: GridView.builder(
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
    );
  }
}
