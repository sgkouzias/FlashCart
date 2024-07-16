import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flashcart_app/data/strings.dart';
import 'package:flashcart_app/models/gemini.dart';
import 'package:flashcart_app/models/product.dart';
import 'package:flashcart_app/widgets/image_processing.dart';
import 'package:flashcart_app/widgets/shopping_list_tab.dart';
import 'package:flashcart_app/widgets/purchased_list_tab.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flashcart_app/providers/theme_provider.dart';

void main() async {
  final model = await createGenerativeModel();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: ScaffoldMessenger(
          child: FlashCartApp(model: model),
        ),
      ),
    ),
  );
}

class FlashCartApp extends StatefulWidget {
  final GenerativeModel model;

  const FlashCartApp({super.key, required this.model});

  @override
  _FlashCartAppState createState() => _FlashCartAppState();
}

class _FlashCartAppState extends State<FlashCartApp> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final List<XFile> _images = [];
  List<Product> _productData = [];
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
    setState(() {
      _isLoading = true; // Start loading
    });

    final imageParts = await Future.wait(
      _images.map(processImage),
    );

    try {
      final response = await widget.model.generateContent([
        Content.multi([TextPart(prompt), ...imageParts]),
      ]);

      final descriptions = response.text?.split(RegExp(r'\s*---\s*')) ?? [];

      if (descriptions.length > _images.length) {
        descriptions.removeRange(_images.length, descriptions.length);
      } else if (descriptions.length < _images.length) {
        final missingDescriptions = _images.length - descriptions.length;
        descriptions.addAll(
            List.filled(missingDescriptions, "No description available"));
      }

      final validProducts = <Product>[]; // List to store valid products

      for (var i = 0; i < descriptions.length; i++) {
        final description = descriptions[i].trim();
        if (description.isNotEmpty && description != 'e') {
          // Check if description is valid
          validProducts.add(Product(
            image: _images[i],
            description: description,
          ));
        }
      }
      setState(() {
        _productData = validProducts; // Update productData with valid products
        _isLoading = false;
      });
    } catch (e) {
      // Use the Builder widget to get the correct context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BuildContext? context = _scaffoldMessengerKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e. Please try again.'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  _resetAppState(); // Reset app state and allow retry
                },
              ),
            ),
          );
        } else {
          // Handle the case where the context is not available (e.g., widget is not mounted)
          print('Error: Could not show SnackBar. Context is null.');
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

  void _editDescription(int index, String newDescription) {
    setState(() {
      _productData[index] =
          _productData[index].copyWith(description: newDescription);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'FlashCart⚡',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
// ... Customize your light theme here ...
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
// ... Customize your dark theme here ...
      ),
      home: ScaffoldMessenger(
// Wrap with ScaffoldMessenger
        key: _scaffoldMessengerKey,
        child: DefaultTabController(
          length: 2, // Two tabs: To Buy and Purchased
          child: Scaffold(
            appBar: AppBar(
              title: InkWell(
// Replace Row with InkWell
                onTap: _pickImages, // Call _pickImages on tap
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Center the logo-button horizontally
                  children: [
                    SvgPicture.asset(
                      'assets/logo.svg',
                      height: 50,
                    ),
                    const SizedBox(width: 8),
                    const Text('FlashCart'),
                  ],
                ),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'To Buy'),
                  Tab(text: 'Purchased'),
                ],
              ),
              actions: [
                Consumer<ThemeProvider>(
// Use Consumer to rebuild when theme changes
                  builder: (context, themeProvider, child) {
                    return IconButton(
                      icon: Icon(themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode),
                      onPressed: () {
                        themeProvider.toggleTheme(!themeProvider.isDarkMode);
                      },
                    );
                  },
                ),
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
                      onEditDescription: _editDescription, // Pass the callback
                      context: context,
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
            floatingActionButton: null,
            floatingActionButtonLocation: null,
          ),
        ),
      ),
    );
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
      _productData[index] = _productData[index]
          .copyWith(isPurchased: !_productData[index].isPurchased);
    });
  }
}
