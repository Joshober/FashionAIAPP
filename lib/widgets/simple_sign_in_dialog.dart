import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_session.dart';

Future<void> showSimpleSignInDialog(BuildContext context, WidgetRef ref) async {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  try {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Sign in'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
              ),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.maybeOf(context);
                try {
                  await ref.read(authSessionProvider).signIn(emailCtrl.text, passCtrl.text);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } on DioException catch (e) {
                  final msg = e.response?.data is Map && (e.response!.data as Map)['error'] != null
                      ? '${(e.response!.data as Map)['error']}'
                      : (e.message ?? 'Sign in failed');
                  messenger?.showSnackBar(SnackBar(content: Text(msg)));
                } catch (e) {
                  messenger?.showSnackBar(SnackBar(content: Text('$e')));
                }
              },
              child: const Text('Sign in'),
            ),
          ],
        );
      },
    );
  } finally {
    emailCtrl.dispose();
    passCtrl.dispose();
  }
}
