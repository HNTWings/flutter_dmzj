import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/baseModel.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:package_info/package_info.dart';

class VersionModel extends BaseModel {
  // 更新通道
  int _updateChannel = 0;

  static const List<String> channels=[
    'release','beta'
  ];

  String _latestVersion = '0.0.1';
  String _currentVersion = '0.0.1';
  String _localLatestVersion = '0.0.1';

  VersionModel(){
    init();
  }

  Future<void> init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version;
    DataBase dataBase = DataBase();
    _localLatestVersion = await dataBase.getVersion();
    _updateChannel=await dataBase.getUpdateChannel();
    if(_localLatestVersion==''||ToolMethods.checkVersionSemver(_localLatestVersion, _currentVersion)){
      _localLatestVersion=_currentVersion;
    }
    await checkUpdate();
    logger.i('class: VersionModel, action: init, latestVersion: $latestVersion, currentVersion: $currentVersion, localLatestVersion: $localLatestVersion');
    notifyListeners();
  }

  Future<void> checkUpdate() async {
    try {
      CustomHttp http = CustomHttp();

        switch (_updateChannel) {
          case 0:
            var response = await http.checkUpdate();
            if (response.statusCode == 200) {
              _latestVersion = response.data['tag_name'].substring(1);
            }
            break;
          case 1:
            var response=await http.getAllUpdateList();
            _latestVersion = response.data.first['tag_name'].substring(1);
            break;
        }
        notifyListeners();
    } catch (e) {
      logger.e('class: VersionModel, action: checkUpdateFailed, exception: $e');
    }
  }

  void showUpdateDialog(context)async{
    CustomHttp http = CustomHttp();
    String tagName;
    String body;
    String htmlUrl;
    String downloadUrl;
    switch(_updateChannel){
      case 0:
        var response = await http.checkUpdate();
        tagName=response.data['tag_name'];
        body=response.data['body'];
        htmlUrl=response.data['html_url'];
        if(response.data['assets'].length>0){
          downloadUrl=response.data['assets'][0]['browser_download_url'];
        }
        break;
      case 1:
        var response=await http.getAllUpdateList();
        tagName=response.data.first['tag_name'];
        body=response.data.first['body'];
        htmlUrl=response.data.first['html_url'];
        if(response.data.first['assets'].length>0){
          downloadUrl=response.data.first['assets'][0]['browser_download_url'];
        }
        break;
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('版本点亮：$tagName'),
            content: Container(
              width: 300,
              height: 300,
              child: MarkdownWidget(data: body),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('打开网页'),
                onPressed: () {
                  ToolMethods.callWeb('$htmlUrl', context);
                },
              ),
              FlatButton(
                child: Text('更新'),
                onPressed: () async {
                  if (downloadUrl!=null) {
                    DataBase dataBase = DataBase();
                    var downloadPath = await dataBase.getDownloadPath();
                    FlutterDownloader.enqueue(
                        url: downloadUrl, savedDir: '$downloadPath');
                    Navigator.pop(context);
                  } else {
                    ToolMethods.callWeb('$htmlUrl', context);
                  }
                },
              ),
              FlatButton(
                child: Text('镜像更新'),
                onPressed: () async {
                  if (downloadUrl!=null) {
                    DataBase dataBase = DataBase();
                    var downloadPath = await dataBase.getDownloadPath();
                    FlutterDownloader.enqueue(
                        url:
                        'https://divine-boat-417a.hanerx.workers.dev/$downloadUrl',
                        savedDir: '$downloadPath');
                    Navigator.pop(context);
                  } else {
                    ToolMethods.callWeb('$htmlUrl', context);
                  }
                },
              ),
              FlatButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  int get updateChannel => _updateChannel;

  String get updateChannelName=>_updateChannel<channels.length?channels[_updateChannel]:'未知通道';

  set updateChannel(int channel) {
    if(0<=channel&&channel<channels.length){
      _updateChannel = channel;
    }else{
      _updateChannel=0;
    }
    DataBase dataBase=DataBase();
    dataBase.setUpdateChannel(channel);
    notifyListeners();
  }

  String get localLatestVersion => _localLatestVersion;

  set localLatestVersion(String version){
    DataBase dataBase=DataBase();
    dataBase.setVersion(version);
    _localLatestVersion=version;
    notifyListeners();
  }

  String get currentVersion => _currentVersion;

  String get latestVersion => _latestVersion;
}
