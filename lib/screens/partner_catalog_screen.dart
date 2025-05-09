import 'package:flutter/material.dart';
import 'package:prescripta/models/product_suggestion.dart';
import 'package:prescripta/services/partner_product_service.dart';
import 'package:prescripta/widgets/custom_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prescripta/services/auth_services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class PartnerCatalogScreen extends StatefulWidget {
  const PartnerCatalogScreen({super.key});

  @override
  State<PartnerCatalogScreen> createState() => _PartnerCatalogScreenState();
}

class _PartnerCatalogScreenState extends State<PartnerCatalogScreen> {
  List<ProductSuggestion> products = [];
  final AuthService authService = AuthService();
  String role = "";

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final token = await authService.getToken();
    if (token.isNotEmpty) {
      final decoded = JwtDecoder.decode(token);
      setState(() {
        role = decoded["role"] ?? "";
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final loaded = await PartnerProductService().loadAllProducts();
      setState(() {
        products = loaded;
      });
    } catch (e) {
      print("❌ Erreur chargement produits : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("partner_catalog.load_error".tr())),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception("Could not launch $url");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("partner_catalog.link_error".tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedByPartner = <String, List<ProductSuggestion>>{};
    for (var product in products) {
      groupedByPartner.putIfAbsent(product.partner, () => []).add(product);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("partner_catalog.title".tr()),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: CustomDrawer(currentPage: '/partner-catalog', role: role),
      body:
          products.isEmpty
              ? Center(child: Text("partner_catalog.empty".tr()))
              : ListView(
                padding: const EdgeInsets.all(16),
                children:
                    groupedByPartner.entries.map((entry) {
                      final partner = entry.key;
                      final items = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partner,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...items.map((product) {
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.label,
                                  color: Colors.indigo,
                                ),
                                title: Text(product.translationKey?.tr() ?? ""),
                                subtitle:
                                    product.url != null
                                        ? Text(
                                          product.url!,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        )
                                        : Text("partner_catalog.no_link".tr()),
                                trailing:
                                    product.url != null
                                        ? IconButton(
                                          icon: const Icon(Icons.open_in_new),
                                          onPressed:
                                              () => _openUrl(product.url!),
                                        )
                                        : null,
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                        ],
                      );
                    }).toList(),
              ),
    );
  }
}
