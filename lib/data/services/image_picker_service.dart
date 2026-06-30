// lib/data/services/image_picker_service.dart
// ============================================================================
// SERVICIO CORREGIDO PARA MANEJAR SELECCIÓN DE IMÁGENES
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';
import '../../presentation/screens/v2/components/minimal_colors.dart';

class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger();

  /// Mostrar diálogo para seleccionar origen de imagen - CORREGIDO
  Future<String?> showImageSourceDialog(BuildContext context) async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: MinimalColors.backgroundSecondary(bottomSheetContext),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      '📸 Seleccionar foto de perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Colors.purple,
                    size: 28,
                  ),
                  title: const Text(
                    'Tomar foto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text(
                    'Usar la cámara',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () async {
                    // ✅ CORRECCIÓN: Lógica simplificada
                    try {
                      final imagePath = await _pickImageFromCamera();
                      if (bottomSheetContext.mounted) {
                        Navigator.pop(bottomSheetContext, imagePath);
                      }
                    } catch (e) {
                      _logger.e('Error tomando foto: $e');
                      if (bottomSheetContext.mounted) {
                        Navigator.pop(bottomSheetContext, null);
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Colors.green,
                    size: 28,
                  ),
                  title: const Text(
                    'Galería',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text(
                    'Seleccionar de galería',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () async {
                    // ✅ CORRECCIÓN: Lógica simplificada
                    try {
                      final imagePath = await _pickImageFromGallery();
                      if (bottomSheetContext.mounted) {
                        Navigator.pop(bottomSheetContext, imagePath);
                      }
                    } catch (e) {
                      _logger.e('Error seleccionando de galería: $e');
                      if (bottomSheetContext.mounted) {
                        Navigator.pop(bottomSheetContext, null);
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 28,
                  ),
                  title: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    // ✅ CORRECCIÓN: Solo cerrar sin resultado
                    Navigator.pop(bottomSheetContext, null);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Tomar foto con la cámara
  Future<String?> _pickImageFromCamera() async {
    try {
      _logger.i('📷 Iniciando captura de imagen con cámara');

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        final savedPath = await _saveImageToAppDirectory(image);
        _logger.i('✅ Imagen capturada y guardada: $savedPath');
        return savedPath;
      }

      _logger.i('📷 Captura de imagen cancelada por el usuario');
      return null;
    } catch (e) {
      _logger.e('❌ Error al capturar imagen: $e');
      return null;
    }
  }

  /// Seleccionar imagen de la galería
  Future<String?> _pickImageFromGallery() async {
    try {
      _logger.i('📸 Iniciando selección de imagen desde galería');

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        final savedPath = await _saveImageToAppDirectory(image);
        _logger.i('✅ Imagen seleccionada y guardada: $savedPath');
        return savedPath;
      }

      _logger.i('📸 Selección de imagen cancelada por el usuario');
      return null;
    } catch (e) {
      _logger.e('❌ Error al seleccionar imagen: $e');
      return null;
    }
  }

  /// Guardar imagen en el directorio de la aplicación
  Future<String> _saveImageToAppDirectory(XFile image) async {
    try {
      // ✅ CORRECCIÓN: Usar getApplicationDocumentsDirectory en lugar de getApplicationSupportDirectory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String profilePicsDir = path.join(appDocDir.path, 'profile_pictures');

      // Crear directorio si no existe
      final Directory profileDir = Directory(profilePicsDir);
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // Generar nombre único basado en timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileExtension = path.extension(image.path);
      final String fileName = 'profile_$timestamp$fileExtension';
      final String newPath = path.join(profilePicsDir, fileName);

      // Copiar archivo a la nueva ubicación
      final File originalFile = File(image.path);
      await originalFile.copy(newPath);

      _logger.i('💾 Imagen guardada exitosamente en: $newPath');
      return newPath;
    } catch (e) {
      _logger.e('❌ Error al guardar imagen: $e');
      rethrow;
    }
  }

  /// Eliminar imagen de perfil anterior
  Future<void> deleteProfilePicture(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;

    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        _logger.i('🗑️ Imagen de perfil anterior eliminada: $imagePath');
      }
    } catch (e) {
      _logger.e('❌ Error al eliminar imagen: $e');
    }
  }

  /// Verificar si el archivo de imagen existe
  Future<bool> imageExists(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;

    try {
      final File imageFile = File(imagePath);
      return await imageFile.exists();
    } catch (e) {
      _logger.e('❌ Error al verificar existencia de imagen: $e');
      return false;
    }
  }

  /// ✅ NUEVO: Método directo para tomar foto (sin modal)
  Future<String?> takePicture() async {
    return await _pickImageFromCamera();
  }

  /// ✅ NUEVO: Método directo para seleccionar de galería (sin modal)
  Future<String?> pickFromGallery() async {
    return await _pickImageFromGallery();
  }
}