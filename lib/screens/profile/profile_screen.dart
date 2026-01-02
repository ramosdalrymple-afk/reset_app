import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // FIX 1: We don't store 'user' in a final variable. We get it fresh.
  User? get currentUser => FirebaseAuth.instance.currentUser;

  late TextEditingController _nameController;
  final FocusNode _nameFocusNode = FocusNode();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: currentUser?.displayName ?? "",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    // Prevent empty names
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Name cannot be empty")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Update Firebase
      await currentUser?.updateDisplayName(_nameController.text.trim());

      // 2. Reload the user to ensure local data is fresh
      await currentUser?.reload();

      // 3. Update UI
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });

        // Close keyboard
        _nameFocusNode.unfocus();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Identity updated successfully."),
            backgroundColor: Colors.blueAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error updating name: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // If we were editing and clicked the button (Cancel action), reset text
        _nameController.text = currentUser?.displayName ?? "";
        _nameFocusNode.unfocus();
        _isEditing = false;
      } else {
        // Start editing
        _isEditing = true;
        // Delay focus slightly to allow UI to rebuild first
        Future.delayed(const Duration(milliseconds: 100), () {
          _nameFocusNode.requestFocus();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- 1. Background Elements ---
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(isDark ? 0.08 : 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(isDark ? 0.05 : 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // --- 2. Main Content ---
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark ? Colors.white : Colors.black,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Identity",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),

                        // Avatar (Visual only for now)
                        _buildAvatar(currentUser, isDark),

                        const SizedBox(height: 40),

                        // Info Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black12,
                            ),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // DISPLAY NAME ROW
                              _buildEditableRow(
                                label: "DISPLAY NAME",
                                isDark: isDark,
                                // Icon logic: If editing, show X to cancel. If not, show Edit.
                                // If Loading, show spinner.
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          if (_isEditing) {
                                            // If button clicked while editing, treat as Save
                                            _updateName();
                                          } else {
                                            _toggleEdit();
                                          }
                                        },
                                        child: Icon(
                                          _isEditing
                                              ? Icons.check_circle
                                              : Icons.edit_rounded,
                                          color: _isEditing
                                              ? Colors.greenAccent
                                              : Colors.blueAccent,
                                          size: 20,
                                        ),
                                      ),
                                child: _isEditing
                                    ? TextField(
                                        controller: _nameController,
                                        focusNode: _nameFocusNode,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: "Enter Name",
                                        ),
                                        onSubmitted: (_) => _updateName(),
                                      )
                                    : Text(
                                        currentUser?.displayName ?? "User",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Divider(
                                  height: 1,
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black12,
                                ),
                              ),

                              // EMAIL ROW
                              _buildEditableRow(
                                label: "EMAIL",
                                isDark: isDark,
                                icon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black26,
                                  size: 18,
                                ),
                                child: Text(
                                  currentUser?.email ?? "No email linked",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildLogoutButton(context, isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(User? user, bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        // Border & Image
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.blueAccent.withOpacity(0.5),
              width: 2,
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? Icon(
                    Icons.person,
                    size: 40,
                    color: isDark ? Colors.white54 : Colors.black45,
                  )
                : null,
          ),
        ),
        // Camera Icon (Visual only)
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableRow({
    required String label,
    required Widget child,
    required Widget icon,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: child),
            const SizedBox(width: 10),
            icon,
          ],
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: () async {
          await AuthService().signOut();
          if (mounted) Navigator.pop(context);
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.redAccent.withOpacity(isDark ? 0.1 : 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
          ),
        ),
        child: const Text(
          "Log Out",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
