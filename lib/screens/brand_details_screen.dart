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
  const BrandDetailsScreen({super.key, required this.name, required this.brandId, required this.isAdmin});

  @override
  State<BrandDetailsScreen> createState() => _BrandDetailsScreenState();
}

class _BrandDetailsScreenState extends State<BrandDetailsScreen> {

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File file = File(pickedFile.path);
    
    // --- عملية ضغط الصورة ---
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
    
    var compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // ضغط بنسبة 70% للحفاظ على الجودة وتقليل المساحة
    );

    if (compressedFile == null) return;
    File finalFile = File(compressedFile.path);

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child('brands').child(widget.brandId).child(fileName);
    
    await ref.putFile(finalFile);
    String downloadUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('brands').doc(widget.brandId).collection('items').add({
      'image': downloadUrl,
      'path': ref.fullPath,
    });
  }

  // ... (دالة deleteImage تبقى كما هي)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(widget.name.toUpperCase())),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('brands').doc(widget.brandId).collection('items').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!.docs;
          if (items.isEmpty) return const Center(child: Text("No images yet"));

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final imageUrl = item['image'];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FullImageScreen(imageUrl: imageUrl))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  // --- استخدام الكاش هنا ---
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.isAdmin ? FloatingActionButton(onPressed: pickAndUploadImage, child: const Icon(Icons.add)) : null,
    );
  }
}