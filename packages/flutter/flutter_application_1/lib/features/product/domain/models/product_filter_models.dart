/// 品牌数据模型
class Brand {
  final String id;
  final String name;
  final String displayName;
  final String? logo;
  final bool isActive;

  const Brand({
    required this.id,
    required this.name,
    required this.displayName,
    this.logo,
    this.isActive = true,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
      displayName: json['displayName'],
      logo: json['logo'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'logo': logo,
      'isActive': isActive,
    };
  }

  Brand copyWith({
    String? id,
    String? name,
    String? displayName,
    String? logo,
    bool? isActive,
  }) {
    return Brand(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      logo: logo ?? this.logo,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Brand && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Brand(id: $id, name: $name, displayName: $displayName)';
}

/// 产品类别数据模型
class Category {
  final String id;
  final String name;
  final String displayName;
  final String? icon;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    required this.displayName,
    this.icon,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      displayName: json['displayName'],
      icon: json['icon'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'icon': icon,
      'isActive': isActive,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? displayName,
    String? icon,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Category(id: $id, name: $name, displayName: $displayName)';
}

/// 产品线数据模型
class ProductLine {
  final String id;
  final String name;
  final String displayName;
  final String? icon;
  final bool isActive;

  const ProductLine({
    required this.id,
    required this.name,
    required this.displayName,
    this.icon,
    this.isActive = true,
  });

  factory ProductLine.fromJson(Map<String, dynamic> json) {
    return ProductLine(
      id: json['id'],
      name: json['name'],
      displayName: json['displayName'],
      icon: json['icon'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'icon': icon,
      'isActive': isActive,
    };
  }

  ProductLine copyWith({
    String? id,
    String? name,
    String? displayName,
    String? icon,
    bool? isActive,
  }) {
    return ProductLine(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductLine && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ProductLine(id: $id, name: $name, displayName: $displayName)';
}

/// 产品数据模型
class Product {
  final String id;
  final String name;
  final String displayName;
  final String? image;
  final Map<String, dynamic>? specs;
  final bool isActive;

  const Product({
    required this.id,
    required this.name,
    required this.displayName,
    this.image,
    this.specs,
    this.isActive = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      displayName: json['displayName'],
      image: json['image'],
      specs: json['specs'] as Map<String, dynamic>?,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'image': image,
      'specs': specs,
      'isActive': isActive,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? displayName,
    String? image,
    Map<String, dynamic>? specs,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      image: image ?? this.image,
      specs: specs ?? this.specs,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Product(id: $id, name: $name, displayName: $displayName)';
}

/// 筛选器选择状态模型
class FilterSelectionState {
  final String? selectedBrand;
  final String? selectedCategory;
  final String? selectedProductLine;

  const FilterSelectionState({
    this.selectedBrand,
    this.selectedCategory,
    this.selectedProductLine,
  });

  FilterSelectionState copyWith({
    String? selectedBrand,
    String? selectedCategory,
    String? selectedProductLine,
  }) {
    return FilterSelectionState(
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedProductLine: selectedProductLine ?? this.selectedProductLine,
    );
  }

  @override
  String toString() {
    return 'FilterSelectionState(brand: $selectedBrand, category: $selectedCategory, productLine: $selectedProductLine)';
  }
}
