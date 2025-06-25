import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kalos_ai/providers/goals_provider.dart';

class AdjustGoalsScreen extends StatefulWidget {
  const AdjustGoalsScreen({super.key});

  @override
  State<AdjustGoalsScreen> createState() => _AdjustGoalsScreenState();
}

class _AdjustGoalsScreenState extends State<AdjustGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _calorieController;
  late TextEditingController _proteinController;
  late TextEditingController _carbController;
  late TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    final goalsProvider = context.read<GoalsProvider>();
    _calorieController = TextEditingController(text: goalsProvider.calories.toStringAsFixed(0));
    _proteinController = TextEditingController(text: goalsProvider.protein.toStringAsFixed(0));
    _carbController = TextEditingController(text: goalsProvider.carbs.toStringAsFixed(0));
    _fatController = TextEditingController(text: goalsProvider.fat.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _updateGoals() async {
    if (_formKey.currentState!.validate()) {
      final goalsProvider = context.read<GoalsProvider>();
      try {
        await goalsProvider.updateGoals(
          calories: double.parse(_calorieController.text).round(),
          protein: double.parse(_proteinController.text).round(),
          carbs: double.parse(_carbController.text).round(),
          fat: double.parse(_fatController.text).round(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Goals updated successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update goals: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust Goals', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildGoalInputField(
              controller: _calorieController,
              label: 'Calorie Goal',
              icon: Icons.local_fire_department,
            ),
            _buildGoalInputField(
              controller: _proteinController,
              label: 'Protein Goal (g)',
              icon: Icons.flash_on,
            ),
            _buildGoalInputField(
              controller: _carbController,
              label: 'Carb Goal (g)',
              icon: Icons.grain,
            ),
            _buildGoalInputField(
              controller: _fatController,
              label: 'Fat Goal (g)',
              icon: Icons.opacity,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateGoals,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Update Goals', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
} 