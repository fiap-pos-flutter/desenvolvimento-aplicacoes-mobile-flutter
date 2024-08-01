import 'package:flutter/material.dart';
import 'image_gallery.dart';
import 'routes.dart';
import 'image_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Gallery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) => ImageGallery(),
        Routes.viewImage: (context) => ImageView(),
      },
    );
  }
}
