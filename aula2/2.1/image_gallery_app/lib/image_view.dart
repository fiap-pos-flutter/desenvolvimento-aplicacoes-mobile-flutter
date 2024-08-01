import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String imagePath = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('View Image'),
      ),
      body: Center(
        child: Image.asset(imagePath),
      ),
    );
  }
}