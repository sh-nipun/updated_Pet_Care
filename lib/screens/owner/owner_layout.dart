// lib/screens/owner/owner_layout.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'owner_dashboard.dart';
import 'owner_pets_screen.dart';
import 'owner_book_appointment.dart';
import 'owner_health_screen.dart';
import 'owner_profile_screen.dart';

class OwnerLayout extends StatefulWidget {
  final String uid;
  const OwnerLayout({super.key, required this.uid});
  @override
  State<OwnerLayout> createState() => _OwnerLayoutState();
}

class _OwnerLayoutState extends State<OwnerLayout> {
  int _idx = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      OwnerDashboard(uid: widget.uid, onNavigate: (i) => setState(() => _idx = i)),
      OwnerPetsScreen(uid: widget.uid),
      OwnerBookAppointment(uid: widget.uid),
      OwnerHealthScreen(uid: widget.uid),
      OwnerProfileScreen(uid: widget.uid),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AC.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: AC.violet,
          unselectedItemColor: AC.text3,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.pets_outlined), activeIcon: Icon(Icons.pets), label: 'Pets'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Book'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Health'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
