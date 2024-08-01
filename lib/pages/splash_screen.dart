import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'dart:async';

import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late GifController _gifController;

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this);

    // Belirli bir süre sonra giriş sayfasına yönlendir
    Timer(const Duration(seconds: 3), () {
      // 3 saniye (GIF süresine göre ayarlayın)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Gif(
          image: const AssetImage("assets/animations/loading.gif"),
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
