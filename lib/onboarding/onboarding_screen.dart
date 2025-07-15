import 'package:flutter/material.dart';
import '../google_signin/google_signin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      image: 'assets/onboarding_one.png',
      title: 'Track Your Progress',
      subtitle: 'Stay motivated by tracking your daily calorie intake and exercise.',
    ),
    _OnboardingPageData(
      image: 'assets/onboarding_two.png',
      title: 'Track your exercise',
      subtitle: 'Log your workouts and see how many calories you\'ve burned',
    ),
    _OnboardingPageData(
      image: 'assets/onboarding_three.png',
      title: 'Compete with Friends',
      subtitle: 'Stay motivated by challenging your friends and family to reach their fitness goals.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GoogleSignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * 0.4;
    final cardHeight = size.height * 0.6;
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      body: Stack(
        children: [
          // Top image (changes instantly, no slide)
          SizedBox(
            width: double.infinity,
            height: imageHeight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: Image.asset(
                _pages[_currentPage].image,
                key: ValueKey(_pages[_currentPage].image),
                fit: BoxFit.cover,
                width: double.infinity,
                height: imageHeight,
              ),
            ),
          ),
          // Card content (bottom 60%)
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              height: cardHeight,
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            page.title,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.subtitle,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          _PageIndicator(current: _currentPage, count: _pages.length),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 18),
                              ),
                              child: Text(
                                index == _pages.length - 1 ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  final String image;
  final String title;
  final String subtitle;
  const _OnboardingPageData({required this.image, required this.title, required this.subtitle});
}

class _PageIndicator extends StatelessWidget {
  final int current;
  final int count;
  const _PageIndicator({required this.current, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: i == current ? Colors.black : Colors.black26,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
} 