import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kalos_ai/providers/auth_provider.dart';
import 'package:kalos_ai/providers/goals_provider.dart';
import 'package:kalos_ai/providers/food_history_provider.dart';
import 'package:kalos_ai/services/upload_service.dart';
import 'package:kalos_ai/screens/settings_screen.dart';
import 'package:kalos_ai/screens/analytics_screen.dart';
import 'package:kalos_ai/screens/food_detail_screen.dart';
import 'package:kalos_ai/models/food_item.dart';
import 'package:intl/intl.dart';
import 'package:kalos_ai/utils/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kalos_ai/screens/camera_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<__HomeScreenContentState> _homeContentKey = GlobalKey();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _HomeScreenContent(key: _homeContentKey),
      AnalyticsScreen(),
      SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.apple, color: Colors.black),
            const SizedBox(width: 8),
            Text('Kalos Ai', style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                SizedBox(width: 4),
                Text('0', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _homeContentKey.currentState?._onCapturePressed(context);
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent({Key? key}) : super(key: key);

  @override
  __HomeScreenContentState createState() => __HomeScreenContentState();
}

class __HomeScreenContentState extends State<_HomeScreenContent> {
  List<DateTime> _weekDates = [];
  int _selectedDayIndex = 0;
  final ImagePicker _picker = ImagePicker();
  final UploadService _uploadService = UploadService();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _generateDates();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(
        _selectedDayIndex * 56.0,
      );
    });

    Future.microtask(() {
      context.read<GoalsProvider>().fetchGoals(date: _weekDates[_selectedDayIndex]);
      context.read<FoodHistoryProvider>().fetchFoodHistory(date: _weekDates[_selectedDayIndex]);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateDates() {
    final today = DateTime.now();
    _weekDates = List.generate(30, (index) {
      return today.subtract(Duration(days: 29 - index));
    });

    _selectedDayIndex = _weekDates.indexWhere((date) => date.day == today.day && date.month == today.month && date.year == today.year);
  }

  void _onDaySelected(int index) {
    setState(() {
      _selectedDayIndex = index;
    });
    context.read<GoalsProvider>().fetchGoals(date: _weekDates[index]);
    context.read<FoodHistoryProvider>().fetchFoodHistory(date: _weekDates[index]);
  }

  void _onCapturePressed(BuildContext context) async {
    print('Camera button pressed');
    if (!await ensureCameraPermission(context)) {
      print('Camera permission not granted, returning');
      return;
    }
    print('Camera permission granted, showing bottom sheet');

    if (!mounted) {
      print('Widget not mounted, returning');
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        print('Building bottom sheet');
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scan Barcode'),
                onTap: () {
                  print('Barcode option selected');
                  Navigator.of(bc).pop();
                  _openCameraScreen(context, 'barcode');
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Scan Food Item'),
                onTap: () {
                  print('Food item option selected');
                  Navigator.of(bc).pop();
                  _openCameraScreen(context, 'food_item');
                },
              ),
            ],
          ),
        );
      },
    ).then((_) {
      print('Bottom sheet closed');
    });
  }

  void _openCameraScreen(BuildContext context, String type) {
    print('Opening camera screen for type: $type');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          type: type,
          onCaptureComplete: (success) {
            print('Camera capture completed with success: $success');
            if (success) {
              // Refresh food history after successful upload
              context.read<FoodHistoryProvider>().fetchFoodHistory(date: _weekDates[_selectedDayIndex]);
            }
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalsProvider = context.watch<GoalsProvider>();
    final foodHistoryProvider = context.watch<FoodHistoryProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<GoalsProvider>().refreshGoals(date: _weekDates[_selectedDayIndex]);
        await context.read<FoodHistoryProvider>().fetchFoodHistory(date: _weekDates[_selectedDayIndex]);
      },
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 60,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _weekDates.length,
              itemBuilder: (context, i) {
                final date = _weekDates[i];
                final isSelected = i == _selectedDayIndex;
                final weekday = DateFormat('E').format(date)[0];
                final dayOfMonth = DateFormat('dd').format(date);

                return GestureDetector(
                  onTap: () => _onDaySelected(i),
                  child: Container(
                    width: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(weekday, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey)),
                        const SizedBox(height: 4),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300, width: 2),
                            color: isSelected ? Colors.white : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(dayOfMonth, style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  goalsProvider.isLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 36,
                            width: 80,
                            color: Colors.white, // Placeholder for the shimmering effect
                          ),
                        )
                      : Text(
                          goalsProvider.calories.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                  const SizedBox(height: 4),
                  const Text('Calories left', style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Icon(Icons.local_fire_department, color: Colors.orange, size: 36),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _MacroCard(
                  label: 'Protein left',
                  value: goalsProvider.isLoading
                      ? '--'
                      : '${goalsProvider.protein.toStringAsFixed(0)}g',
                  icon: Icons.flash_on,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 8),
                _MacroCard(
                  label: 'Carbs left',
                  value: goalsProvider.isLoading
                      ? '--'
                      : '${goalsProvider.carbs.toStringAsFixed(0)}g',
                  icon: Icons.grain,
                  color: Colors.orangeAccent,
                ),
                const SizedBox(width: 8),
                _MacroCard(
                  label: 'Fats left',
                  value: goalsProvider.isLoading
                      ? '--'
                      : '${goalsProvider.fat.toStringAsFixed(0)}g',
                  icon: Icons.opacity,
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recently eaten', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                foodHistoryProvider.isLoading
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(3, (index) => // Show 3 shimmering cards
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white, // Placeholder for the shimmering effect
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : foodHistoryProvider.errorMessage != null
                        ? Center(
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  'Failed to load food history. Please try again.',
                                  style: TextStyle(color: Colors.red[700], fontSize: 16),
                                ),
                                if (foodHistoryProvider.errorMessage!.contains('404') || foodHistoryProvider.errorMessage!.contains('No food found'))
                                  const Text(
                                    'No food entries for this date.',
                                    style: TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                              ],
                            ),
                          )
                        : foodHistoryProvider.foodHistory.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("You haven't uploaded any food", style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    Text("Start tracking Today's meals by taking a quick pictures", style: TextStyle(color: Colors.black54)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: foodHistoryProvider.foodHistory.length,
                                itemBuilder: (context, index) {
                                  final foodItem = foodHistoryProvider.foodHistory[index];
                                  return FoodHistoryCard(
                                    foodItem: foodItem,
                                    onDeleteSuccess: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Food item deleted successfully')),
                                      );
                                      context.read<FoodHistoryProvider>().fetchFoodHistory(date: _weekDates[_selectedDayIndex]);
                                    },
                                  );
                                },
                              ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MacroCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            Icon(icon, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}

class FoodHistoryCard extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onDeleteSuccess;

  const FoodHistoryCard({
    Key? key,
    required this.foodItem,
    required this.onDeleteSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(foodItem: foodItem),
          ),
        );

        if (result == true) {
          onDeleteSuccess();
        } else if (result == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete food item')),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              foodItem.imageUrl != null && foodItem.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        foodItem.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.image_not_supported, size: 30, color: Colors.grey)),
                        ),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Icon(Icons.fastfood, size: 30, color: Colors.grey)),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodItem.dishName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('h:mm a').format(foodItem.uploadTime),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildNutrientIcon(Icons.local_fire_department, foodItem.calories, Colors.red),
                        _buildNutrientIcon(Icons.grain, '${foodItem.carbs}g', Colors.orange),
                        _buildNutrientIcon(Icons.flash_on, '${foodItem.protein}g', Colors.blue),
                        _buildNutrientIcon(Icons.opacity, '${foodItem.fat}g', Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientIcon(IconData icon, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}