import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../catalog/repositories/product_repository.dart';
import '../../navigation/widgets/vaidyam_footer_widget.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedSearchCategory = 'All Categories';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).signInWithEmail(
          email: email,
          password: password,
        );

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);

    if (success) {
      if (authState.isAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back Admin ($email)! Opening Master Admin Console...'),
            backgroundColor: const Color(0xFF4338CA),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/admin');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back to Vaidyam Botanicals ($email)!'),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage ?? 'Invalid email or password. Please check your credentials.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
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
                    'Free Shipping on orders over ₹999 • 100% Certified Organic Botanicals',
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
                                hintText: 'Search for products, formulations...',
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
                        onTap: () => context.go('/login'),
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

            const SizedBox(height: 32),

            // 3. Main Login Card Layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 440, child: _buildLoginFormCard(context, authState)),
                          const SizedBox(width: 60),
                          Expanded(child: _buildRightHeroShowcase(context)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildLoginFormCard(context, authState),
                          const SizedBox(height: 40),
                          _buildRightHeroShowcase(context),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 60),
            const VaidyamFooterWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginFormCard(BuildContext context, AuthStateModel authState) {
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
            'Sign In',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your credentials to access your Vaidyam account.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),

          const SizedBox(height: 24),

          // Email Address
          const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          const SizedBox(height: 6),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Color(0xFF9CA3AF)),
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
          ),

          const SizedBox(height: 16),

          // Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset link sent to your registered email.')),
                  );
                },
                child: const Text('Forgot password?', style: TextStyle(fontSize: 12, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF9CA3AF)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                  color: const Color(0xFF9CA3AF),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
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
          ),

          const SizedBox(height: 24),

          // Sign In CTA
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: authState.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 24),

          // Sign Up Link
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account? ', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                InkWell(
                  onTap: () => context.go('/signup'),
                  child: const Text('Create Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightHeroShowcase(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontFamily: 'serif', fontSize: 40, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.15),
            children: [
              TextSpan(text: 'Organic Beauty.\nPure '),
              TextSpan(text: 'Ayurveda.', style: TextStyle(color: Color(0xFF4F46E5))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Sign in to manage your botanical orders, track deliveries, and unlock subscriber discounts.',
          style: TextStyle(fontSize: 15, color: Color(0xFF4B5563), height: 1.4),
        ),
        const SizedBox(height: 28),
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: AssetImage('assets/images/shampoo.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
