import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageService {
  static const String _apiKey = 'ac5cbc2c4264e232a25e1a6cad5a3f5f';

  static Future<String?> pickAndUploadImage() async {
    try {
      // 1. Seleccionar imagen del dispositivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;
      final file = result.files.first;

      // 2. Subir a imgBB
      final uri = Uri.parse('https://api.imgbb.com/1/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['key'] = _apiKey
        ..files.add(http.MultipartFile.fromBytes(
          'image', 
          file.bytes!,
          filename: file.name,
        ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);

      // 3. Retornar URL de la imagen subida
      return jsonData['data']['url'];
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }
}