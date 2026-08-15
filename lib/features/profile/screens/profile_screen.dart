import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Profile Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.luxurySageGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.goldAccent,
                    child: const Icon(Icons.person, size: 32, color: AppColors.forestSageDark),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.email ?? 'Priya Verma (Guest)',
                          style: const TextStyle(
                            fontFamily: 'serif',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'VAIDYAM PRIVILEGE CLUB',
                            style: TextStyle(
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

            // 2. Orders & Subscriptions Hub
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
                    leading: const Icon(Icons.location_on_outlined, color: AppColors.forestSage),
                    title: const Text('Saved Delivery Addresses'),
                    subtitle: const Text('1 default address in Patna, Bihar', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Default address: Patna, Bihar 800001')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Brand & Trust
            const Text(
              'About Cosmyra & Vaidyam',
              style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.spa_outlined, color: AppColors.forestSage),
                    title: const Text('Our Story & Ayurveda Philosophy'),
                    subtitle: const Text('Clean dermatology crafted for Indian climate', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('The Vaidyam Story', style: TextStyle(fontFamily: 'serif')),
                          content: const Text(
                            'Cosmyra Technologies Pvt Ltd is on a mission to bring high-potency Ayurvedic dermatology directly to consumers without toxic compromises or inflated middleman markups.\n\nEvery product is 100% vegetarian, SLS-free, and formulated with clinical botanical extracts.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.verified_outlined, color: AppColors.goldAccent),
                    title: const Text('"Free From 12" Clean Certification'),
                    subtitle: const Text('Zero sulfates, parabens, silicones & toxins', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('"Free From 12" Standard', style: TextStyle(fontFamily: 'serif')),
                          content: const Text(
                            '1. Sulfate Free\n2. Paraben Free\n3. Silicon Free\n4. Mineral Oil Free\n5. Phthalate Free\n6. Synthetic Dye Free\n7. Formaldehyde Free\n8. GMO Free\n9. Animal Fat Free\n10. Microplastic Free\n11. Heavy Metal Safe\n12. 100% Cruelty Free',
                            style: TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got It')),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.support_agent_outlined, color: AppColors.forestSage),
                    title: const Text('Customer Support & Help Center'),
                    subtitle: const Text('care@cosmyra.com • WhatsApp support', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Support line: care@cosmyra.com')),
                      );
                    },
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
                  'Switch to Admin Web Console',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: const Text(
                  'Manage orders, assign couriers & update stock',
                  style: TextStyle(fontSize: 11),
                ),
                trailing: const Icon(Icons.arrow_forward, size: 18),
                onTap: () => context.push('/admin'),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
