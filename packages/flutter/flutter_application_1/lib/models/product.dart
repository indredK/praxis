class Product {
  final String id;
  final String name;
  final String company;
  final String category;
  final String imageUrl;
  final double price;
  final DateTime releaseDate;
  final Map<String, dynamic> specs;

  Product({
    required this.id,
    required this.name,
    required this.company,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.releaseDate,
    required this.specs,
  });

  // 从 JSON 创建 Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      company: json['company'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toDouble(),
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      specs: Map<String, dynamic>.from(json['specs'] as Map),
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'category': category,
      'imageUrl': imageUrl,
      'price': price,
      'releaseDate': releaseDate.toIso8601String(),
      'specs': specs,
    };
  }
}

// 产品规格对比项
class SpecComparison {
  final String name;
  final String unit;
  final List<SpecValue> values;

  SpecComparison({
    required this.name,
    required this.unit,
    required this.values,
  });

  factory SpecComparison.fromJson(Map<String, dynamic> json) {
    return SpecComparison(
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      values:
          (json['values'] as List<dynamic>?)
              ?.map((value) => SpecValue.fromJson(value))
              .toList() ??
          [],
    );
  }
}

class SpecValue {
  final String productId;
  final String productName;
  final dynamic value;
  final String displayValue;

  SpecValue({
    required this.productId,
    required this.productName,
    required this.value,
    required this.displayValue,
  });

  factory SpecValue.fromJson(Map<String, dynamic> json) {
    return SpecValue(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      value: json['value'],
      displayValue: json['displayValue'] ?? '',
    );
  }
}

// 图表数据类型
enum ChartType {
  bar, // 柱状图
  radar, // 雷达图
  line, // 折线图
  scatter, // 散点图
}

// 图表数据
class ChartData {
  final ChartType type;
  final String title;
  final List<ChartItem> items;

  ChartData({required this.type, required this.title, required this.items});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      type: ChartType.values.firstWhere(
        (e) => e.toString() == 'ChartType.${json['type']}',
        orElse: () => ChartType.bar,
      ),
      title: json['title'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => ChartItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ChartItem {
  final String label;
  final double value;
  final String? color;
  final Map<String, dynamic>? metadata;

  ChartItem({
    required this.label,
    required this.value,
    this.color,
    this.metadata,
  });

  factory ChartItem.fromJson(Map<String, dynamic> json) {
    return ChartItem(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      color: json['color'],
      metadata: json['metadata'],
    );
  }
}
