import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class FullImageScreen extends StatelessWidget {
  final String imageUrl;
  const FullImageScreen({super.key, required this.imageUrl});

  // الدالة الأساسية للمشاركة - مضمونة العمل بإذن الله
  void _onShare(BuildContext context) async {
    final String text = "Check out this item from Roula Closet: \n$imageUrl";
    
    // استخدام Share.share من مكتبة share_plus
    await Share.share(
      text,
      subject: "Roula Closet Item",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // خلفية سوداء فخمة
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        // تم حذف الأزرار من هنا تماماً بناءً على طلبك
      ),
      body: Stack(
        children: [
          // عرض الصورة في المنتصف
          Center(
            child: InteractiveViewer(
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // الزر الوحيد والأساسي في الأسفل
          Positioned(
            bottom: 50,
            left: 40,
            right: 40,
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _onShare(context), // استدعاء الدالة المباشرة
                icon: const Icon(Icons.share, color: Colors.black),
                label: const Text(
                  "SHARE",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black,
                    letterSpacing: 2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}