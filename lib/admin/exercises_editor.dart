import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:universal_html/html.dart' as html;
import 'package:mathtools/models/exercise_model.dart';

class ExerciseEditorScreen extends StatefulWidget {
  const ExerciseEditorScreen({super.key});

  @override
  State<ExerciseEditorScreen> createState() => _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends State<ExerciseEditorScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('ejercicios');
  final _formKey = GlobalKey<FormState>();
  final _newTopicController = TextEditingController();
  final _newSubTopicController = TextEditingController();

  List<String> _temas = [];
  List<String> _subtemas = [];
  List<ExerciseModel> _ejercicios = [];
  Map<String, dynamic> _ejercicioData = {};
  
  String? _selectedTema;
  String? _selectedSubtema;
  bool _isLoading = true;
  bool _isSaving = false;
  File? _imageFile;
  bool _isUploading = false;
  bool _isNewExercise = false;
  bool _showNewTopicField = false;
  bool _showNewSubTopicField = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final temasSnapshot = await _dbRef.child('temas').get();
      if (temasSnapshot.exists) {
        _temas = List<String>.from(temasSnapshot.value as List);
        if (_temas.isNotEmpty) {
          _selectedTema = _temas.first;
          await _loadSubtemas(_selectedTema!);
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _loadSubtemas(String tema) async {
    setState(() {
      _isLoading = true;
      _selectedSubtema = null;
      _subtemas = [];
      _ejercicios = [];
    });

    try {
      final snapshot = await _dbRef.child('subtemas/$tema').get();
      if (snapshot.exists) {
        _subtemas = List<String>.from(snapshot.value as List);
        if (_subtemas.isNotEmpty) {
          _selectedSubtema = _subtemas.first;
          await _loadEjercicios(tema, _selectedSubtema!);
        }
      }
    } catch (e) {
      debugPrint('Error loading subtemas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEjercicios(String tema, String subtema) async {
    setState(() {
      _isLoading = true;
      _ejercicios = [];
    });

    try {
      final snapshot = await _dbRef.child('ejercicios/$tema/$subtema').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _ejercicios = data.entries.map((e) {
          final exerciseData = Map<String, dynamic>.from(e.value);
          return ExerciseModel.fromMap(exerciseData);
        }).toList();
      }
    } catch (e) {
      debugPrint('Error loading ejercicios: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _newExercise() {
    setState(() {
      _isNewExercise = true;
      _ejercicioData = {
        'id': '',
        'tema': _selectedTema,
        'subtema': _selectedSubtema,
        'dificultad': 'facil',
        'premisa': '',
        'opciones': {'a': '', 'b': '', 'c': '', 'd': ''},
        'opcionCorrecta': 'a',
        'solucion': '',
        'imagenUrl': '',
      };
    });
  }

  void _editExercise(ExerciseModel ejercicio) {
    setState(() {
      _isNewExercise = false;
      _ejercicioData = ejercicio.toMap();
    });
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
        final file = result.files.single;
        url = await _uploadToImgBBWeb(file);
      } else {
        _imageFile = File(result.files.single.path!);
        url = await _uploadToImgBB(_imageFile!);
      }

      setState(() {
        _ejercicioData['imagenUrl'] = url;
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

    final json = request.responseText != null 
      ? jsonDecode(request.responseText!) 
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

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTema == null || _selectedSubtema == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un tema y subtema'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final tema = _selectedTema!;
      final subtema = _selectedSubtema!;
      
      if (_isNewExercise) {
        // Generar nuevo ID
        final newId = 'ej${DateTime.now().millisecondsSinceEpoch}';
        _ejercicioData['id'] = newId;
      }

      await _dbRef.child('ejercicios/$tema/$subtema/${_ejercicioData['id']}').update(_ejercicioData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ejercicio guardado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Recargar los ejercicios
      await _loadEjercicios(tema, subtema);
      setState(() => _isNewExercise = false);
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

  Future<void> _addNewTopic() async {
    if (_newTopicController.text.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final newTopic = _newTopicController.text.trim();
      
      // Agregar a la lista de temas
      await _dbRef.child('temas').set([..._temas, newTopic]);
      
      // Crear estructura para el nuevo tema
      await _dbRef.child('subtemas/$newTopic').set([]);
      await _dbRef.child('ejercicios/$newTopic').set({});

      setState(() {
        _temas.add(newTopic);
        _selectedTema = newTopic;
        _showNewTopicField = false;
        _newTopicController.clear();
      });

      await _loadSubtemas(newTopic);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar tema: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _addNewSubTopic() async {
    if (_newSubTopicController.text.isEmpty || _selectedTema == null) return;

    setState(() => _isSaving = true);
    try {
      final newSubTopic = _newSubTopicController.text.trim();
      
      // Agregar a la lista de subtemas
      await _dbRef.child('subtemas/$_selectedTema').set([..._subtemas, newSubTopic]);
      
      // Crear estructura para el nuevo subtema
      await _dbRef.child('ejercicios/$_selectedTema/$newSubTopic').set({});

      setState(() {
        _subtemas.add(newSubTopic);
        _selectedSubtema = newSubTopic;
        _showNewSubTopicField = false;
        _newSubTopicController.clear();
      });

      await _loadEjercicios(_selectedTema!, newSubTopic);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar subtema: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteExercise() async {
    if (_selectedTema == null || _selectedSubtema == null || _ejercicioData['id'] == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este ejercicio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      await _dbRef.child('ejercicios/$_selectedTema/$_selectedSubtema/${_ejercicioData['id']}').remove();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ejercicio eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Recargar los ejercicios
      await _loadEjercicios(_selectedTema!, _selectedSubtema!);
      setState(() => _ejercicioData = {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel izquierdo - Lista de ejercicios
        Expanded(
          flex: 2,
          child: _buildExerciseListPanel(),
        ),
        
        // Panel derecho - Editor de ejercicio
        Expanded(
          flex: 3,
          child: _ejercicioData.isNotEmpty 
              ? _buildExerciseEditor() 
              : const Center(child: Text('Selecciona o crea un ejercicio para editar')),
        ),
      ],
    );
  }

  Widget _buildExerciseListPanel() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Selector de tema
            _buildTopicSelector(),
            const SizedBox(height: 16),
            
            // Selector de subtema
            _buildSubTopicSelector(),
            const SizedBox(height: 16),
            
            // Lista de ejercicios
            Expanded(
              child: _ejercicios.isEmpty
                  ? const Center(child: Text('No hay ejercicios en este subtema'))
                  : ListView.builder(
                      itemCount: _ejercicios.length,
                      itemBuilder: (context, index) {
                        final ejercicio = _ejercicios[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text('Ejercicio ${index + 1}'),
                            subtitle: Text('Dificultad: ${ejercicio.dificultad}'),
                            trailing: IconButton(
                              icon: const Icon(Iconsax.edit),
                              onPressed: () => _editExercise(ejercicio),
                            ),
                            onTap: () => _editExercise(ejercicio),
                          ),
                        );
                      },
                    ),
            ),
            
            // Botón para nuevo ejercicio
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSubtema == null ? null : _newExercise,
                child: const Text('Nuevo Ejercicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedTema,
                items: _temas.map((tema) {
                  return DropdownMenuItem(
                    value: tema,
                    child: Text(tema),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedTema = value);
                    _loadSubtemas(value);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Tema',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(_showNewTopicField ? Iconsax.close_circle : Iconsax.add),
              onPressed: () {
                setState(() {
                  _showNewTopicField = !_showNewTopicField;
                  if (!_showNewTopicField) _newTopicController.clear();
                });
              },
            ),
          ],
        ),
        
        if (_showNewTopicField) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _newTopicController,
                  decoration: InputDecoration(
                    labelText: 'Nuevo tema',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.tick_circle),
                onPressed: _addNewTopic,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSubTopicSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSubtema,
                items: _subtemas.map((subtema) {
                  return DropdownMenuItem(
                    value: subtema,
                    child: Text(subtema),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null && _selectedTema != null) {
                    setState(() => _selectedSubtema = value);
                    _loadEjercicios(_selectedTema!, value);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Subtema',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(_showNewSubTopicField ? Iconsax.close_circle : Iconsax.add),
              onPressed: () {
                if (_selectedTema == null) return;
                setState(() {
                  _showNewSubTopicField = !_showNewSubTopicField;
                  if (!_showNewSubTopicField) _newSubTopicController.clear();
                });
              },
            ),
          ],
        ),
        
        if (_showNewSubTopicField) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _newSubTopicController,
                  decoration: InputDecoration(
                    labelText: 'Nuevo subtema',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.tick_circle),
                onPressed: _addNewSubTopic,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildExerciseEditor() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isNewExercise ? 'Nuevo Ejercicio' : 'Editar Ejercicio',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_isNewExercise)
                    IconButton(
                      icon: const Icon(Iconsax.trash, color: Colors.red),
                      onPressed: _deleteExercise,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Dificultad
              DropdownButtonFormField<String>(
                value: _ejercicioData['dificultad'] ?? 'facil',
                items: const [
                  DropdownMenuItem(value: 'facil', child: Text('Fácil')),
                  DropdownMenuItem(value: 'medio', child: Text('Medio')),
                  DropdownMenuItem(value: 'dificil', child: Text('Difícil')),
                  DropdownMenuItem(value: 'experto', child: Text('Experto')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _ejercicioData['dificultad'] = value);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Dificultad',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Premisa
              _buildTextField(
                'Premisa', 
                _ejercicioData['premisa'] ?? '', 
                (value) => _ejercicioData['premisa'] = value,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Imagen
              _buildImageUploader(),
              const SizedBox(height: 16),
              
              // Opciones de respuesta
              _buildOptionsSection(),
              const SizedBox(height: 16),
              
              // Solución
              _buildTextField(
                'Solución', 
                _ejercicioData['solucion'] ?? '', 
                (value) => _ejercicioData['solucion'] = value,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              
              // Botones de guardar/cancelar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _ejercicioData = {});
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0924AA),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'GUARDAR',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          'Imagen del ejercicio',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        if (_ejercicioData['imagenUrl'] != null || (!kIsWeb && _imageFile != null))
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
                    ? Image.network(_ejercicioData['imagenUrl'], fit: BoxFit.cover)
                    : _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : Image.network(_ejercicioData['imagenUrl'], fit: BoxFit.cover),
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
    final options = _ejercicioData['opciones'] as Map<dynamic, dynamic>? ?? {};
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
      onChanged: (value) {
        setState(() {
          _ejercicioData['opciones'][key] = value;
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Opción requerida' : null,
    );
  }

  Widget _buildCorrectOptionRadio(String key) {
    final primaryColor = const Color(0xFF0924AA);
    
    return Radio(
      value: key,
      groupValue: _ejercicioData['opcionCorrecta'],
      onChanged: (value) {
        setState(() {
          _ejercicioData['opcionCorrecta'] = value;
        });
      },
      fillColor: WidgetStateProperty.all(primaryColor),
    );
  }
}