import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullImageScreen extends StatelessWidget {
  final String imageUrl;
  const FullImageScreen({super.key, required this.imageUrl});

  // دالة المشاركة المضمونة لنظام iOS
  void _onShare(BuildContext context) async {
    final String text = "Check out this item from Roula Closet: \n$imageUrl";

    try {
      // تحديد إحداثيات الزر لضمان عمله على آيفون وآيباد
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      
      await Share.share(
        text,
        subject: 'Roula Closet Item',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      // إظهار تنبيه في حال حدوث خطأ تقني مفاجئ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Share Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // AppBar شفاف لإعطاء مظهر عصري
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // عرض الصورة مع ميزة الكاش والزووم
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: imageUrl,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),

          // زر المشاركة الأنيق في الأسفل
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () => _onShare(context),
                  icon: const Icon(Icons.share_rounded, color: Colors.black),
                  label: const Text(
                    "SHARE ITEM",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}