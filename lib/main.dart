import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:gif/gif.dart';
import 'dart:async';

import 'pages/home_page.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bavul',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // SplashScreen'i her zaman göster
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late GifController _gifController;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this);
    _checkLoginStatus(); // Giriş durumunu kontrol et
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    Timer(const Duration(seconds: 3), () {
      // GIF süresine göre ayarlayın
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                _isLoggedIn ? const HomePage() : const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Gif(
          image: const AssetImage(
              "assets/animations/loading.gif"), // GIF'in yolunu ayarlayın
          controller: _gifController,
          autostart: Autostart.once,
          onFetchCompleted: () {
            _gifController.reset();
            _gifController.forward();
          },
        ),
      ),
    );
  }
}
