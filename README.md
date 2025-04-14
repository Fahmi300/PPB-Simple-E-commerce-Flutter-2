# Langkah - langkah Menggunakan Isar dalam project ini

### Tambahkan dependensi pada pubsec.yaml

```yaml
dependencies:
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.5

dev_dependencies:
  isar_generator: ^3.1.0+1
  build_runner: any
```
Dependensi digunakan untuk menggunakan Isar

### Membuat Model
```dart
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
    .....
  }) {
    return Product()
      ..id = id
      ..createdAt = createdAt
      ..updatedAt = DateTime.now()
      ..name = name
      .....
  }
}
```
Dengan `@Collection()`  Menandakan bahwa class Product adalah sebuah koleksi di database Isar, kemudian part `product.g.dart` digunakan agar dapat mengenerate file helper untuk database secara otomatis dengan menjalankan `flutter pub run build_runner build`, maka file helper tergenerate sesuai nama yang didefinisikan, disini adalah `product.g.dart`. Menambahkan method `copyWith()` untuk membuat salinan objek Product dengan nilai-nilai baru.h.

### Membuat Database Service
```dart
class DatabaseService {
  static late final Isar db;

  static Future<void> setup() async {
    final appDir = await getApplicationDocumentsDirectory();
    db = await Isar.open(
      [
        ProductSchema,
      ],
      directory: appDir.path,
    );
  }
}
```
Database service digunakan untuk insiasi awal dan menyimpan instance Isar ke dalam variabel agar tidak perlu terus membuka koneksi berulang kali. Kemudian untuk menentukan logasi penyimpanan database.


