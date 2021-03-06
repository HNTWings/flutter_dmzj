import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/model/baseModel.dart';

class SystemSettingModel extends BaseModel {
  static const List darkMode = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark
  ];

  // 夜间模式
  int _darkState = 0;

  // 备用API
  bool _backupApi = false;

  bool _blackBox = false;

  String _savePath = '';

  bool _noMedia = false;

  bool _labState=false;

  bool _novel=false;

  bool _deepSearch=false;

  bool _darkSide=false;

  DataBase _dataBase = DataBase();

  SystemSettingModel() {
    this
        .init()
        .then((value) => logger.i('class: SystemSettingModel, action: init'));
  }

  Future<void> init() async {
    _darkState = await _dataBase.getDarkMode();
    _backupApi = await _dataBase.getBackupApi();
    _blackBox = await _dataBase.getBlackBox();
    _savePath = await _dataBase.getDownloadPath();
    _noMedia = await File('$savePath/.nomedia').exists();
    _labState=await _dataBase.getLabState();
    _novel=await _dataBase.getNovelState();
    _darkSide=await _dataBase.getDarkSide();
    _deepSearch=await _dataBase.getDeepSearch();
    notifyListeners();
  }

  ThemeMode get themeMode => darkMode[_darkState];

  set darkState(int state) {
    _dataBase.setDarkMode(state);
    _darkState = state;
    notifyListeners();
  }

  int get darkState => _darkState;

  bool get backupApi => _backupApi;

  set backupApi(bool state) {
    _dataBase.setBackupApi(state);
    _backupApi = state;
    notifyListeners();
  }

  bool get blackBox => _blackBox;

  set blackBox(bool value) {
    _dataBase.setBlackBox(value);
    _blackBox = value;
    notifyListeners();
  }

  String get savePath => _savePath;

  set savePath(String path) {
    _dataBase.setDownloadPath(path);
    _savePath = path;
    notifyListeners();
  }

  bool get noMedia => _noMedia;

  set noMedia(bool value) {
    _noMedia = value;
    var file = File('$savePath/.nomedia');
    if (value) {
      file.exists().then((value) {
        if (!value) {
          file.create(recursive: true);
        }
      });
    } else {
      file.exists().then((value) {
        if (value) {
          file.delete();
        }
      });
    }
    notifyListeners();
  }

  bool get labState=>_labState;

  set labState(bool value){
    _dataBase.setLabState(value);
    _labState=value;
    notifyListeners();
  }


  bool get darkSide => _darkSide;

  set darkSide(bool value) {
    _dataBase.setDarkSide(value);
    _darkSide = value;
    notifyListeners();
  }

  bool get deepSearch => _deepSearch;

  set deepSearch(bool value) {
    _dataBase.setDeepSearch(value);
    _deepSearch = value;
    notifyListeners();
  }

  bool get novel => _novel;

  set novel(bool value) {
    _dataBase.setNovelState(value);
    _novel = value;
    notifyListeners();
  }
}
