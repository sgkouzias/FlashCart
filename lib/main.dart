import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: 'vars.env');
  final apiKey = dotenv.env['API_KEY'] ?? '';

  final generationConfig = GenerationConfig(
    temperature: 0.3,
    topP: 0.95,
    topK: 64,
    responseMimeType: "text/plain",
  );

  final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      generationConfig: generationConfig);
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
  final List<Map<String, dynamic>> _productData = [];
  bool _isLoading = false;

  final prompt =
      """You are a supplies specialist. For each image, identify the product.
Generate a full product description including the product name and
if possible: the brand name, utility and any other useful details.
Validate data by searching the web.
Descriptions should not exceed 40 words each.
Separate descriptions with '---'.
Generate only descriptions, not other comments.
If the image does not contain a product write: 'e'""";

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage();
    setState(() {
      _images.addAll(pickedImages); // Add the new images to the existing list
      _generateDescriptions(); // Trigger descriptions generation immediately
    });
  }

  Future<void> _generateDescriptions() async {
    setState(() {
      _isLoading = true;
    });
    _productData.clear();

    final imageParts = await Future.wait(
      _images.map(
        (image) async {
          final file = File(image.path);
          final imageData = await file.readAsBytes();

// Image resizing
          final resizedImage = img.decodeImage(imageData)!;
          final aspectRatio = resizedImage.width / resizedImage.height;
          const newWidth = 250; // Max width
          final newHeight = (newWidth / aspectRatio).round();
          final resizedImageData = img.encodeJpg(
            img.copyResize(resizedImage, width: newWidth, height: newHeight),
            quality: 80,
          );

          return DataPart('image/jpeg', resizedImageData); // Resized image data
        },
      ),
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
            _productData.add({
              'image': _images[i],
              'description': description,
              'isPurchased': false,
              'itemCount': 1, // Initial item count
            });
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
                  height: 40,
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
          ),
          body: TabBarView(
            children: [
              _buildShoppingListTab(), // Build the "To Buy" tab
              _buildPurchasedListTab(), // Build the "Purchased" tab
            ],
          ),
          floatingActionButton: _images.isEmpty
              ? FloatingActionButton(
                  onPressed: _pickImages,
                  child: const Icon(Icons.add_a_photo),
                )
              : null, // Hide the button if images are selected
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }

// "To Buy" Tab
  Widget _buildShoppingListTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _images.isEmpty
            ? const Center(child: Text('No images selected'))
            : ListView.builder(
                itemCount: _productData.length,
                itemBuilder: (context, index) {
                  final product = _productData[index];
                  return Dismissible(
                    key: Key(product['image'].path),
                    onDismissed: (direction) {
                      setState(() {
                        _images.removeAt(index);
                        _productData.removeAt(index);
                      });
                    },
                    child: Card(
                      child: Row(
// Use Row to arrange image and description horizontally
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Align items to the top
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImage(
                                    imageProvider:
                                        FileImage(File(product['image'].path)),
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
// Use SizedBox to control thumbnail size
                              width: 50,
                              height: 100,
                              child: Image.file(
                                File(product['image'].path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
// Allow description to take up remaining space
                            child: Padding(
// Add some padding for visual separation
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MarkdownBody(data: product['description']),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Checkbox(
// Add checkbox for purchased status
                                        value: product['isPurchased'] ??
                                            false, // Default to false if null
                                        onChanged: (value) =>
                                            _togglePurchased(index),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('${product['itemCount']}'),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            product['itemCount']++;
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }

// "Purchased" Tab
  Widget _buildPurchasedListTab() {
    final purchasedProducts = _productData
        .where((product) =>
            product['isPurchased'] ?? false) // Default to false if null
        .toList();

    return purchasedProducts.isEmpty
        ? const Center(child: Text('No purchased items yet!'))
        : ListView.builder(
            itemCount: purchasedProducts.length,
            itemBuilder: (context, index) {
              final product = purchasedProducts[index];
              return Card(
                child: Row(
// Use Row to arrange image and description horizontally
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align items to the top
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImage(
                              imageProvider:
                                  FileImage(File(product['image'].path)),
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
// Use SizedBox to control thumbnail size
                        width: 50,
                        height: 100,
                        child: Image.file(
                          File(product['image'].path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
// Allow description to take up remaining space
                      child: Padding(
// Add some padding for visual separation
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MarkdownBody(data: product['description']),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                const SizedBox(width: 8),
                                Text('${product['itemCount']}'),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

// Toggle purchased status
  void _togglePurchased(int index) {
    setState(() {
      _productData[index]['isPurchased'] = !_productData[index]['isPurchased'];
    });
  }
}

// Widget for Full Screen Image View
class FullScreenImage extends StatelessWidget {
  final ImageProvider imageProvider;

  const FullScreenImage({super.key, required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: PhotoView(
        imageProvider: imageProvider,
      ),
    );
  }
}
