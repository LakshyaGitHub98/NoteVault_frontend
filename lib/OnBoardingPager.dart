import 'package:flutter/material.dart';
import 'screens/starters/Screen1.dart';
import 'screens/starters/Screen2.dart';
import 'screens/starters/Screen3.dart';

class OnboardingPager extends StatefulWidget {
  const OnboardingPager({super.key});

  @override
  State<OnboardingPager> createState() => _OnboardingPagerState();
}

class _OnboardingPagerState extends State<OnboardingPager> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _controller,
        physics: BouncingScrollPhysics(),
        children: [
          Screen1(controller:_controller),
          Screen2(controller:_controller),
          Screen3(controller:_controller),
        ],
      ),
    );
  }
}