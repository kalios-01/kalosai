import 'package:flutter/material.dart';

class BMICalculator {
  static double calculateBMI(double weightKg, double heightCm) {
    // Convert height from cm to meters
    double heightM = heightCm / 100;
    // Calculate BMI: weight (kg) / (height (m))²
    return weightKg / (heightM * heightM);
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal weight';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  static Color getBMICategoryColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue; // Underweight
    } else if (bmi < 25) {
      return Colors.green; // Normal weight
    } else if (bmi < 30) {
      return Colors.orange; // Overweight
    } else {
      return Colors.red; // Obese
    }
  }
} 