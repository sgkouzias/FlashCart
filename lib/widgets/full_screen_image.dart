import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

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
