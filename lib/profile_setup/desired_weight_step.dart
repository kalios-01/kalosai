import 'package:flutter/material.dart';
import 'package:flutter_ruler_picker/flutter_ruler_picker.dart';

import 'profile_setup_model.dart';

class DesiredWeightStep extends StatefulWidget {
  final ProfileSetupModel model;
  final VoidCallback onContinue;
  final String? goal;
  const DesiredWeightStep({
    Key? key,
    required this.model,
    required this.onContinue,
    this.goal,
  }) : super(key: key);

  @override
  State<DesiredWeightStep> createState() => _DesiredWeightStepState();
}

class _DesiredWeightStepState extends State<DesiredWeightStep> {
  double _desiredWeight = 160; // Default visible weight, center of range
  late RulerPickerController _controller;

  @override
  void initState() {
    super.initState();
    _desiredWeight = widget.model.desiredWeight ?? 160;
    _controller = RulerPickerController(value: _desiredWeight);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    widget.model.desiredWeight = _desiredWeight;
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Choose your desired weight?',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  widget.goal == 'lose'
                      ? 'Lose Weight'
                      : 'Gain Weight',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_desiredWeight.toStringAsFixed(0)} lbs',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationX(3.14159),
                  child: RulerPicker(
                    controller: _controller,
                    onValueChanged: (value) {
                      setState(() {
                        _desiredWeight = value.toDouble();
                      });
                    },
                    onBuildRulerScaleText: (int index, num rulerScaleValue) {
                      return '';
                    },
                    scaleLineStyleList: const [
                      ScaleLineStyle(
                        scale: 10,
                        color: Colors.black,
                        width: 2,
                        height: 30,
                      ),
                      ScaleLineStyle(
                        scale: 5,
                        color: Colors.grey,
                        width: 1.5,
                        height: 20,
                      ),
                      ScaleLineStyle(
                        scale: 1,
                        color: Colors.grey,
                        width: 1,
                        height: 10,
                      ),
                    ],
                    rulerBackgroundColor: Colors.transparent,
                    marker: SizedBox.shrink(), // Remove any default marker/highlight
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    ranges: const [
                      RulerRange(begin: 80, end: 400, scale: 1),
                    ],
                  ),
                ),
                // Custom centered marker
                Positioned(
                  top: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.topCenter,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
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
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
