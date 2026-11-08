import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/auth_api.dart';
import 'data/file_api.dart';
import 'data/http_lost_found_repository.dart';
import 'data/token_store.dart';
import 'models/claims_model.dart';
import 'models/items_model.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiBase = kIsWeb
      ? 'http://localhost:8080'
      : (defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8080'
          : 'http://localhost:8080');

  final tokens = TokenStore();
  final loggedIn = await tokens.read() != null;

  appRouter = createAppRouter(loggedIn: loggedIn);

  final repository = HttpLostFoundRepository(
    apiBase,
    tokens,
    onUnauthorized: () => appRouter.go('/login'),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthApi>(create: (_) => AuthApi(apiBase, tokens)),
        Provider<FileApi>(create: (_) => FileApi(apiBase, tokens)),
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
