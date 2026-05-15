import 'package:flutter/material.dart';
import 'package:app_silacak/routes/routes.dart';

class BottomTabbar extends StatefulWidget {
  final int currentIndex;

  const BottomTabbar({
    super.key,
    required this.currentIndex,
  });

  @override
  State<BottomTabbar> createState() =>
      _BottomTabbarState();
}

class _BottomTabbarState
    extends State<BottomTabbar> {

  // ====================================
  // NAVIGATION FIX
  // ====================================
  void _onItemTapped(int index) {

    // 🔥 FIX BUG
    if (index == widget.currentIndex) return;

    String route = Routes.home;

    switch (index) {

      case 0:
        route = Routes.home;
        break;

      case 1:
        route = Routes.history;
        break;

      case 2:
        route = Routes.tracking;
        break;

      case 3:
        route = Routes.modules;
        break;

      case 4:
        route = Routes.account;
        break;
    }

    // 🔥 FIX BUG NAVIGATION
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.fromLTRB(
        14,
        0,
        14,
        14,
      ),

      decoration: BoxDecoration(

        // ========================
        // MODERN BLUE STYLE
        // ========================
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1D4ED8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius:
            BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color:
                Colors.blue.withOpacity(0.25),

            blurRadius: 20,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(24),

        child: BottomNavigationBar(

          // ========================
          // STYLE
          // ========================
          backgroundColor:
              Colors.transparent,

          elevation: 0,

          currentIndex:
              widget.currentIndex,

          type:
              BottomNavigationBarType.fixed,

          showUnselectedLabels: true,

          selectedItemColor:
              Colors.white,

          unselectedItemColor:
              Colors.white70,

          selectedLabelStyle:
              const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),

          unselectedLabelStyle:
              const TextStyle(
            fontSize: 11,
          ),

          onTap: _onItemTapped,

          // ========================
          // ITEMS
          // ========================
          items: [

            // HOME
            BottomNavigationBarItem(
              icon: _buildIcon(
                icon:
                    Icons.home_rounded,
                index: 0,
              ),

              label: 'Beranda',
            ),

            // HISTORY
            BottomNavigationBarItem(
              icon: _buildIcon(
                icon:
                    Icons.history_rounded,
                index: 1,
              ),

              label: 'Riwayat',
            ),

            // TRACKING
            BottomNavigationBarItem(
              icon: _buildIcon(
                icon:
                    Icons.location_on_rounded,
                index: 2,
              ),

              label: 'Lacak',
            ),

            // MODULE
            BottomNavigationBarItem(
              icon: _buildIcon(
                icon:
                    Icons.two_wheeler,
                index: 3,
              ),

              label: 'Modul',
            ),

            // ACCOUNT
            BottomNavigationBarItem(
              icon: _buildIcon(
                icon:
                    Icons.person_rounded,
                index: 4,
              ),

              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }

  // ====================================
  // MODERN ACTIVE ICON
  // ====================================
  Widget _buildIcon({
    required IconData icon,
    required int index,
  }) {

    final bool isSelected =
        widget.currentIndex == index;

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 250),

      padding:
          const EdgeInsets.all(10),

      decoration: BoxDecoration(

        color: isSelected
            ? Colors.white.withOpacity(0.18)
            : Colors.transparent,

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Icon(
        icon,

        size: isSelected ? 28 : 24,

        color: isSelected
            ? Colors.white
            : Colors.white70,
      ),
    );
  }
}