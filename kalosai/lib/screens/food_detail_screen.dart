import 'package:flutter/material.dart';
import 'package:kalos_ai/models/food_item.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kalos_ai/providers/food_history_provider.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({Key? key, required this.foodItem}) : super(key: key);

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final foodItem = widget.foodItem;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text('Nutrition', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            foodItem.imageUrl != null && foodItem.imageUrl!.isNotEmpty
                ? Image.network(
                    foodItem.imageUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                    ),
                  )
                : Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.fastfood, size: 50, color: Colors.grey)),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          foodItem.dishName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          maxLines: null,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('h:mm a').format(foodItem.uploadTime),
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildNutrientCard(label: 'Calories', value: foodItem.calories, icon: Icons.local_fire_department, color: Colors.red),
                  _buildNutrientCard(label: 'Carbs', value: '${foodItem.carbs}g', icon: Icons.grain, color: Colors.orange),
                  _buildNutrientCard(label: 'Protein', value: '${foodItem.protein}g', icon: Icons.flash_on, color: Colors.blue),
                  _buildNutrientCard(label: 'Fat', value: '${foodItem.fat}g', icon: Icons.opacity, color: Colors.purple),
                  const SizedBox(height: 16),
                  _buildHealthScoreCard(foodItem.healthScore),
                  if (foodItem.description != null && foodItem.description!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text('Description:', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(foodItem.description!),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _confirmDelete(),
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                label: const Text('Delete', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Done', style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Food Item'),
          content: const Text('Are you sure you want to delete this food entry?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                bool success = false;
                try {
                  success = await context.read<FoodHistoryProvider>().deleteFoodItem(widget.foodItem.foodId);
                } catch (e) {
                  print('Error during deleteFoodItem call: $e');
                  success = false;
                }

                if (mounted) {
                  Navigator.of(context).pop(success);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNutrientCard({required String label, required String value, required IconData icon, required Color color}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(String score) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.favorite, color: Colors.pink, size: 24),
            const SizedBox(width: 12),
            Text('Health Score', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('$score/10', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
} 