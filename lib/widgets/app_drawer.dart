import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF3D2C4D)),
            child: Text(
              'Fashion AI',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.checkroom_outlined),
            title: const Text('Wardrobe'),
            onTap: () {
              Navigator.pop(context);
              context.go('/wardrobe');
            },
          ),
          ListTile(
            leading: const Icon(Icons.layers_outlined),
            title: const Text('Saved outfits'),
            onTap: () {
              Navigator.pop(context);
              context.go('/wardrobe/outfits');
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('Generate'),
            onTap: () {
              Navigator.pop(context);
              context.go('/generate');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Chat'),
            onTap: () {
              Navigator.pop(context);
              context.go('/chat');
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_front_outlined),
            title: const Text('Mirror'),
            onTap: () {
              Navigator.pop(context);
              context.go('/mirror');
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: const Text('Mirror context'),
            onTap: () {
              Navigator.pop(context);
              context.go('/mirror/context');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Model examples'),
            onTap: () {
              Navigator.pop(context);
              context.go('/modelo/ejemplos');
            },
          ),
        ],
      ),
    );
  }
}
