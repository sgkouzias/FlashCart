import 'package:image_picker/image_picker.dart';

class Product {
  final XFile image;
  final String description;
  bool isPurchased;
  int itemCount;

  Product({
    required this.image,
    required this.description,
    this.isPurchased = false,
    this.itemCount = 1,
  });

  // TODO: Add any other methods or properties you need for Product
}