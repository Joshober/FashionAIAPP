import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_token.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final envFile = kReleaseMode
      ? 'assets/env/production.env'
      : (kIsWeb ? 'assets/env/dev.web.env' : 'assets/env/dev.env');
  await dotenv.load(fileName: envFile);

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
      theme: buildFashionAiTheme(),
    );
  }
}
