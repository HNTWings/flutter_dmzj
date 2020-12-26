import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/LoadingRow.dart';
import 'package:flutterdmzj/component/SubscribeCard.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/utils/static_language.dart';
import 'package:flutterdmzj/view/novel_pages/novel_detail_page.dart';

class NovelFavoritePage extends StatefulWidget {
  final String uid;

  const NovelFavoritePage({Key key, this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelFavoritePage();
  }
}

class _NovelFavoritePage extends State<NovelFavoritePage> {
  ScrollController _controller = ScrollController();
  List list = <Widget>[LoadingRow()];
  int page = 0;
  int _row = 3;
  bool refreshState = false;

  Future<void> getSubscribe() async {
    CustomHttp http = CustomHttp();
    var response =
        await http.getSubscribe(int.parse(widget.uid), page, type: 1);
    if (response.statusCode == 200 && mounted) {
      setState(() {
        if (page == 0) {
          list.clear();
        } else {
          list.removeLast();
        }
        if (response.data.length == 0) {
          refreshState = true;
          if (page == 0) {
            list.add(Center(
              child: Text('看起来你没收藏啥，请先去收藏'),
            ));
          }
          return;
        }
        var cardList = <Widget>[];
        var position = 0;
        for (var item in response.data) {
          if (position >= _row) {
            list.add(Row(
              children: cardList,
            ));
            position = 0;
            cardList = <Widget>[];
          }
          cardList.add(_NovelCard(id: item['id'],cover: item['sub_img'],title: item['name'],subtitle: item['sub_update'],));
          position++;
        }
        if (cardList.length > 0 && position < _row) {
          list.add(Row(
            children: cardList,
          ));
        }
        refreshState = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSubscribe();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          !refreshState) {
        setState(() {
          refreshState = true;
          page++;
          list.add(LoadingRow());
        });
        getSubscribe();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scrollbar(
      child: RefreshIndicator(
        onRefresh: ()async{
          setState(() {
            page=0;
            refreshState=true;
            list.clear();
            list.add(LoadingRow());
          });
          await getSubscribe();
        },
        child: SingleChildScrollView(
          controller: _controller,
          child: Column(
            children: list,
          ),
        ),
      )
    );
  }
}

class _NovelCard extends StatelessWidget {
  final String cover;
  final String title;
  final String subtitle;
  final int id;

  const _NovelCard({Key key, this.cover, this.title, this.subtitle, this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Expanded(
      child: FlatButton(
        padding: EdgeInsets.all(0),
        child: Card(
          child: _Card(cover, title, subtitle),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return NovelDetailPage(
              id: id,
            );
          }));
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String cover;
  final String title;
  final String subTitle;

  _Card(this.cover, this.title, this.subTitle);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        CachedNetworkImage(
          imageUrl: '$cover',
          httpHeaders: {'referer': 'http://images.dmzj.com'},
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        Text(
          '$title',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${StaticLanguage.staticStrings['subscribeCard.latestUpdate']}$subTitle',
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}
