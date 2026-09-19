import 'package:flutter/material.dart';

ImageProvider? avatarProvider(String? path) {
  if (path == null || path.isEmpty) return null;
  return NetworkImage(path);
}
