import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FullImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullImageScreen({super.key, required this.imageUrl});

  Future<void> openWhatsApp() async {
    // قمنا بإضافة رابط الصورة داخل النص لكي يراها صاحب الرقم فوراً
    final String message = "Hello, I want this item: $imageUrl";
    final String encodedMessage = Uri.encodeComponent(message);
    
    final Uri url = Uri.parse(
      "https://wa.me/971566159244?text=$encodedMessage",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: imageUrl,
              child: InteractiveViewer(
                child: Image.network(imageUrl),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF25D366),
              child: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
              onPressed: openWhatsApp,
            ),
          ),
        ],
      ),
    );
  }
}