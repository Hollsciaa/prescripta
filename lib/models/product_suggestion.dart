class ProductSuggestion {
  final String translationKey;
  final String partner;
  final String? url;

  ProductSuggestion({
    required this.translationKey,
    required this.partner,
    this.url,
  });

  factory ProductSuggestion.fromJson(Map<String, dynamic> json) {
    return ProductSuggestion(
      translationKey: json['translation_key'] ?? '',
      partner: json['partner'] ?? '',
      url: json['url'],
    );
  }
}
