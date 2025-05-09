import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prescripta/models/client.dart';
import 'package:prescripta/services/client_services.dart';
import 'package:prescripta/services/pdf_services.dart';
import 'package:prescripta/formatters/phone_input_formatter.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;
  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final needsController = TextEditingController();
  final budgetController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      firstNameController.text = widget.client!.firstName;
      nameController.text = widget.client!.name;
      emailController.text = widget.client!.email;
      phoneController.text = widget.client!.phone;
      needsController.text = widget.client!.needs ?? '';
      budgetController.text = widget.client!.budget?.toString() ?? '';
      notesController.text = widget.client!.notes ?? '';
    }
  }

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      final client = Client(
        id: widget.client?.id,
        firstName: firstNameController.text,
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        needs: needsController.text,
        budget: double.tryParse(budgetController.text),
        notes: notesController.text,
      );

      try {
        if (widget.client == null) {
          await ClientService().createClient(client);
        } else {
          await ClientService().updateClient(client);
        }
        Navigator.pop(context);
      } catch (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('clients.save_error'.tr())));
      }
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int lines = 1,
    TextInputType inputType = TextInputType.text,
    IconData? icon,
    bool isBudget = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        validator: (value) {
          if (value == null || value.isEmpty) return 'clients.required'.tr();

          if (label.toLowerCase().contains('email')) {
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
            if (!emailRegex.hasMatch(value))
              return 'clients.invalid_email'.tr();
          }

          if (label.toLowerCase().contains('phone') ||
              label.toLowerCase().contains('téléphone')) {
            final phoneRegex = RegExp(r'^(?:\+33|0)[1-9](?:[\s.-]?\d{2}){4}$');
            if (!phoneRegex.hasMatch(value))
              return 'clients.invalid_phone'.tr();
          }

          if (isBudget) {
            final budget = value.replaceAll(RegExp(r'[^\d]'), '');
            if (budget.isEmpty) return 'clients.invalid_budget'.tr();
          }

          return null;
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          labelText: label,
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.deepPurple) : null,
          suffixText: isBudget ? '€' : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.client == null
              ? 'clients.add_client'.tr()
              : 'clients.edit_client'.tr(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                firstNameController,
                'clients.first_name'.tr(),
                icon: Icons.person,
              ),
              _buildTextField(
                nameController,
                'clients.name'.tr(),
                icon: Icons.person_outline,
              ),
              _buildTextField(
                emailController,
                'clients.email'.tr(),
                inputType: TextInputType.emailAddress,
                icon: Icons.email,
              ),
              _buildTextField(
                phoneController,
                'clients.phone'.tr(),
                inputType: TextInputType.phone,
                icon: Icons.phone,
                inputFormatters: [PhoneInputFormatter()],
              ),
              _buildTextField(
                needsController,
                'clients.needs'.tr(),
                icon: Icons.assignment,
              ),
              _buildTextField(
                budgetController,
                'clients.budget'.tr(),
                inputType: TextInputType.number,
                icon: Icons.euro,
                isBudget: true,
              ),
              _buildTextField(
                notesController,
                'clients.notes'.tr(),
                icon: Icons.note,
                lines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveClient,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.deepPurple.shade200,
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("clients.save".tr()),
              ),
              if (widget.client != null) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await PDFService.exportClientToPdf(widget.client!, context);
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(
                    "clients.export_pdf".tr(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    side: BorderSide(color: Colors.deepPurple),
                    elevation: 2,
                    shadowColor: Colors.deepPurpleAccent,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
