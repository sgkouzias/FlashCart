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
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage();

    if (pickedImages.isNotEmpty) {
      setState(() {
        _images.addAll(pickedImages);
      });

      // Introduce a slight delay before setting _isLoading to true
      await Future.delayed(
          const Duration(milliseconds: 50)); // Adjust delay if needed

      setState(() {
        _isLoading = true;
      });

      _generateDescriptions();
    }
  }

  Future<void> _generateDescriptions() async {
    setState(() {
      _isLoading = true;
    });
    _productData.clear();

    final imageParts = await Future.wait(
      _images.map(processImage), // Use the extracted function
    );

    try {
      final response = await widget.model.generateContent([
        Content.multi([TextPart(prompt), ...imageParts]),
      ]);

      final descriptions = response.text?.split('---');
      if (descriptions != null && descriptions.length == _images.length) {
        for (var i = 0; i < _images.length; i++) {
          final description =
              descriptions[i].trim(); // Get description at correct index
          if (description
                  .isNotEmpty && // Check if description is not empty or null
              description != 'e') {
            _productData.add(Product(
              // Create a Product object directly
              image: _images[i],
              description: description,
            ));
          }
        }
      } else {
        throw Exception(
            "Error: Number of descriptions doesn't match number of images.");
      }
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
          body: TabBarView(
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
                onIncrementItemCount: (int index) {
                  setState(() {
                    _productData[index].itemCount++;
                  });
                },
                isLoading: _isLoading, // Pass the isLoading state
                context: context,
              ),
              PurchasedListTab(
                // Use the PurchasedListTab widget
                productData: _productData,
                context: context, // Pass the context
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
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

  void _togglePurchased(int index) {
    setState(() {
      _productData[index].isPurchased = !_productData[index].isPurchased;
    });
  }
}
