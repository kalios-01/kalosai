import 'package:flutter/material.dart';
import 'profile_setup_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DietStep extends StatelessWidget {
  final ProfileSetupModel model;
  final VoidCallback onContinue;
  final ValueChanged<String> onDietSelected;
  final String? selectedDiet;
  const DietStep({Key? key, required this.model, required this.onContinue, required this.onDietSelected, this.selectedDiet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dietIcons = {
      'Classic': 'assets/icons/chicken.svg',
      'Pescatarian': 'assets/icons/fish.svg',
      'Vegetarian': 'assets/icons/apple.svg',
      'Vegan': 'assets/icons/leaf.svg',
    };
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
                'Do you follow a specific diet?',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Colors.black,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _OptionButton(
                    label: 'Classic',
                    selected: selectedDiet == 'Classic',
                    onTap: () => onDietSelected('Classic'),
                    iconPath: dietIcons['Classic'],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _OptionButton(
                    label: 'Pescatarian',
                    selected: selectedDiet == 'Pescatarian',
                    onTap: () => onDietSelected('Pescatarian'),
                    iconPath: dietIcons['Pescatarian'],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _OptionButton(
                    label: 'Vegetarian',
                    selected: selectedDiet == 'Vegetarian',
                    onTap: () => onDietSelected('Vegetarian'),
                    iconPath: dietIcons['Vegetarian'],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _OptionButton(
                    label: 'Vegan',
                    selected: selectedDiet == 'Vegan',
                    onTap: () => onDietSelected('Vegan'),
                    iconPath: dietIcons['Vegan'],
                  ),
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
              onPressed: selectedDiet != null ? onContinue : null,
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
  final bool selected;
  final VoidCallback onTap;
  final String? iconPath;
  const _OptionButton({required this.label, required this.selected, required this.onTap, this.iconPath});

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
                  child: SvgPicture.asset(
                    iconPath!,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 