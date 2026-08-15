import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, String currentName, String currentPhone) {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Account Profile', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 18)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (e.g. +91 98765 43210)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestSage,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty) {
                  await ref.read(authControllerProvider.notifier).updateUserProfile(
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                      );
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile information updated successfully!')),
                  );
                }
              },
              child: const Text('Save Profile'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final auth = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve name, email, phone dynamically
    final String resolvedName = auth.userName ??
        user?.userMetadata?['full_name'] ??
        (auth.isGuest ? auth.guestName : null) ??
        (user?.email != null ? user!.email!.split('@').first : 'Valued Customer');

    final String resolvedEmail = auth.userEmail ??
        user?.email ??
        (auth.isGuest ? auth.guestEmail : null) ??
        'Not registered';

    final String resolvedPhone = auth.userPhone ??
        user?.phone ??
        (auth.isGuest ? auth.guestPhone : null) ??
        (auth.userPhone?.isNotEmpty == true ? auth.userPhone! : 'Not provided');

    final bool isLoggedIn = auth.isLoggedIn || user != null || auth.isGuest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account & Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.luxurySageGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.goldAccent,
                    child: Text(
                      resolvedName.isNotEmpty ? resolvedName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.forestSageDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resolvedName,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          resolvedEmail,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            auth.isAdmin ? 'MASTER ADMIN SESSION' : (auth.isGuest ? 'GUEST USER' : 'VAIDYAM PRIVILEGE CLUB'),
                            style: const TextStyle(
                              color: AppColors.goldAccentLight,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Personal Information Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showEditProfileDialog(context, ref, resolvedName, resolvedPhone),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.forestSage),
                  label: const Text('Edit Info', style: TextStyle(color: AppColors.forestSage, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: AppColors.forestSage),
                    title: const Text('Full Name', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    subtitle: Text(resolvedName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email_outlined, color: AppColors.forestSage),
                    title: const Text('Email Address', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    subtitle: Text(resolvedEmail, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined, color: AppColors.forestSage),
                    title: const Text('Phone Number', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    subtitle: Text(
                      resolvedPhone.isNotEmpty && resolvedPhone != 'Not provided' ? resolvedPhone : 'Click Edit Info to add phone number',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: resolvedPhone.isNotEmpty && resolvedPhone != 'Not provided' ? null : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Shopping & Orders Hub
            const Text(
              'Shopping & Orders',
              style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined, color: AppColors.forestSage),
                    title: const Text('My Orders & Tracking'),
                    subtitle: const Text('View status and dispatch details', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.push('/orders'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.autorenew, color: AppColors.goldAccent),
                    title: const Text('Subscribe & Save Refills'),
                    subtitle: const Text('Manage 15, 30, 45, 60 day delivery schedules', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.push('/subscriptions'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.favorite_border, color: Colors.pink),
                    title: const Text('My Saved Wishlist'),
                    subtitle: const Text('View products saved for later', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.push('/wishlist'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. Admin Portal Access
            Card(
              color: isDark ? const Color(0xFF1B2A22) : const Color(0xFFEBF4EE),
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: AppColors.forestSage),
                title: const Text(
                  'Master Admin Web Console',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: const Text(
                  'Manage products, categories, orders & website CMS',
                  style: TextStyle(fontSize: 11),
                ),
                trailing: const Icon(Icons.arrow_forward, size: 18),
                onTap: () => context.push('/admin'),
              ),
            ),

            const SizedBox(height: 24),

            // 5. Sign Out / Switch Account Button
            if (isLoggedIn)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out successfully.')),
                      );
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Sign Out / Switch Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In / Register Account', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestSage,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
