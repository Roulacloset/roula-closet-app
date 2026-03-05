import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    setupFCM();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  Future<void> setupFCM() async {

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // طلب إذن الإشعارات
    NotificationSettings settings = await messaging.requestPermission();

    print("Permission status: ${settings.authorizationStatus}");

    // 🔥 طباعة التوكن
    String? token = await messaging.getToken();
    print("FCM TOKEN: $token");

    // الاشتراك بالـ topic
    await messaging.subscribeToTopic("allUsers");
    print("Subscribed to allUsers");

    // استقبال إشعار والتطبيق مفتوح
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.notification!.title ?? "New Notification",
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: controller,
          child: const Text(
            "RC",
            style: TextStyle(
              fontSize: 60,
              letterSpacing: 6,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}