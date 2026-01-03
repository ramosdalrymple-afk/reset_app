import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:intl/intl.dart';

class SavedWisdomScreen extends StatelessWidget {
  const SavedWisdomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in")));
    }

    return Scaffold(
      appBar: AppBar(
        // CHANGED: "Vault" -> "Saved Wisdom" for a softer feel
        title: const Text(
          "Saved Wisdom",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('saved_wisdom')
            .orderBy('savedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. Empty
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .bookmarks_outlined, // Changed icon to look less like a "cookie"
                    size: 64,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No saved wisdom yet.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap the jar to find inspiration.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // 4. Data List
          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              // Formatting Timestamp
              String dateStr = "";
              if (data['savedAt'] != null) {
                Timestamp t = data['savedAt'];
                dateStr = DateFormat.yMMMd().format(t.toDate());
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(
                  20,
                ), // Increased padding for "breathing room"
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF6E3), // Keeping the paper look
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Softer, rounder corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quote Text
                    Text(
                      '"${data['text'] ?? ''}"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Times New Roman',
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                        height: 1.4, // Better line height for readability
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 12),

                    // Footer Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Author & Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "- ${data['source'] ?? 'Unknown'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Saved on $dateStr",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // NEW: Visible Delete Button
                        IconButton(
                          onPressed: () {
                            // Show confirmation dialog before deleting
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Remove this quote?"),
                                content: const Text("This cannot be undone."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop(); // Close dialog
                                      // Perform Delete
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .collection('saved_wisdom')
                                          .doc(docId)
                                          .delete();
                                    },
                                    child: const Text(
                                      "Remove",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                          tooltip: "Remove",
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
