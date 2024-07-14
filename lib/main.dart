import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flashcart_app/data/strings.dart';
import 'package:flashcart_app/models/gemini.dart';
import 'package:flashcart_app/models/product.dart';
import 'package:flashcart_app/widgets/image_processing.dart';
import 'package:flashcart_app/widgets/shopping_list_tab.dart';
import 'package:flashcart_app/widgets/purchased_list_tab.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  final model = await createGenerativeModel(); // Create the model
  runApp(MaterialApp(home: FlashCartApp(model: model)));
}

class FlashCartApp extends StatefulWidget {
  final GenerativeModel model;

  const FlashCartApp({super.key, required this.model});

  @override
  _FlashCartAppState createState() => _FlashCartAppState();
}

class _FlashCartAppState extends State<FlashCartApp> {
  final List<XFile> _images = [];
  final List<Product> _productData = [];
  bool _isLoading = false;

  final prompt = suppliesSpecialist;

  Future<void> _pickImages() async {
    if (_isLoading) {
      return; // Prevent picking images while loading
    }

    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage();

    if (pickedImages.isNotEmpty) {
      setState(() {
        _images.addAll(pickedImages);
        _isLoading = true; // Start loading when images are picked
      });

      await _generateDescriptions();
      setState(() => _isLoading =
          false); // Set loading to false after descriptions are generated
    }
  }

  Future<void> _generateDescriptions() async {
    final imageParts = await Future.wait(_images.map(processImage));
    try {
      final response = await widget.model.generateContent([
        Content.multi([TextPart(prompt), ...imageParts]),
      ]);

      final descriptions = response.text?.split('---') ?? [];

      if (descriptions.length != _images.length) {
        throw Exception(
            "Error: Number of descriptions doesn't match number of images.");
      }

      setState(() {
        // Rebuild the entire productData list
        _productData.clear();
        for (var i = 0; i < descriptions.length; i++) {
          final description = descriptions[i].trim();
          if (description.isNotEmpty && description != 'e') {
            _productData.add(
              Product(
                image: _images[i],
                description: description,
              ),
            );
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      // Store the snackbar message for later use
      String snackbarMessage = 'Error: $e. Please try again.';

      // Use a callback to show the snackbar after the async operation
      // is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Check if the widget is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(snackbarMessage),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  _resetAppState(); // Reset app state and allow retry
                },
              ),
            ),
          );
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetAppState() {
    setState(() {
      _images.clear();
      _productData.clear();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'FlashCart⚡',
        home: DefaultTabController(
          length: 2, // Two tabs: To Buy and Purchased
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/logo.svg',
                    height: 50,
                  ),
                  const SizedBox(width: 8),
                  const Text('FlashCart'),
                ],
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'To Buy'),
                  Tab(text: 'Purchased'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    // Exit the app
                    exit(0);
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                TabBarView(
                  children: [
                    ShoppingListTab(
                      productData: _productData,
                      onTogglePurchased: _togglePurchased,
                      onDeleteItem: (index) {
                        setState(() {
                          _images.removeAt(index);
                          _productData.removeAt(index);
                        });
                      },
                      onIncrementItemCount: _incrementItemCount,
                      onDecrementItemCount: _decrementItemCount,
                      context: context, // Make sure to pass the context here
                      isLoading: _isLoading, // Pass isLoading here
                    ),
                    PurchasedListTab(
                      productData: _productData,
                      context: context,
                    ),
                  ],
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              // Always show the button
              onPressed: _pickImages,
              child: const Icon(Icons.add_a_photo),
            ),

            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          ),
        ));
  }

  // FloatingActionButton builder
  Widget? _buildFloatingActionButton() {
    // Show the "add photos" button only if no images are selected and not loading
    if (_images.isEmpty && !_isLoading) {
      return FloatingActionButton(
        onPressed: _pickImages,
        child: const Icon(Icons.add_a_photo),
      );
    } else {
      // Hide the button in all other cases (loading or images present)
      return null;
    }
  }

  // Callback to increment item count
  void _incrementItemCount(int index) {
    setState(() {
      _productData[index].itemCount++;
    });
  }

  // Add the _decrementItemCount function here
  void _decrementItemCount(int index) {
    setState(() {
      if (_productData[index].itemCount > 1) {
        _productData[index].itemCount--;
      }
    });
  }

  void _togglePurchased(int index) {
    setState(() {
      _productData[index].isPurchased = !_productData[index].isPurchased;
    });
  }
}
