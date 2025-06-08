import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      image: 'assets/images/onboarding1.png',
      title: 'Calorie tracking made easy',
      description: "Just snap a quick photo of your meal and we'll do the rest",
    ),
    _OnboardingPageData(
      image: 'assets/images/onboarding2.png',
      title: 'In-depth nutrition analyses',
      description: 'We will keep you informed about your food choices and their nutritional content',
    ),
    _OnboardingPageData(
      image: 'assets/images/onboarding3.png',
      title: 'Transform your body',
      description: 'Today is the best time to start working toward your dream body',
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                page.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (index == 0)
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 80),
                                  height: 120,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            if (index == 1)
                              _NutritionOverlay(),
                            if (index == 2)
                              Positioned(
                                left: 24,
                                top: 80,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Weight Goal', style: TextStyle(color: Colors.white, fontSize: 16)),
                                      SizedBox(height: 4),
                                      Text('60 Kg', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.background,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              page.title,
                              style: theme.textTheme.displayMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              page.description,
                              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.secondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_pages.length, (dotIndex) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentPage == dotIndex ? Colors.black : Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _onNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                ),
                                child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next', style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String image;
  final String title;
  final String description;
  _OnboardingPageData({required this.image, required this.title, required this.description});
}

class _NutritionOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 16,
          top: 80,
          child: _circleStat('Protein', '35g', Colors.redAccent),
        ),
        Positioned(
          left: 120,
          top: 180,
          child: _circleStat('Carbs', '35g', Colors.orangeAccent),
        ),
        Positioned(
          right: 16,
          top: 120,
          child: _circleStat('Fat', '35g', Colors.blueAccent),
        ),
      ],
    );
  }

  Widget _circleStat(String label, String value, Color color) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
} 