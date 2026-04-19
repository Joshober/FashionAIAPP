import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/chat_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/generate_outfit_detail_screen.dart';
import '../screens/generate_screen.dart';
import '../screens/mirror_context_screen.dart';
import '../screens/mirror_screen.dart';
import '../screens/model_examples_screen.dart';
import '../screens/outfit_detail_screen.dart';
import '../screens/prenda_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/wardrobe_outfits_screen.dart';
import '../screens/wardrobe_screen.dart';
import '../widgets/tubelight_shell.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/auth-callback',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Signing in…')),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => TubelightShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/wardrobe',
            builder: (context, state) => const WardrobeScreen(),
          ),
          GoRoute(
            path: '/wardrobe/outfits',
            builder: (context, state) => const WardrobeOutfitsScreen(),
          ),
          GoRoute(
            path: '/wardrobe/prenda/:id',
            builder: (context, state) => PrendaDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/wardrobe/outfit/:id',
            builder: (context, state) => OutfitDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/prendas',
            redirect: (_, __) => '/wardrobe',
          ),
          GoRoute(
            path: '/generate',
            builder: (context, state) => const GenerateScreen(),
          ),
          GoRoute(
            path: '/outfits',
            redirect: (_, __) => '/generate',
          ),
          GoRoute(
            path: '/generate/outfit',
            builder: (context, state) {
              final extra = state.extra;
              Map<String, dynamic>? map;
              if (extra is Map<String, dynamic>) {
                map = extra;
              } else if (extra is Map) {
                map = Map<String, dynamic>.from(extra);
              }
              return GenerateOutfitDetailScreen(outfit: map);
            },
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/mirror',
            builder: (context, state) => const MirrorScreen(),
          ),
          GoRoute(
            path: '/mirror/context',
            builder: (context, state) => const MirrorContextScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/modelo/ejemplos',
            builder: (context, state) => const ModelExamplesScreen(),
          ),
        ],
      ),
    ],
  );
});
