import 'package:flutter_project/douban/model/home_model.dart';
import 'package:flutter_project/douban/service/http_request.dart';

///首页请求类
class HomeRequest {

  /// 请求电影列表
  static Future<List<MovieItem>> requestMovieList(int start,int count) async {
    // 1.构建电影url
    final movieUrl = "/v2/movie/weekly?apikey=0df993c66c0c636e29ecbb5344252a4a&start=$start&count=$count";

    // 2.发起请求
    final result = await HttpRequest.request(movieUrl);
    final subjects = result["subjects"] as List<dynamic>;

    // 3.map转换为模型
    List<MovieItem> movies = [];
    for (var sub in subjects){
      movies.add(MovieItem.fromMap(sub as Map<String,dynamic>));
    }
    return movies;
  }


}