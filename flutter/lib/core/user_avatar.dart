import 'package:flutter/material.dart';

import 'avatar_provider_web.dart'
    if (dart.library.io) 'avatar_provider_io.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.name,
    this.path,
    this.radius = 20,
    super.key,
  });

  final String name;
  final String? path;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = avatarProvider(path);
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      backgroundImage: image,
      foregroundColor: theme.colorScheme.primary,
      child: image == null
          ? Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}
