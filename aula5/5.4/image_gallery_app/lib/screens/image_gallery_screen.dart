import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../app_colors.dart';
import '../routes.dart';

part '../widgets/custom_images.dart';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key});

  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  final List<String> _imagesUrls = [];
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();
  AccelerometerEvent? _accelerometerEvent;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (_auth.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, Routes.login);
        return;
      });
    }

    accelerometerEvents.listen((event) {
      setState(() {
        _accelerometerEvent = event;
      });
    });

    _listImages();

    super.initState();
  }

  void _listImages() async {
    setState(() {
      _loading = true;
    });

    final ListResult result =
        await FirebaseStorage.instance.ref('uploads').list();

    final List<String> urls = await Future.wait(
      result.items.map((element) async {
        return await element.getDownloadURL();
      }),
    );

    setState(() {
      _loading = false;
      _imagesUrls.addAll(urls);
    });
  }

  void _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        var file = File(pickedFile.path);
        _uploadImage(file);
      }
    } catch (e) {
      print(e);
    }
  }

  void _uploadImage(File file) async {
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
        _imagesUrls.add(url);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FC), // Light purple background
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: AppColors.background, //change your color here
        ),
        title: const Text(
          'Image Gallery',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: AppColors.background,
          ),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20.0),
                  // Display accelerometer data in a neat format
                  Text(
                    'Accelerometer Data',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary[700],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8.0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'X: ${_accelerometerEvent?.x.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        Text(
                          'Y: ${_accelerometerEvent?.y.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        Text(
                          'Z: ${_accelerometerEvent?.z.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  _CustomImages(images: _imagesUrls),
                ],
              ),
            ),
    );
  }
}
