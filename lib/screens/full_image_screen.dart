import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class FullImageScreen extends StatelessWidget {
  final String imageUrl;
  const FullImageScreen({super.key, required this.imageUrl});

  void _onShare(BuildContext context) async {
    // هذا السطر يطبع في الـ Console لنتأكد أن الكود وصل لهنا
    debugPrint("Attempting to share: $imageUrl");

    final String text = "Check out this item from Roula Closet: \n$imageUrl";

    try {
      // إجبار النظام على استخدام صندوق المشاركة المخصص لـ iOS و iPad
      final box = context.findRenderObject() as RenderBox?;
      
      await Share.share(
        text,
        subject: 'Roula Closet Item',
        // هذا السطر ضروري جداً لـ iOS لكي يعرف النظام مكان خروج القائمة
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      debugPrint("Share Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                // تم ربط الزر بالدالة الجديدة
                onPressed: () => _onShare(context),
                icon: const Icon(Icons.share, color: Colors.black),
                label: const Text("SHARE ITEM", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}