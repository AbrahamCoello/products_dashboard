import 'dart:convert';

ProductModel productModelFromJson(String str) =>
    ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  String? id;
  String title;
  double value;
  bool available;
  String photoUrl;

  ProductModel({
    this.id,
    this.title = '',
    this.value = 0.0,
    this.available = true,
    this.photoUrl = '',
  });

  ProductModel copyWith({
    String? id,
    String? title,
    double? value,
    bool? available,
    String? photoUrl,
  }) =>
      ProductModel(
        id: id ?? this.id,
        title: title ?? this.title,
        value: value ?? this.value,
        available: available ?? this.available,
        photoUrl: photoUrl ?? this.photoUrl,
      );

  factory ProductModel.fromRawJson(String str) =>
      ProductModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json["id"],
        title: json["title"],
        value: json["value"],
        available: json["available"],
        photoUrl: json["photoUrl"],
      );

  Map<String, dynamic> toJson() => {
        // "id": id,
        "title": title,
        "value": value,
        "available": available,
        "photoUrl": photoUrl,
      };
}
