import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

class FullImageScreen extends StatelessWidget {
  final String imageUrl;
  const FullImageScreen({super.key, required this.imageUrl});

  // تفعيل زر المشاركة 
  void shareItem() {
    Share.share("Check out this item from Roula Closet: $imageUrl");
  }

  Future<void> openInstagram() async {
    final Uri url = Uri.parse("instagram://user?username=roula_closet"); // يحاول فتح التطبيق مباشرة
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      await launchUrl(Uri.parse("https://www.instagram.com/roula_closet/"), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openWhatsApp() async {
    final String message = "Hello, I want this item: $imageUrl";
    final String encodedMessage = Uri.encodeComponent(message);
    final Uri url = Uri.parse("https://wa.me/971566159244?text=$encodedMessage");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // زر المشاركة الأساسي [cite: 390]
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: shareItem,
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(child: Hero(tag: imageUrl, child: Image.network(imageUrl))),
          // وضع أزرار التواصل بشكل جانبي وأنيق 
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: openWhatsApp,
                  icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18),
                  label: const Text("WhatsApp"),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white),
                ),
                const SizedBox(width: 15),
                ElevatedButton.icon(
                  onPressed: openInstagram,
                  icon: const FaIcon(FontAwesomeIcons.instagram, size: 18),
                  label: const Text("Instagram"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}