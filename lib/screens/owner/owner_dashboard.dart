// lib/screens/owner/owner_dashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';
import '../../models/pet_model.dart';
import '../../models/vaccination_model.dart';
import '../../models/points_model.dart';
import '../../theme/app_theme.dart';
import 'leaderboard_screen.dart';

class OwnerDashboard extends StatelessWidget {
  final String uid;
  final void Function(int)? onNavigate;
  const OwnerDashboard({super.key, required this.uid, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    return Scaffold(
      backgroundColor: AC.bg,
      body: StreamBuilder<UserModel?>(
        stream: db.userStream(uid),
        builder: (context, userSnap) {
          final name = userSnap.data?.fullName.split(' ').first ?? 'there';
          return CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                floating: true,
                title: Row(children: [
                  Container(width: 36, height: 36,
                    decoration: BoxDecoration(gradient: AC.gHero, borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: AC.violet.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: const Center(child: Text('🐾', style: TextStyle(fontSize: 18)))),
                  const SizedBox(width: 10),
                  ShaderMask(
                    shaderCallback: (b) => AC.gHero.createShader(b),
                    child: const Text('PetCare', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                  ),
                ]),
                actions: [
                  BounceTap(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeaderboardScreen(uid: uid))),
                    child: Container(margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(gradient: AC.gGold, borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AC.amber.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))]),
                      child: const Row(children: [
                        Text('🏆', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 4),
                        Text('Ranks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                      ])),
                  ),
                  IconButton(
                    icon: Container(padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)]),
                      child: const Icon(Icons.logout_rounded, size: 16, color: AC.coral)),
                    onPressed: () => FirebaseAuth.instance.signOut()),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                sliver: SliverList(delegate: SliverChildListDelegate([

                  // Hero greeting
                  FadeSlide(child: GradCard(
                    gradient: AC.gHero,
                    padding: const EdgeInsets.all(22),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Hey $name! 👋', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          const Text('Your furry friends miss you 🐶🐱', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ])),
                        // Points badge
                        StreamBuilder<UserPoints?>(
                          stream: db.getUserPoints(uid),
                          builder: (context, ptSnap) {
                            final pts = ptSnap.data?.totalPoints ?? 0;
                            final tier = ptSnap.data?.tierEmoji ?? '🥉';
                            return BounceTap(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeaderboardScreen(uid: uid))),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(16)),
                                child: Column(children: [
                                  Text(tier, style: const TextStyle(fontSize: 24)),
                                  Text('$pts pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                                ]),
                              ),
                            );
                          },
                        ),
                      ]),
                      const SizedBox(height: 16),
                      StreamBuilder<List<Pet>>(
                        stream: db.getUserPets(uid),
                        builder: (ctx, ps) {
                          final c = ps.data?.length ?? 0;
                          return Wrap(spacing: 8, children: [
                            _Pill('$c Pet${c != 1 ? "s" : ""}', '🐾'),
                            StreamBuilder(
                              stream: db.getOwnerAppointments(uid),
                              builder: (ctx2, as_) {
                                final n = (as_.data ?? []).where((a) => a.status != 'done' && a.status != 'cancelled').length;
                                return _Pill('$n Appt${n != 1 ? "s" : ""}', '📅');
                              },
                            ),
                          ]);
                        },
                      ),
                    ]),
                  )),
                  const SizedBox(height: 24),

                  // Quick Access
                  FadeSlide(delay: 80, child: SLabel('Quick Access', action: 'See all')),
                  FadeSlide(delay: 100, child: GridView.count(
                    crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.88,
                    children: [
                      _QCard('🐾', 'My Pets',     AC.gHero,    () => onNavigate?.call(1)),
                      _QCard('📅', 'Book Vet',    AC.gOcean,   () => onNavigate?.call(2)),
                      _QCard('💉', 'Vaccines',    AC.gForest,  () => onNavigate?.call(3)),
                      _QCard('💊', 'Medications', AC.gSunset,  () => onNavigate?.call(3)),
                      _QCard('🏃', 'Activities',  AC.gLavender,() => onNavigate?.call(3)),
                      _QCard('🏆', 'Leaderboard', AC.gGold,    () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeaderboardScreen(uid: uid)))),
                    ],
                  )),
                  const SizedBox(height: 28),

                  // Vaccine reminders
                  StreamBuilder<List<Pet>>(
                    stream: db.getUserPets(uid),
                    builder: (ctx, petSnap) {
                      final pets = petSnap.data ?? [];
                      if (pets.isEmpty) return const SizedBox.shrink();
                      final recs = <Map<String, dynamic>>[];
                      for (final p in pets) {
                        for (final r in VaccineScheduleEngine.getRecommendations(p.type, p.age * 12)) {
                          recs.add({...r, 'petName': p.name});
                        }
                      }
                      if (recs.isEmpty) return const SizedBox.shrink();
                      return FadeSlide(delay: 180, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SLabel('💉 Vaccine Reminders'),
                        ...recs.take(3).map((r) {
                          final over = r['isOverdue'] == true;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: over ? AC.coralL : AC.emeraldL,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: over ? AC.coral.withOpacity(0.3) : AC.emerald.withOpacity(0.3)),
                            ),
                            child: Row(children: [
                              ColorIcon(emoji: over ? '⚠️' : '💉', gradient: over ? AC.gSunset : AC.gForest, size: 40),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(r['name'] as String, style: TextStyle(color: over ? AC.coral : AC.emerald, fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('${r['petName']} · ${r['freq']}', style: const TextStyle(color: AC.text2, fontSize: 11)),
                              ])),
                            ]),
                          );
                        }),
                        const SizedBox(height: 8),
                      ]));
                    },
                  ),

                  // Upcoming appointments
                  FadeSlide(delay: 240, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SLabel('Upcoming Appointments'),
                    StreamBuilder(
                      stream: db.getOwnerAppointments(uid),
                      builder: (ctx, snap) {
                        final appts = (snap.data ?? []).where((a) => a.status != 'done' && a.status != 'cancelled').toList();
                        if (appts.isEmpty) return PCard(
                          padding: const EdgeInsets.all(18),
                          child: Row(children: [
                            ColorIcon(emoji: '📅', gradient: AC.gOcean, size: 40),
                            const SizedBox(width: 12),
                            const Text('No upcoming appointments', style: TextStyle(color: AC.text2)),
                          ]),
                        );
                        return Column(children: appts.take(3).map((a) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: PCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(children: [
                              ColorIcon(emoji: '🏥', gradient: AC.gOcean, size: 42),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(a.vetName, style: const TextStyle(fontWeight: FontWeight.w700, color: AC.text1, fontSize: 14)),
                                Text('${a.petName} · ${a.requestedDate}', style: const TextStyle(color: AC.text2, fontSize: 12)),
                              ])),
                              StatusPill(status: a.status),
                            ]),
                          ),
                        )).toList());
                      },
                    ),
                  ])),
                ])),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label, emoji;
  const _Pill(this.label, this.emoji);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _QCard extends StatelessWidget {
  final String emoji, label;
  final Gradient gradient;
  final VoidCallback onTap;
  const _QCard(this.emoji, this.label, this.gradient, this.onTap);

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: AC.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 46, height: 46,
          decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))]),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22)))),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: AC.text1, fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
      ]),
    ),
  );
}
