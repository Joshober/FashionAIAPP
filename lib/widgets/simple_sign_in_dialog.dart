import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_session.dart';
import '../theme/app_theme.dart';

Future<void> showSimpleSignInDialog(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _AuthDialog(ref: ref),
  );
}

class _AuthDialog extends StatefulWidget {
  const _AuthDialog({required this.ref});
  final WidgetRef ref;

  @override
  State<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<_AuthDialog> {
  bool _isSignUp = false;
  bool _busy = false;
  String? _error;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Email and password are required.');
      return;
    }
    if (_isSignUp && pass != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (_isSignUp && pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final session = widget.ref.read(authSessionProvider);
      if (_isSignUp) {
        await session.signUp(email, pass);
      } else {
        await session.signIn(email, pass);
      }
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response!.data as Map)['error'] != null
          ? '${(e.response!.data as Map)['error']}'
          : (e.message ?? (_isSignUp ? 'Sign-up failed' : 'Sign-in failed'));
      if (mounted) setState(() => _error = msg);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: SwColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      title: Row(
        children: [
          Expanded(
            child: Text(
              _isSignUp ? 'Create account' : 'Sign in',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 0.4,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Tab toggle ──────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: SwColors.light,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  _Tab(
                    label: 'Sign in',
                    active: !_isSignUp,
                    onTap: () => setState(() {
                      _isSignUp = false;
                      _error = null;
                    }),
                  ),
                  _Tab(
                    label: 'Sign up',
                    active: _isSignUp,
                    onTap: () => setState(() {
                      _isSignUp = true;
                      _error = null;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Fields ──────────────────────────────────────────────────────
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: SwColors.gray,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              obscureText: _obscurePass,
              textInputAction: _isSignUp ? TextInputAction.next : TextInputAction.done,
              onSubmitted: _isSignUp ? null : (_) => _submit(),
            ),
            if (_isSignUp) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _confirmCtrl,
                decoration: const InputDecoration(labelText: 'Confirm password'),
                obscureText: _obscurePass,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
            ],
            // ── Error ───────────────────────────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(
                  color: SwColors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 4),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(_isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN'),
          ),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? SwColors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: active ? Colors.white : SwColors.gray,
            ),
          ),
        ),
      ),
    );
  }
}
