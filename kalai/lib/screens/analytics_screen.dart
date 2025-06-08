import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_setup_provider.dart';
import '../utils/bmi_calculator.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch profile data when the screen initializes
    Future.microtask(() => context.read<ProfileSetupProvider>().fetchUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.watch<ProfileSetupProvider>();
    final userProfile = profileProvider.userProfileData;
    final isLoading = profileProvider.isFetchingProfile || profileProvider.isUpdatingProfile;

    // Get height and weight from profile
    final height = userProfile?['height']?.toDouble();
    final weight = userProfile?['weight']?.toDouble();
    final goalWeight = userProfile?['goal_weight']?.toDouble();

    // Calculate BMI if we have both height and weight
    double? bmi;
    String bmiCategory = 'N/A';
    Color bmiColor = Colors.grey;

    if (height != null && weight != null) {
      bmi = BMICalculator.calculateBMI(weight, height);
      bmiCategory = BMICalculator.getBMICategory(bmi);
      bmiColor = BMICalculator.getBMICategoryColor(bmi);
    }

    // Helper to format weight (assuming API returns lbs)
    String _formatWeight(double? value) {
      if (value == null) return '-- lbs';
      return '${value.toStringAsFixed(0)} lbs';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Title
              Text(
                'Overview',
                style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Weight Goal Section
              Text(
                'Weight Goal',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  isLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 32,
                            width: 120,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _formatWeight(goalWeight),
                          style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: isLoading ? null : () {
                      _showEditDialog(
                        context: context,
                        label: 'Goal Weight',
                        apiFieldName: 'goal_weight',
                        currentValue: goalWeight?.toString() ?? '',
                        keyboardType: TextInputType.number,
                        profileProvider: profileProvider,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Update', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Current Weight Section
              Text(
                'Current Weight',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isLoading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 48,
                              width: 150,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _formatWeight(weight),
                            style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                    const SizedBox(height: 8),
                    Text(
                      'Try to update once a week so we can adjust your plan\nto ensure you hit your goal.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () {
                          _showEditDialog(
                            context: context,
                            label: 'Current Weight',
                            apiFieldName: 'weight',
                            currentValue: weight?.toString() ?? '',
                            keyboardType: TextInputType.number,
                            profileProvider: profileProvider,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Log weight', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Your BMI Card (existing implementation)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your BMI',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isLoading)
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                      )
                    else if (bmi == null)
                      const Center(
                        child: Text(
                          'Please update your height and weight in settings',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Your weight is ', style: theme.textTheme.bodyLarge),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: bmiColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          bmiCategory,
                                          style: TextStyle(
                                            color: bmiColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.info_outline, color: Colors.grey, size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    bmi.toStringAsFixed(1),
                                    style: theme.textTheme.displayMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // BMI Visual Indicator (simplified for now)
                          _buildBMISlider(bmi, bmiColor), // New widget for the slider
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildBMICategoryLegendItem('Underweight', Colors.blue),
                              _buildBMICategoryLegendItem('Healthy', Colors.green),
                              _buildBMICategoryLegendItem('Overweight', Colors.orange),
                              _buildBMICategoryLegendItem('Obese', Colors.red),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Goal Progress Section (Placeholder)
              Text(
                'Goal Progress',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Timeframe selector (90 Days, 6 Months, etc.)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimeframeButton('90 Days', true), // true for selected
                  _buildTimeframeButton('6 Months', false),
                  _buildTimeframeButton('1 Year', false),
                  _buildTimeframeButton('All time', false),
                ],
              ),
              const SizedBox(height: 16),
              // Placeholder for the graph
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Weight Progress Graph (Coming Soon)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Refactored _showEditDialog to be callable from here
  Future<void> _showEditDialog({
    required BuildContext context,
    required String label,
    required String apiFieldName,
    required dynamic currentValue,
    required TextInputType keyboardType,
    required ProfileSetupProvider profileProvider,
  }) async {
    final TextEditingController controller = TextEditingController(text: currentValue.toString());

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: 'Enter new $label'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newValue = controller.text.trim();
                if (newValue.isNotEmpty) {
                  dynamic parsedValue = newValue; // Default to string

                  if (keyboardType == TextInputType.number || keyboardType == TextInputType.numberWithOptions()){
                    if (apiFieldName == 'height' || apiFieldName == 'weight' || apiFieldName == 'goal_weight') {
                      final intValue = int.tryParse(newValue);
                      if (intValue == null) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Please enter a whole number.')),
                        );
                        return;
                      }
                      parsedValue = intValue;
                    } else {
                      parsedValue = double.tryParse(newValue) ?? int.tryParse(newValue);
                      if (parsedValue == null) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Invalid number format.')),
                        );
                        return;
                      }
                    }
                  } else if (apiFieldName == 'age') {
                    try {
                      final date = DateTime.parse(newValue);
                      parsedValue = DateFormat('yyyy-MM-dd').format(date);
                    } catch (e) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Please enter date in YYYY-MM-DD format.')),
                      );
                      return;
                    }
                  }

                  print('Sending to API - field: $apiFieldName, value: $parsedValue (type: ${parsedValue.runtimeType})');

                  final success = await profileProvider.updateProfileField(
                    fieldName: apiFieldName,
                    fieldValue: parsedValue,
                  );

                  if (success) {
                    if (mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text('$label updated successfully!')),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text('Failed to update $label.')),
                      );
                    }
                  }

                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                } else {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Refactored _showDatePickerDialog to be callable from here
  Future<void> _showDatePickerDialog({
    required BuildContext context,
    required String apiFieldName,
    required DateTime? currentValue,
    required ProfileSetupProvider profileProvider,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentValue ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != currentValue) {
      final String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      final success = await profileProvider.updateProfileField(
        fieldName: apiFieldName,
        fieldValue: formattedDate,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Date of birth updated successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update date of birth.')),
          );
        }
      }
    }
  }

  // New widget for the BMI slider (visual indicator)
  Widget _buildBMISlider(double bmi, Color bmiColor) {
    double sliderValue = bmi.clamp(15.0, 35.0); // Clamp BMI to a reasonable range for slider
    double healthyStart = 18.5;
    double healthyEnd = 24.9;
    double overweightStart = 25.0;
    double obeseStart = 30.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        double totalWidth = constraints.maxWidth;
        double markerPosition = ((sliderValue - 15.0) / (35.0 - 15.0)) * totalWidth;

        return Stack(
          children: [
            // Background gradient for BMI categories
            Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue, // Underweight
                    Colors.green, // Healthy
                    Colors.orange, // Overweight
                    Colors.red, // Obese
                  ],
                  stops: [
                    (healthyStart - 15.0) / (35.0 - 15.0),
                    (overweightStart - 15.0) / (35.0 - 15.0),
                    (obeseStart - 15.0) / (35.0 - 15.0),
                    1.0,
                  ],
                ),
              ),
            ),
            // Current BMI marker
            Positioned(
              left: markerPosition - 2, // Adjust to center the marker
              child: Container(
                width: 4,
                height: 14,
                color: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  // New widget for BMI category legend items
  Widget _buildBMICategoryLegendItem(String category, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(category, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // New widget for timeframe buttons
  Widget _buildTimeframeButton(String text, bool isSelected) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () { /* TODO: Implement timeframe change */ },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.black : Colors.grey[200],
            foregroundColor: isSelected ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
          ),
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}
