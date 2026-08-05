// ====================================================================
// GEOSYNC - LOCAL STORAGE SERVICE (PERSISTENSI DATA LOKAL & IMAGE STORAGE)
// Mengelola penyimpanan permanen anti-reset untuk data karyawan, absensi, & foto profil
// ====================================================================

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ---- BASIC KEY-VALUE GETTERS & SETTERS ----
  static Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  static String? getString(String key) => _prefs.getString(key);

  static Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  static int? getInt(String key) => _prefs.getInt(key);

  static Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  static bool? getBool(String key) => _prefs.getBool(key);

  static Future<bool> remove(String key) => _prefs.remove(key);

  // ---- JSON OBJECT / LIST PERSISTENCE ----
  static Future<bool> setJson(String key, Object data) {
    return _prefs.setString(key, jsonEncode(data));
  }

  static dynamic getJson(String key) {
    final str = _prefs.getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str);
    } catch (_) {
      return null;
    }
  }

  // ---- PERMANENT IMAGE FILE STORAGE ----
  // Salin file gambar sementara dari galeri/camera ke folder dokumen aplikasi permanen
  static Future<String?> savePermanentImage(File sourceFile, String filenamePrefix) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final ext = sourceFile.path.contains('.') ? '.${sourceFile.path.split('.').last}' : '.jpg';
      final newFileName = '${filenamePrefix}_${DateTime.now().millisecondsSinceEpoch}$ext';
      final savedPath = '${appDir.path}/$newFileName';
      
      final newFile = await sourceFile.copy(savedPath);
      return newFile.path;
    } catch (e) {
      return null;
    }
  }
}
