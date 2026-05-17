import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceService {
  Interpreter? _interpreter;
  FaceDetector? _faceDetector;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    _interpreter = await Interpreter.fromAsset('assets/ml/mobilefacenet.tflite');

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableLandmarks: false,
        enableContours: false,
        enableTracking: false,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    _initialized = true;
  }

  bool get isInitialized => _initialized;

  Future<Rect?> detectFaceInFile(String filePath) async {
    if (_faceDetector == null) return null;

    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isEmpty) return null;
      return faces.first.boundingBox;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List> cropFaceFromFile(String filePath, Rect faceRect) async {
    final original = await img.decodeImageFile(filePath);
    if (original == null) {
      throw Exception('Failed to decode image file');
    }

    final imgW = original.width;
    final imgH = original.height;

    final expandRatio = 0.3;
    final expandX = (faceRect.width * expandRatio).toInt();
    final expandY = (faceRect.height * expandRatio).toInt();

    int x = (faceRect.left.toInt() - expandX).clamp(0, imgW);
    int y = (faceRect.top.toInt() - expandY).clamp(0, imgH);
    int w = (faceRect.width.toInt() + expandX * 2).clamp(0, imgW - x);
    int h = (faceRect.height.toInt() + expandY * 2).clamp(0, imgH - y);

    final cropped = img.copyCrop(original, x: x, y: y, width: w, height: h);
    return Uint8List.fromList(img.encodeJpg(cropped, quality: 95));
  }

  List<double> generateEmbedding(Uint8List faceImageBytes) {
    if (_interpreter == null) {
      throw Exception('FaceService not initialized');
    }

    final image = img.decodeImage(faceImageBytes);
    if (image == null) {
      throw Exception('Failed to decode face image');
    }

    final resized = img.copyResize(image, width: 112, height: 112);

    final input = Float32List(1 * 112 * 112 * 3);
    int pixelIndex = 0;

    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        final pixel = resized.getPixel(x, y);
        final double r = pixel.r.toDouble();
        final double g = pixel.g.toDouble();
        final double b = pixel.b.toDouble();
        input[pixelIndex++] = (r / 127.5) - 1.0;
        input[pixelIndex++] = (g / 127.5) - 1.0;
        input[pixelIndex++] = (b / 127.5) - 1.0;
      }
    }

    final output = Float32List(192);
    final inputUint8 = input.buffer.asUint8List();
    final outputUint8 = output.buffer.asUint8List();

    _interpreter!.run(inputUint8, outputUint8);

    return output.toList();
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _faceDetector?.close();
    _faceDetector = null;
    _initialized = false;
  }
}
