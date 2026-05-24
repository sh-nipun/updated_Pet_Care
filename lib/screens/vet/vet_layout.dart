// lib/screens/vet/vet_layout.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'vet_dashboard.dart';
import 'vet_appointments.dart';
import 'vet_profile_setup.dart';

class VetLayout extends StatefulWidget {
  final String uid;
  const VetLayout({super.key, required this.uid});
  @override
  State<VetLayout> createState() => _VetLayoutState();
}

class _VetLayoutState extends State<VetLayout> {
  int _idx = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      VetDashboard(uid: widget.uid),
      VetAppointments(uid: widget.uid),
      VetProfileSetup(uid: widget.uid),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AC.violet,
        unselectedItemColor: AC.text3,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'My Profile'),
        ],
      ),
    );
  }
}
