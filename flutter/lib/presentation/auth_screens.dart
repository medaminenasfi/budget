import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/default_categories.dart';
import '../logic/budget_providers.dart';

// ---------------------------------------------------------------------------
// Onboarding — multi-step first-launch flow
// ---------------------------------------------------------------------------

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  // Step 1 — account
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  // Step 2 — region & currency
  String _region = kRegions.first;
  String _currency = 'TND';

  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_page == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        setState(() => _error = 'Please enter your name.');
        return;
      }
      if (!_emailCtrl.text.contains('@')) {
        setState(() => _error = 'Please enter a valid email.');
        return;
      }
      if (_passwordCtrl.text.length < 6) {
        setState(() => _error = 'Password must be at least 6 characters.');
        return;
      }
    }
    setState(() => _error = null);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _page++);
  }

  Future<void> _finish() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(localAuthRepositoryProvider);
    final profile = await repo.signUp(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      region: _region,
      currency: _currency,
    );
    if (!mounted) return;
    if (profile == null) {
      setState(() {
        _loading = false;
        _error = 'This email is already registered. Please log in.';
      });
      return;
    }
    ref.read(currentUserProvider.notifier).state = profile;
    await ref.read(appCurrencyProvider.notifier).setCurrency(_currency);

    // Offer biometric setup
    final biometricAvailable =
        await ref.read(biometricRepositoryProvider).isAvailable();
    if (!mounted) return;
    if (biometricAvailable) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => const BiometricSetupScreen(isOnboarding: true)),
      );
    } else {
      _goHome();
    }
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    final repo = ref.read(googleAuthRepositoryProvider);
    final profile = await repo.signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    if (profile == null) {
      setState(() => _error =
          'Google Sign-In failed or was cancelled. Make sure google-services.json is configured.');
      return;
    }
    ref.read(currentUserProvider.notifier).state = profile;
    _goHome();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: List.generate(2, (i) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i <= _page
                            ? theme.colorScheme.primary
                            : Colors.black12,
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildAccountStep(theme),
                  _buildPreferencesStep(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.savings_outlined,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 24),
          Text('Welcome to\nSmart Budget',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 8),
          Text('Create your account to get started.',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: Colors.black54)),
          const SizedBox(height: 32),
          _field(
            controller: _nameCtrl,
            label: 'Your name',
            icon: Icons.person_outline,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _field(
            controller: _emailCtrl,
            label: 'Email address',
            icon: Icons.email_outlined,
            keyboard: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _loading ? null : _nextPage,
              style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('or', style: TextStyle(color: Colors.black45)),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _loading ? null : _googleSignIn,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Colors.black12),
                backgroundColor: Colors.white,
              ),
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: const Text('Continue with Google',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text('Already have an account? Sign in'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Almost done!',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Set your region and preferred currency.',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: Colors.black54)),
          const SizedBox(height: 32),
          // Region
          DropdownButtonFormField<String>(
            value: _region,
            decoration: InputDecoration(
              labelText: 'Region / Country',
              prefixIcon: const Icon(Icons.public_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            items: kRegions
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => _region = v ?? _region),
          ),
          const SizedBox(height: 20),
          // Currency
          DropdownButtonFormField<String>(
            value: _currency,
            decoration: InputDecoration(
              labelText: 'Preferred currency',
              prefixIcon: const Icon(Icons.attach_money_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            items: kSupportedCurrencies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _currency = v ?? _currency),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _loading ? null : _finish,
              style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Create Account',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: _loading
                  ? null
                  : () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      setState(() => _page--);
                    },
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      textCapitalization: capitalization,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Login Screen
// ---------------------------------------------------------------------------

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(localAuthRepositoryProvider);
    final profile = await repo.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (profile == null) {
      setState(() => _error = 'Incorrect email or password.');
      return;
    }
    ref.read(currentUserProvider.notifier).state = profile;
    _goHome();
  }

  Future<void> _loginBiometric() async {
    final repo = ref.read(biometricRepositoryProvider);
    final settings = ref.read(settingsRepositoryProvider);
    final enabled = await settings.isBiometricEnabled();
    if (!enabled) return;
    final ok = await repo.authenticate();
    if (!mounted) return;
    if (ok) {
      final profile = await settings.getProfile();
      if (profile != null) {
        ref.read(currentUserProvider.notifier).state = profile;
        _goHome();
      }
    }
  }

  Future<void> _googleLogin() async {
    setState(() => _loading = true);
    final repo = ref.read(googleAuthRepositoryProvider);
    final profile = await repo.signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    if (profile == null) {
      setState(
          () => _error = 'Google Sign-In failed. Please try again.');
      return;
    }
    ref.read(currentUserProvider.notifier).state = profile;
    _goHome();
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final biometricAsync = ref.watch(biometricAvailableProvider);
    final settingsRepo = ref.watch(settingsRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.savings_outlined,
                        color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 28),
                Text('Welcome back',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Sign in to your budget',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: Colors.black54)),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => _login(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_error!,
                                style: const TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _loading ? null : _login,
                    style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Sign In',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                // Biometric button
                biometricAsync.when(
                  data: (available) => FutureBuilder<bool>(
                    future: settingsRepo.isBiometricEnabled(),
                    builder: (context, snap) {
                      if (available && (snap.data ?? false)) {
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _loginBiometric,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: Colors.black12),
                              backgroundColor: Colors.white,
                            ),
                            icon:
                                const Icon(Icons.fingerprint, size: 24),
                            label: const Text('Use Biometrics',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or',
                          style: TextStyle(color: Colors.black45)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _googleLogin,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Colors.black12),
                      backgroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Continue with Google',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => const OnboardingScreen()),
                    ),
                    child:
                        const Text("Don't have an account? Sign up"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Biometric Setup Screen
// ---------------------------------------------------------------------------

class BiometricSetupScreen extends ConsumerWidget {
  const BiometricSetupScreen({super.key, this.isOnboarding = false});

  final bool isOnboarding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Future<void> enable() async {
      final biometricRepo = ref.read(biometricRepositoryProvider);
      final settingsRepo = ref.read(settingsRepositoryProvider);
      final ok = await biometricRepo.authenticate();
      if (ok) {
        await settingsRepo.setBiometricEnabled(true);
      }
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    }

    Future<void> skip() async {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.fingerprint,
                    size: 52, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 32),
              Text(
                'Enable Biometric Login?',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Use Face ID, Touch ID, or fingerprint to quickly access your budget without typing your password.',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: Colors.black54, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: enable,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Enable Biometrics',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: skip,
                child: const Text('Skip for now',
                    style: TextStyle(color: Colors.black54)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
