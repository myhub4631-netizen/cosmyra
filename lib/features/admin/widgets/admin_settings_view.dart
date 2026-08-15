import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';

class AdminSettingsView extends ConsumerStatefulWidget {
  const AdminSettingsView({super.key});

  @override
  ConsumerState<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends ConsumerState<AdminSettingsView> {
  final _freeShippingThresholdController = TextEditingController(text: '499');
  final _flatShippingFeeController = TextEditingController(text: '49');
  final _gstRateController = TextEditingController(text: '18');

  bool _shiprocketActive = true;
  bool _delhiveryActive = true;
  bool _indiaPostActive = true;
  bool _bluedartActive = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store & Logistics Configuration',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.goldAccent : AppColors.forestSageDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Multi-courier API credentials, shipping thresholds, tax rules & store settings.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved store configuration settings.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: AppColors.softWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save Settings'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Logistics & Multi-Courier API Gateways Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Multi-Courier Logistics & API Integration Engine',
                    style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Automated AWB generation, real-time rate comparison, and dispatch webhook routing.',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Shiprocket API (Primary Courier Aggregator)'),
                    subtitle: const Text('Auto-creates AWBs for Delhivery, Xpressbees, Shadowfax & Ecom Express'),
                    value: _shiprocketActive,
                    activeThumbColor: AppColors.goldAccent,
                    onChanged: (val) => setState(() => _shiprocketActive = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Delhivery Direct API (Express Surface/Air)'),
                    subtitle: const Text('Direct enterprise API token configured'),
                    value: _delhiveryActive,
                    activeThumbColor: AppColors.goldAccent,
                    onChanged: (val) => setState(() => _delhiveryActive = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('India Post Speed Post Engine'),
                    subtitle: const Text('Covers 19,000+ PIN codes across remote India tier-3/4 locations'),
                    value: _indiaPostActive,
                    activeThumbColor: AppColors.goldAccent,
                    onChanged: (val) => setState(() => _indiaPostActive = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('BlueDart Express Integration'),
                    subtitle: const Text('Priority air express for premium orders'),
                    value: _bluedartActive,
                    activeThumbColor: AppColors.goldAccent,
                    onChanged: (val) => setState(() => _bluedartActive = val),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Shipping & Tax Parameters Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shipping Rates & Tax Parameters',
                    style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _freeShippingThresholdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Free Shipping Threshold (₹)',
                            helperText: 'Orders above this amount qualify for ₹0 shipping fee',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _flatShippingFeeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Standard Shipping Fee (₹)',
                            helperText: 'Applied to orders below free shipping threshold',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _gstRateController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'GST Rate (%)', helperText: 'Standard Indian cosmetics GST slab'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Botanical Store Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Store Branding & Botanical Certifications',
                    style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Brand Title: Cosmyra • Vaidyam Botanicals', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Ayurvedic License #: MH/AYUR/2026/00918', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('Registered Address: 104 Heritage Heights, Bandra West, Mumbai, MH - 400050', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
