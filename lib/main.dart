import 'package:flutter/material.dart';

void main() {
  runApp(const FashionAIApp());
}

class FashionAIApp extends StatelessWidget {
  const FashionAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fashion AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D2C4D),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const FashionAIHome(),
    );
  }
}

class FashionAIHome extends StatelessWidget {
  const FashionAIHome({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion AI'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.style_rounded, size: 72, color: scheme.primary),
              const SizedBox(height: 24),
              Text(
                'Welcome to Fashion AI',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your AI-powered style assistant.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
