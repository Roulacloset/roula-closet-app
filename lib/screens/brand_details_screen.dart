import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'full_image_screen.dart';

class BrandDetailsScreen extends StatefulWidget {
  final String name;
  final String brandId;
  final bool isAdmin;
  const BrandDetailsScreen({
    super.key,
    required this.name,
    required this.brandId,
    required this.isAdmin,
  });

  @override
  State<BrandDetailsScreen> createState() => _BrandDetailsScreenState();
}

class _BrandDetailsScreenState extends State<BrandDetailsScreen> {
  // دالة لرفع الصور مع الضغط
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File file = File(pickedFile.path);

    // تجهيز مسار الحفظ المؤقت للصورة المضغوطة
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath =
        "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    // عملية الضغط
    var compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // تقليل الحجم بنسبة ممتازة مع الحفاظ على الجودة
    );

    if (compressedFile == null) return;
    File finalFile = File(compressedFile.path);

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('brands')
        .child(widget.brandId)
        .child(fileName);

    // الرفع إلى Firebase Storage
    await ref.putFile(finalFile);
    String downloadUrl = await ref.getDownloadURL();

    // حفظ البيانات في Firestore
    await FirebaseFirestore.instance
        .collection('brands')
        .doc(widget.brandId)
        .collection('items')
        .add({
      'image': downloadUrl,
      'path': ref.fullPath, // حفظ المسار لاستخدامه عند الحذف
    });
  }

  // دالة حذف الصورة من الـ Storage والـ Firestore
  void deleteImage(String docId, String fullPath) async {
    try {
      // 1. الحذف من Firebase Storage
      await FirebaseStorage.instance.ref().child(fullPath).delete();

      // 2. الحذف من Firestore
      await FirebaseFirestore.instance
          .collection('brands')
          .doc(widget.brandId)
          .collection('items')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting image: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.name.toUpperCase()),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('brands')
            .doc(widget.brandId)
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!.docs;
          if (items.isEmpty) {
            return const Center(child: Text("No images yet"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final imageUrl = item['image'];
              final imagePath = item['path'];
              final docId = item.id;

              return Stack(
                children: [
                  // عرض الصورة مع الكاش
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullImageScreen(imageUrl: imageUrl),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                  // زر الحذف يظهر فقط للأدمن
                  if (widget.isAdmin)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () {
                          // إظهار تأكيد قبل الحذف
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Delete Image"),
                              content: const Text("Are you sure?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    deleteImage(docId, imagePath);
                                  },
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: pickAndUploadImage,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}