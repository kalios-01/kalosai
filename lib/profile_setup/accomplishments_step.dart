import 'package:flutter/material.dart';
import 'profile_setup_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccomplishmentsStep extends StatefulWidget {
  final ProfileSetupModel model;
  final VoidCallback onContinue;
  const AccomplishmentsStep({Key? key, required this.model, required this.onContinue}) : super(key: key);

  @override
  State<AccomplishmentsStep> createState() => _AccomplishmentsStepState();
}

class _AccomplishmentsStepState extends State<AccomplishmentsStep> {
  final List<String> _options = [
    'Eat and live healthier',
    'Boost my energy and mood',
    'Stay motivated and consistent',
    'Feel better about my body',
  ];

  final Map<String, String> _optionIcons = {
    'Eat and live healthier': 'assets/icons/apple.svg',
    'Boost my energy and mood': 'assets/icons/sun.svg',
    'Stay motivated and consistent': 'assets/icons/dumbbell.svg',
    'Feel better about my body': 'assets/icons/person.svg',
  };
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.model.accomplishments ?? [];
  }

  void _toggle(String value) {
    setState(() {
      if (_selected.contains(value)) {
        _selected.remove(value);
      } else {
        _selected.add(value);
      }
    });
  }

  void _save() {
    widget.model.accomplishments = List.from(_selected);
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const Text(
            'What would you like to accomplish?',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _options.map((option) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: _MultiSelectOptionButton(
                  label: option,
                  selected: _selected.contains(option),
                  onTap: () => _toggle(option),
                  iconPath: _optionIcons[option],
                ),
              )).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected.isNotEmpty ? _save : null,
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

class _MultiSelectOptionButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? iconPath;
  const _MultiSelectOptionButton({required this.label, required this.selected, required this.onTap, this.iconPath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.black : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (iconPath != null)
              Container(
                margin: const EdgeInsets.only(right: 16),
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
              )
            else
              const SizedBox(width: 40),
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