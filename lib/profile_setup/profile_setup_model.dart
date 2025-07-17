class ProfileSetupModel {
  String? gender;
  int? workoutsPerWeek;
  String? heightUnit; // 'imperial' or 'metric'
  double? height;
  double? weight;
  DateTime? dob;
  String? fitnessGoal; // 'gain', 'maintain', 'lose'
  double? desiredWeight;
  List<String>? goalBarriers;
  String? dietType;
  List<String>? accomplishments;

  ProfileSetupModel();
} 