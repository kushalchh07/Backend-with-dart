class Product {
  final int? productId;
  final int categoryId;
  final int brandId;
  final String productName;
  final String categoryName;
  final String brandName;
  final String? productDescription;
  final String? productThumbnail;
  final dynamic normalPrice;
  final dynamic sellPrice;
  final int totalProductCount;

  Product({
    this.productId,
    required this.categoryId,
    required this.brandId,
    required this.productName,
    required this.categoryName,
    required this.brandName,
    this.productDescription,
    this.productThumbnail,
    required this.normalPrice,
    required this.sellPrice,
    required this.totalProductCount,
  });

  // Convert Product object to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'category_id': categoryId,
      'brand_id': brandId,
      'product_name': productName,
      'category_name': categoryName,
      'brand_name': brandName,
      'product_description': productDescription,
      'product_thumbnail': productThumbnail,
      'normal_price': normalPrice,
      'sell_price': sellPrice,
      'total_product_count': totalProductCount,
    };
  }

  // Create a Product object from a database result
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['product_id'],
      categoryId: map['category_id'],
      brandId: map['brand_id'],
      productName: map['product_name'],
      categoryName: map['category_name'],
      brandName: map['brand_name'],
      productDescription: map['product_description'],
      productThumbnail: map['product_thumbnail'],
      normalPrice: map['normal_price'],
      sellPrice: map['sell_price'],
      totalProductCount: map['total_product_count'],
    );
  }
}
