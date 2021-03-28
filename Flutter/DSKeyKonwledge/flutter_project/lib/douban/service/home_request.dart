import 'package:flutter_project/douban/service/http_request.dart';

///首页请求类
class HomeRequest {

  /// 请求电影列表
  static void requestMovieList(int start) async {
    // 1.构建电影url
    final movieUrl = "https://api.douban.com/v2/movie/weekly?apikey=0df993c66c0c636e29ecbb5344252a4a";

    // 2.发起请求
    final result = await HttpRequest.request(movieUrl);
    final subjects = result["subjects"];

    // 3.map转换为模型
  }


}