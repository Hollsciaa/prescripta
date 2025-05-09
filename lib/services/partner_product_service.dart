import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product_suggestion.dart';

class PartnerProductService {
  Future<List<ProductSuggestion>> loadAllProducts() async {
    final List<String> files = [
      'assets/partners/forever.json',
      'assets/partners/infinity.json',
      'assets/partners/doterra.json',
      'assets/partners/lucibell.json',
      'assets/partners/podcalm.json',
      'assets/partners/serenity.json',
      'assets/partners/mandalas.json',
      'assets/partners/spadaccini.json',
    ];

    List<ProductSuggestion> allProducts = [];

    for (String path in files) {
      final String content = await rootBundle.loadString(path);
      final List<dynamic> data = json.decode(content);
      final products = data.map((e) => ProductSuggestion.fromJson(e)).toList();
      allProducts.addAll(products);
    }

    return allProducts;
  }
}
