class EquipmentModel {
  final String id;
  final String name;
  final String category;
  final double basePriceUSD;
  final String necessity; // required, recommended, optional
  final List<String> alternatives;
  final String imageUrl;
  final String description;

  EquipmentModel({
    required this.id,
    required this.name,
    required this.category,
    required this.basePriceUSD,
    required this.necessity,
    required this.alternatives,
    required this.imageUrl,
    required this.description,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      basePriceUSD: (json['base_price_usd'] ?? 0).toDouble(),
      necessity: json['necessity'] ?? 'optional',
      alternatives: List<String>.from(json['alternatives'] ?? []),
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'base_price_usd': basePriceUSD,
      'necessity': necessity,
      'alternatives': alternatives,
      'image_url': imageUrl,
      'description': description,
    };
  }
}

class CurrencyRate {
  final String code;
  final String symbol;
  final double rate;
  final String flag;

  CurrencyRate({
    required this.code,
    required this.symbol,
    required this.rate,
    required this.flag,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      code: json['code'] ?? '',
      symbol: json['symbol'] ?? '',
      rate: (json['rate'] ?? 1.0).toDouble(),
      flag: json['flag'] ?? '',
    );
  }
}