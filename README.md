## Isar Database
- Dibuat untuk Flutter </br>
Setup minimal, mudah digunakan, tanpa konfigurasi rumit atau boilerplate. Cukup tambahkan beberapa baris kode untuk mulai menggunakan.

- Sangat Skalabel </br>
Simpan ratusan ribu data dalam satu database NoSQL dan lakukan query secara efisien dan asinkron.

- Fitur Lengkap </br>
Isar menyediakan banyak fitur untuk membantu mengelola data, seperti indeks komposit & multi-entry, modifier query, dukungan JSON, dan lainnya.

- Pencarian Teks Penuh </br>
Isar memiliki dukungan pencarian teks penuh bawaan. Buat indeks multi-entry dan cari data dengan mudah.

- Semantik ACID </br>
Isar mematuhi prinsip ACID dan menangani transaksi secara otomatis. Perubahan akan dibatalkan jika terjadi kesalahan.

- Pengetikan Statis </br>
Query di Isar bersifat statis dan diperiksa saat kompilasi, sehingga mengurangi kesalahan saat runtime.

- Multiplatform </br>
Mendukung iOS, Android, dan Desktop!

- Asinkron </br>
Operasi query berjalan paralel & mendukung multi-isolate langsung dari awal.

- Sumber Terbuka </br>
Semua fitur bersifat open source dan gratis selamanya!

## Langkah - langkah Menggunakan Isar dalam project ini

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
Dengan `@Collection()`  Menandakan bahwa class Product adalah sebuah koleksi di database Isar, kemudian part `product.g.dart` digunakan agar dapat mengenerate file helper untuk database secara otomatis dengan menjalankan `flutter pub run build_runner build`, maka file helper tergenerate sesuai nama yang didefinisikan, disini adalah `product.g.dart`. Menambahkan method `copyWith()` untuk membuat salinan Product dengan nilai-nilai baru.

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
Database service digunakan untuk insiasi awal dan menyimpan instance Isar ke dalam variabel agar tidak perlu terus membuka koneksi berulang kali dan juga untuk menentukan logasi penyimpanan database. Lalu untuk method `setup()` dapat dijalankan sebelum `runapp()`.

### Operasi CRUD

#### Membaca Product
```dart
 List<Product> products = [];

  StreamSubscription? productsStream;

  @override
  void initState() {
    super.initState();
    productsStream = DatabaseService.db.products
      .buildQuery<Product>()
      .watch(
        fireImmediately: true,
      )
      .listen(
        (data) {
          setState(() {
            products = data;
          });
        }
    );
  }

  @override
  void dispose() {
    productsStream?.cancel();
    super.dispose();
  }
```
Kode diatas berguna untuk membaca data dari database secara real-time, lalu memperbarui UI secara otomatis.
`initState()` untuk memulai stream dan `dispose()` untuk menghentikan stream.

#### Menambahkan Product
```dart
onPressed: () async {
  Product newProduct = Product();
  newProduct = newProduct.copyWith(
    name: nameController.text,
    price: priceController.text,
    place: placeController.text,
    description: descriptionController.text,
    rating: 0,
    imagePath: '',
  );
  await DatabaseService.db.writeTxn(() async {
      await DatabaseService.db.products.put(newProduct);
  });
  Navigator.pop(context);
},
```
Menambahkan product dengan membuat new product dan memasukan semua text dalam controller ke dalam new product. Setelahnya menggunakan
Database service untuk melakukan insert atau update ke database.

#### Mengubah Product
```dart
onPressed: () async {
  Product updatedProduct = product.copyWith(
    name: nameController.text,
    price: priceController.text,
    place: placeController.text,
    description: descriptionController.text,
    imagePath: product.imagePath ?? '',
  );

  await DatabaseService.db.writeTxn(() async {
      await DatabaseService.db.products.put(updatedProduct);
  });
  Navigator.pop(context);
}
```
Pada Update product sama dengan Add product hanya berbeda pada nama variable.

#### Menghapus Product
```dart
onDelete: () async {
  await DatabaseService.db.writeTxn(() async {
    await DatabaseService.db.products.delete(product.id);
  });
},
```
Untuk delete product menggunakan database service `delete()` dengan parameter product.id sehingga akan mendelete produk tersebut menggunakan id.
