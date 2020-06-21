import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutterdmzj/component/ComicPage.dart';
import 'package:flutterdmzj/component/LoadingRow.dart';
import 'package:flutterdmzj/component/ViewPointChip.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';

class ComicViewer extends StatefulWidget {
  final String comicId;
  final String chapterId;
  final List chapterList;

  ComicViewer(this.comicId, this.chapterId, this.chapterList);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicViewer(comicId, chapterId, chapterList);
  }
}

class _ComicViewer extends State<ComicViewer> {
  final String comicId;
  String chapterId;
  String title = '加载中';
  List list = <Widget>[];
  final List chapterList;
  bool refreshState = false;

//  ScrollController _controller = ScrollController();
  List viewPointList = <Widget>[];
  SwiperController _controller = SwiperController();

//  StreamSubscription _volumeButtonSubscription;
  String previous;
  String next;
  String pageAt;
  int index = 1;

  bool hiddenAppbar = false;
  bool direction = false;

  _ComicViewer(this.comicId, this.chapterId, this.chapterList);

  getComic(comicId, chapterId, above) async {
    CustomHttp http = CustomHttp();
    var response = await http.getComic(comicId, chapterId);
    if (response.statusCode == 200 && mounted) {
      if (response.data == '章节不存在') {
        setState(() {
          list.add(Center(
            child: Text('章节不存在！'),
          ));
        });
        return;
      }
      setState(() {
        var tempList = <Widget>[];
        title = response.data['title'];
        for (var item in response.data['page_url']) {
          tempList.add(ComicPage(item, chapterId, response.data['title']));
        }
        if (above) {
          list = tempList + list;
          if (chapterList.indexOf(chapterId) < chapterList.length - 1) {
            previous = chapterList[chapterList.indexOf(chapterId) + 1];
          } else {
            next = null;
          }
        } else {
          list += tempList;
          if (chapterList.indexOf(chapterId) > 0) {
            next = chapterList[chapterList.indexOf(chapterId) - 1];
          } else {
            next = null;
          }
        }
      });
      setState(() {
        refreshState = false;
      });
      addReadHistory(chapterId);
    }
  }

  getViewPoint() async {
    CustomHttp http = CustomHttp();
    var response = await http.getViewPoint(comicId, pageAt);
    if (response.statusCode == 200 && mounted) {
      setState(() {
        viewPointList.clear();
        response.data.sort((left, right) {
          return left['num'] < right['num'] ? 1 : -1;
        });
        for (var item in response.data) {
          viewPointList.add(ViewPointChip(
              item['content'], item['id'].toString(), item['num']));
        }
      });
    }
  }

  addReadHistory(chapterId) async {
    DataBase dataBase = DataBase();
    bool loginState = await dataBase.getLoginState();
    if (loginState) {
      var uid = await dataBase.getUid();
      CustomHttp http = CustomHttp();
      http.addReadHistory(comicId, uid);
    }
    dataBase.insertHistory(comicId, chapterId);
  }

  getReadDirection() async {
    DataBase dataBase = DataBase();
    bool direction = await dataBase.getReadDirection();
    setState(() {
      this.direction = direction;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReadDirection();
    setState(() {
      if (chapterList.indexOf(chapterId) > 0) {
        next = chapterList[chapterList.indexOf(chapterId) - 1];
      } else {
        next = null;
      }
      if (chapterList.indexOf(chapterId) < chapterList.length - 1) {
        previous = chapterList[chapterList.indexOf(chapterId) + 1];
      } else {
        next = null;
      }
      pageAt = chapterId;
    });
    getComic(comicId, chapterId, false);
//    _volumeButtonSubscription =
//        volumeButtonEvents.listen((VolumeButtonEvent event) {
//          if(event==VolumeButtonEvent.VOLUME_DOWN){
//            setState(() {
//              if(index<=list.length+1){
//                index++;
//              }
//            });
//          }else if(event==VolumeButtonEvent.VOLUME_UP){
//            setState(() {
//              if(index>=0){
//                index--;
//              }
//            });
//          }
//      // do something
//      // event is either VolumeButtonEvent.VOLUME_UP or VolumeButtonEvent.VOLUME_DOWN
//    });
//    _controller.addListener(() {
//      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
//          !refreshState) {
//        var nextId = chapterList.indexOf(chapterId) - 1;
//        if (nextId < 0) {
//          return;
//        }
//        setState(() {
//          chapterId = chapterList[nextId];
//          refreshState = true;
//        });
//        getComic(comicId, chapterList[nextId], false);
//      }
//    });
  }

//  @override
//  void dispose() {
//    super.dispose();
//    // be sure to cancel on dispose
//    _volumeButtonSubscription?.cancel();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hiddenAppbar
          ? null
          : AppBar(
              title: Text('$title'),
              actions: <Widget>[
                FlatButton(
                  child: Icon(
                    Icons.chat,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await getViewPoint();
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 400,
                            padding: EdgeInsets.all(0),
                            child: SingleChildScrollView(
                                child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text('吐槽'),
                                ),
                                Divider(),
                                Wrap(
                                  children: viewPointList,
                                ),
                              ],
                            )),
                          );
                        });
                  },
                )
              ],
            ),
      body: Swiper(
        scrollDirection: direction ? Axis.vertical : Axis.horizontal,
        controller: _controller,
        index: index,
        loop: false,
        itemCount: list.length + 2,
        itemBuilder: (context, index) {
          if (index > 0 && index < list.length + 1) {
            return list[index - 1];
          } else if (index == list.length + 1 && (next == null || next == '')) {
            return Center(
              child: Text('到头了！'),
            );
          } else if (index == 0 && (previous == null || previous == '')) {
            return Center(
              child: Text('到头了！'),
            );
          } else {
            return LoadingRow();
          }
        },
        onIndexChanged: (index) {
          if (refreshState == false && index == 0) {
            if (previous == null || previous == '') {
              return;
            }
            setState(() {
              refreshState = true;
            });
            getComic(comicId, previous, true);
            return;
          }
          if (refreshState == false && index == list.length + 1) {
            if (next == null || next == '') {
              return;
            }
            setState(() {
              refreshState = true;
            });
            getComic(comicId, next, false);
            return;
          }
          if (index > 0 && index < list.length + 1) {
            setState(() {
              pageAt = list[index - 1].chapterId;
              title = list[index - 1].title;
              this.index = index;
            });
          }
          setState(() {
            hiddenAppbar = true;
          });
        },
        onTap: (index) {
          setState(() {
            hiddenAppbar = !hiddenAppbar;
          });
        },
      ),
    );
  }

  @Deprecated("用更好的AppBar替代了")
  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        title: Text('$title'),
        snap: true,
        floating: true,
        actions: <Widget>[
          FlatButton(
            child: Icon(
              Icons.chat,
              color: Colors.white,
            ),
            onPressed: () async {
              await getViewPoint();
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      height: 400,
                      padding: EdgeInsets.all(0),
                      child: SingleChildScrollView(
                          child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Text('吐槽'),
                          ),
                          Divider(),
                          Wrap(
                            children: viewPointList,
                          ),
                        ],
                      )),
                    );
                  });
            },
          )
        ],
      )
    ];
  }
}
