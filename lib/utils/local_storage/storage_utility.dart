import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class StorageService {

  StorageService._();
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;

  final GetStorage _storage = GetStorage();

  Future<void> write(String key, dynamic value) async{
    await _storage.write(key, value);
  }

  dynamic read(String key) {
    return _storage.read(key);
  }

  void remove(String key) {
    _storage.remove(key);
  }

  void clear() {
    _storage.erase();
  }

  void saveLanguage(Locale locale) {
    _storage.write('language_code', locale.languageCode);
    _storage.write('country_code', locale.countryCode);
  }

  Locale getSavedLocale() {
    String? langCode = _storage.read('language_code');
    String? countryCode = _storage.read('country_code');
    return (langCode != null && countryCode != null)
        ? Locale(langCode, countryCode)
        : const Locale('en', 'US');
  }
}