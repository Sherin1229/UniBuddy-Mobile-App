import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudinaryUploadException implements Exception {
  final String message;

  const CloudinaryUploadException(this.message);

  @override
  String toString() => message;
}

class CloudinaryUploadService {
  // Configure these with --dart-define or hardcode values for quick testing.
  static const String _cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
  );
  static const String _uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
  );

  Future<String> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    String folder = 'unibuddy/resources',
  }) async {
    if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
      throw const CloudinaryUploadException(
        'Cloudinary is not configured. Set CLOUDINARY_CLOUD_NAME and CLOUDINARY_UPLOAD_PRESET.',
      );
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/raw/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Cloudinary upload failed (${response.statusCode}).';
      try {
        final parsed = jsonDecode(body) as Map<String, dynamic>;
        final error = parsed['error'] as Map<String, dynamic>?;
        final errorMessage = error?['message'] as String?;
        if (errorMessage != null && errorMessage.trim().isNotEmpty) {
          message = errorMessage;
        }
      } catch (_) {
        // Keep fallback message when response is not JSON.
      }
      throw CloudinaryUploadException(message);
    }

    final parsed = jsonDecode(body) as Map<String, dynamic>;
    final secureUrl = parsed['secure_url'] as String?;
    if (secureUrl == null || secureUrl.trim().isEmpty) {
      throw const CloudinaryUploadException(
        'Cloudinary upload succeeded but did not return a secure URL.',
      );
    }

    return secureUrl;
  }
}
