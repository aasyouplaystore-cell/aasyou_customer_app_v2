import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/global.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';

import '../../../l10n/app_localizations.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  IntroductionPageState createState() => IntroductionPageState();
}

class IntroductionPageState extends State<IntroductionPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  late AnimationController _animationController;
  late AnimationController _iconAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _animationController.forward();
    _iconAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
    _animationController.reset();
    _iconAnimationController.reset();
    _animationController.forward();
    _iconAnimationController.forward();
  }

  void _nextPage() {
    if (currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    // Mark that user has seen the intro screens
    Global.setIsFirstTime(false);

    if (Global.userData?.token.isNotEmpty ?? false) {
      GoRouter.of(context).pushReplacement(AppRoutes.home);
    } else {
      GoRouter.of(context).pushReplacement(AppRoutes.login);
    }
  }

  void _skipToEnd() {
    _navigateToHome();
  }

  late List<OnboardingData> onboardingData = [
    OnboardingData(
      title: AppLocalizations.of(context)!.introPage1Title,
      description: AppLocalizations.of(context)!.introPage1Description,
      image: 'assets/images/intro-1.png',
    ),
    OnboardingData(
      title: AppLocalizations.of(context)!.introPage2Title,
      description: AppLocalizations.of(context)!.introPage2Description,
      image: 'assets/images/intro-2.png',
    ),
    OnboardingData(
      title: AppLocalizations.of(context)!.introPage3Title,
      description: AppLocalizations.of(context)!.introPage3Description,
      image: 'assets/images/intro-3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8F9FF),
                  Color(0xFFFFFFFF),
                ],
              ),
            ),
          ),

          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              return _buildOnboardingPage(onboardingData[index]);
            },
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => _buildIndicator(index),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        currentIndex == onboardingData.length - 1
                            ? AppLocalizations.of(context)!.getStarted
                            : AppLocalizations.of(context)!.next,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 50,
            right: 20,
            child: InkWell(
              onTap: _skipToEnd,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  AppLocalizations.of(context)!.skip,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    int index = onboardingData.indexOf(data);
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [introScreenWidget(data, index)],
          ),
        );
      },
    );
  }

  Widget introScreenWidget(OnboardingData data, int index) {
    return Column(
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: CustomImageContainer(
            imagePath:  data.image,
            height: 160,
          ),
        ),

        const SizedBox(height: 16),
        // Title with slide animation
        Transform.translate(
          offset: _getSlideOffset(index),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                height: 1.2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Description with delayed fade
        AnimatedOpacity(
          opacity: _fadeAnimation.value > 0.5 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Transform.translate(
            offset: Offset(0, (1 - _fadeAnimation.value) * 20),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Offset _getSlideOffset(int index) {
    switch (index) {
      case 0:
        return Offset(0, (1 - _fadeAnimation.value) * 50);
      case 1:
        return Offset((1 - _fadeAnimation.value) * 100, 0);
      case 2:
        return Offset((1 - _fadeAnimation.value) * -100, 0);
      default:
        return Offset(0, (1 - _fadeAnimation.value) * 50);
    }
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: currentIndex == index ? 24 : 8,
      decoration: BoxDecoration(
        color: currentIndex == index ? AppTheme.primaryColor : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
  });
}

