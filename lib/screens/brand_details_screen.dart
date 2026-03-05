import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
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

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File file = File(pickedFile.path);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('brands')
        .child(widget.brandId)
        .child(fileName);

    await ref.putFile(file);
    String downloadUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('brands')
        .doc(widget.brandId)
        .collection('items')
        .add({
      'image': downloadUrl,
      'path': ref.fullPath,
    });
  }

  Future<void> deleteImage(String itemId, String imagePath) async {
    await FirebaseStorage.instance.ref(imagePath).delete();

    await FirebaseFirestore.instance
        .collection('brands')
        .doc(widget.brandId)
        .collection('items')
        .doc(itemId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.name.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {

              final item = items[index];
              final data = item.data() as Map<String, dynamic>;

              final imageUrl = data['image'];
              final itemId = item.id;
              final imagePath = data['path'];

              return Stack(
                children: [

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FullImageScreen(imageUrl: imageUrl),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  if (widget.isAdmin)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () =>
                            deleteImage(itemId, imagePath),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.delete,
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
              backgroundColor: Colors.red,
              child: const Icon(Icons.add),
              onPressed: pickAndUploadImage,
            )
          : null,
    );
  }
}