import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _goToHome();
    } on FirebaseAuthException catch (e) {
      setState(
        () => _errorMessage = e.message ?? 'Sign in failed. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final g = await GoogleSignIn().signIn();
      if (g == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final ga = await g.authentication;
      await _auth.signInWithCredential(
        GoogleAuthProvider.credential(
          accessToken: ga.accessToken,
          idToken: ga.idToken,
        ),
      );
      _goToHome();
    } catch (_) {
      if (mounted)
        setState(
          () => _errorMessage = 'Google sign in failed. Please try again.',
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple Sign In coming soon!'),
        backgroundColor: Color(0xFF7C3AED),
      ),
    );
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(
        () => _errorMessage = 'Enter your email above to reset your password.',
      );
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent!'),
            backgroundColor: Color(0xFF7C3AED),
          ),
        );
      }
    } catch (_) {
      if (mounted)
        setState(() => _errorMessage = 'Failed to send reset email.');
    }
  }

  // ✅ Clean white input box — light grey border, no fill colour
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1D1D1F)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFBDBDBD),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFFBDBDBD), size: 20),
        suffixIcon: isPassword
            ? GestureDetector(
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFFBDBDBD),
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Purple radial glow top
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C3AED).withOpacity(0.12),
                      const Color(0xFFEC4899).withOpacity(0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 0.70],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 48),

                        // Logo
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7C3AED,
                                  ).withOpacity(0.35),
                                  blurRadius: 24,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'L',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Title
                        const Center(
                          child: Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1D1D1F),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Center(
                          child: Text(
                            'Sign in to continue to Lix',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFAEAEB2),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Email label
                        const Text(
                          'Email address',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _emailController,
                          hint: 'you@example.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        // Password label
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _passwordController,
                          hint: 'Enter your password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _forgotPassword,
                            child: const Padding(
                              padding: EdgeInsets.only(top: 12, bottom: 4),
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7C3AED),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Sign In button
                        GestureDetector(
                          onTap: _isLoading ? null : _signInWithEmail,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7C3AED,
                                  ).withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: _isLoading
                                ? const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                          ),
                        ),

                        // Error message
                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFEF4444),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade200),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                'or continue with',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFAEAEB2),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade200),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Social buttons
                        Row(
                          children: [
                            // Google
                            Expanded(
                              child: GestureDetector(
                                onTap: _isLoading ? null : _signInWithGoogle,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFE0E0E0),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _GoogleLogo(),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Google',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1D1D1F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Apple
                            Expanded(
                              child: GestureDetector(
                                onTap: _isLoading ? null : _signInWithApple,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1D1D1F),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.18),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.apple,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Apple',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Bottom: Sign Up + Terms
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 28,
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        ),
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B6B6B),
                            ),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              const TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF7C3AED),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFAEAEB2),
                            height: 1.6,
                          ),
                          children: [
                            const TextSpan(
                              text: 'By signing in, you agree to our ',
                            ),
                            const TextSpan(
                              text: 'Terms',
                              style: TextStyle(
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            const TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.75),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7C3AED),
                  strokeWidth: 2.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Google Logo ───────────────────────────────────────────────
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = Paint()..style = PaintingStyle.fill;

    final blue = Path()
      ..moveTo(22.56 * s, 12.25 * s)
      ..cubicTo(22.56 * s, 11.47 * s, 22.49 * s, 10.72 * s, 22.36 * s, 10.0 * s)
      ..lineTo(12 * s, 10.0 * s)
      ..lineTo(12 * s, 14.26 * s)
      ..lineTo(17.92 * s, 14.26 * s)
      ..cubicTo(
        17.66 * s,
        15.63 * s,
        16.88 * s,
        16.79 * s,
        15.71 * s,
        17.57 * s,
      )
      ..lineTo(15.71 * s, 20.34 * s)
      ..lineTo(19.28 * s, 20.34 * s)
      ..cubicTo(21.36 * s, 18.42 * s, 22.56 * s, 15.6 * s, 22.56 * s, 12.25 * s)
      ..close();
    p.color = const Color(0xFF4285F4);
    canvas.drawPath(blue, p);

    final green = Path()
      ..moveTo(12 * s, 23 * s)
      ..cubicTo(14.97 * s, 23 * s, 17.46 * s, 22.02 * s, 19.28 * s, 20.34 * s)
      ..lineTo(15.71 * s, 17.57 * s)
      ..cubicTo(14.73 * s, 18.23 * s, 13.48 * s, 18.63 * s, 12 * s, 18.63 * s)
      ..cubicTo(9.14 * s, 18.63 * s, 6.71 * s, 16.7 * s, 5.84 * s, 14.1 * s)
      ..lineTo(2.18 * s, 14.1 * s)
      ..lineTo(2.18 * s, 16.94 * s)
      ..cubicTo(3.99 * s, 20.53 * s, 7.7 * s, 23 * s, 12 * s, 23 * s)
      ..close();
    p.color = const Color(0xFF34A853);
    canvas.drawPath(green, p);

    final yellow = Path()
      ..moveTo(5.84 * s, 14.09 * s)
      ..cubicTo(5.62 * s, 13.43 * s, 5.49 * s, 12.73 * s, 5.49 * s, 12 * s)
      ..cubicTo(5.49 * s, 11.27 * s, 5.62 * s, 10.57 * s, 5.84 * s, 9.91 * s)
      ..lineTo(2.18 * s, 7.07 * s)
      ..cubicTo(1.43 * s, 8.55 * s, 1 * s, 10.22 * s, 1 * s, 12 * s)
      ..cubicTo(1 * s, 13.78 * s, 1.43 * s, 15.45 * s, 2.18 * s, 16.93 * s)
      ..lineTo(5.84 * s, 14.09 * s)
      ..close();
    p.color = const Color(0xFFFBBC05);
    canvas.drawPath(yellow, p);

    final red = Path()
      ..moveTo(12 * s, 5.38 * s)
      ..cubicTo(13.62 * s, 5.38 * s, 15.06 * s, 5.94 * s, 16.21 * s, 7.02 * s)
      ..lineTo(19.36 * s, 3.87 * s)
      ..cubicTo(17.45 * s, 2.09 * s, 14.97 * s, 1 * s, 12 * s, 1 * s)
      ..cubicTo(7.7 * s, 1 * s, 3.99 * s, 3.47 * s, 2.18 * s, 7.07 * s)
      ..lineTo(5.84 * s, 9.91 * s)
      ..cubicTo(6.71 * s, 7.31 * s, 9.14 * s, 5.38 * s, 12 * s, 5.38 * s)
      ..close();
    p.color = const Color(0xFFEA4335);
    canvas.drawPath(red, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
