import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

class CalHomeTab extends StatefulWidget {
  const CalHomeTab({Key? key}) : super(key: key);

  @override
  State<CalHomeTab> createState() => _CalHomeTabState();
}

class _CalHomeTabState extends State<CalHomeTab> {
  final PageController _pageController = PageController();
  final int _pageCount = 2; // Now two pages

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF), // white at the top
                Color(0xFFF3F4F6), // very light grey in the middle
                Color(0xFFFFFFFF), // white at the bottom
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/home/kalos_icon.svg',
                          width: 28,
                          height: 28,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'KALOS AI',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/fire.svg',
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '0',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DateSelector(),
                const SizedBox(height: 20),
                // Slider for stats and macros
                SizedBox(
                  height: 340,
                  child: PageView(
                    controller: _pageController,
                    children: [
                      // First page: main stats and macros
                      Column(
                        children: [
                MainStatsCard(),
                const SizedBox(height: 16),
                Row(
                  children: const [
                              Expanded(
                                child: MacroCard(
                                  label: 'Protein',
                                  value: '0g',
                                  icon: 'assets/icons/home/protien.svg',
                                ),
                              ),
                    SizedBox(width: 8),
                              Expanded(
                                child: MacroCard(
                                  label: 'Carbs',
                                  value: '0g',
                                  icon: 'assets/icons/home/cabs.svg',
                                ),
                              ),
                    SizedBox(width: 8),
                              Expanded(
                                child: MacroCard(
                                  label: 'Fats',
                                  value: '0g',
                                  icon: 'assets/icons/home/fats.svg',
                                ),
                              ),
                  ],
                ),
                        ],
                      ),
                      // Second page: Steps Today and Calories Burned cards
                      Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Row(
                              children: [
                                Expanded(
                                  child: StepsTodayCard(),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/home/fire.svg',
                                              width: 20,
                                              height: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              '48',
                                              style: TextStyle(
                                                fontFamily: 'Manrope',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Calories Burned',
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: const BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  'assets/icons/home/shoe.svg',
                                                  width: 18,
                                                  height: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: const [
                                                Text(
                                                  'Steps',
                                                  style: TextStyle(
                                                    fontFamily: 'Manrope',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  '+48',
                                                  style: TextStyle(
                                                    fontFamily: 'Manrope',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement Google Health Connect permission logic
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                textStyle: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              child: const Text('Connect to Google Health'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _pageCount,
                    effect: const WormEffect(
                      dotColor: Color(0xFFD1D5DB),
                      activeDotColor: Colors.black,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // (Button moved inside StepsTodayCard)
                const Text(
                  'Recently eaten',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F6F9),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "You haven't uploaded any food",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Start tracking today's meals by taking a quick pictures",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Floating action button
        Positioned(
          right: 24,
          bottom: 24,
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.black,
            child: const Icon(Icons.add, color: Colors.white, size: 32),
            elevation: 4,
            shape: const CircleBorder(),
          ),
        ),
      ],
    );
  }
}

class DateSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final days = [
      {'label': 'T', 'date': '10'},
      {'label': 'F', 'date': '11'},
      {'label': 'S', 'date': '12'},
      {'label': 'S', 'date': '13'},
      {'label': 'M', 'date': '14'},
      {'label': 'T', 'date': '15', 'selected': true},
      {'label': 'W', 'date': '16'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final bool selected = day['selected'] == true;
        return Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? Colors.black : const Color(0xFFD1D5DB),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(19),
                color: selected ? Colors.white : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  day['label'] as String,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: selected ? Colors.black : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              day['date'] as String,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                color: selected ? Colors.black : const Color(0xFF6B7280),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class MainStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '0',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Calories over',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB), width: 4),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/home/fire.svg',
                width: 32,
                height: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const MacroCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            ' $label over',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
            ),
            child: Center(child: SvgPicture.asset(icon, width: 20, height: 20)),
          ),
        ],
      ),
    );
  }
}

// StepsTodayCard widget for the left card on the second page
class StepsTodayCard extends StatelessWidget {
  const StepsTodayCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for the bar chart
    final List<int> steps = [900, 600, 1100, 1728, 1728, 900, 200];
    final List<String> days = ['T', 'W', 'T', 'M', 'S', 'S', 'F'];
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny_outlined, color: Colors.black, size: 24),
              const SizedBox(width: 8),
              const Text(
                '1728',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Steps Today',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1800,
                minY: 0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final int idx = value.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            days[idx],
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                      reservedSize: 24,
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(steps.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: steps[i].toDouble(),
                        color: Colors.black.withOpacity(i == 3 || i == 4 ? 0.8 : 0.5),
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
