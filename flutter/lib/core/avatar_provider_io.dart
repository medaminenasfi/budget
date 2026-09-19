import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider? avatarProvider(String? path) {
  if (path == null || path.isEmpty) return null;
  final file = File(path);
  if (!file.existsSync()) return null;
  return FileImage(file);
}
