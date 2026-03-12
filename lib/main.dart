import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/home_screen.dart';
import 'theme.dart';
import 'firebase_options.dart';

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  runApp(const RoulaApp());
}

class RoulaApp extends StatelessWidget {
  const RoulaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const ClosetSplashScreen(),
    );
  }
}

class ClosetSplashScreen extends StatefulWidget {
  const ClosetSplashScreen({super.key});
  @override
  State<ClosetSplashScreen> createState() => _ClosetSplashScreenState();
}

class _ClosetSplashScreenState extends State<ClosetSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _doorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _doorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart));

    Future.delayed(const Duration(seconds: 1), () {
      _controller.forward().then((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Center(child: Text("ROULA CLOSET", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4))),
          AnimatedBuilder(
            animation: _doorAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // الدرفة اليسرى
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Transform.translate(
                        offset: Offset(-MediaQuery.of(context).size.width * 0.5 * _doorAnimation.value, 0),
                        child: Container(color: Colors.black),
                      ),
                    ),
                  ),
                  // الدرفة اليمنى
                  Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Transform.translate(
                        offset: Offset(MediaQuery.of(context).size.width * 0.5 * _doorAnimation.value, 0),
                        child: Container(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}