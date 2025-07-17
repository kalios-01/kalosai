import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _tabViews = [
    _HomeTab(),
    Center(child: Text('Analytics', style: TextStyle(fontFamily: 'Manrope', fontSize: 22))),
    Center(child: Text('Friends', style: TextStyle(fontFamily: 'Manrope', fontSize: 22))),
    Center(child: Text('Profile', style: TextStyle(fontFamily: 'Manrope', fontSize: 22))),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black38,
        selectedLabelStyle: const TextStyle(fontFamily: 'Manrope'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Manrope'),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Spacer(),
              Text(
                'Today',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Calories',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SizedBox(),
              Text(
                '1,800 / 3,000',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 1800 / 3000,
            backgroundColor: Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            minHeight: 8,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(height: 8),
          const Text(
            '1,200 remaining',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Meals',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _MealTile(icon: Icons.lunch_dining, title: 'Oatmeal with Berries', subtitle: 'Breakfast', calories: 350),
          _MealTile(icon: Icons.lunch_dining, title: 'Chicken Salad Sandwich', subtitle: 'Lunch', calories: 500),
          _MealTile(icon: Icons.set_meal, title: 'Salmon with Roasted Vegetables', subtitle: 'Dinner', calories: 700),
          _MealTile(icon: Icons.add, title: 'Add Meal', subtitle: '', calories: null, isAdd: true),
          const SizedBox(height: 24),
          const Text(
            'Exercises',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _MealTile(icon: Icons.directions_run, title: '30-minute Run', subtitle: 'Morning', calories: 250),
          _MealTile(icon: Icons.spa, title: 'Yoga Session', subtitle: 'Evening', calories: 150),
          _MealTile(icon: Icons.add, title: 'Add Exercise', subtitle: '', calories: null, isAdd: true),
        ],
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int? calories;
  final bool isAdd;
  const _MealTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.calories,
    this.isAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      color: Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
          ),
          if (calories != null)
            Text(
              calories.toString(),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
} 