import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_tab/cal_home_tab.dart';
import 'analytics_tab/analytics_tab.dart';
import 'leaderboard_tab/leaderboard_tab.dart';
import 'friends_tab/friends_tab.dart';
import 'profile_tab/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _tabViews = [
    CalHomeTab(),
    AnalyticsTab(),
    LeaderboardTab(),
    FriendsTab(),
    ProfileTab(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _tabViews[_selectedIndex]),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xFF64748B),
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _selectedIndex == 0
                    ? 'assets/icons/home.svg'
                    : 'assets/icons/home.svg',
                color: _selectedIndex == 0
                    ? Colors.black
                    : const Color(0xFF64748B),
                width: 28,
                height: 28,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/analytics.svg',
                color: _selectedIndex == 1
                    ? Colors.black
                    : const Color(0xFF64748B),
                width: 28,
                height: 28,
              ),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/leaderboard.svg',
                color: _selectedIndex == 2
                    ? Colors.black
                    : const Color(0xFF64748B),
                width: 28,
                height: 28,
              ),
              label: 'Ranks',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/friends.svg',
                color: _selectedIndex == 3
                    ? Colors.black
                    : const Color(0xFF64748B),
                width: 28,
                height: 28,
              ),
              label: 'Friends',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/profile.svg',
                color: _selectedIndex == 4
                    ? Colors.black
                    : const Color(0xFF64748B),
                width: 28,
                height: 28,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
