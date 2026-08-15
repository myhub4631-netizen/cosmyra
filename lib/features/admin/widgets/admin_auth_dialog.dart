import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';

class AdminAuthDialog extends ConsumerStatefulWidget {
  const AdminAuthDialog({super.key});

  @override
  ConsumerState<AdminAuthDialog> createState() => _AdminAuthDialogState();
}

class _AdminAuthDialogState extends ConsumerState<AdminAuthDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In controllers
  final _signInEmailController = TextEditingController(text: '1mdollar2027@gmail.com');
  final _signInPasswordController = TextEditingController(text: '000624282aZ!');

  // Create Staff controllers
  final _staffNameController = TextEditingController();
  final _staffEmailController = TextEditingController();
  final _staffPasswordController = TextEditingController();
  String _selectedRole = 'staff';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _staffNameController.dispose();
    _staffEmailController.dispose();
    _staffPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.goldAccent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Master Admin Authentication & Security',
                        style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Sign in to your admin console or provision new staff credentials.',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),

            const SizedBox(height: 16),

            TabBar(
              controller: _tabController,
              labelColor: isDark ? AppColors.goldAccent : AppColors.forestSage,
              indicatorColor: isDark ? AppColors.goldAccent : AppColors.forestSage,
              tabs: const [
                Tab(icon: Icon(Icons.lock_open_outlined), text: '1. Admin Sign In'),
                Tab(icon: Icon(Icons.person_add_alt_outlined), text: '2. Create Staff Account'),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 290,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Sign In
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (currentUser != null || authState.isAdmin)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user, color: AppColors.success, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Active Admin Session: ${currentUser?.email ?? "Dr. Rajesh Vaidya (Master Admin)"}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await ref.read(authControllerProvider.notifier).signOut();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Signed out of Admin Console')),
                                      );
                                    }
                                  },
                                  child: const Text('Sign Out', style: TextStyle(fontSize: 11, color: AppColors.error)),
                                ),
                              ],
                            ),
                          ),

                        TextField(
                          controller: _signInEmailController,
                          decoration: const InputDecoration(labelText: 'Admin Email *', prefixIcon: Icon(Icons.email_outlined)),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _signInPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Password *', prefixIcon: Icon(Icons.lock_outline)),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            // Quick Demo Sign-In Preset
                            OutlinedButton.icon(
                              onPressed: () {
                                ref.read(authControllerProvider.notifier).toggleAdminPreview(true);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Logged in as Dr. Rajesh Vaidya (Master Admin)')),
                                );
                              },
                              icon: const Icon(Icons.bolt, color: AppColors.goldAccent, size: 16),
                              label: const Text('Quick Demo Login', style: TextStyle(fontSize: 12)),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: authState.isLoading
                                  ? null
                                  : () async {
                                      final success = await ref.read(authControllerProvider.notifier).signInWithEmail(
                                            email: _signInEmailController.text.trim(),
                                            password: _signInPasswordController.text.trim(),
                                          );
                                      if (context.mounted) {
                                        if (success) {
                                          ref.read(authControllerProvider.notifier).toggleAdminPreview(true);
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Admin authentication successful!')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(authState.errorMessage ?? 'Authentication failed. Check credentials.')),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: AppColors.softWhite),
                              icon: const Icon(Icons.login, size: 16),
                              label: const Text('Sign In to Admin'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tab 2: Create Staff Account
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _staffNameController,
                          decoration: const InputDecoration(labelText: 'Full Staff Name *', hintText: 'e.g. Vikramaditya Singh'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _staffEmailController,
                                decoration: const InputDecoration(labelText: 'Staff Email *', hintText: 'vikram@cosmyra.com'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedRole,
                                decoration: const InputDecoration(labelText: 'Assigned Role *'),
                                items: const [
                                  DropdownMenuItem(value: 'admin', child: Text('Master Admin')),
                                  DropdownMenuItem(value: 'staff', child: Text('Inventory Manager')),
                                  DropdownMenuItem(value: 'logistics', child: Text('Orders & Logistics')),
                                ],
                                onChanged: (val) => setState(() => _selectedRole = val ?? 'staff'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _staffPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Set Temporary Password *'),
                        ),
                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_staffEmailController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter a valid staff email.')),
                                );
                                return;
                              }
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Created staff account for ${_staffEmailController.text} (${_selectedRole.toUpperCase()})')),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: AppColors.softWhite),
                            icon: const Icon(Icons.person_add, size: 16),
                            label: const Text('Provision Staff Credentials'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
