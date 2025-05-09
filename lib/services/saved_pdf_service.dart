import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/saved_pdf.dart';

class SavedPdfService {
  static Future<List<SavedPdf>> loadSavedPdfs() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync().where((f) => f.path.endsWith('.pdf')).toList();

    return files.map((file) {
      final stat = file.statSync();
      return SavedPdf(
        name: file.uri.pathSegments.last,
        path: file.path,
        createdAt: stat.modified,
      );
    }).toList();
  }
}
