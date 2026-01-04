import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/community_provider.dart';
import 'package:my_auth_project/models/community_post_model.dart';
import 'package:my_auth_project/screens/journal/post_detail_screen.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final communityProvider = Provider.of<CommunityProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: () => _showAddPostDialog(context, isDark),
        icon: const Icon(PhosphorIconsFill.pencilSimple, color: Colors.white),
        label: const Text("Share Story", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: StreamBuilder<List<CommunityPost>>(
          stream: communityProvider.postsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final posts = snapshot.data ?? [];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SUPPORT HUB",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Community Stories",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (posts.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.newspaper(),
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No stories yet.\nBe the first to share!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: _buildFeedCard(context, posts[index], isDark),
                      );
                    }, childCount: posts.length),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedCard(BuildContext context, CommunityPost post, bool isDark) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isLiked = post.likedBy.contains(currentUid);

    // 🟢 CHECK IF CURRENT USER IS THE AUTHOR
    final isAuthor = currentUid == post.userId;

    final dateString = DateFormat(
      'MMM d, yyyy • h:mm a',
    ).format(post.timestamp);

    Color accentColor;
    switch (post.color) {
      case PostColor.blue:
        accentColor = const Color(0xFF6366F1);
        break;
      case PostColor.pink:
        accentColor = const Color(0xFFEC4899);
        break;
      case PostColor.green:
        accentColor = const Color(0xFF10B981);
        break;
      case PostColor.orange:
        accentColor = Colors.orange;
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey[100]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: accentColor.withOpacity(0.2),
                  radius: 20,
                  child: Text(
                    post.userInitial,
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        dateString,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🟢 OPTION MENU: Only show if author
                if (isAuthor)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz, color: Colors.grey),
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditPostDialog(context, isDark, post);
                      } else if (value == 'delete') {
                        _confirmDelete(context, post.id);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIcons.pencilSimple(),
                                  size: 18,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIcons.trash(),
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    post.habit,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "•  ${post.topic.toUpperCase()}",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              post.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Provider.of<CommunityProvider>(
                      context,
                      listen: false,
                    ).toggleLike(post.id, post.likedBy);
                  },
                  child: Row(
                    children: [
                      Icon(
                        isLiked
                            ? PhosphorIconsFill.heart
                            : PhosphorIcons.heart(),
                        size: 20,
                        color: isLiked ? Colors.redAccent : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${post.likedBy.length}",
                        style: TextStyle(
                          color: isLiked ? Colors.redAccent : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Icon(PhosphorIcons.chatCircle(), size: 20, color: Colors.grey),
                const SizedBox(width: 6),
                const Text("Comment", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPostDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => const _ShareStoryDialog(),
    );
  }

  // 🟢 LOGIC: Show Edit Dialog (Pre-filled)
  void _showEditPostDialog(
    BuildContext context,
    bool isDark,
    CommunityPost post,
  ) {
    showDialog(
      context: context,
      builder: (context) => _ShareStoryDialog(postToEdit: post),
    );
  }

  // 🟢 LOGIC: Delete Confirmation
  void _confirmDelete(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CommunityProvider>(
                context,
                listen: false,
              ).deletePost(postId);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// 🟢 UPDATED DIALOG: Handles both "Add" and "Edit"
class _ShareStoryDialog extends StatefulWidget {
  final CommunityPost? postToEdit; // If null, it's a new post

  const _ShareStoryDialog({this.postToEdit});

  @override
  State<_ShareStoryDialog> createState() => _ShareStoryDialogState();
}

class _ShareStoryDialogState extends State<_ShareStoryDialog> {
  late TextEditingController _habitController;
  late TextEditingController _topicController;
  late TextEditingController _contentController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // 🟢 Pre-fill if editing
    _habitController = TextEditingController(
      text: widget.postToEdit?.habit ?? '',
    );
    _topicController = TextEditingController(
      text: widget.postToEdit?.topic ?? '',
    );
    _contentController = TextEditingController(
      text: widget.postToEdit?.content ?? '',
    );
  }

  @override
  void dispose() {
    _habitController.dispose();
    _topicController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final isEditing = widget.postToEdit != null;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      scrollable: true,
      title: Text(
        isEditing ? "Edit Story" : "Share Story",
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            isDark,
            _habitController,
            "Habit",
            "e.g., Smoking, Gaming",
          ),
          const SizedBox(height: 12),
          _buildTextField(
            isDark,
            _topicController,
            "Topic",
            "e.g., Motivation, Relapse",
          ),
          const SizedBox(height: 12),
          _buildTextField(
            isDark,
            _contentController,
            "What's on your mind?",
            "Share your thoughts...",
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
          ),
          onPressed: _isUploading
              ? null
              : () async {
                  if (_habitController.text.isNotEmpty &&
                      _contentController.text.isNotEmpty) {
                    setState(() => _isUploading = true);

                    try {
                      if (isEditing) {
                        // 🟢 CALL UPDATE
                        await Provider.of<CommunityProvider>(
                          context,
                          listen: false,
                        ).updatePost(
                          postId: widget.postToEdit!.id,
                          habit: _habitController.text,
                          topic: _topicController.text,
                          content: _contentController.text,
                        );
                      } else {
                        // 🟢 CALL ADD
                        await Provider.of<CommunityProvider>(
                          context,
                          listen: false,
                        ).addPost(
                          habit: _habitController.text,
                          topic: _topicController.text,
                          content: _contentController.text,
                        );
                      }

                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                        setState(() => _isUploading = false);
                      }
                    }
                  }
                },
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  isEditing ? "Save" : "Post",
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    bool isDark,
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
            filled: true,
            fillColor: isDark ? Colors.black12 : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
