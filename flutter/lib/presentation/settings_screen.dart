import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/persist_avatar_web.dart'
    if (dart.library.io) '../core/persist_avatar_io.dart';
import '../core/user_avatar.dart';
import '../data/local/database.dart';
import '../data/models/default_categories.dart';
import '../logic/budget_providers.dart';
import 'auth_screens.dart';
import 'phase_five_screens.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Profile edit controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  bool _editingProfile = false;
  String _region = kRegions.first;
  bool _savingProfile = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _loadProfile();
  }

  void _loadProfile() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameCtrl.text = user.name;
      _emailCtrl.text = user.email;
      _region = user.region;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _savingProfile = true);
    final currency = ref.read(appCurrencyProvider);
    await ref.read(settingsRepositoryProvider).updateProfile(
          id: user.id,
          name: _nameCtrl.text.trim(),
          region: _region,
          currency: currency,
        );
    // Refresh current user in provider
    final updated =
        await ref.read(settingsRepositoryProvider).getProfileById(user.id);
    if (mounted) {
      ref.read(currentUserProvider.notifier).state = updated;
      setState(() {
        _editingProfile = false;
        _savingProfile = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign out')),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(googleAuthRepositoryProvider).signOut();
    await ref.read(localAuthRepositoryProvider).logout();
    ref.read(currentUserProvider.notifier).state = null;
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _pickAvatar() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) return;
    final stored = await persistAvatar(picked.path, user.id);
    await ref.read(settingsRepositoryProvider).updateAvatarPath(user.id, stored);
    final updated =
        await ref.read(settingsRepositoryProvider).getProfileById(user.id);
    if (!mounted) return;
    ref.read(currentUserProvider.notifier).state = updated;
  }

  Future<void> _changePassword() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    if (user.isGoogleAccount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Google accounts sign in with Google, not a password.')),
      );
      return;
    }
    final currentCtrl = TextEditingController();
    final nextCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nextCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    final error = await ref.read(localAuthRepositoryProvider).changePassword(
          userId: user.id,
          currentPassword: currentCtrl.text,
          newPassword: nextCtrl.text,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Password updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final currency = ref.watch(appCurrencyProvider);
    final biometricAsync = ref.watch(biometricAvailableProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final localeCode = ref.watch(appLocaleProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          // ----------------------------------------------------------------
          // Profile section
          // ----------------------------------------------------------------
          _sectionHeader(context, 'Profile', Icons.person_outline),
          Card(
            elevation: 0,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _editingProfile
                  ? _buildProfileEditForm(theme)
                  : _buildProfileView(user, theme),
            ),
          ),

          // ----------------------------------------------------------------
          // Currency section
          // ----------------------------------------------------------------
          _sectionHeader(context, 'Currency', Icons.currency_exchange),
          Card(
            elevation: 0,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Display Currency',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.black45)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: currency,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.attach_money_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF7F5F0),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    items: kSupportedCurrencies
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      await ref
                          .read(appCurrencyProvider.notifier)
                          .setCurrency(v);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Currency changed to $v. All screens updated.')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Changing currency updates amounts across the entire app.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.black38),
                  ),
                ],
              ),
            ),
          ),

          _sectionHeader(context, 'Language', Icons.language),
          Card(
            elevation: 0,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: DropdownButtonFormField<String>(
                value: localeCode,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.translate),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFF7F5F0),
                ),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (v) async {
                  if (v == null) return;
                  await ref.read(appLocaleProvider.notifier).setLocale(v);
                },
              ),
            ),
          ),

          _sectionHeader(context, 'More', Icons.tune),
          Card(
            elevation: 0,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text('Recurring expenses'),
                  subtitle: const Text(
                      'Subscriptions and bills that repeat automatically'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const RecurringRulesScreen()),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: const Text('Change password'),
                  onTap: _changePassword,
                ),
              ],
            ),
          ),

          // ----------------------------------------------------------------
          // Security section
          // ----------------------------------------------------------------
          _sectionHeader(context, 'Security', Icons.shield_outlined),
          Card(
            elevation: 0,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                biometricAsync.when(
                  data: (available) {
                    if (!available) {
                      return ListTile(
                        leading: const Icon(Icons.fingerprint,
                            color: Colors.black38),
                        title: const Text('Biometric Login'),
                        subtitle:
                            const Text('Not available on this device'),
                        trailing: const Icon(Icons.block,
                            color: Colors.black26, size: 20),
                      );
                    }
                    return SwitchListTile(
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return theme.colorScheme.primary;
                        }
                        return Colors.white;
                      }),
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return theme.colorScheme.primary.withOpacity(0.45);
                        }
                        return Colors.black26;
                      }),
                      trackOutlineColor:
                          const WidgetStatePropertyAll(Colors.transparent),
                      secondary: Icon(Icons.fingerprint,
                          color: biometricEnabled
                              ? theme.colorScheme.primary
                              : Colors.black45),
                      title: const Text('Biometric Login'),
                      subtitle: Text(biometricEnabled
                          ? 'Face ID / Fingerprint enabled'
                          : 'Use fingerprint or face to log in'),
                      value: biometricEnabled,
                      onChanged: (val) async {
                        if (val) {
                          final ok = await ref
                              .read(biometricRepositoryProvider)
                              .authenticate();
                          if (ok) {
                            await ref
                                .read(biometricEnabledProvider.notifier)
                                .setEnabled(true);
                          }
                        } else {
                          await ref
                              .read(biometricEnabledProvider.notifier)
                              .setEnabled(false);
                        }
                      },
                    );
                  },
                  loading: () => const ListTile(
                    leading: Icon(Icons.fingerprint),
                    title: Text('Biometric Login'),
                    trailing: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading:
                      const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Sign Out',
                      style: TextStyle(color: Colors.redAccent)),
                  onTap: _logout,
                ),
              ],
            ),
          ),

          // ----------------------------------------------------------------
          // About section
          // ----------------------------------------------------------------
          _sectionHeader(context, 'About', Icons.info_outline),
          Card(
            elevation: 0,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.savings_outlined),
                  title: Text('Smart Budget Manager'),
                  subtitle: Text('Version 2.0.0'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.storage_outlined),
                  title: const Text('Data Storage'),
                  subtitle: const Text('All data stored locally on device'),
                  trailing: Icon(Icons.check_circle_outline,
                      color: Colors.green.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView(UserProfile? user, ThemeData theme) {
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }
    return Column(
      children: [
        Row(
          children: [
            InkWell(
              onTap: _pickAvatar,
              child: UserAvatar(
                name: user.name,
                path: user.avatarPath,
                radius: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(user.email,
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.public, size: 14,
                          color: Colors.black38),
                      const SizedBox(width: 4),
                      Text(user.region,
                          style: const TextStyle(
                              color: Colors.black45, fontSize: 13)),
                    ],
                  ),
                  if (user.isGoogleAccount) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Google Account',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _pickAvatar,
          icon: const Icon(Icons.photo_camera_outlined, size: 18),
          label: const Text('Change photo'),
        ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: () => setState(() => _editingProfile = true),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileEditForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Name',
            prefixIcon: const Icon(Icons.person_outline),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: const Color(0xFFF7F5F0),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailCtrl,
          enabled: false, // Email cannot be changed
          decoration: InputDecoration(
            labelText: 'Email (cannot be changed)',
            prefixIcon: const Icon(Icons.email_outlined),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.black.withOpacity(0.04),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _region,
          decoration: InputDecoration(
            labelText: 'Region',
            prefixIcon: const Icon(Icons.public_outlined),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: const Color(0xFFF7F5F0),
          ),
          items: kRegions
              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
              .toList(),
          onChanged: (v) => setState(() => _region = v ?? _region),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _editingProfile = false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _savingProfile ? null : _saveProfile,
                child: _savingProfile
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionHeader(
      BuildContext context, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
