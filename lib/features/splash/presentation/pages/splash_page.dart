import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _activeDot = 0;
  Timer? _dotTimer;

  @override
  void initState() {
    super.initState();

    _dotTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (!mounted) return;

      setState(() {
        _activeDot = (_activeDot + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            final contentWidth = screenWidth > 600 ? 390.0 : screenWidth;
            final logoSize = screenWidth > 600
                ? 112.0
                : (screenWidth * 0.285).clamp(96.0, 112.0);

            final titleSize = screenWidth > 600
                ? 31.0
                : (screenWidth * 0.079).clamp(26.0, 31.0);

            final subtitleSize = screenWidth > 600
                ? 16.0
                : (screenWidth * 0.041).clamp(14.0, 16.0);

            final verticalOffset = screenHeight < 600
                ? 0.0
                : -screenHeight * 0.035;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: Transform.translate(
                  offset: Offset(0, verticalOffset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LogoBox(size: logoSize),
                      SizedBox(height: logoSize * 0.23),
                      Text(
                        'Easy Shop',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      SizedBox(height: logoSize * 0.05),
                      Text(
                        'Merchant Portal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: logoSize * 0.48),
                      _PageIndicator(activeDot: _activeDot),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: [
          BoxShadow(
            color: const Color(0x33000000),
            blurRadius: size * 0.18,
            offset: Offset(0, size * 0.09),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/easy_shop_logo.png',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.activeDot});

  final int activeDot;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isActive = index == activeDot;

        return Padding(
          padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: isActive ? 10 : 8,
            height: isActive ? 10 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.white : Colors.white70,
            ),
          ),
        );
      }),
    );
  }
}
