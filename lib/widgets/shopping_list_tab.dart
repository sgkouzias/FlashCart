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
  final Function(int) onDecrementItemCount;
  final Function(int, String) onEditDescription;

  final BuildContext context;
  final bool isLoading; // Receive isLoading from the parent

  const ShoppingListTab({
    super.key,
    required this.productData,
    required this.onTogglePurchased,
    required this.onDeleteItem,
    required this.onIncrementItemCount,
    required this.onDecrementItemCount,
    required this.context,
    required this.isLoading,
    required this.onEditDescription,
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

  Widget _buildProductCard(Product product, int index) {
// Changed parameter type to Product
    return GestureDetector(
// Add GestureDetector to handle taps
      onTap: () => onTogglePurchased(index), // Call the callback when tapped
      child: Card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildImageThumbnail(product),
            _buildProductDetails(product, index),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(Product product, int index) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: MarkdownBody(
                  data:
                      product.description.isEmpty || product.description == "e"
                          ? "No description available"
                          : product.description,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      decoration: product.isPurchased
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align to start and end
                children: <Widget>[
                  Text('${product.itemCount}'), // Item count at the beginning
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: 25.0,
                        maxHeight: 40.0), // Adjust size as needed
                    child: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: product.itemCount > 1
                          ? () => onDecrementItemCount(index)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 1),
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: 25.0, maxHeight: 40.0),
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => onIncrementItemCount(index),
                    ),
                  ),
                  const SizedBox(width: 1),
                  IconButton(
                    icon: const Icon(Icons.edit), // Edit button
                    onPressed: () =>
                        _showEditDescriptionDialog(context, product, index),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageThumbnail(Product product) {
    // Changed parameter type to Product
    return InkWell(
      onTap: () =>
          _viewImageFullScreen(product.image), // Access image property directly
      child: SizedBox(
        width: 60, // Adjusted size for shopping list tab
        height: 60,
        child: Image.file(
          File(product.image.path), // Access path from image property
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _showEditDescriptionDialog(
      BuildContext context, Product product, int index) {
    TextEditingController descriptionController =
        TextEditingController(text: product.description);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Description"),
        content: TextField(
          controller: descriptionController,
          decoration: const InputDecoration(hintText: "Enter description"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () {
              if (descriptionController.text.isNotEmpty) {
                onEditDescription(index, descriptionController.text);
              }
              Navigator.pop(context);
            },
          ),
        ],
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
