// lib/screens/owner/owner_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';
import '../../models/points_model.dart';
import '../../theme/app_theme.dart';
import 'leaderboard_screen.dart';

class OwnerProfileScreen extends StatelessWidget {
  final String uid;
  const OwnerProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w800, color: AC.text1)),
      ),
      body: StreamBuilder<UserModel?>(
        stream: db.userStream(uid),
        builder: (context, snap) {
          final user = snap.data;
          if (user == null) return const Center(child: CircularProgressIndicator(color: AC.violet));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              // Avatar card
              FadeSlide(child: GradCard(
                gradient: AC.gHero,
                padding: const EdgeInsets.all(28),
                child: Column(children: [
                  CircleAvatar(radius: 44,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 34, color: Colors.white, fontWeight: FontWeight.w900))),
                  const SizedBox(height: 14),
                  Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(user.email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Text('🐾  Pet Owner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ]),
              )),
              const SizedBox(height: 16),

              // Points & tier card
              FadeSlide(delay: 100, child: StreamBuilder<UserPoints?>(
                stream: db.getUserPoints(uid),
                builder: (context, ptSnap) {
                  final pts = ptSnap.data;
                  final totalPts = pts?.totalPoints ?? 0;
                  final tier = pts?.tier ?? 'Bronze';
                  final emoji = pts?.tierEmoji ?? '🥉';
                  final acts = pts?.activitiesCompleted ?? 0;
                  final tierMaxes = {'Bronze': 500, 'Silver': 1000, 'Gold': 2000, 'Diamond': 2000};
                  final tierMins = {'Bronze': 0, 'Silver': 500, 'Gold': 1000, 'Diamond': 2000};
                  final max = tierMaxes[tier] ?? 500;
                  final min = tierMins[tier] ?? 0;
                  final progress = tier == 'Diamond' ? 1.0 : ((totalPts - min) / (max - min)).clamp(0.0, 1.0);

                  return PCard(child: Column(children: [
                    Row(children: [
                      Text(emoji, style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(tier, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AC.text1)),
                        Text('$totalPts points · $acts activities', style: const TextStyle(color: AC.text2, fontSize: 12)),
                      ])),
                      BounceTap(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeaderboardScreen(uid: uid))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(gradient: AC.gGold, borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: AC.amber.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]),
                          child: const Text('Leaderboard 🏆', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: AC.violetL,
                        valueColor: const AlwaysStoppedAnimation<Color>(AC.violet),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text('$totalPts pts', style: const TextStyle(color: AC.text2, fontSize: 11)),
                      const Spacer(),
                      Text(tier == 'Diamond' ? '🎉 Max tier!' : 'Next: $max pts', style: const TextStyle(color: AC.violet, fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ]));
                },
              )),
              const SizedBox(height: 12),

              // Tier breakdown
              FadeSlide(delay: 200, child: PCard(child: Column(children: [
                const Row(children: [
                  ColorIcon(emoji: '🏆', gradient: AC.gGold, size: 36),
                  SizedBox(width: 12),
                  Text('Tier System', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AC.text1)),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  _TierItem('🥉', 'Bronze', '0', AC.amberL),
                  _TierItem('🥈', 'Silver', '500', Colors.grey.shade100),
                  _TierItem('🥇', 'Gold', '1000', const Color(0xFFFEF9C3)),
                  _TierItem('💎', 'Diamond', '2000', AC.violetL),
                ]),
              ]))),
              const SizedBox(height: 28),

              FadeSlide(delay: 300, child: BounceTap(
                onTap: () => FirebaseAuth.instance.signOut(),
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: AC.gSunset,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AC.coral.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5))],
                  ),
                  child: const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.logout_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  ])),
                ),
              )),
            ]),
          );
        },
      ),
    );
  }
}

class _TierItem extends StatelessWidget {
  final String emoji, name, pts;
  final Color color;
  const _TierItem(this.emoji, this.name, this.pts, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    margin: const EdgeInsets.symmetric(horizontal: 3),
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 4),
      Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: AC.text1)),
      Text('$pts+ pts', style: const TextStyle(fontSize: 9, color: AC.text2)),
    ]),
  ));
}
