import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flashcart_app/widgets/full_screen_image.dart';
import 'package:flashcart_app/models/product.dart';
import 'package:image_picker/image_picker.dart';

class PurchasedListTab extends StatelessWidget {
  final List<Product> productData;
  final BuildContext context; // Added for Navigator

  const PurchasedListTab({
    super.key,
    required this.productData,
    required this.context, // Receive the context
  });

  @override
  Widget build(BuildContext context) {
    final purchasedProducts =
        productData.where((product) => product.isPurchased).toList();

    return purchasedProducts.isEmpty
        ? const Center(child: Text('No purchased items yet!'))
        : ListView.builder(
            itemCount: purchasedProducts.length,
            itemBuilder: (context, index) {
              final product = purchasedProducts[index];
              return _buildProductCard(product);
            },
          );
  }

  Widget _buildProductCard(Product product) {
    // Changed parameter type to Product
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildImageThumbnail(product),
          _buildProductDetails(product),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(Product product) {
    // Changed parameter type to Product
    return InkWell(
      onTap: () =>
          _viewImageFullScreen(product.image), // Access image property directly
      child: SizedBox(
        width: 100, // Larger thumbnail in purchased tab
        height: 100,
        child: Image.file(
          File(product.image.path), // Access path from image property
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductDetails(Product product) {
    // Changed to Product type
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
                data: product
                    .description), // Access properties using dot notation
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const SizedBox(width: 1),
                Text('${product.itemCount}'),
                const SizedBox(width: 1),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewImageFullScreen(XFile image) {
    Navigator.push(
      context, // Use the stored context
      MaterialPageRoute(
        builder: (context) =>
            FullScreenImage(imageProvider: FileImage(File(image.path))),
      ),
    );
  }
}
