import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_token.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/env/dev.env');

  final container = ProviderContainer();
  await container.read(authTokenProvider.notifier).restore();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FashionAIApp(),
    ),
  );
}

class FashionAIApp extends ConsumerWidget {
  const FashionAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      routerConfig: router,
      title: 'Fashion AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D2C4D),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
    );
  }
}
