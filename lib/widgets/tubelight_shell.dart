import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_token.dart';
import '../theme/app_theme.dart';
import 'simple_sign_in_dialog.dart';

int tubelightIndexForPath(String path) {
  if (path == '/' || path.isEmpty) return 0;
  if (path.startsWith('/wardrobe')) return 1;
  if (path.startsWith('/generate')) return 2;
  if (path.startsWith('/mirror')) return 3;
  if (path.startsWith('/settings')) return 4;
  return -1;
}

class TubelightShell extends ConsumerWidget {
  const TubelightShell({super.key, required this.child});

  final Widget child;

  static const _items = <_NavItem>[
    _NavItem('Dashboard', Icons.dashboard_outlined, Icons.dashboard, '/'),
    _NavItem('Wardrobe', Icons.checkroom_outlined, Icons.checkroom, '/wardrobe'),
    _NavItem('Generate', Icons.auto_awesome_outlined, Icons.auto_awesome, '/generate'),
    _NavItem('Mirror', Icons.camera_front_outlined, Icons.camera_front, '/mirror'),
    _NavItem('Settings', Icons.settings_outlined, Icons.settings, '/settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final idx = tubelightIndexForPath(path);
    final token = ref.watch(authTokenProvider);
    final authed = token != null && token.isNotEmpty;

    return Scaffold(
      backgroundColor: SwColors.white,
      body: child,
      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xE6FFFFFF),
                border: Border(top: BorderSide(color: SwColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    children: [
                      for (var i = 0; i < _items.length; i++)
                        Expanded(
                          child: _TubelightItem(
                            item: _items[i],
                            active: i == idx,
                            onTap: () => context.go(_items[i].location),
                          ),
                        ),
                      PopupMenuButton<String>(
                        tooltip: 'More',
                        icon: const Icon(Icons.more_horiz, color: SwColors.black),
                        onSelected: (v) {
                          if (v == 'chat') {
                            context.push('/chat');
                          } else if (v == 'mirror_ctx') {
                            context.push('/mirror/context');
                          } else if (v == 'model') {
                            context.push('/modelo/ejemplos');
                          }
                        },
                        itemBuilder: (ctx) => const [
                          PopupMenuItem(value: 'chat', child: Text('Chat')),
                          PopupMenuItem(value: 'mirror_ctx', child: Text('Mirror context')),
                          PopupMenuItem(value: 'model', child: Text('Model examples')),
                        ],
                      ),
                      if (!authed)
                        TextButton(
                          onPressed: () => showSimpleSignInDialog(context, ref),
                          child: const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.activeIcon, this.location);

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String location;
}

class _TubelightItem extends StatelessWidget {
  const _TubelightItem({required this.item, required this.active, required this.onTap});

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? SwColors.accent : SwColors.gray;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 3,
              width: active ? 28 : 0,
              decoration: BoxDecoration(
                color: SwColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            Icon(active ? item.activeIcon : item.icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              item.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
