import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/view/comic_source/comic_source_page.dart';

class SourceSettingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SourceSettingPage();
  }

}

class _SourceSettingPage extends State<SourceSettingPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).SettingPageMainSourceTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(S.of(context).SettingPageSourcePageSourceTitle),
            subtitle: Text(S.of(context).SettingPageSourcePageSourceSubtitle),
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ComicSourcePage()));
            },
          ),
          ListTile(
            title: Text(S.of(context).SettingPageSourcePageSourceProviderTitle),
            subtitle: Text(S.of(context).SettingPageSourcePageSourceProviderSubtitle),
          ),
        ],
      ),
    );
  }

}