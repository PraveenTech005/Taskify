import 'package:flutter/material.dart';
import 'dart:async';
import 'package:taskify/components/navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const Navigation()),
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const Navigation(),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/onboarding_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "TASKIFY",
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'Changa',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "\"Simplify Tasks, Amplify Results\"",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Chivo',
                    color: Theme.of(context).colorScheme.onSurface,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
