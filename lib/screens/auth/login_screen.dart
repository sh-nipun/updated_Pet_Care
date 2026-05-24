// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false, _obscure = true;
  late AnimationController _floatCtrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _float = Tween(begin: -8.0, end: 8.0).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _floatCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  void _login() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithEmailPassword(_emailCtrl.text.trim(), _passCtrl.text.trim());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AC.coral, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(e.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      body: Stack(children: [
        // Decorative blobs
        Positioned(top: -60, right: -60, child: _Blob(const Color(0xFFE9D5FF), 220)),
        Positioned(top: 120, left: -40, child: _Blob(const Color(0xFFFCE7F3), 160)),
        Positioned(bottom: 80, right: -40, child: _Blob(const Color(0xFFD1FAE5), 180)),
        Positioned(bottom: -40, left: 40, child: _Blob(const Color(0xFFE0F2FE), 140)),

        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 50),

            // Floating logo
            Center(child: AnimatedBuilder(
              animation: _float,
              builder: (_, child) => Transform.translate(offset: Offset(0, _float.value), child: child),
              child: Column(children: [
                Container(width: 90, height: 90,
                  decoration: BoxDecoration(gradient: AC.gHero, borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: AC.violet.withOpacity(0.35), blurRadius: 30, offset: const Offset(0, 12))]),
                  child: const Center(child: Text('🐾', style: TextStyle(fontSize: 44)))),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (b) => AC.gHero.createShader(b),
                  child: const Text('PetCare', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.2)),
                ),
                const SizedBox(height: 6),
                const Text('Love your pets. Track everything.', style: TextStyle(color: AC.text2, fontSize: 14)),
              ]),
            )),
            const SizedBox(height: 44),

            // Card
            FadeSlide(delay: 200, child: PCard(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('Welcome back! 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AC.text1)),
                const SizedBox(height: 20),
                TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email Address',
                    prefixIcon: Container(margin: const EdgeInsets.all(10), width: 28, height: 28,
                      decoration: BoxDecoration(gradient: AC.gOcean, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.email_outlined, color: Colors.white, size: 14)))),
                const SizedBox(height: 14),
                TextField(controller: _passCtrl, obscureText: _obscure,
                  decoration: InputDecoration(labelText: 'Password',
                    prefixIcon: Container(margin: const EdgeInsets.all(10), width: 28, height: 28,
                      decoration: BoxDecoration(gradient: AC.gHero, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.lock_outline, color: Colors.white, size: 14)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AC.text3, size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure)))),
                const SizedBox(height: 24),
                BounceTap(
                  onTap: _loading ? () {} : _login,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(gradient: AC.gHero, borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: AC.violet.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]),
                    child: Center(child: _loading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
                  ),
                ),
              ]),
            )),
            const SizedBox(height: 24),
            FadeSlide(delay: 350, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Don't have an account? ", style: TextStyle(color: AC.text2)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                child: ShaderMask(
                  shaderCallback: (b) => AC.gHero.createShader(b),
                  child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ])),
            const SizedBox(height: 40),
          ]),
        )),
      ]),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob(this.color, this.size);
  @override
  Widget build(BuildContext context) => Container(width: size, height: size,
    decoration: BoxDecoration(color: color.withOpacity(0.6), shape: BoxShape.circle));
}
