import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../providers/profile_setup_provider.dart'; // Import ProfileSetupProvider
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:shimmer/shimmer.dart'; // Import shimmer package

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure profile data is fetched when this screen is opened
    // It might already be fetched in SettingsScreen, but calling here ensures it.
    Future.microtask(
      () => context.read<ProfileSetupProvider>().fetchUserProfile(),
    );
  }

  // Helper to format birth date from API (YYYY-MM-DD to MM/DD/YYYY)
  String _formatDateOfBirth(String? birthDateStr) {
    if (birthDateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(birthDateStr);
      return DateFormat('MM/dd/yyyy').format(date);
    } catch (e) {
      print('Error parsing birth date for display: $e');
      return 'N/A';
    }
  }

  // Helper to format height (assuming API returns height in inches and we want ft/in)
  String _formatHeight(double? height) {
    if (height == null) return 'N/A';
    // Assuming the API returns height in the unit saved by the user (metric or imperial)
    // For now, let's assume it's in inches for imperial and cm for metric based on previous context
    // You would need to adjust this based on how your API actually returns and expects units.
    // For demonstration, I'll keep the previous logic that assumed inches.

    // If you need to handle units dynamically, you'd need the unit from the profile data.

    // Example if height is always returned in inches:
    final heightInches = height; // Use the value directly if it's always inches
    final feet = (heightInches / 12).floor();
    final inches = (heightInches % 12).round();
    return '$feet ft $inches in';

    // Example if height unit is included in API response and stored in provider:
    // final unit = context.read<ProfileSetupProvider>().userProfileData?['unit'];
    // if (unit == 'metric') {
    //   return '${height.toStringAsFixed(1)} cm';
    // } else { // imperial
    //   final heightInches = height; // Assuming API sends inches if unit is imperial
    //   final feet = (heightInches / 12).floor();
    //   final inches = (heightInches % 12).round();
    //   return '$feet ft $inches in';
    // }
  }

  // Helper to format weight (assuming API returns weight in lbs)
  String _formatWeight(double? weight) {
    if (weight == null) return 'N/A';
    // Assuming the API returns weight in the unit saved by the user (metric or imperial)
    // For now, let's assume it's in lbs for imperial and kg for metric based on previous context
    // You would need to adjust this based on how your API actually returns and expects units.

    // Example if weight is always returned in lbs:
    final weightLbs = weight; // Use the value directly if it's always lbs
    return '${weightLbs.toStringAsFixed(0)} lbs';

    // Example if weight unit is included in API response and stored in provider:
    // final unit = context.read<ProfileSetupProvider>().userProfileData?['unit'];
    // if (unit == 'metric') {
    //   return '${weight.toStringAsFixed(1)} kg';
    // } else { // imperial
    //   final weightLbs = weight; // Assuming API sends lbs if unit is imperial
    //   return '${weightLbs.toStringAsFixed(0)} lbs';
    // }
  }

  // Helper to format gender
  String _formatGender(String? gender) {
    if (gender == null || gender.isEmpty) return 'N/A';
    return gender[0].toUpperCase() +
        gender.substring(1).toLowerCase(); // Capitalize first letter
  }

  // Function to show edit dialog and handle update
  Future<void> _showEditDialog({
    required String label,
    required String apiFieldName,
    required dynamic currentValue,
    required TextInputType keyboardType,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: currentValue.toString(),
    );

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: 'Enter new $label'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newValue = controller.text.trim();
                if (newValue.isNotEmpty) {
                  dynamic parsedValue = newValue; // Default to string

                  // Attempt to parse to number if applicable
                  if (keyboardType == TextInputType.number ||
                      keyboardType == TextInputType.numberWithOptions()) {
                    // For height and weight, ensure we get an integer
                    if (apiFieldName == 'height' ||
                        apiFieldName == 'current_weight' ||
                        apiFieldName == 'goal_weight') {
                      final intValue = int.tryParse(newValue);
                      if (intValue == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a whole number.'),
                          ),
                        );
                        return;
                      }
                      parsedValue = intValue; // Store as integer
                    } else {
                      // For other number fields, allow decimal
                      parsedValue =
                          double.tryParse(newValue) ?? int.tryParse(newValue);
                      if (parsedValue == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid number format.'),
                          ),
                        );
                        return;
                      }
                    }
                  } else if (apiFieldName == 'age') {
                    // For age, ensure it's in YYYY-MM-DD format
                    try {
                      final date = DateTime.parse(newValue);
                      parsedValue = DateFormat('yyyy-MM-dd').format(date);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter date in YYYY-MM-DD format.',
                          ),
                        ),
                      );
                      return;
                    }
                  }

                  // Log the value being sent to API
                  print(
                    'Sending to API - field: $apiFieldName, value: $parsedValue (type: ${parsedValue.runtimeType})',
                  );

                  final success = await context
                      .read<ProfileSetupProvider>()
                      .updateProfileField(
                        fieldName: apiFieldName,
                        fieldValue: parsedValue,
                      );

                  // Show feedback before closing dialog
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$label updated successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update $label.')),
                    );
                  }

                  // Close dialog after showing feedback
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                } else {
                  // Close dialog if no value entered
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to show date picker and handle update for age
  Future<void> _showDatePickerDialog({
    required String apiFieldName,
    required DateTime? currentValue,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentValue ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != currentValue) {
      // Format the date to YYYY-MM-DD string as expected by the API
      final String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      final success = await context
          .read<ProfileSetupProvider>()
          .updateProfileField(
            fieldName: apiFieldName,
            fieldValue: formattedDate,
          );

      // Show feedback (optional)
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Date of birth updated successfully!'),
            ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch the ProfileSetupProvider for data changes and loading state
    final profileProvider = context.watch<ProfileSetupProvider>();
    final userProfile = profileProvider.userProfileData;
    final isLoading =
        profileProvider.isFetchingProfile || profileProvider.isUpdatingProfile;

    // Extract and format data, handling loading state and nulls
    // Note: Assuming 'age' key holds the birth date string in YYYY-MM-DD format
    // Note: Assuming 'goal_weight', 'weight', and 'height', 'gender' are returned correctly
    final goalWeight = isLoading
        ? null
        : _formatWeight(userProfile?['goal_weight']?.toDouble());
    final currentWeight = isLoading
        ? null
        : _formatWeight(userProfile?['weight']?.toDouble());
    final height = isLoading
        ? null
        : _formatHeight(userProfile?['height']?.toDouble());
    final dateOfBirth = isLoading
        ? null
        : _formatDateOfBirth(userProfile?['age']);
    final gender = isLoading ? null : _formatGender(userProfile?['gender']);

    // Get raw values for passing to edit dialogs
    final rawCurrentWeight = userProfile?['weight']?.toDouble();
    final rawHeight = userProfile?['height']?.toDouble();
    final rawDateOfBirth = userProfile?['age'] != null
        ? DateTime.tryParse(userProfile?['age'])
        : null;
    final rawGender = userProfile?['gender']?.toString();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Personal details',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Goal Weight Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Goal Weight', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      _buildDetailRow(
                        label: 'Goal Weight',
                        value: goalWeight,
                        isLoading: isLoading,
                        onTap: () {
                          _showEditDialog(
                            label: 'Goal Weight',
                            apiFieldName: 'goal_weight',
                            currentValue:
                                userProfile?['goal_weight']
                                    ?.toDouble()
                                    ?.toStringAsFixed(0) ??
                                '',
                            keyboardType: TextInputType.number,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            // Personal Details List
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    label: 'Current Weight',
                    value: currentWeight,
                    isLoading: isLoading,
                    onTap: () {
                      _showEditDialog(
                        label: 'Current Weight',
                        apiFieldName: 'weight',
                        currentValue:
                            rawCurrentWeight?.toStringAsFixed(0) ?? '',
                        keyboardType: TextInputType.number,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    label: 'Height',
                    value: height,
                    isLoading: isLoading,
                    onTap: () {
                      _showEditDialog(
                        label: 'Height',
                        apiFieldName: 'height',
                        currentValue: rawHeight?.toStringAsFixed(0) ?? '',
                        keyboardType: TextInputType.number,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    label: 'Date of birth',
                    value: dateOfBirth,
                    isLoading: isLoading,
                    onTap: () {
                      _showDatePickerDialog(
                        apiFieldName: 'age',
                        currentValue: rawDateOfBirth,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    label: 'Gender',
                    value: gender,
                    isLoading: isLoading,
                    onTap: () {
                      _showEditDialog(
                        label: 'Gender',
                        apiFieldName: 'gender',
                        currentValue: rawGender ?? '',
                        keyboardType: TextInputType.text,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String? value,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                isLoading
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 20,
                          width: 100,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        value ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
