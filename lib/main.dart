import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/resource_sharing/presentation/pages/resource_library_page.dart';
import 'features/resource_sharing/presentation/state/resource_library_provider.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D9E8C)),
          useMaterial3: true,
        ),
        home: const ResourceLibraryPage(),
      ),
    );
  }
}
