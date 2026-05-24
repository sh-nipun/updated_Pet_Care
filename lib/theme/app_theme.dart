// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

// ── Colour System ──────────────────────────────────────────────────────────────
//
// Palette: "Studio Naturale"
//   Base    → warm linen #F5F0E8       (not cold white, not AI-lavender)
//   Primary → deep fig / aubergine     (not electric violet #7C3AED)
//   Teal    → dusty teal               (not electric sky blue)
//   Gold    → deep saffron             (not neon amber)
//   Red     → brick / sienna           (not neon coral)
//   Green   → muted olive              (not electric emerald)
//   Text    → warm espresso-browns     (not cold indigo greys)
//
// Gradients: TONAL only — each stays within its own hue family.
// No cross-complementary rainbow pairs (no purple→pink, no blue→green).
//
class AC {
  // ── Surfaces ────────────────────────────────────────────────────────
  static const bg    = Color(0xFFF5F0E8);   // warm linen
  static const white = Color(0xFFFBF8F2);   // aged cream card surface
  static const card  = Color(0xFFFBF8F2);

  // ── Primary — deep fig / aubergine ──────────────────────────────────
  static const violet  = Color(0xFF5C2D6E);  // deep fig
  static const violetL = Color(0xFFECDFF3);  // fig tint

  // ── Dusty teal ──────────────────────────────────────────────────────
  static const sky  = Color(0xFF3D7A78);    // dusty teal
  static const skyL = Color(0xFFD4ECEB);    // teal tint

  // ── Deep saffron ────────────────────────────────────────────────────
  static const amber  = Color(0xFFCC8A00);  // deep saffron
  static const amberL = Color(0xFFF7E9C0);  // saffron tint

  // ── Brick / sienna ──────────────────────────────────────────────────
  static const coral  = Color(0xFFB84B35);  // brick red
  static const coralL = Color(0xFFF4DDD8);  // brick tint

  // ── Muted olive ─────────────────────────────────────────────────────
  static const emerald  = Color(0xFF5A7A3A);  // muted olive
  static const emeraldL = Color(0xFFDDE8D0);  // olive tint

  // ── Dried rose ──────────────────────────────────────────────────────
  static const pink  = Color(0xFFA84E6A);   // dried rose
  static const pinkL = Color(0xFFF3DCE3);   // rose tint

  // ── Slate indigo (info/confirmed states) ────────────────────────────
  static const indigo  = Color(0xFF3D5080);  // slate indigo
  static const indigoL = Color(0xFFD5DCF0);  // indigo tint

  // ── Warm orange alias ───────────────────────────────────────────────
  static const orange  = Color(0xFFB84B35);
  static const orangeL = Color(0xFFF4DDD8);

  // ── Text: warm-inked, never cold ────────────────────────────────────
  static const text1 = Color(0xFF1F1208);   // deep espresso
  static const text2 = Color(0xFF6B5744);   // warm mid-brown
  static const text3 = Color(0xFFAA9685);   // warm stone

  // ── Gradients: tonal within one hue family ──────────────────────────
  static const gHero = LinearGradient(          // fig → deep plum
    colors: [Color(0xFF5C2D6E), Color(0xFF3D1A4A)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gOcean = LinearGradient(         // dusty teal → deep teal
    colors: [Color(0xFF3D7A78), Color(0xFF235C5A)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gSunset = LinearGradient(        // brick → deep sienna
    colors: [Color(0xFFB84B35), Color(0xFF8A3020)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gForest = LinearGradient(        // olive → deep olive
    colors: [Color(0xFF5A7A3A), Color(0xFF3C5620)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gGold = LinearGradient(          // saffron → deep saffron
    colors: [Color(0xFFCC8A00), Color(0xFF9A6400)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gLavender = LinearGradient(      // dried rose → deep rose
    colors: [Color(0xFFA84E6A), Color(0xFF7A3248)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}

// ── Theme ──────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AC.bg,
    primaryColor: AC.violet,
    colorScheme: ColorScheme.fromSeed(seedColor: AC.violet, brightness: Brightness.light)
        .copyWith(surface: AC.bg, primary: AC.violet, secondary: AC.sky),
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AC.text1),
      titleTextStyle: TextStyle(color: AC.text1, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AC.white,
      selectedItemColor: AC.violet,
      unselectedItemColor: AC.text3,
      elevation: 20,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
    ),
    cardTheme: CardThemeData(
      color: AC.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AC.white,
      labelStyle: const TextStyle(color: AC.text2, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDDD4C4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDDD4C4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AC.violet, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AC.violet, foregroundColor: AC.white, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
  );
}

// ── Reusable widgets ───────────────────────────────────────────────────────────

class PCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final Color? color;
  const PCard({super.key, required this.child, this.padding, this.radius = 20, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AC.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1F1208).withOpacity(0.07), blurRadius: 20, offset: const Offset(0, 4)),
          BoxShadow(color: const Color(0xFF1F1208).withOpacity(0.03), blurRadius: 6,  offset: const Offset(0, 1)),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}

class GradCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsets? padding;
  final double radius;
  const GradCard({super.key, required this.child, required this.gradient, this.padding, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: const Color(0xFF1F1208).withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );
  }
}

class BounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const BounceTap({super.key, required this.child, required this.onTap});
  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.93).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) { _c.reverse(); widget.onTap(); },
      onTapCancel: () => _c.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

class ColorIcon extends StatelessWidget {
  final String emoji;
  final Gradient gradient;
  final double size;
  const ColorIcon({super.key, required this.emoji, required this.gradient, this.size = 44});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(size * 0.3)),
      child: Center(child: Text(emoji, style: TextStyle(fontSize: size * 0.46))),
    );
  }
}

class SLabel extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const SLabel(this.text, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AC.text1, letterSpacing: -0.3)),
        const Spacer(),
        if (action != null) GestureDetector(
          onTap: onAction,
          child: Text(action!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AC.violet)),
        ),
      ]),
    );
  }
}

class FadeSlide extends StatefulWidget {
  final Widget child;
  final int delay;
  const FadeSlide({super.key, required this.child, this.delay = 0});
  @override
  State<FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.delay), () { if (mounted) _c.forward(); });
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: SlideTransition(position: _slide, child: widget.child));
  }
}

class StatusPill extends StatelessWidget {
  final String status;
  const StatusPill({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (status) {
      case 'pending_admin': bg = AC.amberL;   fg = AC.amber;   label = '⏳ Pending';   break;
      case 'confirmed':     bg = AC.skyL;     fg = AC.sky;     label = '✅ Confirmed'; break;
      case 'accepted_vet':  bg = AC.violetL;  fg = AC.violet;  label = '🩺 Accepted';  break;
      case 'done':          bg = AC.emeraldL; fg = AC.emerald; label = '🎉 Done';       break;
      case 'cancelled':     bg = AC.coralL;   fg = AC.coral;   label = '❌ Cancelled';  break;
      default: bg = const Color(0xFFEDE5D8); fg = AC.text2; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
