import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

enum AppValuesKey { citizenId, municipalities, categories }

class AppValuesHelper {
  ///
  /// STATIC
  ///
  //region Static

  static AppValuesHelper? _appValuesHelper;
  static late SharedPreferences _sharedPreferences;

  static AppValuesHelper getInstance() {
    _appValuesHelper ??= AppValuesHelper._();
    return _appValuesHelper!;
  }

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  AppValuesHelper._();

  //endregion

  ///
  /// PROPERTIES
  ///
  //region Properties

  List<T> _getList<T>(
      AppValuesKey appValuesKey, Function(dynamic model) mapping) {
    Iterable l = jsonDecode(getString(appValuesKey) ?? "");
    List<T> list = List<T>.from(l.map((model) => mapping(model)));
    return list;
  }

  List<Municipality> getMunicipalities() {
    return _getList<Municipality>(
        AppValuesKey.municipalities, (model) => Municipality.fromJson(model));
  }

  List<Category> getCategories() {
    return _getList<Category>(
        AppValuesKey.categories, (model) => Category.fromJson(model));
  }

  _saveList(AppValuesKey appValuesKey, List<dynamic> list) {
    var json = jsonEncode(list.map((e) => e.toJson()).toList());
    saveString(appValuesKey, json);
  }

  saveMunicipalities(List<Municipality> municipalities) {
    // Save municipalities
    _saveList(AppValuesKey.municipalities, municipalities);
  }

  saveCategories(List<Category> categories) {
    // Save categories
    _saveList(AppValuesKey.categories, categories);
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  String? getString(AppValuesKey appValuesKey) {
    return _sharedPreferences.getString(appValuesKey.toString());
  }

  int? getInteger(AppValuesKey appValuesKey) {
    try {
      return _sharedPreferences.getInt(appValuesKey.toString());
    } on Exception catch (_) {
      return null;
    }
  }

  bool getBool(AppValuesKey appValuesKey) {
    try {
      return _sharedPreferences.getBool(appValuesKey.toString()) ?? false;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<bool> saveString(AppValuesKey appValuesKey, String value) async {
    return _sharedPreferences.setString(appValuesKey.toString(), value);
  }

  Future<bool> saveBool(AppValuesKey appValuesKey, bool value) async {
    return _sharedPreferences.setBool(appValuesKey.toString(), value);
  }

  Future<bool> saveInteger(AppValuesKey appValuesKey, int value) async {
    return _sharedPreferences.setInt(appValuesKey.toString(), value);
  }

//endregion

}
