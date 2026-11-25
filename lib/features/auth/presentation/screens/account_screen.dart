import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flash_card_app/features/auth/domain/providers/auth_provider.dart';
import 'package:flash_card_app/features/flashcard/domain/providers/flashcard_provider.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      // The user id changed (or the account was upgraded), so pull the
      // flashcards that belong to the new account.
      await ref.read(flashcardProvider.notifier).reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success)),
      );
      setState(() {
        _passwordController.clear();
      });
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter an email and a password.');
      return;
    }
    await _run(
      () => AuthService.createAccountWithEmail(email: email, password: password),
      'Account created. Your flashcards now sync with this account.',
    );
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter an email and a password.');
      return;
    }
    await _run(
      () => AuthService.signInWithEmail(email: email, password: password),
      'Signed in.',
    );
  }

  Future<void> _signInWithGoogle() async {
    await _run(AuthService.signInWithGoogle, 'Signed in with Google.');
  }

  Future<void> _signOut() async {
    final user = FirebaseAuth.instance.currentUser;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: Text(
          'You will go back to a guest account on this browser. '
          'Your flashcards stay saved on '
          '${user?.email ?? 'this account'} and will be there when you sign in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _run(AuthService.signOut, 'Signed out. Using a guest account now.');
  }

  Future<void> _copyUid(String uid) async {
    await Clipboard.setData(ClipboardData(text: uid));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account ID copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch only to rebuild when the signed-in user changes; always read the
    // live value so account linking is reflected immediately.
    ref.watch(authStateProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildStatusCard(user),
                const SizedBox(height: 20),
                if (user.isAnonymous)
                  ..._buildGuestForm()
                else
                  ..._buildSignedInActions(user),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildStatusCard(User user) {
    final signedIn = !user.isAnonymous;
    final label = signedIn
        ? (user.email ?? user.displayName ?? 'Signed in')
        : 'Guest account';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: signedIn
              ? const [Color(0xFF43E97B), Color(0xFF38F9D7)]
              : const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: Icon(
              signedIn ? Icons.verified_user : Icons.person_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  signedIn
                      ? 'Your flashcards sync on every device you sign in to.'
                      : 'Guest data is stored only in this browser.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _copyUid(user.uid),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ID: ${_shortUid(user.uid)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.copy,
                          size: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortUid(String uid) =>
      uid.length <= 12 ? uid : '${uid.substring(0, 6)}...${uid.substring(uid.length - 4)}';

  List<Widget> _buildGuestForm() {
    return [
      const Text(
        'Sign in to keep your flashcards when you change device or browser.',
        style: TextStyle(fontSize: 14),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        decoration: const InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.mail_outline),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        autofillHints: const [AutofillHints.password],
        decoration: InputDecoration(
          labelText: 'Password',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        onSubmitted: (_) => _signIn(),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: _busy ? null : _signIn,
              child: Text(_busy ? 'Please wait...' : 'Sign in'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: _busy ? null : _createAccount,
              child: const Text('Create account'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'Creating an account upgrades this guest account, so the cards you '
        'already have here are kept. Signing into an existing account switches '
        'to that account.',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('or', style: TextStyle(color: Colors.grey.shade600)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: _busy ? null : _signInWithGoogle,
        icon: const Icon(Icons.g_mobiledata, size: 26),
        label: const Text('Continue with Google'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    ];
  }

  List<Widget> _buildSignedInActions(User user) {
    final providers = user.providerData
        .map((p) => p.providerId == 'google.com' ? 'Google' : 'Email')
        .toSet()
        .join(' + ');
    return [
      Text(
        'Sign-in method: ${providers.isEmpty ? 'Email' : providers}',
        style: TextStyle(color: Colors.grey.shade700),
      ),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        onPressed: _busy ? null : _signOut,
        icon: const Icon(Icons.logout),
        label: const Text('Sign out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    ];
  }
}
