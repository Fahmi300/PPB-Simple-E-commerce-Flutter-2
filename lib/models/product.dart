import 'package:isar/isar.dart';

part 'product.g.dart';

@Collection()
class Product {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String? name;
  String? price;
  String? place;
  String? description;
  int? rating;
  String? imagePath;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  Product copyWith({
    String? name,
    String? price,
    String? place,
    String? description,
    int? rating,
    String? imagePath,
  }) {
    return Product()
        ..id = id
        ..createdAt = createdAt
        ..updatedAt = DateTime.now()
        ..name = name
        ..price = price
        ..place = place
        ..description = description
        ..rating = rating
        ..imagePath = imagePath;
  }
}