import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_flutter/models/product.dart';
import 'dart:io';

import 'package:test_flutter/services/database_service.dart';

void main() async {
  await _setup();
  runApp(MaterialApp(
    home: ProductList(),
  ));
}

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.setup();
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final ImagePicker _picker = ImagePicker();
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

  Future<void> _pickImage(Product product) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        product.imagePath = pickedFile.path;
      });
    }
  }

  void _editProduct(Product product) {
    TextEditingController nameController = TextEditingController(text: product.name);
    TextEditingController priceController = TextEditingController(text: product.price);
    TextEditingController placeController = TextEditingController(text: product.place);
    TextEditingController descriptionController = TextEditingController(text: product.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _pickImage(product),
                child: product.imagePath?.isNotEmpty ?? false
                    ? Image.file(File(product.imagePath!), height: 150, width: double.infinity, fit: BoxFit.cover)
                    : Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: SizedBox.expand(child: Icon(Icons.image, size: 50)),
                ),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: placeController,
                decoration: InputDecoration(labelText: 'Place'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              )
            ],
          ),
          actions: [
            CustomButton(
                text: 'Cancel',
                onPressed: () => Navigator.of(context).pop()
            ),
            CustomButton(
              text: 'Save',
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
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController placeController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context)  {
        return AlertDialog(
          title: Text('Add Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: placeController,
                decoration: InputDecoration(labelText: 'Place'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              )
            ],
          ),
          actions: [
            CustomButton(
                text: 'Cancel',
                onPressed: () => Navigator.of(context).pop()
            ),
            CustomButton(
                text: 'Add',
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
                    },
                  );
                  Navigator.pop(context);
                },
            ),
          ],
        );
      },
    );
  }

  void _showCardDialog(Product product) {

    showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: product.imagePath?.isNotEmpty ?? false
                        ? Image.file(File(product.imagePath!), height: 250, width: double.infinity, fit: BoxFit.cover)
                        : Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: SizedBox.expand(child: Icon(Icons.image, size: 50)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(product.name!, style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Rp${product.price}", style: TextStyle(fontSize: 25, color: Colors.grey[800])),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, size:20, color: Colors.grey[600]),
                      Text(product.place!, style: TextStyle(fontSize: 20, color: Colors.grey[600])),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("Description :", style: TextStyle(fontSize: 19)),
                  Text(product.description!, style: TextStyle(fontSize: 20, color: Colors.grey[800])),
                  SizedBox(height: 10),
                  CustomButton(
                      text: "Back",
                      onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Toko Zeus 99'), backgroundColor: Colors.lightGreen),
      body: Column(
        children: [
          Searchbar(),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 kolom dalam satu baris
                crossAxisSpacing: 10, // Spasi antar kolom
                mainAxisSpacing: 10, // Spasi antar baris
                childAspectRatio: 0.6, // Rasio ukuran kartu
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onEdit: () => _editProduct(product),
                  onDelete: () async {
                    await DatabaseService.db.writeTxn(() async {
                      await DatabaseService.db.products.delete(product.id);
                    });
                  },
                  onCardTap: (product) => _showCardDialog(product)
                );
              },
            ),
          ),
          Footer(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.amber,
        onPressed: _showAddDialog,
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(Product) onCardTap;

  ProductCard({required this.product, required this.onEdit, required this.onDelete, required this.onCardTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => onCardTap(product),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: product.imagePath?.isNotEmpty ?? false
                        ? Image.file(File(product.imagePath!), height: 150, width: double.infinity, fit: BoxFit.cover)
                        : Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: SizedBox.expand(child: Icon(Icons.image, size: 50)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(product.name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text("Rp${product.price}", style: TextStyle(fontSize: 16, color: Colors.grey[800])),
                  SizedBox(height: 5),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.location_on, size:15, color: Colors.grey[600]),
                Text(product.place!, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: Icon(Icons.edit, color: Colors.lightGreen), onPressed: onEdit),
                IconButton(icon: Icon(Icons.delete, color: Colors.lightGreen), onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Searchbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.grey[200],
      child: Center(
        child: Text(
          '© 2025 TokoZeus99. All Rights Reserved.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightGreen,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
