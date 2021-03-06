import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutterdmzj/http/http.dart';

import 'SearchListTile.dart';

class DeepSearchTab extends StatefulWidget{
  final Key key;
  final String keyword;

  DeepSearchTab({this.key,this.keyword});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DeepSearchTab(keyword);
  }

}

class _DeepSearchTab extends State<DeepSearchTab>{
  List list = <Widget>[];
  final String keyword;
  bool refreshState = false;


  _DeepSearchTab(this.keyword);

  search() async {
    if(keyword!=null &&keyword!=''){
      CustomHttp http = CustomHttp();
      var response = await http.deepSearch(keyword);
      if (response.statusCode == 200 && mounted) {
        var jsonData=response.data.toString().substring(response.data.toString().indexOf('=')+1,response.data.toString().length-1);
        var data=jsonDecode(jsonData);
        setState(() {
          if (response.data.length == 0) {
            refreshState = true;
            return;
          }
          for (var item in data) {
            list.add(SearchListTile(item['cover'], item['comic_name'], '',
                item['last_update_chapter_name'], item['id'].toString(), item['comic_author']));
          }
          refreshState = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    search();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return list[index];
      },
    );
  }

}