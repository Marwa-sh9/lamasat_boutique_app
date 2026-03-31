import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
String apiKey = dotenv.env['CLOUDINARY_API_KEY']!;
String apiSecret = dotenv.env['CLOUDINARY_API_SECRET']!;
String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

final String CLOUDINARY_UPLOAD_URL = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';



Future<String?> uploadImageToCloudinary({
  required BuildContext context,
  File? imageFile,
  Uint8List? imageBytes,
  required String resourceType,
}) async {
  if (imageFile == null && imageBytes == null) return null;

  final url = CLOUDINARY_UPLOAD_URL;
  final request = http.MultipartRequest('POST', Uri.parse(url))
    ..fields['upload_preset'] = uploadPreset;

  try {
    if (kIsWeb && imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: '${resourceType}_web_${DateTime.now().millisecondsSinceEpoch}.png',
      ));
    } else if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    } else {
      return null;
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final data = json.decode(responseString);
      return data['secure_url'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل رفع الصورة (رمز الخطأ: ${response.statusCode})')),
      );
      return null;
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('خطأ في الاتصال بخدمة Cloudinary.')),
    );
    return null;
  }
}


Future<void> deleteImageFromCloudinary(String imageUrl) async {
  if (!imageUrl.contains(cloudName)) return;
  try {
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;

    String publicIdWithExtension = pathSegments.last;
    String publicId = publicIdWithExtension.split('.').first;

    final auth = utf8.encode('$apiKey:$apiSecret');
    final headers = {
      HttpHeaders.authorizationHeader: 'Basic ${base64Encode(auth)}',
      'Content-Type': 'application/json',
    };

    final finalDeleteUrl = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/resources/image?public_ids[]=$publicId');

    final deleteResponse = await http.delete(finalDeleteUrl, headers: headers);

    if (deleteResponse.statusCode == 200) {
      print('Image deleted successfully from Cloudinary.');
    } else {
      print(
          'Cloudinary delete failed: ${deleteResponse.statusCode} - ${deleteResponse.body}');
    }
  } catch (e) {
    print('Failed to delete image from Cloudinary: $e');
  }
}


class ReusableImageWidget extends StatelessWidget {
  final File? file;
  final Uint8List? bytes;
  final String? url;
  final double size;

  const ReusableImageWidget({
    super.key,
    this.file,
    this.bytes,
    this.url,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    if (file != null || bytes != null) {
      return Image(
        image: kIsWeb ? MemoryImage(bytes!) : FileImage(file!) as ImageProvider,
        height: size,
        width: size,
        fit: BoxFit.cover,
      );
    } else if (url != null && url!.isNotEmpty) {
      return Image.network(
        url!,
        height: size,
        width: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: size * 0.8, color: Colors.redAccent);
        },
      );
    } else {
      return Icon(Icons.image_not_supported, size: size * 0.8, color: Colors.grey);
    }
  }
}