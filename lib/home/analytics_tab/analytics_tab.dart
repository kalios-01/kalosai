import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Current Weight',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          // Weight Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '119 lbs',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Try to update once a week so we can adjust your plan to ensure you hit your goal.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('Log weight'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Your BMI',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          // BMI Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Your weight is ',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Healthy',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.info_outline, color: Colors.black38, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '19.8',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                // BMI Range Bar
                _BmiRangeBar(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _BmiLegend(color: Color(0xFF38BDF8), label: 'Underweight'),
                    _BmiLegend(color: Color(0xFF22C55E), label: 'Healthy'),
                    _BmiLegend(color: Color(0xFFFACC15), label: 'Overweight'),
                    _BmiLegend(color: Color(0xFFF43F5E), label: 'Obese'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Goal Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Goal Progress',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              Text(
                '0.0% Goal achieved',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Segmented control
          _GoalProgressTabs(),
          const SizedBox(height: 16),
          // Weight Progress Chart
          _WeightProgressChart(),
        ],
      ),
    );
  }
}

class _BmiRangeBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Stack(
        children: [
          Row(
            children: [
              _BmiRangeSegment(color: const Color(0xFF38BDF8), flex: 2),
              _BmiRangeSegment(color: const Color(0xFF22C55E), flex: 4),
              _BmiRangeSegment(color: const Color(0xFFFACC15), flex: 2),
              _BmiRangeSegment(color: const Color(0xFFF43F5E), flex: 2),
            ],
          ),
          // BMI marker
          Positioned(
            left:
                MediaQuery.of(context).size.width * 0.5 -
                20, // Centered for mock
            top: 0,
            bottom: 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BmiRangeSegment extends StatelessWidget {
  final Color color;
  final int flex;
  const _BmiRangeSegment({required this.color, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(height: 8, color: color),
    );
  }
}

class _BmiLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _BmiLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _GoalProgressTabs extends StatefulWidget {
  @override
  State<_GoalProgressTabs> createState() => _GoalProgressTabsState();
}

class _GoalProgressTabsState extends State<_GoalProgressTabs> {
  int _selected = 0;
  final List<String> _tabs = ['90 Days', '6 Months', '1 Year', 'All time'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_tabs.length, (i) {
        final bool selected = i == _selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? Colors.white : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: selected
                    ? Border.all(color: Colors.black, width: 1.5)
                    : null,
              ),
              child: Center(
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: selected ? Colors.black : Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _WeightProgressChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mock data for the chart
    final List<FlSpot> spots = [const FlSpot(0, 119)];
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minY: 118,
          maxY: 120,
          minX: 0,
          maxX: 4,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.4,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: const Color(0xFFE5E7EB), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${(value).toStringAsFixed(1)} lbs',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) => const Padding(
                  padding: EdgeInsets.only(top: 8),
      child: Text(
                    '15 Jul',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: Colors.black,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: 6,
                      color: Colors.white,
                      strokeWidth: 3,
                      strokeColor: Colors.black,
                    ),
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
} 
