import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/mock_lost_found_repository.dart';
import 'models/claims_model.dart';
import 'models/items_model.dart';
import 'router.dart';

void main() {
  final repository = MockLostFoundRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<MockLostFoundRepository>.value(value: repository),
        ChangeNotifierProvider(create: (_) => ItemsModel(repository)..load()),
        ChangeNotifierProvider(create: (_) => ClaimsModel(repository)..load()),
      ],
      child: const LostFoundApp(),
    ),
  );
}

class LostFoundApp extends StatelessWidget {
  const LostFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LostFound UTM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E40AF),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
