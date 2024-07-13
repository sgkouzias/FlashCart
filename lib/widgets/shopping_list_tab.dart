import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flashcart_app/models/product.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flashcart_app/widgets/full_screen_image.dart'; 

class ShoppingListTab extends StatelessWidget {
  final List<Product> productData; 
  final Function(int) onTogglePurchased;
  final Function(int) onDeleteItem;
  final Function(int) onIncrementItemCount;
  final BuildContext context;
  final bool isLoading; // Receive isLoading from the parent

  const ShoppingListTab({
    super.key,
    required this.productData,
    required this.onTogglePurchased,
    required this.onDeleteItem,
    required this.onIncrementItemCount,
    required this.context,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show loading indicator at the center of the tab
      return const Center(child: CircularProgressIndicator());
    } else if (productData.isEmpty) {
      // Show "No images selected" only if not loading
      return const Center(child: Text('No images selected'));
    } else {
      // Show the list of products if there are images and not loading
      return ListView.builder(
        itemCount: productData.length,
        itemBuilder: (context, index) {
          final product = productData[index];
          return Dismissible(
            key: Key(product.image.path),
            onDismissed: (direction) => onDeleteItem(index),
            child: _buildProductCard(product, index),
          );
        },
      );
    }
  }

 Widget _buildProductCard(Product product, int index) {  // Changed parameter type to Product
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildImageThumbnail(product),
          _buildProductDetails(product, index),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(Product product) { // Changed parameter type to Product
    return InkWell(
      onTap: () => _viewImageFullScreen(product.image),  // Access image property directly
      child: SizedBox(
        width: 100, // Adjusted size for shopping list tab
        height: 100,
        child: Image.file(
          File(product.image.path), // Access path from image property
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductDetails(Product product, int index) { // Changed to Product type
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(data: product.description), // Access properties using dot notation
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Checkbox(
                  value: product.isPurchased, 
                  onChanged: (value) => onTogglePurchased(index), 
                ),
                const SizedBox(width: 1),
                Text('${product.itemCount}'), 
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => onIncrementItemCount(index),
                ),
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
      context, // Use the passed context
      MaterialPageRoute(
        builder: (context) =>
            FullScreenImage(imageProvider: FileImage(File(image.path))),
      ),
    );
  }
}
