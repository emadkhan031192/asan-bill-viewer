import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// What a digit run most likely is, based on length alone.
enum OcrKind {
  /// 14 digits: a PITC electricity reference (company still needs confirming).
  pitc14,

  /// 13 digits: a K-Electric account number.
  kelectric13,

  /// 8-12 digits: a gas consumer number (SNGPL or SSGC).
  gas,
}

class OcrCandidate {
  const OcrCandidate({required this.digits, required this.kind});

  final String digits;
  final OcrKind kind;
}

/// Pure extraction: find digit runs in OCR text and classify them.
/// Runs may contain spaces or dashes on the printed bill ("1234 5678 …").
List<OcrCandidate> extractCandidates(String text) {
  // Join digit groups split by spaces/dashes: "1234 5678" -> "12345678".
  final joined = text.replaceAll(RegExp(r'(?<=\d)[\s\-–—]+(?=\d)'), '');
  final seen = <String>{};
  final out = <OcrCandidate>[];
  for (final m in RegExp(r'\d{8,15}').allMatches(joined)) {
    final digits = m.group(0)!;
    if (!seen.add(digits)) continue;
    final kind = switch (digits.length) {
      14 => OcrKind.pitc14,
      13 => OcrKind.kelectric13,
      _ => OcrKind.gas, // 8..12
    };
    out.add(OcrCandidate(digits: digits, kind: kind));
    if (out.length >= 8) break;
  }
  // Prefer longer (more specific) numbers first.
  out.sort((a, b) => b.digits.length.compareTo(a.digits.length));
  return out;
}

/// On-device text recognition (ML Kit Latin model, bundled — works offline).
class OcrService {
  OcrService() : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;
  bool _busy = false;

  /// Recognize text from a live camera frame. Returns null when busy or when
  /// the frame format is unsupported; the caller should simply skip the frame.
  Future<String?> processCameraImage(
    CameraImage image,
    CameraDescription camera,
    DeviceOrientation deviceOrientation,
  ) async {
    if (_busy) return null;
    final input = _inputImage(image, camera, deviceOrientation);
    if (input == null) return null;
    _busy = true;
    try {
      final result = await _recognizer.processImage(input);
      return result.text;
    } catch (_) {
      return null;
    } finally {
      _busy = false;
    }
  }

  /// Recognize text from a gallery image file.
  Future<String> processImageFile(File file) async {
    final input = InputImage.fromFilePath(file.path);
    final result = await _recognizer.processImage(input);
    return result.text;
  }

  void dispose() => _recognizer.close();

  static const _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImage(
    CameraImage image,
    CameraDescription camera,
    DeviceOrientation deviceOrientation,
  ) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format != InputImageFormat.yuv420 &&
        format != InputImageFormat.nv21) {
      return null;
    }
    if (image.planes.length != 3) return null;

    final bytes = WriteBuffer();
    for (final plane in image.planes) {
      bytes.putUint8List(plane.bytes);
    }

    final rotation = _rotation(camera, deviceOrientation);
    if (rotation == null) return null;

    return InputImage.fromBytes(
      bytes: bytes.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format!,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  InputImageRotation? _rotation(
    CameraDescription camera,
    DeviceOrientation deviceOrientation,
  ) {
    // Android-only app; iOS path kept for completeness.
    if (Platform.isIOS) {
      return InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    }
    final compensation = _orientations[deviceOrientation];
    if (compensation == null) return null;
    final degrees = camera.lensDirection == CameraLensDirection.front
        ? (camera.sensorOrientation + compensation) % 360
        : (camera.sensorOrientation - compensation + 360) % 360;
    return InputImageRotationValue.fromRawValue(degrees);
  }
}
