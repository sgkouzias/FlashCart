import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

Future<DataPart> processImage(XFile image) async {
  final file = File(image.path);
  final imageData = await file.readAsBytes();

// Image resizing
  final resizedImage = img.decodeImage(imageData)!;
  final aspectRatio = resizedImage.width / resizedImage.height;
  const newWidth = 500; // Max width
  final newHeight = (newWidth / aspectRatio).round();
  final resizedImageData = img.encodeJpg(
    img.copyResize(resizedImage, width: newWidth, height: newHeight),
    quality: 80,
  );

  return DataPart('image/jpeg', resizedImageData); // Resized image data
}