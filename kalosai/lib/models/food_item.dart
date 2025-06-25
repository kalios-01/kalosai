

class FoodItem {
  final String dishName;
  final String calories;
  final String fat;
  final String protein;
  final String carbs;
  final String healthScore;
  final int quantity;
  final String? description;
  final int foodId;
  final int userId;
  final String? imageUrl;
  final DateTime uploadTime;

  FoodItem({
    required this.dishName,
    required this.calories,
    required this.fat,
    required this.protein,
    required this.carbs,
    required this.healthScore,
    required this.quantity,
    this.description,
    required this.foodId,
    required this.userId,
    this.imageUrl,
    required this.uploadTime,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      dishName: json['dish_name'] as String,
      calories: (json['calories'] as num).toString(),
      fat: (json['fat'] as num).toString(),
      protein: (json['protein'] as num).toString(),
      carbs: (json['carbs'] as num).toString(),
      healthScore: (json['health_score'] as num).toString(),
      quantity: json['quantity'] as int,
      description: json['description'] as String?,
      foodId: json['food_id'] as int,
      userId: (json['user_id'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
      uploadTime: DateTime.parse(json['upload_time'] as String),
    );
  }
} 