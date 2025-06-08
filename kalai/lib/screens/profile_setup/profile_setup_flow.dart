import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_setup_provider.dart';
import '../home_screen.dart';

class ProfileSetupFlow extends StatefulWidget {
  const ProfileSetupFlow({super.key});

  @override
  State<ProfileSetupFlow> createState() => _ProfileSetupFlowState();
}

class _ProfileSetupFlowState extends State<ProfileSetupFlow> {
  int _step = 0;

  void _next() {
    setState(() {
      _step++;
    });
  }

  void _back() {
    if (_step > 0) {
      setState(() {
        _step--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileSetupProvider>(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _back,
              )
            : null,
        title: LinearProgressIndicator(
          value: (_step + 1) / 4,
          backgroundColor: Colors.grey[200],
          color: Colors.black,
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: IndexedStack(
            index: _step,
            children: [
              _GenderStep(onNext: _next),
              _WorkoutsStep(onNext: _next, onBack: _back),
              _HeightWeightStep(onNext: _next, onBack: _back),
              _BirthdateStep(onFinish: () async {
                final success = await provider.submitProfile(context);
                if (success && mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                    (route) => false,
                  );
                }
              }, onBack: _back),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderStep extends StatelessWidget {
  final VoidCallback onNext;
  const _GenderStep({required this.onNext});
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
              provider.setGender(g);
              onNext();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: provider.gender == g ? Colors.black : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: provider.gender == g ? Colors.black : Colors.transparent, width: 2),
              ),
              child: Center(
                child: Text(g, style: TextStyle(color: provider.gender == g ? Colors.white : Colors.black, fontSize: 18)),
              ),
            ),
          ),
        )),
      ],
    );
  }
}

class _WorkoutsStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _WorkoutsStep({required this.onNext, required this.onBack});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileSetupProvider>(context);
    final theme = Theme.of(context);
    final options = [
      {'label': '0 - 2', 'desc': 'Workouts now and then', 'value': 2},
      {'label': '3 - 5', 'desc': 'A few workouts per week', 'value': 5},
      {'label': '6+', 'desc': 'Dedicated athlete', 'value': 6},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How many workouts do you do per week?', style: theme.textTheme.displayMedium),
        const SizedBox(height: 8),
        Text('This will be used to calibrate your custom plan.', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 32),
        ...options.map((opt) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              provider.setWorkouts(opt['value'] as int);
              onNext();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: provider.workoutsPerWeek == opt['value'] ? Colors.black : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: provider.workoutsPerWeek == opt['value'] ? Colors.black : Colors.transparent, width: 2),
              ),
              child: Column(
                children: [
                  Text(opt['label'] as String, style: TextStyle(color: provider.workoutsPerWeek == opt['value'] ? Colors.white : Colors.black, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(opt['desc'] as String, style: TextStyle(color: provider.workoutsPerWeek == opt['value'] ? Colors.white70 : Colors.black54)),
                ],
              ),
            ),
          ),
        )),
      ],
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
  double height = 165;
  double weight = 54;

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
                  provider.setUnit('imperial');
                  height = 65.0; // default for imperial
                  weight = 110.0;  // Changed default imperial weight to 110.0
                  provider.setHeight(height);
                  provider.setWeight(weight);
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
                    provider.setUnit(isMetric ? 'metric' : 'imperial');
                    height = isMetric ? 165.0 : 65.0;
                    weight = isMetric ? 54.0 : 110.0;  // Changed default imperial weight to 110.0
                    provider.setHeight(height);
                    provider.setWeight(weight);
                  });
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isMetric = true;
                  provider.setUnit('metric');
                  height = 165.0; // default for metric
                  weight = 54.0;
                  provider.setHeight(height);
                  provider.setWeight(weight);
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
          children: [
            Column(
              children: [
                Text('Height', style: theme.textTheme.bodyLarge),
                DropdownButton<double>(
                  value: height,
                  items: (isMetric
                          ? List.generate(21, (i) => 150.0 + i)
                          : List.generate(21, (i) => 59.0 + i))
                      .map((val) => DropdownMenuItem(
                            value: val,
                            child: Text(isMetric ? '${val.toInt()} cm' : '${val.toInt()} in'),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        height = val;
                        provider.setHeight(val);
                      });
                    }
                  },
                ),
              ],
            ),
            Column(
              children: [
                Text('Weight', style: theme.textTheme.bodyLarge),
                DropdownButton<double>(
                  value: weight,
                  items: (isMetric
                          ? List.generate(21, (i) => 40.0 + i)
                          : List.generate(31, (i) => 90.0 + i))  // Changed to 31 items to include up to 120
                      .map((val) => DropdownMenuItem(
                            value: val,
                            child: Text(isMetric ? '${val.toInt()} kg' : '${val.toInt()} lb'),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        weight = val;
                        provider.setWeight(val);
                      });
                    }
                  },
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
                onPressed: (provider.height != null && provider.weight != null)
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
  final VoidCallback onFinish;
  final VoidCallback onBack;
  const _BirthdateStep({required this.onFinish, required this.onBack});
  @override
  State<_BirthdateStep> createState() => _BirthdateStepState();
}

class _BirthdateStepState extends State<_BirthdateStep> {
  DateTime selectedDate = DateTime(DateTime.now().year - 18, 1, 1);
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileSetupProvider>(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('When were you born?', style: theme.textTheme.displayMedium),
        const SizedBox(height: 8),
        Text('This will be used to calibrate your custom plan.', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 32),
        Center(
          child: SizedBox(
            width: 300,
            child: CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: DateTime(1900),
              lastDate: DateTime(DateTime.now().year - 10),
              onDateChanged: (date) {
                setState(() {
                  selectedDate = date;
                  provider.setBirthDate(date);
                });
              },
            ),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: provider.birthDate != null ? widget.onFinish : null,
                child: const Text('Finish'),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 