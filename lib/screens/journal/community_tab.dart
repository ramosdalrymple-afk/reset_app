import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/community_provider.dart';
import 'package:my_auth_project/models/community_post_model.dart';
import 'package:my_auth_project/screens/journal/post_detail_screen.dart';
import 'package:my_auth_project/widgets/user_avatar.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'package:my_auth_project/models/habit_model.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: () => _showAddPostDialog(context, isDark),
        icon: const Icon(PhosphorIconsFill.pencilSimple, color: Colors.white),
        label: const Text("Share Story", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Consumer<CommunityProvider>(
          builder: (context, communityProvider, child) {
            return StreamBuilder<List<CommunityPost>>(
              stream: communityProvider.postsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 🟢 1. GET ALL DATA
                final allPosts = snapshot.data ?? [];

                // 🟢 2. EXTRACT UNIQUE HABITS FROM THE DATABASE (POSTS)
                // This creates a set of all habits that actually exist in the feed
                final Set<String> uniqueHabits = allPosts
                    .map((p) => p.habit)
                    .toSet();
                final List<String> filterOptions = ['All', ...uniqueHabits];

                // 🟢 3. FILTER THE POSTS FOR DISPLAY
                final visiblePosts = communityProvider.selectedFilter == 'All'
                    ? allPosts
                    : allPosts
                          .where(
                            (p) => p.habit == communityProvider.selectedFilter,
                          )
                          .toList();

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
                            const SizedBox(height: 20),

                            // 🟢 4. WRAP WIDGET FOR RESPONSIVENESS
                            // This allows chips to flow to the next line automatically
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: filterOptions.map((filter) {
                                final isSelected =
                                    communityProvider.selectedFilter == filter;
                                return FilterChip(
                                  label: Text(filter),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    if (selected) {
                                      communityProvider.setFilter(filter);
                                    }
                                  },
                                  backgroundColor: isDark
                                      ? Colors.white10
                                      : Colors.grey[200],
                                  selectedColor: const Color(0xFF6366F1),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white70
                                              : Colors.black87),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? const Color(0xFF6366F1)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  showCheckmark: false,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 0,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (visiblePosts.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIcons.funnelX(),
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No stories found for this filter.",
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
                            child: _buildFeedCard(
                              context,
                              visiblePosts[index],
                              isDark,
                            ),
                          );
                        }, childCount: visiblePosts.length),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ... (Keep _buildFeedCard, _showAddPostDialog, and _ShareStoryDialog exactly as they were)

  Widget _buildFeedCard(BuildContext context, CommunityPost post, bool isDark) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isLiked = post.likedBy.contains(currentUid);
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
                UserAvatar(
                  photoURL: post.userProfilePic,
                  userName: post.userName,
                  isDark: isDark,
                  radius: 20,
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
                Expanded(
                  child: Text(
                    "•  ${post.topic.toUpperCase()}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: isDark ? Colors.white30 : Colors.black38,
                    ),
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
                Text(
                  post.commentCount > 0
                      ? "${post.commentCount} Comments"
                      : "Comment",
                  style: const TextStyle(color: Colors.grey),
                ),
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

// 🟢 _ShareStoryDialog class stays exactly the same as before
class _ShareStoryDialog extends StatefulWidget {
  final CommunityPost? postToEdit;
  const _ShareStoryDialog({this.postToEdit});
  @override
  State<_ShareStoryDialog> createState() => _ShareStoryDialogState();
}

class _ShareStoryDialogState extends State<_ShareStoryDialog> {
  String? _selectedHabit;
  late TextEditingController _topicController;
  late TextEditingController _contentController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedHabit = widget.postToEdit?.habit;
    _topicController = TextEditingController(
      text: widget.postToEdit?.topic ?? '',
    );
    _contentController = TextEditingController(
      text: widget.postToEdit?.content ?? '',
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final isEditing = widget.postToEdit != null;
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final List<Habit> userHabits = habitProvider.habits;

    if (_selectedHabit == null && userHabits.isNotEmpty) {
      _selectedHabit = userHabits.first.title;
    }

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
          if (userHabits.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                "You need to create a habit in your dashboard first!",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            _buildHabitDropdown(isDark, userHabits),
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
          onPressed: _isUploading || userHabits.isEmpty
              ? null
              : () async {
                  if (_selectedHabit != null &&
                      _contentController.text.isNotEmpty) {
                    setState(() => _isUploading = true);
                    try {
                      if (isEditing) {
                        await Provider.of<CommunityProvider>(
                          context,
                          listen: false,
                        ).updatePost(
                          postId: widget.postToEdit!.id,
                          habit: _selectedHabit!,
                          topic: _topicController.text,
                          content: _contentController.text,
                        );
                      } else {
                        await Provider.of<CommunityProvider>(
                          context,
                          listen: false,
                        ).addPost(
                          habit: _selectedHabit!,
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

  Widget _buildHabitDropdown(bool isDark, List<Habit> habits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Habit",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.black12 : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedHabit,
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              icon: Icon(
                PhosphorIcons.caretDown(),
                color: isDark ? Colors.white54 : Colors.grey,
              ),
              isExpanded: true,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
              ),
              items: habits.map((habit) {
                return DropdownMenuItem<String>(
                  value: habit.title,
                  child: Text(habit.title),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedHabit = newValue;
                });
              },
            ),
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
