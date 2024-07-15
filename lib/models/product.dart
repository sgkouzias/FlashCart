import 'package:image_picker/image_picker.dart';

class Product {
  final XFile image;
  String description;
  bool isPurchased;
  int itemCount;

  Product({
    required this.image,
    required this.description,
    this.isPurchased = false,
    this.itemCount = 1,
  });

  // CopyWith method to create a new Product object with modifications
  Product copyWith({
    XFile? image,
    String? description,
    bool? isPurchased,
    int? itemCount,
  }) {
    return Product(
      image: image ?? this.image, // Use the provided value or the current value
      description: description ?? this.description,
      isPurchased: isPurchased ?? this.isPurchased,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}