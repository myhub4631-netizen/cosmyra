import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../catalog/repositories/product_repository.dart';
import '../controllers/auth_controller.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedSearchCategory = 'All Categories';
  final TextEditingController _searchController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Conditions to proceed.')),
      );
      return;
    }

    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 600), () async {
      final isMasterAdmin = email.toLowerCase() == '1mdollar2027@gmail.com' ||
          email.toLowerCase() == 'admin@cosmyra.com' ||
          email.toLowerCase() == 'admin@cosmyra.cloud';

      await ref.read(authControllerProvider.notifier).signUpWithEmail(
            email: email,
            password: _passwordController.text.trim(),
            fullName: name,
          );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (isMasterAdmin) {
        ref.read(authControllerProvider.notifier).toggleAdminPreview(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Master Admin Account created for $email! Opening Master Admin Console...'),
            backgroundColor: const Color(0xFF4338CA),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/admin');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully for $name! Welcome to Vaidyam Botanicals.')),
        );
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final totalCartCount = cartState.totalItemCount;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Top Announcement Bar
            Container(
              width: double.infinity,
              color: const Color(0xFF4F46E5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Free Shipping on orders over ₹499 • 100% Certified Organic Botanicals',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.facebook, color: Colors.white, size: 16),
                      SizedBox(width: 12),
                      Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      SizedBox(width: 12),
                      Icon(Icons.play_circle_fill, color: Colors.white, size: 16),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Main Header Bar (Logo, Category Search, Wishlist/Cart/Account)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  // Brand Logo
                  InkWell(
                    onTap: () => context.go('/'),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Vaidyam Botanicals',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.forestSageDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Category Search Bar
                  if (isWide)
                    Container(
                      width: 480,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSearchCategory,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                items: ['All Categories', 'Haircare', 'Skincare', 'Wellness']
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedSearchCategory = val ?? 'All Categories'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search for products, brands and more...',
                                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => context.go('/explore'),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6366F1),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(7),
                                  bottomRight: Radius.circular(7),
                                ),
                              ),
                              child: const Icon(Icons.search, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Shortcuts
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.go('/wishlist'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Badge(
                              isLabelVisible: wishlist.isNotEmpty,
                              label: Text('${wishlist.length}'),
                              backgroundColor: const Color(0xFF6366F1),
                              child: const Icon(Icons.favorite_border, size: 22, color: Color(0xFF374151)),
                            ),
                            const SizedBox(height: 2),
                            const Text('Wishlist', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () => context.go('/cart'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Badge(
                              isLabelVisible: totalCartCount > 0,
                              label: Text('$totalCartCount'),
                              backgroundColor: const Color(0xFF6366F1),
                              child: const Icon(Icons.shopping_cart_outlined, size: 22, color: Color(0xFF374151)),
                            ),
                            const SizedBox(height: 2),
                            const Text('Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () => context.go('/signup'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.person_outline, size: 22, color: Color(0xFF6366F1)),
                            SizedBox(height: 2),
                            Text('Account', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Navigation Bar Links Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.menu, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('All Categories', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        SizedBox(width: 16),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildNavLink('Home', () => context.go('/')),
                          _buildNavLink('Shop', () => context.go('/explore')),
                          _buildNavLink('Categories', () => context.go('/explore')),
                          _buildNavLink('Deals', () => context.go('/explore')),
                          _buildNavLink('New Arrivals', () => context.go('/explore')),
                          _buildNavLink('Best Sellers', () => context.go('/explore')),
                          _buildNavLink('Brands', () => context.go('/explore')),
                          _buildNavLink('Blog', () {}),
                          _buildNavLink('Contact', () {}),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. Main Signup Content (Two Column Layout)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left Signup Form Card
                          SizedBox(width: 440, child: _buildSignupFormCard(context)),
                          const SizedBox(width: 60),
                          // Right Hero Brand Showcase
                          Expanded(child: _buildRightHeroShowcase(context)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildSignupFormCard(context),
                          const SizedBox(height: 40),
                          _buildRightHeroShowcase(context),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildNavLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
      ),
    );
  }

  // Left Column: Signup Form Card
  Widget _buildSignupFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Join Vaidyam Botanicals and discover amazing products.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),

          const SizedBox(height: 24),

          // Full Name Field
          _buildInputLabel('Full Name'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _fullNameController,
            hint: 'Enter your full name',
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 16),

          // Email Address Field
          _buildInputLabel('Email Address'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _emailController,
            hint: 'Enter your email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          // Phone Number Field
          _buildInputLabel('Phone Number'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _phoneController,
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 16),

          // Password Field
          _buildInputLabel('Password'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _passwordController,
            hint: 'Create a password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: const Color(0xFF9CA3AF),
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),

          const SizedBox(height: 16),

          // Terms Checkbox
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _agreeToTerms,
                  activeColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  children: const [
                    Text('I agree to the ', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                    Text('Terms & Conditions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                    Text(' and ', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                    Text('Privacy Policy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Sign Up CTA Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Sign Up', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 24),

          // Divider
          Row(
            children: const [
              Expanded(child: Divider(color: Color(0xFFE5E7EB))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('or sign up with', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              ),
              Expanded(child: Divider(color: Color(0xFFE5E7EB))),
            ],
          ),

          const SizedBox(height: 20),

          // Social Buttons
          Row(
            children: [
              Expanded(child: _buildSocialButton('Google', Icons.g_mobiledata)),
              const SizedBox(width: 12),
              Expanded(child: _buildSocialButton('Facebook', Icons.facebook)),
              const SizedBox(width: 12),
              Expanded(child: _buildSocialButton('Apple', Icons.apple)),
            ],
          ),

          const SizedBox(height: 24),

          // Login Link
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? ', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                InkWell(
                  onTap: () => context.go('/admin'),
                  child: const Text('Login', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF374151)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
        ],
      ),
    );
  }

  // Right Column: Brand Hero Showcase
  Widget _buildRightHeroShowcase(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline
        RichText(
          text: const TextSpan(
            style: TextStyle(fontFamily: 'serif', fontSize: 44, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.15),
            children: [
              TextSpan(text: 'Shop Smart.\nLive '),
              TextSpan(text: 'Better.', style: TextStyle(color: Color(0xFF4F46E5))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Quality products, best prices and a better shopping experience.',
          style: TextStyle(fontSize: 16, color: Color(0xFF4B5563), height: 1.4),
        ),

        const SizedBox(height: 36),

        // 3 Metric Badges
        _buildMetricTile(Icons.people_outline, '10K+', 'Happy Customers'),
        const SizedBox(height: 20),
        _buildMetricTile(Icons.shopping_bag_outlined, '50K+', 'Products'),
        const SizedBox(height: 20),
        _buildMetricTile(Icons.verified_outlined, '99.5%', 'Satisfaction Rate'),

        const SizedBox(height: 36),

        // Lifestyle Image Accent Card
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFEDE9FE), Color(0xFFF5F3FF)],
            ),
            image: const DecorationImage(
              image: AssetImage('assets/images/facewash.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4F46E5), size: 28),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
            Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ],
        ),
      ],
    );
  }
}
