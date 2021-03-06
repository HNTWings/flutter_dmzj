import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutterdmzj/database/database.dart';

class CustomHttp {
  Dio dio;
  Dio unCachedDio;
  String baseUrl = 'https://v3api.dmzj1.com';
  String apiUrl='https://api.dmzj1.com';
  String sacgUrl='https://sacg.dmzj1.com';
  String imgUrl='http://imgsmall.dmzj1.com';
  String iUrl='https://i.dmzj1.com';
  String mUrl='https://m.dmzj.com';
  final String queryOptions = 'channel=Android&version=1.2.0';
  DioCacheManager _cacheManager;

  CustomHttp() {
    dio = Dio();
    _cacheManager = DioCacheManager(CacheConfig(baseUrl: baseUrl));
    dio.interceptors.add(_cacheManager.interceptor);
    dio.interceptors.add(
        DioCacheManager(CacheConfig(baseUrl: 'https://dark-dmzj.hloli.net'))
            .interceptor);
    dio.interceptors.add(
        DioCacheManager(CacheConfig(baseUrl: sacgUrl))
            .interceptor);
    dio.interceptors
        .add(DioCacheManager(CacheConfig(baseUrl: apiUrl)).interceptor);
    dio.interceptors
        .add(DioCacheManager(CacheConfig(baseUrl: imgUrl)).interceptor);
    dio.interceptors
        .add(DioCacheManager(CacheConfig(baseUrl: mUrl)).interceptor);
    unCachedDio = Dio();
  }

  clearCache() {
    _cacheManager.clearAll();
  }

  Future<Options> setHeader() async {
    DataBase dataBase = DataBase();
    var cookies = await dataBase.getCookies();
    var cookie = '';
    for (var item in cookies.first) {
      cookie += item['key'] + '=' + item['value'].split(';')[0] + ';';
    }
    Map<String, dynamic> headers = new Map();
    headers['Cookie'] = cookie;
    Options options = new Options(headers: headers);
    return options;
  }

  Future<Response<T>> getMainPageRecommend<T>() async {
    return dio.get(baseUrl + "/recommend.json?$queryOptions",
        options: buildCacheOptions(Duration(days: 1)));
  }

  Future<Response<T>> getNovelMainPageRecommend<T>() async {
    return dio.get(baseUrl + "/novel/recommend.json?$queryOptions",
        options: buildCacheOptions(Duration(days: 1)));
  }

  Future<Response<T>> getCategory<T>(int type) async {
    return dio.get(baseUrl + '/$type/category.json?$queryOptions',
        options: buildCacheOptions(Duration(days: 3)));
  }

  Future<Response<T>> getFilterTags<T>() async {
    return dio.get(baseUrl + '/rank/type_filter.json?$queryOptions',
        options: buildCacheOptions(Duration(days: 7)));
  }

  Future<Response<T>> getRankList<T>(
      int date, int type, int tag, int page) async {
    return dio.get(baseUrl + '/rank/$tag/$date/$type/$page.json?$queryOptions',
        options: buildCacheOptions(Duration(hours: 2)));
  }

  Future<Response<T>> getNovelFilterTags<T>() async {
    return dio.get(baseUrl + '/novel/tag.json?$queryOptions',
        options: buildCacheOptions(Duration(days: 7)));
  }

  Future<Response<T>> getNovelRankList<T>(int type, int tag, int page) async {
    return dio.get(baseUrl + '/novel/rank/$type/$tag/$page.json?$queryOptions',
        options: buildCacheOptions(Duration(hours: 2)));
  }

  Future<Response<T>> getComicDetail<T>(String comicId) async {
    Options options = await this.setHeader();
    return dio.get(baseUrl + '/comic/comic_$comicId.json?$queryOptions',
        options: buildCacheOptions(Duration(hours: 1), options: options));
  }

  Future<Response<T>> getComicDetailWeb<T>(String comicId) async {
    return dio.get('$mUrl/info/$comicId.html');
  }

  Future<Response<T>> getComicDetailDark<T>(String comicId) async {
    Options options = await this.setHeader();
    return dio.get('$apiUrl/dynamic/comicinfo/$comicId.json',
        options: buildCacheOptions(Duration(hours: 1), options: options));
  }

  Future<Response<T>> getComic<T>(String comicId, String chapterId) async {
    Options options = await this.setHeader();
    return dio.get(baseUrl + '/chapter/$comicId/$chapterId.json?$queryOptions',
        options: buildCacheOptions(Duration(hours: 8), options: options));
  }

  Future<Response<T>> getComicWeb<T>(String comicId, String chapterId) async {
    Options options = await this.setHeader();
    return dio.get('https://m.dmzj.com/chapinfo/$comicId/$chapterId.html',
        options: buildCacheOptions(Duration(hours: 8), options: options));
  }

  Future<Response<T>> getViewPoint<T>(String comicId, String chapterId) async {
    return dio.get(
        baseUrl + '/viewPoint/0/$comicId/$chapterId.json?$queryOptions',
        options: buildCacheOptions(Duration(hours: 8)));
  }

  Future<Response<T>> getSubjectDetail<T>(String subjectId) async {
    return dio.get(baseUrl + '/subject/$subjectId.json?$queryOptions');
  }

  Future<Response<T>> getCategoryFilter<T>({int novel: 0}) async {
    return dio.get(baseUrl +
        '/${novel == 0 ? 'classify' : 'novel'}/filter.json?$queryOptions');
  }

  Future<Response<T>> getCategoryDetail<T>(
      int categoryId, int date, int tag, int type, int page) async {
    return dio.get(
        '$baseUrl/classify/$categoryId-$date-$tag/$type/$page.json?$queryOptions',
        options: buildCacheOptions(Duration(hours: 1)));
  }

  Future<Response<T>> getNovelCategoryDetail<T>(
      int categoryId, int tag, int type, int page) async {
    return dio.get(
        '$baseUrl/novel/$categoryId/$tag/$type/$page.json?$queryOptions',
        options: buildCacheOptions(Duration(hours: 1)));
  }

  Future<Response<T>> getSubscribe<T>(int uid, int page, {int type: 0}) {
    return dio.get(
        '$baseUrl/UCenter/subscribe?uid=$uid&sub_type=1&letter=all&page=$page&type=$type&$queryOptions',
        options: buildCacheOptions(Duration(minutes: 5),
            subKey: 'uid=$uid&page=$page&type=$type'));
  }

  Future<Response<T>> login<T>(String username, String password) {
    print(
        "class: http, action: login, url: '$iUrl/api/login?callback=&nickname=$username&password=$password&type=1'");
    return unCachedDio.get(
        '$iUrl/api/login?callback=&nickname=$username&password=$password&type=1');
  }

  Future<Response<T>> getUserInfo<T>(String uid) {
    return dio.get("$baseUrl/UCenter/comics/$uid.json?$queryOptions",
        options: buildCacheOptions(Duration(days: 7)));
  }

  Future<Response<T>> getMySubscribe<T>() async {
    Options options = await this.setHeader();
    return unCachedDio.get("https://m.dmzj.com/mysubscribe", options: options);
  }

  Future<Response<T>> getIfSubscribe<T>(String comicId, String uid,
      {int type: 0}) async {
    return unCachedDio
        .get('$baseUrl/subscribe/$type/$uid/$comicId?$queryOptions');
  }

  Future<Response<T>> cancelSubscribe<T>(String comicId, String uid,
      {int type: 0}) async {
    _cacheManager.delete("$baseUrl/UCenter/subscribe");
    return unCachedDio.get(
        '$baseUrl/subscribe/cancel?obj_ids=$comicId&uid=$uid&type=${type == 0 ? 'mh' : 'xs'}&$queryOptions');
  }

  Future<Response<T>> addSubscribe<T>(String comicId, String uid,
      {int type: 0}) async {
    _cacheManager.delete("$baseUrl/UCenter/subscribe");
    FormData formData = FormData.fromMap(
        {"obj_ids": comicId, "uid": uid, 'type': type == 0 ? 'mh' : 'xs'});
    return unCachedDio.post('$baseUrl/subscribe/add', data: formData);
  }

  Future<Response<T>> addReadHistory<T>(String comicId, String uid) async {
    Options options = await this.setHeader();
    return unCachedDio.get(
        '$baseUrl/subscribe/read?obj_ids=$comicId&uid=$uid&type=mh?obj_ids=$comicId&uid=$uid&type=mh&channel=Android&version=2.7.017',
        options: options);
  }

  Future<Response<T>> addReadHistory0<T>(String comicId, String uid) async {
    Options options = await this.setHeader();
    return unCachedDio.get('$baseUrl/subscribe/0/$uid/$comicId?$queryOptions',
        options: options);
  }

  Future<Response<T>> addReadHistory1<T>(String subId) async {
    Options options = await this.setHeader();
    FormData formData = FormData.fromMap({'subid': int.parse(subId)});
    return unCachedDio.post('$iUrl/ajax/update/read',
        options: options, data: formData);
  }

  Future<Response<T>> addHistoryNew<T>(int comicId, String uid, int chapterId,
      {int page: 1}) async {
    Map map = {
      comicId.toString(): chapterId.toString(),
      "comicId": comicId.toString(),
      "chapterId": chapterId.toString(),
      "page": page,
      "time": DateTime.now().millisecondsSinceEpoch / 1000
    };
    var json = Uri.encodeComponent(jsonEncode(map));
    return unCachedDio.get(
        "https://interface.dmzj.com/api/record/getRe?st=comic&uid=$uid&callback=record_jsonpCallback&json=[$json]&type=3");
  }

  Future<Response<T>> setUpRead<T>(String subId) async {
    Options options = await this.setHeader();
    return unCachedDio.get(
        'https://interface.dmzj.com/api/subscribe/upread?sub_id=$subId',
        options: options);
  }

  Future<Response<T>> getReadHistory<T>(String uid, int page) {
    return dio.get(
        "https://interface.dmzj.com/api/getReInfo/comic/$uid/$page?$queryOptions",
        options: buildCacheOptions(Duration(minutes: 5)));
  }

  Future<Response<T>> getRecommendBatchUpdate<T>(String uid) {
    return dio.get(
        '$baseUrl/recommend/batchUpdate?uid=$uid&category_id=49&$queryOptions');
  }

  Future<Response<T>> search<T>(String keyword, int page, {int type: 0}) {
    return dio.get(
        '$baseUrl/search/show/$type/${Uri.encodeComponent(keyword)}/$page.json?$queryOptions');
  }

  Future<Response<T>> getLatestList<T>(int tagId, int page) {
    return dio.get('$baseUrl/latest/$tagId/$page.json?$queryOptions');
  }

  Future<Response<T>> getNovelLatestList<T>(int page) {
    return dio.get('$baseUrl/novel/recentUpdate/$page.json?$queryOptions');
  }

  Future<Response<T>> getDarkInfo<T>() {
    return dio.get('https://dark-dmzj.hloli.net/data.json');
  }

  Future<Response<T>> getComicComment<T>(String comicId, int page, int type,{int novel:0}) {
    return dio.get(
        '$baseUrl/old/comment/$novel/$type/$comicId/$page.json?$queryOptions',
        options: buildCacheOptions(Duration(days: 1)));
  }

  Future<Response<T>> checkUpdate<T>() {
    return dio.get(
        'https://api.github.com/repos/hanerx/flutter_dmzj/releases/latest');
  }

  Future<Response<T>> getAllUpdateList<T>(){
    return dio.get('https://api.github.com/repos/hanerx/flutter_dmzj/releases');
  }

  Future<Response<T>> getReleases<T>() {
    return dio.get('https://api.github.com/repos/hanerx/flutter_dmzj/releases');
  }

  Future<Response<T>> getAuthor<T>(int authorId) {
    return dio.get('$baseUrl/UCenter/author/$authorId.json?$queryOptions');
  }

  Future<Response<T>> deepSearch<T>(String search) {
    return dio
        .get('$sacgUrl/comicsum/search.php?s=$search&callback=');
  }

  Future<Response<T>> downloadFile<T>(String url, String savePath) {
    return dio.download(url, savePath,
        options: Options(headers: {'referer': 'http://images.dmzj.com'}));
  }

  Future<Response<T>> getImage<T>(String url) {
    return dio.get(url,
        options: Options(
            headers: {'referer': 'http://images.dmzj.com'},
            responseType: ResponseType.bytes));
  }

  Future<Response<T>> getNovelDetail<T>(int novelID) {
    return dio.get('$baseUrl/novel/$novelID.json?$queryOptions',
        options: buildCacheOptions(Duration(days: 1)));
  }

  Future<Response<T>> getNovelChapter<T>(int novelID) {
    return dio.get('$baseUrl/novel/chapter/$novelID.json?$queryOptions',
        options: buildCacheOptions(Duration(days: 1)));
  }

  Future<Response<T>> getNovel<T>(int novelID, int volumeID, int chapterID) {
    return dio.get(
        '$baseUrl/novel/download/${novelID}_${volumeID}_$chapterID.txt?$queryOptions',
        options: buildCacheOptions(Duration(days: 30)));
  }

  Future<Response<T>> getComicPage<T>(String firstLetter, String comicId, String chapterId, int page){
    return dio.get('$imgUrl/$firstLetter/$comicId/$chapterId/$page.jpg',
        options: Options(
            headers: {'referer': 'http://images.dmzj.com'},
            responseType: ResponseType.bytes));
  }

}
