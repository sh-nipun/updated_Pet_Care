// lib/screens/auth/signup_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _auth = AuthService();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'pet_owner';
  bool _loading = false, _obscure = true;
  late AnimationController _c;

  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward(); }
  @override
  void dispose() { _c.dispose(); _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  void _signup() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.signUpWithEmailPassword(_emailCtrl.text.trim(), _passCtrl.text.trim(), _nameCtrl.text.trim(), _role);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AC.coral, behavior: SnackBarBehavior.floating,
        content: Text(e.toString(), style: const TextStyle(color: Colors.white))));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AC.white, borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]),
            child: const Icon(Icons.arrow_back_ios_new, size: 14, color: AC.text1)),
          onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(children: [
        Positioned(top: -40, right: -40, child: Container(width: 180, height: 180,
          decoration: BoxDecoration(color: AC.violetL, shape: BoxShape.circle))),
        Positioned(bottom: 60, left: -60, child: Container(width: 200, height: 200,
          decoration: BoxDecoration(color: AC.pinkL, shape: BoxShape.circle))),

        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 8),
            FadeSlide(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ShaderMask(
                shaderCallback: (b) => AC.gHero.createShader(b),
                child: const Text('Join PetCare', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.8)),
              ),
              const SizedBox(height: 6),
              const Text('Your pet\'s health companion', style: TextStyle(color: AC.text2, fontSize: 14)),
            ])),
            const SizedBox(height: 28),

            // Role cards
            FadeSlide(delay: 100, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('I am a...', style: TextStyle(fontWeight: FontWeight.w700, color: AC.text1, fontSize: 15)),
              const SizedBox(height: 12),
              Row(children: [
                _RoleCard(
                  emoji: '🐾', label: 'Pet Owner',
                  subtitle: 'Track & care for pets',
                  gradient: AC.gHero,
                  selected: _role == 'pet_owner',
                  onTap: () => setState(() => _role = 'pet_owner'),
                ),
                const SizedBox(width: 12),
                _RoleCard(
                  emoji: '🏥', label: 'Veterinarian',
                  subtitle: 'Manage appointments',
                  gradient: AC.gOcean,
                  selected: _role == 'veterinarian',
                  onTap: () => setState(() => _role = 'veterinarian'),
                ),
              ]),
            ])),
            const SizedBox(height: 24),

            FadeSlide(delay: 200, child: PCard(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                _Field(ctrl: _nameCtrl, label: 'Full Name', emoji: '😊', gradient: AC.gSunset),
                const SizedBox(height: 12),
                _Field(ctrl: _emailCtrl, label: 'Email Address', emoji: '📧', gradient: AC.gOcean, type: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _PassField(ctrl: _passCtrl, obscure: _obscure, onToggle: () => setState(() => _obscure = !_obscure)),
              ]),
            )),
            const SizedBox(height: 24),

            FadeSlide(delay: 300, child: BounceTap(
              onTap: _loading ? () {} : _signup,
              child: Container(height: 56,
                decoration: BoxDecoration(
                  gradient: _role == 'pet_owner' ? AC.gHero : AC.gOcean,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: (_role == 'pet_owner' ? AC.violet : AC.sky).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Center(child: _loading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Create Account 🚀', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
              ),
            )),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Already have an account? ', style: TextStyle(color: AC.text2)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: ShaderMask(
                  shaderCallback: (b) => AC.gHero.createShader(b),
                  child: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
            const SizedBox(height: 32),
          ]),
        )),
      ]),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String emoji, label, subtitle;
  final Gradient gradient;
  final bool selected;
  final VoidCallback onTap;
  const _RoleCard({required this.emoji, required this.label, required this.subtitle, required this.gradient, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(child: BounceTap(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: selected ? gradient : null,
        color: selected ? null : AC.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selected ? Colors.transparent : Colors.grey.shade200, width: 2),
        boxShadow: selected ? [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6))] : [],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: selected ? Colors.white : AC.text1)),
        Text(subtitle, style: TextStyle(fontSize: 11, color: selected ? Colors.white70 : AC.text3)),
      ]),
    ),
  ));
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, emoji;
  final Gradient gradient;
  final TextInputType? type;
  const _Field({required this.ctrl, required this.label, required this.emoji, required this.gradient, this.type});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    keyboardType: type,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Padding(padding: const EdgeInsets.all(10),
        child: Container(width: 28, height: 28,
          decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 13))))),
    ),
  );
}

class _PassField extends StatelessWidget {
  final TextEditingController ctrl;
  final bool obscure;
  final VoidCallback onToggle;
  const _PassField({required this.ctrl, required this.obscure, required this.onToggle});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    obscureText: obscure,
    decoration: InputDecoration(
      labelText: 'Password',
      prefixIcon: Padding(padding: const EdgeInsets.all(10),
        child: Container(width: 28, height: 28,
          decoration: BoxDecoration(gradient: AC.gLavender, borderRadius: BorderRadius.circular(8)),
          child: const Center(child: Text('🔒', style: TextStyle(fontSize: 13))))),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AC.text3, size: 20),
        onPressed: onToggle),
    ),
  );
}
