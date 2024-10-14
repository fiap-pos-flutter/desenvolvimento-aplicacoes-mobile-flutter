import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_app/screens/login_screen.dart';
import 'package:image_gallery_app/screens/register_screen.dart';
import 'screens/image_gallery_screen.dart';
import 'routes.dart';
import 'screens/image_view_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Gallery App',
      initialRoute: Routes.login,
      routes: {
        Routes.register: (context) => const RegisterScreen(),
        Routes.imageView: (context) => const ImageViewScreen(),
        Routes.login: (context) => const LoginScreen(),
        Routes.imageGallery: (context) => const ImageGalleryScreen(),
      },
    );
  }
}
