import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prescripta/widgets/custom_drawer.dart';
import 'package:prescripta/services/auth_services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SavedPdfsScreen extends StatefulWidget {
  const SavedPdfsScreen({super.key});

  @override
  State<SavedPdfsScreen> createState() => _SavedPdfsScreenState();
}

class _SavedPdfsScreenState extends State<SavedPdfsScreen> {
  final AuthService authService = AuthService();
  List<File> pdfFiles = [];
  String role = "";
  String userId = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfoAndFiles();
    });
  }

  Future<void> _loadUserInfoAndFiles() async {
    final token = await authService.getToken();
    if (token.isNotEmpty) {
      final decoded = JwtDecoder.decode(token);
      userId = decoded["id"] ?? "";
      role = (decoded["role"] ?? "").toString().trim().toLowerCase();

      print("🧩 CONNECTED ROLE: $role");
      print("🧩 CONNECTED USER ID: $userId");

      await _loadSavedPdfs();
    }
  }

  Future<void> _loadSavedPdfs() async {
    setState(() => isLoading = true);
    final directory = await getApplicationDocumentsDirectory();
    final rootDir = Directory("${directory.path}/saved_pdfs");

    if (!await rootDir.exists()) {
      setState(() {
        pdfFiles = [];
        isLoading = false;
      });
      return;
    }

    List<File> files = [];

    if (role == "admin") {
      final userDirs = await rootDir.list().toList();
      for (final entity in userDirs) {
        if (entity is Directory) {
          final pdfs =
              await entity
                  .list()
                  .where((file) => file.path.endsWith('.pdf'))
                  .toList();
          files.addAll(pdfs.cast<File>());
        }
      }
    } else {
      final userDir = Directory("${rootDir.path}/$userId");
      if (await userDir.exists()) {
        final pdfs =
            await userDir
                .list()
                .where((file) => file.path.endsWith('.pdf'))
                .toList();
        files.addAll(pdfs.cast<File>());
      }
    }

    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    setState(() {
      pdfFiles = files;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (role.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('history.title'.tr()),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: CustomDrawer(currentPage: '/saved-pdfs', role: role),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : pdfFiles.isEmpty
              ? Center(child: Text('history.empty'.tr()))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pdfFiles.length,
                itemBuilder: (context, index) {
                  final file = pdfFiles[index];
                  final createdAt = file.lastModifiedSync();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                      ),
                      title: Text(file.uri.pathSegments.last),
                      subtitle: Text(
                        'Créé le ${DateFormat('dd/MM/yyyy').format(createdAt)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => OpenFile.open(file.path),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
