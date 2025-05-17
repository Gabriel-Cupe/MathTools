import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:universal_html/html.dart' as html;

class RetoEditorScreen extends StatefulWidget {
  const RetoEditorScreen({super.key});

  @override
  State<RetoEditorScreen> createState() => _RetoEditorScreenState();
}

class _RetoEditorScreenState extends State<RetoEditorScreen> {
  final DatabaseReference _retoRef = FirebaseDatabase.instance.ref('retos/problema_del_dia');
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _retoData;
  bool _isLoading = true;
  bool _isSaving = false;
  File? _imageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadReto();
  }

  Future<void> _loadReto() async {
    try {
      final snapshot = await _retoRef.get();
      if (snapshot.exists) {
        setState(() {
          _retoData = Map<String, dynamic>.from(snapshot.value as Map);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading reto: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      String url;
      if (kIsWeb) {
        // Solución para Web
        final file = result.files.single;
        url = await _uploadToImgBBWeb(file);
      } else {
        // Solución para móvil/desktop
        _imageFile = File(result.files.single.path!);
        url = await _uploadToImgBB(_imageFile!);
      }

      setState(() {
        _retoData['imagenUrl'] = url;
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> _uploadToImgBBWeb(PlatformFile file) async {
    const apiKey = 'ac5cbc2c4264e232a25e1a6cad5a3f5f';
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    
    final formData = html.FormData();
    final blob = html.Blob([file.bytes], 'image/${file.extension}');
    formData.appendBlob('image', blob, file.name);

    final request = await html.HttpRequest.request(
      uri.toString(),
      method: 'POST',
      sendData: formData,
    );
    if (request.status != 200) {
      throw Exception('Error HTTP ${request.status}');
    }
    final response = request;
    if (response.status != 200) {
      throw Exception('Error HTTP ${response.status}');
    }

    final json = response.responseText != null 
      ? jsonDecode(response.responseText!) 
      : throw Exception('Respuesta vacía de ImgBB');
    
    return json['data']['url'] as String;
  }

  Future<String> _uploadToImgBB(File image) async {
    const apiKey = 'ac5cbc2c4264e232a25e1a6cad5a3f5f';
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final json = jsonDecode(responseData);

    if (response.statusCode != 200) {
      throw Exception('Error de ImgBB: ${json['error']['message']}');
    }

    return json['data']['url'] as String;
  }
  Future<void> _saveReto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await _retoRef.update(_retoData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reto actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField('Apartado', _retoData['apartado'] ?? '', (value) => _retoData['apartado'] = value),
            const SizedBox(height: 16),
            _buildTextField('Premisa', _retoData['premisa'] ?? '', (value) => _retoData['premisa'] = value, maxLines: 5),
            const SizedBox(height: 16),
            _buildImageUploader(),
            const SizedBox(height: 16),
            _buildOptionsSection(),
            const SizedBox(height: 16),
            _buildTextField('Solución', _retoData['solucion'] ?? '', (value) => _retoData['solucion'] = value, maxLines: 5),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged, {int maxLines = 1}) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
    );
  }

  Widget _buildImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen del problema',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        if (_retoData['imagenUrl'] != null || (!kIsWeb && _imageFile != null))
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _isUploading
                ? const Center(child: CircularProgressIndicator())
                : kIsWeb
                    ? Image.network(_retoData['imagenUrl'], fit: BoxFit.cover)
                    : _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : Image.network(_retoData['imagenUrl'], fit: BoxFit.cover),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Iconsax.gallery_add),
            label: Text(_isUploading ? 'Subiendo...' : 'Seleccionar imagen'),
            onPressed: _isUploading ? null : _pickAndUploadImage,
          ),
        ),
      ],
    );
  }
  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opciones de respuesta',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ..._buildOptionFields(),
      ],
    );
  }

  List<Widget> _buildOptionFields() {
    final options = _retoData['opciones'] as Map<dynamic, dynamic>? ?? {};
    return options.keys.map((key) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            _buildOptionLabel(key.toString()),
            const SizedBox(width: 12),
            Expanded(child: _buildOptionTextField(key, options[key]?.toString() ?? '')),
            const SizedBox(width: 12),
            _buildCorrectOptionRadio(key),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildOptionLabel(String label) {
    final primaryColor = const Color(0xFF0924AA);
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTextField(String key, String value) {
    return TextFormField(
      initialValue: value,
      onChanged: (value) => _retoData['opciones'][key] = value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCorrectOptionRadio(String key) {
    final primaryColor = const Color(0xFF0924AA);
    
    return Radio(
      value: key,
      groupValue: _retoData['opcionCorrecta'],
      onChanged: (value) => setState(() => _retoData['opcionCorrecta'] = value),
      fillColor: WidgetStateProperty.all(primaryColor),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveReto,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF0924AA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              'GUARDAR CAMBIOS',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
      ),
    );
  }
}