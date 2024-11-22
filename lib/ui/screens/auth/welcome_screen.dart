import 'package:flutter/material.dart';
import 'package:app/ui/screens/auth/login_screen.dart';
import 'package:app/ui/screens/auth/registration_screen.dart';
import 'package:app/constants/constants.dart';
import 'package:introduction_screen/introduction_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  List<PageViewModel> getPages() {
    return [
      PageViewModel(
        title: "Welcome to VirtuLearn",
        body: "Your personalized learning journey starts here",
        image: Image.asset("assets/screens/onboarding1.png"),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      PageViewModel(
        title: "Interactive Learning",
        body: "Engage with AI-powered quizzes and personalized content",
        image: Image.asset("assets/screens/onboarding2.png"),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      PageViewModel(
        title: "Track Your Progress",
        body: "Monitor your learning journey with detailed analytics",
        image: Image.asset("assets/screens/onboarding3.png"),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
  }

  Widget _buildAuthButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.lg),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(60),
          topRight: Radius.circular(60),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: Dimensions.buttonHeight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.borderRadiusLg),
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ),
              child: Text(
                "Login",
                style: TextStyles.buttonText.copyWith(color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.md),
          SizedBox(
            width: double.infinity,
            height: Dimensions.buttonHeight,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.borderRadiusLg),
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegistrationScreen()),
              ),
              child: Text(
                "Sign Up",
                style: TextStyles.buttonText.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: getPages(),
        showSkipButton: true,
        skip: const Text("Skip"),
        next: const Text("Next"),
        done: const Text("Done"),
        onDone: () {
          // Show auth buttons when onboarding is complete
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _buildAuthButtons(context),
          );
        },
        onSkip: () {
          // Show auth buttons when user skips
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _buildAuthButtons(context),
          );
        },
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: AppColors.primary,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}
