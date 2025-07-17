import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'profile_setup_model.dart';

class HeightWeightStep extends StatefulWidget {
  final ProfileSetupModel model;
  final VoidCallback onContinue;
  const HeightWeightStep({
    Key? key,
    required this.model,
    required this.onContinue,
  }) : super(key: key);

  @override
  State<HeightWeightStep> createState() => _HeightWeightStepState();
}

class _HeightWeightStepState extends State<HeightWeightStep> {
  String _unit = 'imperial';
  int _feet = 5;
  int _inches = 5;
  int _weightLb = 120;
  int _heightCm = 165;
  int _weightKg = 54;

  @override
  void initState() {
    super.initState();
    _unit = widget.model.heightUnit ?? 'imperial';
    if (_unit == 'imperial') {
      if (widget.model.height != null) {
        _feet = widget.model.height!.floor();
        _inches = (((widget.model.height! - _feet) * 12).round()).clamp(0, 11);
      }
      if (widget.model.weight != null) {
        _weightLb = widget.model.weight!.round();
      }
    } else {
      if (widget.model.height != null) {
        _heightCm = widget.model.height!.round();
      }
      if (widget.model.weight != null) {
        _weightKg = widget.model.weight!.round();
      }
    }
  }

  bool get _valid => _unit == 'imperial'
      ? _feet != null && _inches != null && _weightLb != null
      : _heightCm != null && _weightKg != null;

  void _save() {
    if (_unit == 'imperial') {
      widget.model.heightUnit = 'imperial';
      widget.model.height = _feet + _inches / 12.0;
      widget.model.weight = _weightLb.toDouble();
    } else {
      widget.model.heightUnit = 'metric';
      widget.model.height = _heightCm.toDouble();
      widget.model.weight = _weightKg.toDouble();
    }
    widget.onContinue();
  }

  Widget _buildFlatPicker({
    required List<String> values,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    return SizedBox(
      width: 72,
      height: 150,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 38,
        perspective: 0.0001,
        squeeze: 1,
        physics: const FixedExtentScrollPhysics(),
        overAndUnderCenterOpacity: 0.2,
        // ADD THIS LINE - This is the key fix!
        controller: FixedExtentScrollController(initialItem: selectedIndex),
        onSelectedItemChanged: onSelected,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: values.length,
          builder: (context, i) {
            final isSelected = i == selectedIndex;
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
                  values[i],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Height & Weight',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This will be used to calibrate your custom plan.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => _unit = 'imperial'),
                child: Text(
                  'Imperial',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _unit == 'imperial'
                        ? Colors.black
                        : Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CupertinoSwitch(
                value: _unit == 'metric',
                onChanged: (v) =>
                    setState(() => _unit = v ? 'metric' : 'imperial'),
                activeColor: Colors.black,
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _unit = 'metric'),
                child: Text(
                  'Metric',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _unit == 'metric'
                        ? Colors.black
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_unit == 'imperial') ...[
                Column(
                  children: [
                    const Text(
                      'Height',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildFlatPicker(
                          values: List.generate(5, (i) => '${i + 3} ft'),
                          selectedIndex: _feet - 3,
                          onSelected: (i) => setState(() => _feet = i + 3),
                        ),
                        const SizedBox(width: 6),
                        _buildFlatPicker(
                          values: List.generate(12, (i) => '$i in'),
                          selectedIndex: _inches,
                          onSelected: (i) => setState(() => _inches = i),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Weight',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFlatPicker(
                      values: List.generate(321, (i) => '${i + 80} lb'),
                      selectedIndex: _weightLb - 80,
                      onSelected: (i) => setState(() => _weightLb = i + 80),
                    ),
                  ],
                ),
              ] else ...[
                Column(
                  children: [
                    const Text(
                      'Height',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFlatPicker(
                      values: List.generate(151, (i) => '${i + 100} cm'),
                      selectedIndex: _heightCm - 100,
                      onSelected: (i) => setState(() => _heightCm = i + 100),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Weight',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFlatPicker(
                      values: List.generate(171, (i) => '${i + 30} kg'),
                      selectedIndex: _weightKg - 30,
                      onSelected: (i) => setState(() => _weightKg = i + 30),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _valid ? _save : null,
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
    );
  }
}
