import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> persistAvatar(String sourcePath, int userId) async {
  final dir = await getApplicationDocumentsDirectory();
  final dest = File('${dir.path}/avatar_$userId${p.extension(sourcePath)}');
  await File(sourcePath).copy(dest.path);
  return dest.path;
}
