import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class FullImageScreen extends StatelessWidget {
  final String imageUrl;
  const FullImageScreen({super.key, required this.imageUrl});

  // هذه الدالة هي المفتاح لقبول أبل: تستخدم ميزة المشاركة الرسمية للنظام
  // سيظهر للمستخدم خيارات (واتساب، إنستغرام، إيميل، حفظ الصورة) بشكل تلقائي
  void shareItem(BuildContext context) async {
    try {
      // نقوم بمشاركة نص يحتوي على رابط الصورة
      await Share.share(
        "Check out this item from Roula Closet: \n$imageUrl",
        subject: "Roula Closet Item",
      );
    } catch (e) {
      debugPrint("Error sharing: $e");
    }
  }

  // دالة احتياطية في حال أردت فتح الإنستغرام مباشرة على الرسائل (للأندرويد والـ iOS)
  Future<void> openInstagramDirect() async {
    // هذا الرابط يفتح صندوق الرسائل المباشرة مع حسابك
    final Uri url = Uri.parse("https://www.instagram.com/direct/t/roula_closet/");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // جعل الخلفية سوداء لتعطي فخامة للصورة
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // تم إبقاء زر واحد فقط للمشاركة في الأعلى لإرضاء مراجعي أبل
          IconButton(
            icon: const Icon(Icons.share, size: 28),
            onPressed: () => shareItem(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // عرض الصورة في المنتصف مع خاصية الـ Hero للانتقال السلس
          Center(
            child: InteractiveViewer( // أضفت لك ميزة الزووم للصورة بالأصابع
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                ),
              ),
            ),
          ),
          
          // إضافة زر كبير وواضح في الأسفل للمشاركة (بدلاً من الأزرار المشتتة)
          Positioned(
            bottom: 50,
            left: 40,
            right: 40,
            child: ElevatedButton.icon(
              onPressed: () => shareItem(context),
              icon: const Icon(Icons.ios_share),
              label: const Text(
                "SHARE & ENQUIRE",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}