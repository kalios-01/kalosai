import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_setup_provider.dart';
import '../google_signin_screen.dart';
import 'package:flutter/cupertino.dart';

class ProfileSetupFlow extends StatefulWidget {
  const ProfileSetupFlow({super.key});

  @override
  State<ProfileSetupFlow> createState() => _ProfileSetupFlowState();
}

class _ProfileSetupFlowState extends State<ProfileSetupFlow> {
  int _step = 0;
  final int _totalSteps = 4;
  bool _finished = false;

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() {
        _step++;
      });
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() {
        _step--;
      });
    }
  }

  void _onFinish() async {
    setState(() {
      _finished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileSetupProvider>(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: (_step > 0 && !_finished)
            ? IconButton(
                icon: const Icon(Icons.arrow_back,color: Colors.black,),
                onPressed: _back,
              )
            : null,
        title: Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: (_step + 1) / _totalSteps,
                backgroundColor: Colors.grey[200],
                color: Colors.black,
              ),
            ),
            // const SizedBox(width: 12),
            // Text(
            //   '${_step + 1}/$_totalSteps',
            //   style: theme.textTheme.bodyLarge,
            // ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: IndexedStack(
            index: _step,
            children: [
              _GenderStep(onNext: _next),
              _HeightWeightStep(onNext: _next, onBack: _back),
              _BirthdateStep(onNext: _next, onBack: _back),
              _WorkoutFrequencyStep(
                onFinish: () async {
                  final success = await provider.submitProfile(context);
                  if (success && mounted) {
                    _onFinish();
                    // After finish, navigate and prevent going back
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => GoogleSignInScreen()),
                      (route) => false,
                    );
                  }
                },
                onBack: _back,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderStep extends StatefulWidget {
  final VoidCallback onNext;
  const _GenderStep({required this.onNext});
  @override
  State<_GenderStep> createState() => _GenderStepState();
}

class _GenderStepState extends State<_GenderStep> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileSetupProvider>(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose your Gender', style: theme.textTheme.displayMedium),
        const SizedBox(height: 8),
        Text('This will be used to calibrate your custom plan.', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 32),
        ...['Male', 'Female', 'Other'].map((g) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedGender = g;
              });
              provider.setGender(g);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: _selectedGender == g ? Colors.black : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedGender == g ? Colors.black : Colors.transparent, width: 2),
              ),
              child: Center(
                child: Text(g, style: TextStyle(color: _selectedGender == g ? Colors.white : Colors.black, fontSize: 18)),
              ),
            ),
          ),
        )),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedGender != null ? widget.onNext : null,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WorkoutFrequencyStep extends StatefulWidget {
  final VoidCallback onFinish;
  final VoidCallback onBack;
  const _WorkoutFrequencyStep({required this.onFinish, required this.onBack});

  @override
  State<_WorkoutFrequencyStep> createState() => _WorkoutFrequencyStepState();
}

class _WorkoutFrequencyStepState extends State<_WorkoutFrequencyStep> {
  String? _selectedFrequency;

  final Map<String, String> options = {
    '0 - 2': 'Workouts now and then',
    '3 - 5': 'A few workouts per week',
    '6+': 'Dedicated athlete',
  };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileSetupProvider>(context, listen: false);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How many workouts do you do per week?', style: theme.textTheme.displayMedium),
        const SizedBox(height: 8),
        Text('This will be used to calibrate your custom plan.', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 32),
        ...options.entries.map((entry) {
          final key = entry.key;
          final value = entry.value;
          final isSelected = _selectedFrequency == key;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFrequency = key;
                });
                provider.setActivityLevel(key);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    _buildIconForKey(key, isSelected),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedFrequency != null ? widget.onFinish : null,
                child: const Text('Finish'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconForKey(String key, bool isSelected) {
    Widget icon;
    Color color = isSelected ? Colors.white : Colors.black;

    switch (key) {
      case '0 - 2':
        icon = Icon(Icons.circle, size: 10, color: color);
        break;
      case '3 - 5':
        icon = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.circle, size: 5, color: color),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 5, color: color),
                const SizedBox(width: 2),
                Icon(Icons.circle, size: 5, color: color),
              ],
            )
          ],
        );
        break;
      case '6+':
        icon = Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
              3,
              (rowIndex) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        3,
                        (colIndex) => Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Icon(Icons.circle, size: 4, color: color),
                            )),
                  )),
        );
        break;
      default:
        icon = const SizedBox.shrink();
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.15) : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Center(child: icon),
    );
  }
}

class _HeightWeightStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _HeightWeightStep({required this.onNext, required this.onBack});
  @override
  State<_HeightWeightStep> createState() => _HeightWeightStepState();
}

class _HeightWeightStepState extends State<_HeightWeightStep> {
  bool isMetric = true;
  int heightCm = 165;
  int heightFt = 5;
  int heightIn = 5;
  int weightKg = 54;
  int weightLb = 119;

  FixedExtentScrollController? _heightCmController;
  FixedExtentScrollController? _heightFtController;
  FixedExtentScrollController? _heightInController;
  FixedExtentScrollController? _weightKgController;
  FixedExtentScrollController? _weightLbController;

  @override
  void initState() {
    super.initState();
    _heightCmController = FixedExtentScrollController(initialItem: heightCm - 140);
    _heightFtController = FixedExtentScrollController(initialItem: heightFt - 3);
    _heightInController = FixedExtentScrollController(initialItem: heightIn);
    _weightKgController = FixedExtentScrollController(initialItem: weightKg - 40);
    _weightLbController = FixedExtentScrollController(initialItem: weightLb - 80);
  }

  @override
  void dispose() {
    _heightCmController?.dispose();
    _heightFtController?.dispose();
    _heightInController?.dispose();
    _weightKgController?.dispose();
    _weightLbController?.dispose();
    super.dispose();
  }

  Widget _buildPickerItem(String text, bool selected) {
    return Container(
      alignment: Alignment.center,
      child: selected
          ? Container(
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileSetupProvider>(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Height & Weight', style: theme.textTheme.displayMedium),
        const SizedBox(height: 8),
        Text('This will be used to calibrate your custom plan.', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isMetric = false;
                });
              },
              child: Text(
                'Imperial',
                style: TextStyle(
                  fontWeight: !isMetric ? FontWeight.bold : FontWeight.normal,
                  color: !isMetric ? Colors.black : Colors.grey,
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Switch(
                value: isMetric,
                onChanged: (val) {
                  setState(() {
                    isMetric = val;
                  });
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isMetric = true;
                });
              },
              child: Text(
                'Metric',
                style: TextStyle(
                  fontWeight: isMetric ? FontWeight.bold : FontWeight.normal,
                  color: isMetric ? Colors.black : Colors.grey,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Height pickers
            Column(
              children: [
                Text('Height', style: theme.textTheme.bodyLarge),
                Row(
                  children: isMetric
                      ? [
                          SizedBox(
                            height: 150,
                            width: 100,
                            child: CupertinoPicker(
                              scrollController: _heightCmController,
                              itemExtent: 56,
                              diameterRatio: 100,
                              useMagnifier: false,
                              magnification: 1.0,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  heightCm = 140 + index;
                                  provider.setHeight(heightCm.toDouble());
                                });
                              },
                              selectionOverlay: Container(),
                              children: List.generate(101, (i) {
                                int val = 140 + i;
                                return _buildPickerItem('$val cm', heightCm == val);
                              }),
                            ),
                          ),
                        ]
                      : [
                          SizedBox(
                            height: 150,
                            width: 70,
                            child: CupertinoPicker(
                              scrollController: _heightFtController,
                              itemExtent: 56,
                              diameterRatio: 100,
                              useMagnifier: false,
                              magnification: 1.0,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  heightFt = 3 + index;
                                  provider.setHeight((heightFt * 12 + heightIn) * 2.54); // store as cm
                                });
                              },
                              selectionOverlay: Container(),
                              children: List.generate(5, (i) {
                                int val = 3 + i;
                                return _buildPickerItem('$val ft', heightFt == val);
                              }),
                            ),
                          ),
                          SizedBox(width: 16),
                          SizedBox(
                            height: 150,
                            width: 70,
                            child: CupertinoPicker(
                              scrollController: _heightInController,
                              itemExtent: 56,
                              diameterRatio: 100,
                              useMagnifier: false,
                              magnification: 1.0,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  heightIn = index;
                                  provider.setHeight((heightFt * 12 + heightIn) * 2.54); // store as cm
                                });
                              },
                              selectionOverlay: Container(),
                              children: List.generate(12, (i) {
                                return _buildPickerItem('$i in', heightIn == i);
                              }),
                            ),
                          ),
                        ],
                ),
              ],
            ),
            SizedBox(width: 32), // Space between height and weight pickers
            // Weight picker
            Column(
              children: [
                Text('Weight', style: theme.textTheme.bodyLarge),
                SizedBox(
                  height: 150,
                  width: 100,
                  child: CupertinoPicker(
                    scrollController: isMetric ? _weightKgController : _weightLbController,
                    itemExtent: 56,
                    diameterRatio: 100,
                    useMagnifier: false,
                    magnification: 1.0,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        if (isMetric) {
                          weightKg = 40 + index;
                          provider.setWeight(weightKg.toDouble());
                        } else {
                          weightLb = 80 + index;
                          provider.setWeight(weightLb.toDouble());
                        }
                      });
                    },
                    children: isMetric
                        ? List.generate(101, (i) {
                            int val = 40 + i;
                            return _buildPickerItem('$val kg', weightKg == val);
                          })
                        : List.generate(121, (i) {
                            int val = 80 + i;
                            return _buildPickerItem('$val lb', weightLb == val);
                          }),
                    selectionOverlay: Container(),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: (isMetric
                        ? provider.height != null && provider.weight != null
                        : provider.height != null && provider.weight != null)
                    ? widget.onNext
                    : null,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BirthdateStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _BirthdateStep({required this.onNext, required this.onBack});
  @override
  State<_BirthdateStep> createState() => _BirthdateStepState();
}

class _BirthdateStepState extends State<_BirthdateStep> {
  DateTime selectedDate = DateTime(DateTime.now().year - 18, 1, 1);

  final List<String> months = const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  int get selectedMonth => selectedDate.month;
  int get selectedDay => selectedDate.day;
  int get selectedYear => selectedDate.year;

  int get daysInMonth => DateTime(selectedYear, selectedMonth + 1, 0).day;

  Widget _buildDatePickerItem(String text, bool selected) {
    return Container(
      alignment: Alignment.center,
      decoration: selected
          ? BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  void _onMonthChanged(int index) {
    setState(() {
      int newMonth = index + 1;
      int newDay = selectedDay > DateTime(selectedYear, newMonth + 1, 0).day
          ? DateTime(selectedYear, newMonth + 1, 0).day
          : selectedDay;
      selectedDate = DateTime(selectedYear, newMonth, newDay);
      Provider.of<ProfileSetupProvider>(context, listen: false).setBirthDate(selectedDate);
    });
  }

  void _onDayChanged(int index) {
    setState(() {
      int newDay = index + 1;
      selectedDate = DateTime(selectedYear, selectedMonth, newDay);
      Provider.of<ProfileSetupProvider>(context, listen: false).setBirthDate(selectedDate);
    });
  }

  void _onYearChanged(int index) {
    setState(() {
      int newYear = DateTime.now().year - 10 - index;
      int newDay = selectedDay > DateTime(newYear, selectedMonth + 1, 0).day
          ? DateTime(newYear, selectedMonth + 1, 0).day
          : selectedDay;
      selectedDate = DateTime(newYear, selectedMonth, newDay);
      Provider.of<ProfileSetupProvider>(context, listen: false).setBirthDate(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileSetupProvider>(context);
    final theme = Theme.of(context);
    int yearStart = 1900;
    int yearEnd = DateTime.now().year - 10;
    int yearCount = yearEnd - yearStart + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('When were you born?', style: theme.textTheme.displayMedium),
        const SizedBox(height: 8),
        Text('This will be used to calibrate your custom plan.', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 32),
        Center(
          child: SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: selectedMonth - 1),
                    itemExtent: 56,
                    diameterRatio: 100,
                    useMagnifier: false,
                    magnification: 1.0,
                    selectionOverlay: Container(),
                    onSelectedItemChanged: _onMonthChanged,
                    children: List.generate(12, (i) => _buildDatePickerItem(months[i], selectedMonth - 1 == i)),
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 70,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: selectedDay - 1),
                    itemExtent: 56,
                    diameterRatio: 100,
                    useMagnifier: false,
                    magnification: 1.0,
                    selectionOverlay: Container(),
                    onSelectedItemChanged: _onDayChanged,
                    children: List.generate(daysInMonth, (i) => _buildDatePickerItem((i + 1).toString().padLeft(2, '0'), selectedDay - 1 == i)),
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 90,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: yearEnd - selectedYear),
                    itemExtent: 56,
                    diameterRatio: 100,
                    useMagnifier: false,
                    magnification: 1.0,
                    selectionOverlay: Container(),
                    onSelectedItemChanged: _onYearChanged,
                    children: List.generate(yearCount, (i) {
                      int val = yearEnd - i;
                      return _buildDatePickerItem(val.toString(), selectedYear == val);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: provider.birthDate != null ? widget.onNext : null,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 