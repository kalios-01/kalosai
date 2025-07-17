import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'profile_setup_model.dart';

class WorkoutsStep extends StatelessWidget {
  final ProfileSetupModel model;
  final VoidCallback onContinue;
  final ValueChanged<int> onWorkoutsSelected;
  final int? selectedWorkouts;
  const WorkoutsStep({
    Key? key,
    required this.model,
    required this.onContinue,
    required this.onWorkoutsSelected,
    this.selectedWorkouts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_WorkoutOption> options = [
      _WorkoutOption(
        label: '0 - 2',
        subtitle: 'Workouts now and then',
        value: 2,
        iconPath: 'assets/icons/dot.svg',
      ),
      _WorkoutOption(
        label: '3 - 5',
        subtitle: 'A few workouts per week',
        value: 5,
        iconPath: 'assets/icons/ellipsis.svg',
      ),
      _WorkoutOption(
        label: '6+',
        subtitle: 'Dedicated athlete',
        value: 6,
        iconPath: 'assets/icons/grip.svg',
      ),
    ];
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
                'Workouts per week',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This will be used to calibrate your custom plan.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in options) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _OptionButton(
                      label: option.label,
                      subtitle: option.subtitle,
                      selected: selectedWorkouts == option.value,
                      onTap: () => onWorkoutsSelected(option.value),
                      iconPath: option.iconPath,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedWorkouts != null ? onContinue : null,
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
              child: const Text('Continue'),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? iconPath;
  const _OptionButton({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: selected ? Colors.black : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (iconPath != null)
              Container(
                margin: const EdgeInsets.only(left: 8, right: 16),
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(iconPath!, width: 24, height: 24),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: selected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      color: selected ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutOption {
  final String label;
  final String subtitle;
  final int value;
  final String iconPath;
  const _WorkoutOption({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.iconPath,
  });
}
