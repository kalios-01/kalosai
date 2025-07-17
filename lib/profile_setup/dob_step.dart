import 'package:flutter/material.dart';

import 'profile_setup_model.dart';

class DOBStep extends StatefulWidget {
  final ProfileSetupModel model;
  final VoidCallback onContinue;
  const DOBStep({Key? key, required this.model, required this.onContinue})
    : super(key: key);

  @override
  State<DOBStep> createState() => _DOBStepState();
}

class _DOBStepState extends State<DOBStep> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  static const int minYear = 1900;
  static final int maxYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    final dob = widget.model.dob ?? DateTime(maxYear - 10, 1, 1);
    _selectedYear = dob.year;
    _selectedMonth = dob.month;
    _selectedDay = dob.day;
  }

  void _onSelectedYear(int index) {
    setState(() {
      _selectedYear = maxYear - index;
      _selectedDay = _selectedDay.clamp(
        1,
        _daysInMonth(_selectedYear, _selectedMonth),
      );
    });
  }

  void _onSelectedMonth(int index) {
    setState(() {
      _selectedMonth = index + 1;
      _selectedDay = _selectedDay.clamp(
        1,
        _daysInMonth(_selectedYear, _selectedMonth),
      );
    });
  }

  void _onSelectedDay(int index) {
    setState(() {
      _selectedDay = index + 1;
    });
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void _save() {
    widget.model.dob = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    widget.onContinue();
  }

  Widget _buildFlatWheel({
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onSelectedItemChanged,
    required double width,
  }) {
    return SizedBox(
      width: width,
      height: 150,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 38,
        perspective: 0.0001,
        squeeze: 1,
        physics: const FixedExtentScrollPhysics(),
        overAndUnderCenterOpacity: 0.2,
        onSelectedItemChanged: onSelectedItemChanged,
        controller: FixedExtentScrollController(initialItem: selectedIndex),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (context, index) {
            final isSelected = index == selectedIndex;
            return Center(
              child: Container(
                decoration: isSelected
                    ? BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  items[index],
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isSelected ? Colors.black : Colors.grey.shade400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final months = List<String>.generate(12, (i) => _monthName(i + 1));
    final days = List<String>.generate(
      _daysInMonth(_selectedYear, _selectedMonth),
      (i) => (i + 1).toString().padLeft(2, '0'),
    );
    final years = List<String>.generate(
      maxYear - minYear + 1,
      (i) => (maxYear - i).toString(),
    );
    final monthIndex = _selectedMonth - 1;
    final dayIndex = _selectedDay - 1;
    final yearIndex = maxYear - _selectedYear;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'When were you born?',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'This will be used to calibrate your custom plan.',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFlatWheel(
                    items: months,
                    selectedIndex: monthIndex,
                    onSelectedItemChanged: _onSelectedMonth,
                    width: 120,
                  ),
                  const SizedBox(width: 8),
                  _buildFlatWheel(
                    items: days,
                    selectedIndex: dayIndex,
                    onSelectedItemChanged: _onSelectedDay,
                    width: 80,
                  ),
                  const SizedBox(width: 8),
                  _buildFlatWheel(
                    items: years,
                    selectedIndex: yearIndex,
                    onSelectedItemChanged: _onSelectedYear,
                    width: 100,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                child: const Text('Next'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }
}
