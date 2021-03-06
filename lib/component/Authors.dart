import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/view/author_page.dart';

class Authors extends StatelessWidget{
  final List tags;


  Authors(this.tags);

  @override
  Widget build(BuildContext context) {
    
    // TODO: implement build
    return FlatButton(
      padding: EdgeInsets.zero,
      child: Text('${tags.map((value){return value['tag_name'];}).toList().join('/')}'),
      onPressed: (){
        showDialog(context: context, builder: (context){
          return SimpleDialog(
            title: Text('作者'),
            children: tags.map((value){
              return SimpleDialogOption(
                child: Text('${value['tag_name']}'),
                onPressed: (){
                  Navigator.pop(context);
                  if(value['tag_name']!=null){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return AuthorPage(value['tag_id'],value['tag_name']);
                    }));
                  }
                },
              );
            }).toList(),
          );
        });
      },
    );
  }

}