import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:prescripta/models/client.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:prescripta/services/auth_services.dart';

class PDFService {
  static Future<void> exportClientToPdf(
    Client client,
    BuildContext context,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);

    final ByteData bytes = await rootBundle.load(
      'assets/images/prescripta_logo.png',
    );
    final logo = pw.MemoryImage(bytes.buffer.asUint8List());

    final userId = await AuthService().getUserId();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Container(
            color: PdfColors.grey100,
            child: pw.Column(
              children: [
                pw.SizedBox(height: 16),
                pw.Center(child: pw.Image(logo, width: 60)),
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Text(
                    'Fiche Client',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.deepPurple,
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(color: PdfColors.grey),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildField("Prénom", client.firstName),
                      _buildField("Nom", client.name),
                      _buildField("Email", client.email),
                      _buildField("Téléphone", client.phone),
                      _buildField("Besoins", client.needs ?? "-"),
                      _buildField(
                        "Budget",
                        client.budget != null
                            ? "${client.budget!.toStringAsFixed(2)} EUR"
                            : "-",
                      ),
                      _buildField("Notes", client.notes ?? "-"),
                      pw.Divider(),
                      pw.Text(
                        "Date de création : $formattedDate",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Divider(),
                pw.Center(
                  child: pw.Text(
                    "Document généré par Prescripta",
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory userDir = Directory("${appDocDir.path}/saved_pdfs/$userId");

    if (!await userDir.exists()) {
      await userDir.create(recursive: true);
    }

    final file = File(
      "${userDir.path}/client_${client.firstName}_${client.name}_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  static pw.Widget _buildField(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "$title :",
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.Text(value, style: pw.TextStyle(fontSize: 12)),
          pw.Divider(),
        ],
      ),
    );
  }
}
