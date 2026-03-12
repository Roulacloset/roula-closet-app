import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

class FullImageScreen extends StatelessWidget {
  final String imageUrl;
  const FullImageScreen({super.key, required this.imageUrl});

  void shareItem() {
    Share.share("Check out this item from Roula Closet: $imageUrl");
  }

  Future<void> openInstagram() async {
    final Uri url = Uri.parse("https://www.instagram.com/roula_closet/");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
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
          IconButton(icon: const Icon(Icons.share), onPressed: shareItem), // ميزة المشاركة لإرضاء أبل
        ],
      ),
      body: Stack(
        children: [
          Center(child: Hero(tag: imageUrl, child: Image.network(imageUrl))),
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "ig",
                  backgroundColor: Colors.purple,
                  onPressed: openInstagram,
                  child: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white),
                ),
                const SizedBox(height: 15),
                FloatingActionButton(
                  heroTag: "wa",
                  backgroundColor: const Color(0xFF25D366),
                  onPressed: openWhatsApp,
                  child: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}