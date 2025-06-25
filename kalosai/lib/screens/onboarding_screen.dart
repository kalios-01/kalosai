import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'google_signin_screen.dart';
import 'package:flutter/rendering.dart';

// Scanner overlay configuration
class ScannerOverlayConfig {
  // Dimensions
  static const double scannerSize = 400.0;
  static const double scannerTopMargin = 80.0;
  static const double cornerSize = 24.0;
  static const double borderWidth = 2.0;
  static const double borderRadius = 16.0;
  static const double scanLineHeight = 4.0;
  
  // Transparency/Opacity values
  static const double borderOpacity = 0.8;
  static const double scanLineOpacity = 0.7;
  static const double overlayStartOpacity = 0.05;
  static const double overlayEndOpacity = 0.1;
  static const double cornerOpacity = 0.0;
  
  // Blur effect
  static const double blurSigma = 0;

  // Weight Goal Overlay Position
  static const double weightGoalLeft = 50.0;
  static const double weightGoalTop = 400.0;
  static const double weightGoalPadding = 12.0;
  static const double weightGoalBorderRadius = 12.0;
  static const double weightGoalOpacity = 0.7;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      image: 'assets/images/one.png',
      title: 'Calorie tracking made easy',
      description: "Just snap a quick photo of your meal and we'll do the rest",
    ),
    _OnboardingPageData(
      image: 'assets/images/one.png',
      title: 'In-depth nutrition analyses',
      description: 'We will keep you informed about your food choices and their nutritional content',
    ),
    _OnboardingPageData(
      image: 'assets/images/three.png',
      title: 'Transform your body',
      description: 'Today is the best time to start working toward your dream body',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_scanAnimationController);
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

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
    await prefs.setBool('profile_setup_complete', true);
    if (mounted) {
      print('Navigating to GoogleSignInScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GoogleSignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Set status bar to light (white text)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          PageView.builder(
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
                        if (index < 2)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        if (index == 0)
                          Center(
                            child: AnimatedBuilder(
                              animation: _scanAnimation,
                              builder: (context, child) {
                                return Container(
                                  margin: EdgeInsets.only(top: ScannerOverlayConfig.scannerTopMargin),
                                  height: ScannerOverlayConfig.scannerSize,
                                  width: ScannerOverlayConfig.scannerSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(ScannerOverlayConfig.borderRadius),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(ScannerOverlayConfig.borderOpacity),
                                      width: ScannerOverlayConfig.borderWidth,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Scanning line
                                      Positioned(
                                        top: ScannerOverlayConfig.scannerSize * _scanAnimation.value - 2,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: ScannerOverlayConfig.scanLineHeight,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0),
                                                Colors.white.withOpacity(ScannerOverlayConfig.scanLineOpacity),
                                                Colors.white.withOpacity(0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Scanner overlay
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(ScannerOverlayConfig.borderRadius),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: ScannerOverlayConfig.blurSigma,
                                            sigmaY: ScannerOverlayConfig.blurSigma
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.white.withOpacity(ScannerOverlayConfig.overlayStartOpacity),
                                                  Colors.white.withOpacity(ScannerOverlayConfig.overlayEndOpacity),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Corner markers
                                      ...List.generate(4, (index) {
                                        final isTop = index < 2;
                                        final isLeft = index.isEven;
                                        return Positioned(
                                          top: isTop ? 0 : null,
                                          bottom: !isTop ? 0 : null,
                                          left: isLeft ? 0 : null,
                                          right: !isLeft ? 0 : null,
                                          child: Container(
                                            width: ScannerOverlayConfig.cornerSize,
                                            height: ScannerOverlayConfig.cornerSize,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: isTop ? BorderSide(color: Colors.white.withOpacity(ScannerOverlayConfig.cornerOpacity), width: ScannerOverlayConfig.borderWidth) : BorderSide.none,
                                                bottom: !isTop ? BorderSide(color: Colors.white.withOpacity(ScannerOverlayConfig.cornerOpacity), width: ScannerOverlayConfig.borderWidth) : BorderSide.none,
                                                left: isLeft ? BorderSide(color: Colors.white.withOpacity(ScannerOverlayConfig.cornerOpacity), width: ScannerOverlayConfig.borderWidth) : BorderSide.none,
                                                right: !isLeft ? BorderSide(color: Colors.white.withOpacity(ScannerOverlayConfig.cornerOpacity), width: ScannerOverlayConfig.borderWidth) : BorderSide.none,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        if (index == 1)
                          _NutritionOverlay(),
                        if (index == 2)
                          Positioned(
                            left: ScannerOverlayConfig.weightGoalLeft,
                            top: ScannerOverlayConfig.weightGoalTop,
                            child: Container(
                              padding: EdgeInsets.all(ScannerOverlayConfig.weightGoalPadding),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(ScannerOverlayConfig.weightGoalOpacity),
                                borderRadius: BorderRadius.circular(ScannerOverlayConfig.weightGoalBorderRadius),
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
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 32,
                      bottom: 32 + MediaQuery.of(context).padding.bottom,
                    ),
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
        ],
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.7), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 