import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:darq/darq.dart';

enum AppValuesKey {
  citizenId,
  municipalities,
  categories,
  reportCategories,
  defaultMunicipalityId
}

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
    String str = getString(appValuesKey) ?? "";
    if (str.isEmpty) return List.empty(growable: true);
    Iterable l = jsonDecode(str);
    List<T> list = List<T>.from(l.map((model) => mapping(model)));
    return list;
  }

  List<Municipality> getMunicipalities() {
    return _getList<Municipality>(AppValuesKey.municipalities,
            (model) => Municipality.fromJson(model))
        .orderBy((element) => element.name!,
            keyComparer: EqualityComparer(
                sorter: (String a, String b) => a.compareTo(b)))
        .toList(growable: true);
  }

  List<Category> getCategories() {
    return _getList<Category>(
        AppValuesKey.categories, (model) => Category.fromJson(model));
  }

  List<ReportCategory> getReportCategories() {
    return _getList<ReportCategory>(AppValuesKey.reportCategories,
        (model) => ReportCategory.fromJson(model));
  }

  List<IssueState> getIssueStates() {
    List<IssueState> list = List.empty(growable: true);
    list.add(IssueState(id: 1, name: "Created"));
    list.add(IssueState(id: 2, name: "Approved"));
    list.add(IssueState(id: 3, name: "Resolved"));
    list.add(IssueState(id: 4, name: "Not resolved"));
    return list;
  }

  _saveList(AppValuesKey appValuesKey, List<dynamic> list) {
    var json = jsonEncode(list.map((e) => e.toJson()).toList());
    saveString(appValuesKey, json);
  }

  saveMunicipalities(List<Municipality> municipalities) {
    _saveList(AppValuesKey.municipalities, municipalities);
  }

  saveCategories(List<Category> categories) {
    _saveList(AppValuesKey.categories, categories);
  }

  saveReportCategories(List<ReportCategory> reportCategories) {
    _saveList(AppValuesKey.reportCategories, reportCategories);
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

  Future<bool> saveInteger(AppValuesKey appValuesKey, int? value) async {
    if (value == null) {
      _sharedPreferences.remove(appValuesKey.toString());
      return true;
    } else {
      return _sharedPreferences.setInt(appValuesKey.toString(), value);
    }
  }

//endregion

}
