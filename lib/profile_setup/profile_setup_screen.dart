import 'package:flutter/material.dart';
import 'profile_setup_model.dart';
import 'gender_step.dart';
import 'workouts_step.dart';
import 'height_weight_step.dart';
import 'dob_step.dart';
import 'fitness_goal_step.dart';
import 'desired_weight_step.dart';
import 'goal_barriers_step.dart';
import 'diet_step.dart';
import 'accomplishments_step.dart';
import 'thank_you_step.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _controller = PageController();
  final ProfileSetupModel _model = ProfileSetupModel();
  int _currentStep = 0;
  String? _selectedGender;
  int? _selectedWorkouts;
  String? _selectedGoal;
  String? _selectedDiet;

  // Helper to determine if we should show the DesiredWeightStep
  bool get _shouldShowDesiredWeightStep => _selectedGoal != 'maintain';

  List<String> get _stepTitles => [
    'Gender',
    'Workouts',
    'Height & Weight',
    'Date of Birth',
    'Fitness Goal',
    'Desired Weight',
    'Barriers',
    'Diet',
    'Accomplishments',
    'Finish',
  ];

  double get _progress => (_currentStep + 1) / 10.0;

  void _nextStep() {
    // If next step is DesiredWeightStep and goal is 'maintain', skip it
    if (_currentStep == 5 && _selectedGoal == 'maintain') {
      setState(() => _currentStep += 2);
      _controller.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      return;
    }
    if (_currentStep < 9) {
      setState(() => _currentStep++);
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _submitPlan() {
    // TODO: Send _model to backend or persist as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _currentStep > 0 ? _prevStep : null,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: const Color(0xFFEAEAEA),
                      color: Colors.black,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  GenderStep(
                    model: _model,
                    selectedGender: _selectedGender,
                    onGenderSelected: (gender) {
                      setState(() {
                        _selectedGender = gender;
                        _model.gender = gender;
                      });
                    },
                    onContinue: _selectedGender != null ? _nextStep : () {},
                  ),
                  WorkoutsStep(
                    model: _model,
                    selectedWorkouts: _selectedWorkouts,
                    onWorkoutsSelected: (workouts) {
                      setState(() {
                        _selectedWorkouts = workouts;
                        _model.workoutsPerWeek = workouts;
                      });
                    },
                    onContinue: _selectedWorkouts != null ? _nextStep : () {},
                  ),
                  HeightWeightStep(
                    model: _model,
                    onContinue: _nextStep,
                  ),
                  DOBStep(
                    model: _model,
                    onContinue: _nextStep,
                  ),
                  FitnessGoalStep(
                    model: _model,
                    selectedGoal: _selectedGoal,
                    onGoalSelected: (goal) {
                      setState(() {
                        _selectedGoal = goal;
                        _model.fitnessGoal = goal;
                      });
                    },
                    onContinue: _selectedGoal != null ? _nextStep : () {},
                  ),
                  if (_shouldShowDesiredWeightStep)
                    DesiredWeightStep(
                      model: _model,
                      onContinue: _nextStep,
                      goal: _selectedGoal,
                    ),
                  GoalBarriersStep(
                    model: _model,
                    onContinue: _nextStep,
                  ),
                  DietStep(
                    model: _model,
                    selectedDiet: _selectedDiet,
                    onDietSelected: (diet) {
                      setState(() {
                        _selectedDiet = diet;
                        _model.dietType = diet;
                      });
                    },
                    onContinue: _selectedDiet != null ? _nextStep : () {},
                  ),
                  AccomplishmentsStep(
                    model: _model,
                    onContinue: _nextStep,
                  ),
                  ThankYouStep(
                    model: _model,
                    onCreatePlan: _submitPlan,
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