import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/vaidyam_header_widget.dart';
import '../widgets/vaidyam_mobile_bottom_nav_bar.dart';

class AboutCosmyraScreen extends StatelessWidget {
  const AboutCosmyraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      bottomNavigationBar: screenWidth <= 768 ? const VaidyamMobileBottomNavBar(activeTab: 'Home') : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isWide) const VaidyamHeaderWidget(activeTab: 'Shop'),

              // Top Navigation Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1E293B)),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'About Cosmyra',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance back button
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? (screenWidth - 700) / 2 : 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand Logo Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF818CF8), Color(0xFFA855F7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.auto_awesome, size: 44, color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Brand Name
                    const Text(
                      'COSMYRA',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Subtitle
                    const Text(
                      'Premium Organic Cosmetics',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6366F1),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description text
                    const Text(
                      'Cosmyra is your trusted destination for premium organic cosmetics. We combine nature\'s goodness with advanced science to bring you safe, effective and luxurious beauty products.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.55,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Our Mission Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.eco_rounded, color: Color(0xFF9333EA), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Our Mission',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 6),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.45),
                                    children: [
                                      TextSpan(text: 'To '),
                                      TextSpan(
                                        text: 'empower beauty naturally',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7E22CE)),
                                      ),
                                      TextSpan(
                                        text: ' with clean, organic and sustainable cosmetic solutions that nurture your skin and the planet.',
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

                    const SizedBox(height: 32),

                    // "Why Choose Cosmyra?" Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 30, height: 1.5, color: const Color(0xFFC7D2FE)),
                        const SizedBox(width: 10),
                        const Text(
                          'Why Choose Cosmyra?',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(width: 30, height: 1.5, color: const Color(0xFFC7D2FE)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Feature List
                    _buildFeatureItem(
                      icon: Icons.spa_outlined,
                      iconBg: const Color(0xFFF0FDF4),
                      iconColor: const Color(0xFF16A34A),
                      title: '100% Organic & Safe',
                      description: 'Made with natural ingredients that are gentle and safe.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.verified_outlined,
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF9333EA),
                      title: 'Premium Quality',
                      description: 'Carefully crafted with the highest standards of quality.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.local_florist_outlined,
                      iconBg: const Color(0xFFEEF2FF),
                      iconColor: const Color(0xFF4F46E5),
                      title: 'Sustainable Beauty',
                      description: 'Eco-friendly products and packaging for a better planet.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.favorite_border_rounded,
                      iconBg: const Color(0xFFFFF1F2),
                      iconColor: const Color(0xFFE11D48),
                      title: 'Cruelty Free',
                      description: 'We love animals. None of our products are tested on animals.',
                    ),

                    const SizedBox(height: 32),

                    // Metrics Stats Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _buildStatColumn(Icons.people_outline_rounded, const Color(0xFF4F46E5), '10K+', 'Happy Customers'),
                          _buildStatDivider(),
                          _buildStatColumn(Icons.inventory_2_outlined, const Color(0xFF9333EA), '250+', 'Products'),
                          _buildStatDivider(),
                          _buildStatColumn(Icons.card_giftcard_outlined, const Color(0xFF2563EB), '50+', 'Ingredients Sourced'),
                          _buildStatDivider(),
                          _buildStatColumn(Icons.favorite_outline_rounded, const Color(0xFF7E22CE), '100%', 'Organic Promise'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Bottom Showcase Hero Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE9D5FF), Color(0xFFDDD6FE), Color(0xFFEEF2FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pure. Organic.\nBeautiful You.',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF3B0764),
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Discover the power of nature in every drop.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B21A8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/shampoo.jpg',
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 100,
                                  color: Colors.purple.shade100,
                                  child: const Center(
                                    child: Icon(Icons.sanitizer_rounded, size: 48, color: Color(0xFF9333EA)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(IconData icon, Color iconColor, String stat, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(
            stat,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 30,
      color: const Color(0xFFF1F5F9),
    );
  }
}
