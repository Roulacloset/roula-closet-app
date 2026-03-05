import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'brand_details_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

  final brandController = TextEditingController();
  final notificationController = TextEditingController();

  void addBrand() async {
    if (brandController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('brands').add({
      'name': brandController.text,
    });

    brandController.clear();
  }

  void deleteBrand(String brandId) async {
    await FirebaseFirestore.instance
        .collection('brands')
        .doc(brandId)
        .delete();
  }

  void sendNotification() async {
    if (notificationController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('notifications').add({
      'message': notificationController.text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    notificationController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification Sent")),
    );
  }

  void openNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Send Notification"),
          content: TextField(
            controller: notificationController,
            decoration: const InputDecoration(
              labelText: "Write message",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: sendNotification,
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        // 👇 نكسر تأثير الثيم العام بالكامل
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          "Admin Panel",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: openNotificationDialog,
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('brands').snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final brands = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [

              const Text(
                "Add Brand",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: brandController,
                decoration: const InputDecoration(
                  labelText: "Brand Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: addBrand,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Add Brand"),
              ),

              const Divider(height: 40),

              ...brands.map((brand) {
                return ListTile(
                  title: Text(brand['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BrandDetailsScreen(
                          name: brand['name'],
                          brandId: brand.id,
                          isAdmin: true,
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteBrand(brand.id),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}