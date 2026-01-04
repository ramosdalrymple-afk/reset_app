import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/saved_account_service.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/widgets/user_avatar.dart';

class SwitchAccountSheet extends StatefulWidget {
  const SwitchAccountSheet({super.key});

  @override
  State<SwitchAccountSheet> createState() => _SwitchAccountSheetState();
}

class _SwitchAccountSheetState extends State<SwitchAccountSheet> {
  List<SavedUser> _savedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    await SavedAccountService().saveCurrentUser();
    final list = await SavedAccountService().getSavedAccounts();
    if (mounted) {
      setState(() {
        _savedUsers = list;
        _isLoading = false;
      });
    }
  }

  // 🟢 FIXED LOGIC: The seamless switch happens here
  void _handleAccountSwitch(SavedUser account) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    // 1. If switching to the same account, just close.
    if (currentUser?.uid == account.uid) {
      Navigator.pop(context);
      return;
    }

    // 2. CLOSE THE SHEET FIRST (Fixes the "Click Back" bug)
    Navigator.pop(context);

    // 3. Sign Out
    // (Your AuthWrapper will immediately detect this and show the Login Page background)
    final authService = AuthService();
    await authService.signOut();

    // 4. If it's a Google Account, AUTO-TRIGGER the popup
    if (account.authProvider == 'google.com') {
      await authService.signInWithGoogle();
    }

    // 5. If it's Email/Password:
    // We CANNOT auto-fill the password for security reasons.
    // The user lands on the Login Page and must type it.
  }

  void _addNewAccount() async {
    // Close sheet first
    Navigator.pop(context);
    // Sign out to show login screen
    await AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Switch Accounts",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                ..._savedUsers.map((account) {
                  final isCurrent = account.uid == currentUserUid;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _handleAccountSwitch(account),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFF6366F1).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFF6366F1)
                                : (isDark ? Colors.white10 : Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            UserAvatar(
                              photoURL: account.photoURL,
                              userName: account.displayName,
                              isDark: isDark,
                              radius: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.displayName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // 🟢 Optional: Show icon for provider
                                      Icon(
                                        account.authProvider == 'google.com'
                                            ? PhosphorIcons.googleLogo()
                                            : PhosphorIcons.envelopeSimple(),
                                        size: 12,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        account.email,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrent)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF6366F1),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _addNewAccount,
                    icon: const Icon(PhosphorIconsFill.plus),
                    label: const Text("Add New Account"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: isDark ? Colors.white24 : Colors.grey[300]!,
                      ),
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
        ],
      ),
    );
  }
}
