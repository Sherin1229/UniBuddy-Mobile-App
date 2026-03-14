import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/resource_sharing/presentation/state/resource_library_provider.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResourceLibraryProvider(),
      child: MaterialApp(
        title: 'UniBuddy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)), // Adjusted to match primaryBrand
          useMaterial3: true,
        ),
        home: const OnboardingPage(),
      ),
    );
  }
}
