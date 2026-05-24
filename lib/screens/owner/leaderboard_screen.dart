// lib/screens/owner/leaderboard_screen.dart
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/points_model.dart';
import '../../theme/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  final String uid;
  const LeaderboardScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    return Scaffold(
      backgroundColor: AC.bg,
      body: StreamBuilder<List<UserPoints>>(
        stream: db.getLeaderboard(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AC.violet));
          }
          final board = snap.data ?? [];
          final myIdx = board.indexWhere((u) => u.uid == uid);
          final myEntry = myIdx >= 0 ? board[myIdx] : null;

          return CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 200,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back_ios_new, size: 14, color: AC.text1)),
                  onPressed: () => Navigator.pop(context)),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: AC.gGold),
                    child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const SizedBox(height: 40),
                      const Text('🏆', style: TextStyle(fontSize: 48)),
                      const Text('Leaderboard', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                      const Text('Earn points by logging activities!', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ])),
                  ),
                ),
              ),

              // My rank banner
              if (myEntry != null) SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: FadeSlide(child: GradCard(
                  gradient: AC.gHero,
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Text(myEntry.tierEmoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Your Ranking', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('#${myIdx + 1}  ·  ${myEntry.totalPoints} pts  ·  ${myEntry.tier}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                      child: Text('${myEntry.activitiesCompleted} acts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ]),
                )),
              )),

              // Podium
              if (board.length >= 3) SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.all(16),
                child: _Podium(top3: board.take(3).toList()),
              )),

              // Tier legend
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PCard(padding: const EdgeInsets.all(14), child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TierBadge('🥉', 'Bronze', '0+', AC.amberL),
                    _TierBadge('🥈', 'Silver', '500+', Colors.grey.shade100),
                    _TierBadge('🥇', 'Gold', '1000+', const Color(0xFFFEF9C3)),
                    _TierBadge('💎', 'Diamond', '2000+', AC.violetL),
                  ],
                )),
              )),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // List
              if (board.isEmpty) const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(children: [
                    Text('🏅', style: TextStyle(fontSize: 60)),
                    SizedBox(height: 12),
                    Text('No scores yet!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AC.text1)),
                    Text('Log activities to get on the board', style: TextStyle(color: AC.text2)),
                  ]),
                )),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(delegate: SliverChildBuilderDelegate((context, i) {
                  final e = board[i];
                  final isMe = e.uid == uid;
                  return FadeSlide(
                    delay: (i * 40).clamp(0, 400),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: PCard(
                        color: isMe ? AC.violetL : null,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(children: [
                          // Rank
                          SizedBox(width: 36, child: i < 3
                            ? Text(['🥇','🥈','🥉'][i], style: const TextStyle(fontSize: 22))
                            : Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(color: AC.violetL, borderRadius: BorderRadius.circular(8)),
                                child: Center(child: Text('#${i+1}', style: const TextStyle(fontWeight: FontWeight.w800, color: AC.violet, fontSize: 11))))),
                          const SizedBox(width: 10),
                          // Avatar
                          Container(width: 38, height: 38,
                            decoration: BoxDecoration(gradient: isMe ? AC.gHero : AC.gOcean, borderRadius: BorderRadius.circular(12)),
                            child: Center(child: Text(e.fullName.isNotEmpty ? e.fullName[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(e.fullName, style: TextStyle(fontWeight: FontWeight.w700, color: isMe ? AC.violet : AC.text1)),
                            Text('${e.activitiesCompleted} activities', style: const TextStyle(color: AC.text2, fontSize: 11)),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('${e.totalPoints}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isMe ? AC.violet : AC.amber)),
                            const Text('pts', style: TextStyle(color: AC.text3, fontSize: 10)),
                          ]),
                          const SizedBox(width: 6),
                          Text(e.tierEmoji, style: const TextStyle(fontSize: 20)),
                        ]),
                      ),
                    ),
                  );
                }, childCount: board.length)),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<UserPoints> top3;
  const _Podium({required this.top3});
  @override
  Widget build(BuildContext context) {
    final order = [1, 0, 2];
    final heights = [90.0, 120.0, 70.0];
    final gradients = [AC.gLavender, AC.gGold, AC.gSunset];
    final medals = ['🥈', '🥇', '🥉'];
    return SizedBox(
      height: 210,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: order.map((idx) {
        if (idx >= top3.length) return const Expanded(child: SizedBox());
        final u = top3[idx];
        final orderIdx = order.indexOf(idx);
        return Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text(medals[orderIdx], style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          Text(u.fullName.split(' ').first, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AC.text1), overflow: TextOverflow.ellipsis),
          Text('${u.totalPoints} pts', style: TextStyle(fontSize: 11, color: idx == 0 ? AC.amber : AC.text2, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            height: heights[orderIdx],
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: gradients[orderIdx],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Center(child: Text('#${idx + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
          ),
        ]));
      }).toList()),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final String emoji, name, pts;
  final Color color;
  const _TierBadge(this.emoji, this.name, this.pts, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: AC.text1)),
      Text(pts, style: const TextStyle(fontSize: 9, color: AC.text2)),
    ]),
  );
}
